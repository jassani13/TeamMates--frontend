import 'dart:async';
import 'dart:io';

import 'package:base_code/model/conversation_item.dart';
import 'package:base_code/module/bottom/chat/chat_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../../data/network/server_config.dart';
import '../chat_screen.dart';

class ChatDetailController extends GetxController {
  // Public observable state used by the UI
  final RxList<types.Message> messages = <types.Message>[].obs;
  final RxBool loading = false.obs;
  final RxMap<String, types.User> typingUsers = <String, types.User>{}.obs;

  // New: search query observable used for keyword-based highlighting
  final RxString searchQuery = ''.obs;

  // Flagged filter toggle
  final RxBool showFlaggedOnly = false.obs;

  // Pinned filter toggle
  final RxBool showPinnedOnly = false.obs;

  // Search navigation state
  final RxList<String> _matchIds = <String>[].obs;
  final RxInt _matchIndex = (-1).obs; // -1 when none selected
  final RxInt currentMatchNumber = 0.obs; // 1-based for UI
  final RxInt totalMatches = 0.obs;

  ConversationItem? conversation;
  late final types.User me;

  // If navigating from a search hit, use this to jump to the specific message once.
  String? _initialFocusMessageId;
  bool _didInitialFocusJump = false;

  // Reuse existing chat controller for media upload helper
  final ChatScreenController chatController =
      Get.isRegistered<ChatScreenController>()
          ? Get.find<ChatScreenController>()
          : Get.put(ChatScreenController());

  // Scroll helpers (moved from UI for readability)
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final Map<String, int> msgIdToIndex = {};

  // Controls visibility of the "Jump to first unread" button
  final RxBool showJumpToUnreadButton = false.obs;

  // Observable last-read id to allow UI to rebuild separators when it changes
  final RxString lastReadMessageId = ''.obs;

  // Track manual unread boundary set during this session. When non-empty,
  // we should not auto-mark read (including on dispose) to preserve the user's intent.
  final RxString manualUnreadMessageId = ''.obs;

  // Read receipts: whether my privacy setting allows showing read receipts
  final RxBool myReadReceiptsOn = true.obs;

  // Socket event constants (kept consistent with the rest of the app)
  static const evGetMessages = 'get_messages';
  static const evMessagesResult = 'conversation_messages';
  static const evSend = 'send_message';
  static const evNewMessage = 'setNewConversationMessage';
  static const evTyping = 'typing';
  static const evMessageRead = 'message_read';
  static const evMessagesReadBroadcast = 'messages_read';
  static const evReaction = 'message_reaction';
  static const evMessageEdited = 'message_edited';
  static const evMessageDeleted = 'message_deleted';
  static const evMarkUnread = 'mark_unread';
  static const evFlag = 'flag_message';
  static const evUnflag = 'unflag_message';
  static const evPinnedEvent = 'message_pinned';
  static const evFlaggedEvent = 'message_flagged';
  static const evThreadReply = 'new_thread_reply';

  // Internal typing helpers
  Timer? _typingDebounce;
  DateTime? _lastTypingTrue;
  bool _isTyping = false;

  static const _typingTTL = Duration(seconds: 4);
  static const _typingHeartbeat = Duration(seconds: 3);
  final Map<String, Timer> _typingTimers = {};

  @override
  void onInit() {
    super.onInit();
    _ensureSocketBootstrapped();
    final args = Get.arguments ?? {};
    conversation = args['conversation'] as ConversationItem?;
    // Pick up a specific message to focus when opening the screen (from global search results)
    final focusId = args['focus_message_id']?.toString();
    if (focusId != null && focusId.isNotEmpty) {
      _initialFocusMessageId = focusId;
    }
    me = types.User(id: AppPref().userId.toString());
    lastReadMessageId.value = conversation?.lastReadMessageId ?? '';
    _registerSocketListeners();
    // Track viewport to decide when to show/hide the jump button
    itemPositionsListener.itemPositions.addListener(_onViewportChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMyPrivacy();
    });

