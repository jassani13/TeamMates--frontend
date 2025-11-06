import 'dart:async';

import 'package:base_code/model/conversation_item.dart';
import 'package:base_code/module/bottom/chat/chat_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../chat_screen.dart';

class ChatDetailController extends GetxController {
  // Public observable state used by the UI
  final RxList<types.Message> messages = <types.Message>[].obs;
  final RxBool loading = false.obs;
  final RxMap<String, types.User> typingUsers = <String, types.User>{}.obs;

  // New: search query observable used for keyword-based highlighting
  final RxString searchQuery = ''.obs;

  ConversationItem? conversation;
  late final types.User me;

  // Reuse existing chat controller for media upload helper
  final ChatScreenController chatController = Get.put(ChatScreenController());

  // Scroll helpers (moved from UI for readability)
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final Map<String, int> msgIdToIndex = {};
  // Controls visibility of the "Jump to first unread" button
  final RxBool showJumpToUnreadButton = false.obs;
  // Observable last-read id to allow UI to rebuild separators when it changes
  final RxString lastReadMessageId = ''.obs;

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
    final args = Get.arguments ?? {};
    conversation = args['conversation'] as ConversationItem?;
    me = types.User(id: AppPref().userId.toString());
    lastReadMessageId.value = conversation?.lastReadMessageId ?? '';
    _registerSocketListeners();
    // Track viewport to decide when to show/hide the jump button
    itemPositionsListener.itemPositions.addListener(_onViewportChanged);
    loadInitial();
  }

  /// Set the current search query; UI should call this when user types in search.
  void setSearchQuery(String q) {
    searchQuery.value = q;
  }

  /// Clear the current search query.
  void clearSearch() {
    searchQuery.value = '';
  }

  void _registerSocketListeners() {
    socket.on(evMessagesResult, _onMessagesResult);
    socket.on(evNewMessage, _onNewMessage);
    socket.on(evTyping, _onTyping);
    socket.on(evMessagesReadBroadcast, _onMessagesRead);
    socket.on(evReaction, _onReaction);
    socket.on(evMessageEdited, _onMessageEdited);
    socket.on(evMessageDeleted, _onMessageDeleted);
  }

  void _removeSocketListeners() {
    socket.off(evMessagesResult, _onMessagesResult);
    socket.off(evNewMessage, _onNewMessage);
    socket.off(evTyping, _onTyping);
    socket.off(evMessagesReadBroadcast, _onMessagesRead);
    socket.off(evReaction, _onReaction);
    socket.off(evMessageEdited, _onMessageEdited);
    socket.off(evMessageDeleted, _onMessageDeleted);
  }

  /// Request initial messages for the conversation.
  void loadInitial() {
    if (conversation == null) return;
    loading.value = true;
    socket.emit(evGetMessages, {
      'conversation_id': conversation?.conversationId ?? '',
    });
  }

  void _onMessagesResult(dynamic payload) {
    if (payload == null) return;
    if (payload['conversation_id']?.toString() != conversation?.conversationId)
      return;
    final list = (payload['messages'] as List?) ?? [];
    messages.clear();
    for (final raw in list) {
      final msg = _fromSocket(raw);
      messages.insert(0, msg);
    }
    loading.value = false;
    // After messages load, update jump button visibility
    updateJumpToUnreadVisibility();
    // Ensure lastRead observable is in sync with conversation state
    lastReadMessageId.value =
        conversation?.lastReadMessageId ?? lastReadMessageId.value;
  }

  void _onNewMessage(dynamic data) {
    final raw = data['resData'] ?? data;
    if (raw == null) return;
    if (raw['conversation_id']?.toString() != conversation?.conversationId)
      return;
    final msg = _fromSocket(raw);
    messages.insert(0, msg);
    // Update visibility as list changed
    updateJumpToUnreadVisibility();
    // If received from others, mark read shortly after to allow UI to update
    if (msg.author.id != me.id) {
      Future.delayed(const Duration(milliseconds: 250), () => markRead());
    } else {
      // If the message is authored by me, update last-read to this message id
      // so unread boundary moves with my own messages and the jump button hides.
      _setLastReadToMessage(msg.id);
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
    // optional: implement per-message read state if required
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
    if (text.trim().isEmpty || conversation == null) return;
    socket.emit(evSend, {
      'conversation_id': conversation?.conversationId ?? '',
      'msg': text.trim(),
      'msg_type': 'text',
    });
    // stop typing
    if (_isTyping) {
      socket.emit(evTyping, {
        'conversation_id': conversation?.conversationId ?? '',
        'isTyping': false
      });
      _isTyping = false;
    }
  }

  Future<void> sendImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        imageQuality: 70,
        maxWidth: 1440,
        source: ImageSource.gallery,
      );
      if (picked == null) return;
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

  void sendReaction(String messageId, String reaction) {
    socket
        .emit(evReaction, {'message_id': messageId, 'reaction_type': reaction});
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
    markRead();
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
      'edited': raw['edited'] == true ||
          ((raw['updated_at']?.toString().isNotEmpty ?? false) &&
              (raw['updated_at']?.toString() != raw['created_at']?.toString())),
      'created_at': raw['created_at'],
      'updated_at': raw['updated_at'],
      'deleted_by': raw['deleted_by']?.toString(),
      'deleted_at': raw['deleted_at'],
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
}