    loadInitial();
  }

  Future<void> _fetchMyPrivacy() async {
    try {
      final body = dio_pkg.FormData.fromMap({'user_id': AppPref().userId});
      final res = await callApi(
          dio.post(ApiEndPoint.readReceiptsPrivacy, data: body), false);
      if (res?.statusCode == 200) {
        final data = res?.data;
        final val = (data?['data']?['read_receipts'] ?? true);
        if (val is bool)
          myReadReceiptsOn.value = val;
        else if (val is num)
          myReadReceiptsOn.value = val != 0;
        else if (val is String)
          myReadReceiptsOn.value = (val.toLowerCase() == 'true' || val == '1');
      }
    } catch (e) {
      debugPrint("_fetchMyPrivacy_error: $e");
    }
  }

  /// Set the current search query; UI should call this when user types in search.
  void setSearchQuery(String q) {
    searchQuery.value = q;
    _recomputeMatches();
  }

  /// Clear the current search query.
  void clearSearch() {
    searchQuery.value = '';
    _recomputeMatches();
  }

  void _recomputeMatches() {
    final q = searchQuery.value.trim().toLowerCase();
    _matchIds.clear();
    _matchIndex.value = -1;
    if (q.isEmpty) {
      totalMatches.value = 0;
      currentMatchNumber.value = 0;
      return;
    }
    for (final m in messages) {
      final text = _extractSearchableText(m).toLowerCase();
      if (text.contains(q)) {
        _matchIds.add(m.id);
      }
    }
    totalMatches.value = _matchIds.length;
    currentMatchNumber.value = _matchIds.isEmpty ? 0 : 1;
    _matchIndex.value = _matchIds.isEmpty ? -1 : 0;
  }

  String _extractSearchableText(types.Message m) {
    final meta = m.metadata;
    final raw = (meta != null ? (meta['raw_msg']?.toString() ?? '') : '');
    if (raw.isNotEmpty) return raw;
    if (m is types.TextMessage) return m.text;
    return '';
  }

  // Navigation helpers for search matches
  void goToNextMatch() {
    if (_matchIds.isEmpty) return;
    if (_matchIndex.value < 0) {
      _matchIndex.value = 0;
    } else {
      // Next = newer message in our reversed list -> move towards index 0
      _matchIndex.value = (_matchIndex.value - 1) < 0
          ? (_matchIds.length - 1)
          : (_matchIndex.value - 1);
    }
    currentMatchNumber.value = _matchIndex.value + 1;
    _scrollToMatchAtIndex(_matchIndex.value);
  }

  void goToPrevMatch() {
    if (_matchIds.isEmpty) return;
    if (_matchIndex.value < 0) {
      _matchIndex.value = 0;
    } else {
      // Prev = older message -> increase index, wrap
      _matchIndex.value = (_matchIndex.value + 1) % _matchIds.length;
    }
    currentMatchNumber.value = _matchIndex.value + 1;
    _scrollToMatchAtIndex(_matchIndex.value);
  }

  Future<void> _scrollToMatchAtIndex(int index) async {
    if (index < 0 || index >= _matchIds.length) return;
    final id = _matchIds[index];
    await scrollToMessageNoSideEffects(id);
  }

  void _ensureSocketBootstrapped() {
    if (socketInitialized) {
      if (!socket.connected) {
        try {
          socket.connect();
        } catch (e) {
          debugPrint('[SOCKET] reconnect error: $e');
        }
      }
      return;
    }

    final String url = ServerConfig.socketBaseUrl;
    debugPrint("[SOCKET] detail init url:$url");

    socket = IO.io(
      url,
      {
        'transports': ['websocket'],
        'autoConnect': false,
        'forceNew': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 2000,
      },
    );

    socket.onConnect((_) {
      debugPrint('[SOCKET] detail connected');
      socket.emit('register', {'user_id': AppPref().userId});
    });

    socket.onConnectError((e) {
      debugPrint('[SOCKET] detail connect error:$e');
    });

    socket.connect();
    socketInitialized = true;
  }

  void _registerSocketListeners() {
    socket.on(evMessagesResult, _onMessagesResult);
    socket.on(evNewMessage, _onNewMessage);
    socket.on(evTyping, _onTyping);
    socket.on(evMessagesReadBroadcast, _onMessagesRead);
    socket.on(evReaction, _onReaction);
    socket.on(evMessageEdited, _onMessageEdited);
    socket.on(evMessageDeleted, _onMessageDeleted);
    socket.on(evFlaggedEvent, _onMessageFlagged);
    socket.on(evPinnedEvent, _onMessagePinned);
    socket.on(evThreadReply, _onThreadReply);
  }

  void _removeSocketListeners() {
    socket.off(evMessagesResult, _onMessagesResult);
    socket.off(evNewMessage, _onNewMessage);
    socket.off(evTyping, _onTyping);
    socket.off(evMessagesReadBroadcast, _onMessagesRead);
    socket.off(evReaction, _onReaction);
    socket.off(evMessageEdited, _onMessageEdited);
    socket.off(evMessageDeleted, _onMessageDeleted);
    socket.off(evFlaggedEvent, _onMessageFlagged);
    socket.off(evPinnedEvent, _onMessagePinned);
    socket.off(evThreadReply, _onThreadReply);
  }

  /// Request initial messages for the conversation.
  void loadInitial() {
    if (conversation == null) return;
    socket.emit(evGetMessages, {
      'conversation_id': conversation?.conversationId ?? '',
    });
  }

  void _onMessagesResult(dynamic payload) {
    if (payload == null) return;
    if (payload['conversation_id']?.toString() != conversation?.conversationId)
      return;
    final list = (payload['messages'] as List?) ?? [];
    final parentMessages = <dynamic>[];
    final threadReplies = <dynamic>[];
    for (final raw in list) {
      if (raw is Map &&
          raw['parent_message_id'] != null &&
          raw['parent_message_id'].toString().isNotEmpty) {
        threadReplies.add(raw);
      } else {
        parentMessages.add(raw);
      }
    }

    messages.clear();
    for (final raw in parentMessages) {
      final msg = _fromSocket(raw);
      messages.insert(0, msg);
    }

    for (final raw in threadReplies) {
      final parentId = raw['parent_message_id']?.toString();
      if (parentId == null || parentId.isEmpty) continue;
      _refreshThreadPreviewFromPayload(
        parentId: parentId,
        repliesCount: raw['parent_replies_count'] ?? raw['replies_count'],
        messageData: raw is Map ? raw : null,
      );
    }

    loading.value = false;
    final fromServerLastRead = payload['last_read_message_id']?.toString();
    if (fromServerLastRead != null && fromServerLastRead.isNotEmpty) {
      _updateConversationLastRead(fromServerLastRead);
      lastReadMessageId.value = fromServerLastRead;
    } else {
      lastReadMessageId.value =
          conversation?.lastReadMessageId ?? lastReadMessageId.value;
    }
    // After messages load, update jump button visibility
    updateJumpToUnreadVisibility();

    // If we navigated with a target message id, jump to it once the list is ready
    if (_initialFocusMessageId != null && !_didInitialFocusJump) {
      _didInitialFocusJump = true;
      final targetId = _initialFocusMessageId!;
      // Wait for first frame so that item builder can populate index map
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // small delay to ensure layout complete
        await Future.delayed(const Duration(milliseconds: 120));
        await scrollToMessageNoSideEffects(targetId);
      });
    }
  }

  void _onNewMessage(dynamic data) {
    final raw = data['resData'] ?? data;
    if (raw == null) return;
    if (raw['conversation_id']?.toString() != conversation?.conversationId)
      return;
    final parentId = raw['parent_message_id']?.toString();
    if (parentId != null && parentId.isNotEmpty) {
      _refreshThreadPreviewFromPayload(
        parentId: parentId,
        repliesCount: raw['parent_replies_count'] ?? raw['replies_count'],
        messageData: raw is Map ? raw : null,
      );
      return;
    }
    final msg = _fromSocket(raw);
    messages.insert(0, msg);
    // Update visibility as list changed
    updateJumpToUnreadVisibility();
    // If received from others, mark read shortly after to allow UI to update
    // BUT do not auto-mark if user explicitly set a manual unread boundary.
    if (msg.author.id != me.id) {
      if (manualUnreadMessageId.value.isEmpty) {
        Future.delayed(const Duration(milliseconds: 250), () => markRead());
      }
    } else {
      // If the message is authored by me, normally we'd update last-read to this message id.
      // But if the user explicitly set a manual unread boundary, do NOT override it.
      if (manualUnreadMessageId.value.isEmpty) {
        _setLastReadToMessage(msg.id);
      }
    }
  }

  void _onTyping(dynamic data) {
    if (data == null) return;
    final cid = data['conversation_id']?.toString();
    if (cid != conversation?.conversationId) return;
    final uid = data['user_id']?.toString();
    if (uid == null || uid == me.id) return;

    final isTyping = data['isTyping'] == true;
    if (isTyping) {
      final known = _resolveTypingUser(uid);
      typingUsers[uid] = known;
      _typingTimers[uid]?.cancel();
      _typingTimers[uid] = Timer(_typingTTL, () {
        typingUsers.remove(uid);
        _typingTimers.remove(uid)?.cancel();
      });
      typingUsers.refresh();
    } else {
      typingUsers.remove(uid);
      _typingTimers.remove(uid)?.cancel();
      typingUsers.refresh();
    }
  }

  void _onMessagesRead(dynamic data) {
    try {
      if (data == null) return;
      final cid = data['conversation_id']?.toString();
      if (cid != conversation?.conversationId) return;
      final readerId = data['user_id']?.toString();
      if (readerId == null || readerId.trim().isEmpty || readerId == me.id) {
        return; // ignore my own or invalid read events
      }
      final rawLastId = data['last_read_message_id'];
      final lastIdStr = rawLastId?.toString() ?? '';
      final lastId = lastIdStr.isEmpty ? null : int.tryParse(lastIdStr);

      bool changed = false;
      for (int i = 0; i < messages.length; i++) {
        final m = messages[i];
        if (m.author.id != me.id) continue; // only care about messages I sent
        final mid = int.tryParse(m.id) ?? -1;
        final shouldBeMarkedRead = lastId != null && mid != -1 && mid <= lastId;
        final meta = {...?m.metadata};
        final existing = (meta['read_by'] as List?) ?? [];
        final readBy = existing
            .map((e) => e.toString())
            .where((s) => s.trim().isNotEmpty)
            .toList();
        final alreadyHasReader = readBy.contains(readerId);

        bool localChange = false;
        if (shouldBeMarkedRead && !alreadyHasReader) {
          readBy.add(readerId);
          localChange = true;
        }
        if (!shouldBeMarkedRead && alreadyHasReader) {
          readBy.removeWhere((id) => id == readerId);
          localChange = true;
        }

        if (localChange) {
          meta['read_by'] = readBy;
          if (m is types.TextMessage) messages[i] = m.copyWith(metadata: meta);
          if (m is types.ImageMessage) messages[i] = m.copyWith(metadata: meta);
          if (m is types.FileMessage) messages[i] = m.copyWith(metadata: meta);
          changed = true;
        }
      }
      if (changed) messages.refresh();
    } catch (_) {}
  }

  void _onReaction(dynamic data) {
    if (data == null) return;
    final mid = data['message_id']?.toString();
    if (mid == null) return;
    final idx = messages.indexWhere((m) => m.id == mid);
    if (idx == -1) return;

    List reactions;
    if (data['reactions'] is List) {
      reactions = List.from(data['reactions'].map((r) => {
            'user_id': r['user_id'].toString(),
            'reaction': r['reaction'],
          }));
    } else {
      final existing = messages[idx].metadata?['reactions'] as List? ?? [];
      reactions = [
        ...existing,
        {
          'user_id': data['user_id'].toString(),
          'reaction': data['reaction_type']
        }
      ];
    }

    // Deduplicate by user_id, keep last
    final map = <String, Map<String, dynamic>>{};
    for (final r in reactions) {
      final uid = r['user_id'].toString();
      map[uid] = {'user_id': uid, 'reaction': r['reaction']};
    }
    final normalized = map.values.toList();

    final old = messages[idx];
    final meta = {...?old.metadata, 'reactions': normalized};
    if (old is types.TextMessage) messages[idx] = old.copyWith(metadata: meta);
    if (old is types.ImageMessage) messages[idx] = old.copyWith(metadata: meta);
    if (old is types.FileMessage) messages[idx] = old.copyWith(metadata: meta);
    messages.refresh();
  }

  void _onMessageEdited(dynamic data) {
    final raw = data['resData'] ?? data;
    if (raw == null) return;
    if (raw['conversation_id']?.toString() != conversation?.conversationId)
      return;
    final id = raw['message_id']?.toString();
    if (id == null) return;
    final idx = messages.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    final old = messages[idx];
    final newText = (raw['msg'] ?? '').toString();
    final newMeta = {
      ...?old.metadata,
      'raw_msg': newText,
      'edited': true,
      'updated_at': raw['updated_at'],
    };
    if (old is types.TextMessage) {
      messages[idx] = old.copyWith(text: newText, metadata: newMeta);
    } else if (old is types.ImageMessage) {
      messages[idx] = old.copyWith(metadata: newMeta);
    } else if (old is types.FileMessage) {
      messages[idx] = old.copyWith(metadata: newMeta);
    }
    messages.refresh();
  }

  void _onMessageDeleted(dynamic data) {
    final raw = data['resData'] ?? data;
    if (raw == null) return;
    if (raw['conversation_id']?.toString() != conversation?.conversationId)
      return;
    final id = raw['message_id']?.toString();
    if (id == null) return;
    final idx = messages.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    final old = messages[idx];
    final newMeta = {
      ...?old.metadata,
      'deleted': true,
      'deleted_at': raw['deleted_at'],
      'deleted_by': raw['deleted_by'],
      'reactions': <dynamic>[],
    };
    if (old is types.TextMessage) {
      messages[idx] = old.copyWith(text: '', metadata: newMeta);
    } else if (old is types.ImageMessage) {
      messages[idx] = old.copyWith(metadata: newMeta);
    } else if (old is types.FileMessage) {
      messages[idx] = old.copyWith(metadata: newMeta);
    }
    messages.refresh();
  }

  void _onMessageFlagged(dynamic data) {
    try {
      final id = data['message_id']?.toString();
      final flagged = data['flagged'] == true;
      if (id == null) return;
      final idx = messages.indexWhere((m) => m.id == id);
      if (idx == -1) return;
      final old = messages[idx];
      final meta = {...?old.metadata, 'flagged': flagged};
      if (old is types.TextMessage)
        messages[idx] = old.copyWith(metadata: meta);
      if (old is types.ImageMessage)
        messages[idx] = old.copyWith(metadata: meta);
      if (old is types.FileMessage)
        messages[idx] = old.copyWith(metadata: meta);
      messages.refresh();
    } catch (_) {}
  }

  void _onMessagePinned(dynamic data) {
    try {
      final id = data['message_id']?.toString();
      final pinned = data['pinned'] == true;
      if (id == null) return;
      final idx = messages.indexWhere((m) => m.id == id);
      if (idx == -1) return;
      final old = messages[idx];
      final meta = {...?old.metadata, 'pinned': pinned};
      if (old is types.TextMessage)
        messages[idx] = old.copyWith(metadata: meta);
      if (old is types.ImageMessage)
        messages[idx] = old.copyWith(metadata: meta);
      if (old is types.FileMessage)
        messages[idx] = old.copyWith(metadata: meta);
      messages.refresh();
    } catch (_) {}
  }

  void disposeTimers() {
    _typingDebounce?.cancel();
    for (final t in _typingTimers.values) {
      t.cancel();
    }
    _typingTimers.clear();
  }

  @override
  void onClose() {
    _removeSocketListeners();
    disposeTimers();
    if (_isTyping) {
      socket.emit(evTyping, {
        'conversation_id': conversation?.conversationId ?? '',
        'isTyping': false,
      });
      _isTyping = false;
    }
    // Remove viewport listener to avoid leaks
    try {
      itemPositionsListener.itemPositions.removeListener(_onViewportChanged);
    } catch (_) {}
    super.onClose();
  }

  // ----- Public API for UI -----
  void sendText(String text) {
    debugPrint("sending text: $text :: conversation:$conversation");
    if (text.trim().isEmpty || conversation == null) return;
    debugPrint("emitting send message:${conversation?.conversationId}");
    socket.emit(evSend, {
      'conversation_id': conversation?.conversationId ?? '',
      'msg': text.trim(),
      'msg_type': 'text',
    });
    debugPrint("sending message: $text");
    // stop typing
    if (_isTyping) {
      socket.emit(evTyping, {
        'conversation_id': conversation?.conversationId ?? '',
        'isTyping': false
      });
      _isTyping = false;
    }
  }

  void _onThreadReply(dynamic data) {
    if (data == null) return;
    final cid = data['conversation_id']?.toString();
    if (cid != conversation?.conversationId) return;
    final parentId = data['parent_message_id']?.toString();
    if (parentId == null || parentId.isEmpty) return;

    final idx = messages.indexWhere((m) => m.id == parentId);
    if (idx == -1) return;

    final messageData = data['message'] as Map?;
    final old = messages[idx];
    final meta = {...?old.metadata};

    final countFromPayload = data['parent_replies_count'];
    final parsedCount = countFromPayload is int
        ? countFromPayload
        : int.tryParse(countFromPayload?.toString() ?? '');
    final existingCount = meta['replies_count'] is int
        ? meta['replies_count'] as int
        : int.tryParse(meta['replies_count']?.toString() ?? '0') ?? 0;
    meta['replies_count'] = parsedCount ?? (existingCount + 1);

    final msgType =
        (messageData?['msg_type'] ?? meta['latest_reply_msg_type'] ?? 'text')
            .toString();
    final previewText = _threadPreviewLabel(
      msgType,
      messageData?['msg'],
    );

    meta['latest_reply_text'] = previewText;
    meta['latest_reply_sender'] =
        (messageData?['sender_name'] ?? '').toString();
    meta['latest_reply_sender_id'] = messageData?['sender_id']?.toString();
    meta['latest_reply_msg_type'] = msgType;
    meta['latest_reply_created_at'] = messageData?['created_at']?.toString();
    meta['latest_reply_file_url'] = (messageData?['file_url'] ?? '').toString();

    if (old is types.TextMessage) messages[idx] = old.copyWith(metadata: meta);
    if (old is types.ImageMessage) messages[idx] = old.copyWith(metadata: meta);
    if (old is types.FileMessage) messages[idx] = old.copyWith(metadata: meta);
    messages.refresh();
  }

  Future<void> sendImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        imageQuality: 70,
        maxWidth: 1440,
        source: ImageSource.gallery,
      );
      if (picked == null) return;
      final confirmed = await _showImagePreviewSheet(picked.path) ?? false;
      if (!confirmed) return;
      loading.value = true;
      final url = await chatController.setMediaChatApiCall(result: picked);
      loading.value = false;
      if (url.isNotEmpty) {
        socket.emit(evSend, {
          'conversation_id': conversation?.conversationId ?? '',
          'msg': url.split('/').last,
          'msg_type': 'image',
          'file_url': url,
        });
      }
    } catch (e) {
      loading.value = false;
    }
  }

  Future<void> sendFile() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['pdf'],
      );
      if (res == null || res.files.isEmpty || res.files.single.path == null)
        return;
      final file = res.files.single;
      final confirmed = await _showDocumentPreviewSheet(file) ?? false;
      if (!confirmed) return;
      loading.value = true;
      final url = await chatController.setMediaChatApiCall(result: file);
      loading.value = false;
      if (url.isNotEmpty) {
        socket.emit(evSend, {
          'conversation_id': conversation?.conversationId ?? '',
          'msg': file.name,
          'msg_type': 'file',
          'file_url': url,
        });
      }
    } catch (e) {
      loading.value = false;
    }
  }

  // ----- Preview Sheets -----
  Future<bool?> _showImagePreviewSheet(String path) {
    return Get.bottomSheet<bool>(
      SafeArea(
        child: Container(
          padding:
              const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Image preview',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black12Color),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: AppColor.greyF6Color,
                    child: path.isNotEmpty
                        ? Image.file(
                            File(path),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image,
                                    size: 48, color: Colors.black26)),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Cancel',
                          style: TextStyle(color: AppColor.black12Color)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Send'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  Future<bool?> _showDocumentPreviewSheet(PlatformFile file) {
    final sizeKb = (file.size / 1024).toStringAsFixed(1);
    return Get.bottomSheet<bool>(
      SafeArea(
        child: Container(
          padding:
              const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Document preview',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black12Color),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.greyF6Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf,
                        size: 36, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColor.black12Color),
                          ),
                          const SizedBox(height: 6),
                          Text('$sizeKb KB',
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Cancel',
                          style: TextStyle(color: AppColor.black12Color)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Send'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  void sendReaction(String messageId, String reaction) {
    socket
        .emit(evReaction, {'message_id': messageId, 'reaction_type': reaction});
  }

  // --- Flag / Pin / Mark as unread API ---
  void toggleFlag(String messageId, bool currentlyFlagged) {
    socket
        .emit(currentlyFlagged ? evUnflag : evFlag, {'message_id': messageId});
    // Optimistic local update so UI reflects immediately
    final idx = messages.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      final old = messages[idx];
      final meta = {...?old.metadata, 'flagged': !currentlyFlagged};
      if (old is types.TextMessage)
        messages[idx] = old.copyWith(metadata: meta);
      if (old is types.ImageMessage)
        messages[idx] = old.copyWith(metadata: meta);
      if (old is types.FileMessage)
        messages[idx] = old.copyWith(metadata: meta);
      messages.refresh();
    }
  }

  void togglePin(String messageId, bool currentlyPinned) {
    socket.emit(currentlyPinned ? 'unpin_message' : 'pin_message',
        {'message_id': messageId});
    // Optimistic local update so UI reflects immediately
    final idx = messages.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      final old = messages[idx];
      final meta = {...?old.metadata, 'pinned': !currentlyPinned};
      if (old is types.TextMessage)
        messages[idx] = old.copyWith(metadata: meta);
      if (old is types.ImageMessage)
        messages[idx] = old.copyWith(metadata: meta);
      if (old is types.FileMessage)
        messages[idx] = old.copyWith(metadata: meta);
      messages.refresh();
    }
  }

  void markAsUnread(String messageId) {
    socket.emit(evMarkUnread, {
      'conversation_id': conversation?.conversationId ?? '',
      'message_id': messageId,
    });
    // Optimistically update local unread boundary so UI reflects immediately
    _updateConversationLastRead(messageId);
    lastReadMessageId.value = messageId;
    manualUnreadMessageId.value = messageId;
    updateJumpToUnreadVisibility();
  }

  void editMessage(String messageId, String newText) {
    socket.emit('edit_message', {'message_id': messageId, 'new_text': newText});
  }

  void deleteMessage(String messageId) {
    socket.emit('delete_message', {'message_id': messageId});
  }

  void markRead() {
    final lastMessageId = messages.isNotEmpty ? messages.first.id : null;
    if (lastMessageId == null) return;
    socket.emit(evMessageRead, {
      'conversation_id': conversation?.conversationId ?? '',
      'last_read_message_id': lastMessageId,
    });
    // Update local conversation model
    _updateConversationLastRead(lastMessageId);
    lastReadMessageId.value = lastMessageId;
    // Clear manual override locally; server will clear it too
    manualUnreadMessageId.value = '';
    updateJumpToUnreadVisibility();
  }

  void onUserTyping(String currentText) {
    final convId = conversation?.conversationId ?? '';
    final now = DateTime.now();
    if (currentText.isEmpty) {
      _typingDebounce?.cancel();
      if (_isTyping) {
        socket.emit(evTyping, {'conversation_id': convId, 'isTyping': false});
        _isTyping = false;
      }
      return;
    }
    if (!_isTyping ||
        _lastTypingTrue == null ||
        now.difference(_lastTypingTrue!) >= _typingHeartbeat) {
      socket.emit(evTyping, {'conversation_id': convId, 'isTyping': true});
      _isTyping = true;
      _lastTypingTrue = now;
    }
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(seconds: 2), () {
      socket.emit(evTyping, {'conversation_id': convId, 'isTyping': false});
      _isTyping = false;
    });
  }

  /// Public method UI can call to jump to the message with [messageId].
  /// If possible, it scrolls so that one message before the target is visible
  /// to provide context.
  Future<void> jumpToMessage(String messageId) async {
    if (messageId.isEmpty) return;

    int? idx = msgIdToIndex[messageId];

    if (idx == null) {
      idx = messages.indexWhere((m) => m.id == messageId);
      if (idx == -1) idx = null;
    }

    if (idx == null) {
      // Give UI a short time to build items and try again
      await Future.delayed(const Duration(milliseconds: 200));
      idx = msgIdToIndex[messageId];
      if (idx == null) {
        final found = messages.indexWhere((m) => m.id == messageId);
        if (found != -1) idx = found;
      }
    }

    if (idx == null) return;

    final unreadIndex = idx - 1 >= 0 ? idx - 1 : 0;
    await tryScrollToIndex(unreadIndex);
    // Hide the button once we've jumped to unread
    showJumpToUnreadButton.value = false;
    // Optionally mark as read up to newest after jumping
    // But respect manual unread if user set it; do not auto-clear.
    if (manualUnreadMessageId.value.isEmpty) {
      markRead();
    }
  }

  /// Scroll to a message without altering unread state or jump button.
  Future<void> scrollToMessageNoSideEffects(String messageId) async {
    if (messageId.isEmpty) return;

    int? idx = msgIdToIndex[messageId];
    if (idx == null) {
      idx = messages.indexWhere((m) => m.id == messageId);
      if (idx == -1) idx = null;
    }
    if (idx == null) {
      await Future.delayed(const Duration(milliseconds: 200));
      idx = msgIdToIndex[messageId];
      if (idx == null) {
        final found = messages.indexWhere((m) => m.id == messageId);
        if (found != -1) idx = found;
      }
    }
    if (idx == null) return;
    final target = idx - 1 >= 0 ? idx - 1 : 0;
    await tryScrollToIndex(target);
  }

  /// Compute the index of the first unread message based on
  /// conversation.lastReadMessageId and current message list
  int? getFirstUnreadIndex() {
    final lastReadId = conversation?.lastReadMessageId ?? '';
    if (lastReadId.isEmpty || messages.isEmpty) return null;

    final idx = messages.indexWhere((m) => m.id == lastReadId);
    if (idx == -1) {
      // lastRead not in current window; consider everything unread
      // so the first unread is the newest message (index 0)
      // but jumping to 0 is usually unnecessary; prefer showing button that
      // scrolls close to the boundary. We'll scroll to the last item to show oldest loaded.
      return messages.length - 1;
    }
    // List is reversed (0 = newest). First unread is just newer than lastRead.
    final firstUnread = idx - 1;
    if (firstUnread < 0) return null; // nothing unread
    return firstUnread;
  }

  /// Recalculate whether the jump button should be visible, based on
  /// unread index and current viewport.
  void updateJumpToUnreadVisibility() {
    // If newest message is mine, no need to show the button
    if (messages.isNotEmpty && messages.first.author.id == me.id) {
      showJumpToUnreadButton.value = false;
      return;
    }
    final firstUnread = getFirstUnreadIndex();
    if (firstUnread == null) {
      showJumpToUnreadButton.value = false;
      return;
    }

    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) {
      // If we haven't laid out yet, keep the button visible when there's unread
      showJumpToUnreadButton.value = true;
      return;
    }

    // Determine visible index range
    int minIndex = 1 << 30;
    int maxIndex = -1;
    for (final p in positions) {
      if (p.index < minIndex) minIndex = p.index;
      if (p.index > maxIndex) maxIndex = p.index;
    }

    final isVisible = firstUnread >= minIndex && firstUnread <= maxIndex;
    showJumpToUnreadButton.value = !isVisible;
  }

  void _onViewportChanged() {
    updateJumpToUnreadVisibility();
  }

  /// Jump using derived first-unread logic with fallbacks
  Future<void> jumpToFirstUnread() async {
    final target = getFirstUnreadIndex();
    if (target != null) {
      await tryScrollToIndex(target);
      showJumpToUnreadButton.value = false;
      markRead();
      return;
    }
    // Fallback to lastRead id based jump (no-op if empty)
    final id = conversation?.lastReadMessageId ?? '';
    if (id.isNotEmpty) await jumpToMessage(id);
  }

  void _setLastReadToMessage(String messageId) {
    if (messageId.isEmpty) return;
    socket.emit(evMessageRead, {
      'conversation_id': conversation?.conversationId ?? '',
      'last_read_message_id': messageId,
    });
    _updateConversationLastRead(messageId);
    lastReadMessageId.value = messageId;
    updateJumpToUnreadVisibility();
  }

  void _updateConversationLastRead(String messageId) {
    if (conversation == null) return;
    conversation = ConversationItem(
      conversationId: conversation!.conversationId,
      ownerId: conversation!.ownerId,
      type: conversation!.type,
      title: conversation!.title,
      image: conversation!.image,
      lastMessage: conversation!.lastMessage,
      lastMessageFileUrl: conversation!.lastMessageFileUrl,
      lastReadMessageId: messageId,
      msgType: conversation!.msgType,
      createdAt: conversation!.createdAt,
      unreadCount: 0,
    );
  }

  /// Internal helper which retries scrolling until the item becomes visible
  /// or a max attempts threshold is reached.
  Future<void> tryScrollToIndex(int index) async {
    const int maxAttempts = 6;
    const Duration attemptDelay = Duration(milliseconds: 150);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        await itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      } catch (e) {
        debugPrint('Scroll attempt $attempt failed -> $e');
      }

      await Future.delayed(attemptDelay);

      final positions = itemPositionsListener.itemPositions.value;
      final visible = positions.any((p) => p.index == index);
      if (visible) return;

      if (attempt == maxAttempts - 1) {
        try {
          itemScrollController.jumpTo(index: index);
        } catch (_) {}
      }
    }
  }

  // ----- Small helper to convert raw socket message into types.Message -----
  types.Message _fromSocket(dynamic raw) {
    final msgType = (raw['msg_type'] ?? 'text').toString();
    final senderId = raw['sender_id'].toString();
    final senderFirstName = "${raw['sender_first_name'] ?? ""}";
    final senderLastName = "${raw['sender_last_name'] ?? ""}";
    final senderProfile = raw['sender_profile']?.toString();
    final id = raw['message_id'].toString();
    final createdAtStr = raw['created_at']?.toString();
    final createdAt = createdAtStr != null
        ? DateTime.tryParse(createdAtStr)?.toUtc().millisecondsSinceEpoch
        : DateTime.now().toUtc().millisecondsSinceEpoch;

    final metadata = <String, dynamic>{
      'msg_type': msgType,
      'raw_msg': raw['msg'],
      'file_url': raw['file_url'],
      'reactions': raw['reactions'] ?? [],
      // Populate read receipts from server payload (if provided)
      'read_by': raw['read_by'] ?? raw['readBy'] ?? [],
      'flagged': raw['flagged'] == true,
      'pinned': raw['pinned'] == true,
      'edited': raw['edited'] == true ||
          ((raw['updated_at']?.toString().isNotEmpty ?? false) &&
              (raw['updated_at']?.toString() != raw['created_at']?.toString())),
      'created_at': raw['created_at'],
      'updated_at': raw['updated_at'],
      'deleted_by': raw['deleted_by']?.toString(),
      'deleted_at': raw['deleted_at'],
      'parent_message_id': raw['parent_message_id']?.toString(),
      'replies_count': raw['replies_count'] ?? 0,
      'latest_reply_text': raw['latest_reply_text'] ?? '',
      'latest_reply_sender': raw['latest_reply_sender'] ?? '',
      'latest_reply_sender_id': raw['latest_reply_sender_id']?.toString(),
      'latest_reply_msg_type': raw['latest_reply_msg_type'] ?? '',
      'latest_reply_created_at': raw['latest_reply_created_at'],
      'latest_reply_file_url': raw['latest_reply_file_url'] ?? '',
      'read_target_count': raw['read_target_count'] ??
          raw['readTargetCount'] ??
          raw['readTarget'] ??
          0,
    };

    if (msgType == 'image') {
      return types.ImageMessage(
        id: id,
        author: types.User(
            id: senderId,
            firstName: senderFirstName,
            lastName: senderLastName,
            imageUrl: senderProfile),
        createdAt: createdAt,
        uri: raw['file_url'] ?? raw['msg'] ?? '',
        name: 'image',
        size: 0,
        metadata: metadata,
      );
    } else if (msgType == 'pdf' || msgType == 'file') {
      return types.FileMessage(
        id: id,
        author: types.User(
            id: senderId,
            firstName: senderFirstName,
            lastName: senderLastName,
            imageUrl: senderProfile),
        createdAt: createdAt,
        uri: raw['file_url'] ?? raw['msg'] ?? '',
        name: raw['msg'] ?? 'document',
        size: 0,
        metadata: metadata,
      );
    }

    return types.TextMessage(
      id: id,
      author: types.User(
          id: senderId,
          firstName: senderFirstName,
          lastName: senderLastName,
          imageUrl: senderProfile),
      createdAt: createdAt,
      text: raw['msg']?.toString() ?? '',
      metadata: metadata,
    );
  }

  /// Best-effort resolver to attach a human-readable name for typing users.
  /// Order of resolution:
  /// 1) Any existing message authored by [uid] -> reuse its author info
  /// 2) For personal conversations, fallback to conversation title/image
  /// 3) Otherwise return a minimal user with only id
  types.User _resolveTypingUser(String uid) {
    // 1) Try to find an authored message from this user to reuse name/image
    try {
      final idx = messages.indexWhere((m) => m.author.id == uid);
      if (idx != -1) {
        final a = messages[idx].author;
        return types.User(
          id: a.id,
          firstName: a.firstName,
          lastName: a.lastName,
          imageUrl: a.imageUrl,
        );
      }
    } catch (_) {}

    // 2) For personal chats, the conversation title/image represent the other user
    try {
      if ((conversation?.type ?? '').toLowerCase() == 'personal' &&
          uid != me.id) {
        final title = (conversation?.title ?? '').trim();
        final img = (conversation?.image ?? '').trim();
        if (title.isNotEmpty) {
          // Split naive: first token -> firstName, rest -> lastName
          final parts = title.split(' ');
          final first = parts.isNotEmpty ? parts.first : title;
          final last = parts.length > 1 ? parts.sublist(1).join(' ') : null;
          return types.User(
            id: uid,
            firstName: first,
            lastName: last,
            imageUrl: img.isNotEmpty ? img : null,
          );
        }
        // If no title, still attach image when available
        if (img.isNotEmpty) {
          return types.User(id: uid, imageUrl: img);
        }
      }
    } catch (_) {}

    // 3) Fallback minimal
    return types.User(id: uid);
  }

  void _refreshThreadPreviewFromPayload({
    required String parentId,
    dynamic repliesCount,
    Map? messageData,
  }) {
    final idx = messages.indexWhere((m) => m.id == parentId);
    if (idx == -1) return;

    final old = messages[idx];
    final meta = {...?old.metadata};

    final parsedCount = _intFrom(repliesCount);
    final existingCount = _intFrom(meta['replies_count']) ?? 0;

    if (parsedCount != null) {
      if (parsedCount > 0) {
        meta['replies_count'] = parsedCount;
      } else if (existingCount > 0) {
        meta['replies_count'] = existingCount;
      } else {
        meta['replies_count'] = 1;
      }
    } else {
      meta['replies_count'] = existingCount + 1;
    }

    if (messageData != null) {
      final msgType =
          (messageData['msg_type'] ?? meta['latest_reply_msg_type'] ?? 'text')
              .toString();
      final previewText = _threadPreviewLabel(
        msgType,
        messageData['msg'] ?? messageData['raw_msg'],
      );
      final sender =
          _extractSenderName(messageData) ?? meta['latest_reply_sender'] ?? '';

      meta['latest_reply_text'] = previewText;
      meta['latest_reply_sender'] = sender;
      if (messageData['sender_id'] != null) {
        meta['latest_reply_sender_id'] = messageData['sender_id'].toString();
      }
      meta['latest_reply_msg_type'] = msgType;
      meta['latest_reply_created_at'] = messageData['created_at']?.toString() ??
          messageData['updated_at']?.toString() ??
          meta['latest_reply_created_at'];
      final fileUrl = (messageData['file_url'] ?? '').toString();
      meta['latest_reply_file_url'] = msgType == 'text' ? '' : fileUrl;
    }

    if (old is types.TextMessage) {
      messages[idx] = old.copyWith(metadata: meta);
    } else if (old is types.ImageMessage) {
      messages[idx] = old.copyWith(metadata: meta);
    } else if (old is types.FileMessage) {
      messages[idx] = old.copyWith(metadata: meta);
    }
    messages.refresh();
  }

  int? _intFrom(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  String? _extractSenderName(Map? messageData) {
    if (messageData == null) return null;
    final direct = (messageData['sender_name'] ?? '').toString().trim();
    if (direct.isNotEmpty) return direct;
    final first = (messageData['sender_first_name'] ?? '').toString().trim();
    final last = (messageData['sender_last_name'] ?? '').toString().trim();
    final combined = ('$first $last').trim();
    return combined.isNotEmpty ? combined : null;
  }

  String _threadPreviewLabel(String msgType, dynamic rawMsg) {
    final normalized = msgType.toLowerCase();
    final text = (rawMsg ?? '').toString();
    switch (normalized) {
      case 'image':
        return 'Photo';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'file':
        return text.isNotEmpty ? text : 'File';
      case 'media':
        return 'Attachment';
      default:
        return text;
    }
  }
}
