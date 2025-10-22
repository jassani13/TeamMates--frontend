import 'dart:async';
import 'package:base_code/main.dart'; // for socket/AppPref if you centralize them
import 'package:base_code/model/conversation_item.dart';
import 'package:base_code/module/bottom/chat/utils/chat_app_bar.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:flutter_chat_reactions/model/menu_item.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../../model/media_draft.dart';
import 'chat_controller.dart';
import 'chat_screen.dart';

/// Factory to convert socket payloads into flutter_chat_ui messages.
class ConversationMessageFactory {
  static types.Message fromSocket(dynamic raw) {
    final msgType = (raw['msg_type'] ?? 'text').toString();
    final senderId = raw['sender_id'].toString();
    final senderFirstName = "${raw['sender_first_name'] ?? ""}";
    final senderLastName = "${raw['sender_last_name'] ?? ""}";
    final senderProfile = raw['sender_profile']?.toString();
    final id = raw['message_id'].toString();
    final createdAtStr = raw['created_at']?.toString();
    final lastReadMessageID = raw?['last_read_message_id']?.toString();
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
      'last_read_message_id': lastReadMessageID,
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
        type: types.MessageType.image,
        height: 150,
        width: 200,
        metadata: metadata,
      );
    } else if (msgType == 'pdf') {
      return types.FileMessage(
        id: id,
        author: types.User(
            id: senderId,
            firstName: senderFirstName,
            lastName: senderLastName,
            imageUrl: senderProfile),
        createdAt: createdAt,
        uri: raw['file_url'] ?? raw['msg'] ?? '',
        name: 'document.pdf',
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

  static types.Message applyReactions(types.Message original, List reactions) {
    final meta = {...?original.metadata, 'reactions': reactions};
    if (original is types.TextMessage) return original.copyWith(metadata: meta);
    if (original is types.ImageMessage)
      return original.copyWith(metadata: meta);
    if (original is types.FileMessage) return original.copyWith(metadata: meta);
    return original;
  }
}

class ConversationDetailScreen extends StatefulWidget {
  const ConversationDetailScreen({super.key});

  @override
  State<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  final chatController = Get.put<ChatScreenController>(ChatScreenController());
  ConversationItem? conversation;
  final user = types.User(id: AppPref().userId.toString());
  final List<types.Message> _messages = [];

  bool _loading = false;
  bool _initialLoaded = false;
  String? _lastMessageId;
  Timer? _typingDebounce;
  bool _typingSent = false;

  // Typing State fields
  final Map<String, types.User> _knownUsers =
      {}; // cache participants for names/avatars
  final Map<String, types.User> _typingUsers =
      {}; // currently typing users (except me)
  final Map<String, Timer> _typingTimers = {}; // per-user expiry timers
  static const _typingTTL = Duration(
      seconds: 4); // how long one 'isTyping: true' lasts without refresh

  // How often we re-send `isTyping:true` while typing
  static const Duration _typingHeartbeat = Duration(seconds: 3);
  DateTime? _lastTypingTrue;
  bool _isTyping = false;

  // Keep this in sync with backend EDIT_WINDOW_SECONDS (default 15 mins)
  static const int _editWindowSeconds = 15 * 60;

  // Search state
  String _searchQuery = '';
  final Map<String, List<TextRange>> _matchRangesById =
      {}; // messageId -> matches
  final List<String> _matchIds = []; // ordered ids of messages that match
  int _currentMatchIndex = -1;

  // Keys to scroll to specific messages
  final Map<String, GlobalKey> _bubbleKeys = {};

  GlobalKey _keyFor(String messageId) =>
      _bubbleKeys.putIfAbsent(messageId, () => GlobalKey());

  void _pruneBubbleKeys(Iterable<String> liveIds) {
    _bubbleKeys.removeWhere((id, _) => !liveIds.contains(id));
  }

// Move through matches
  Future<void> _gotoMatch(int delta) async {
    if (_matchIds.isEmpty) return;

    setState(() {
      _currentMatchIndex =
          ((_currentMatchIndex + delta) % _matchIds.length + _matchIds.length) %
              _matchIds.length;
    });
    await _jumpToMatchIndex(_currentMatchIndex);
  }

  Future<void> _jumpToMatchIndex(int idx) async {
    if (idx < 0 || idx >= _matchIds.length) return;
    if (_isJumping) return;
    _isJumping = true;

    try {
      final id = _matchIds[idx];
      final listIndex = _messages.indexWhere((m) => m.id == id);
      if (listIndex == -1) return;
      final builderIndex =
          _messages.length - 1 - listIndex; // account for reverse:true
      await _chatScrollController.scrollToIndex(
        builderIndex,
        preferPosition: AutoScrollPosition.middle,
        duration: const Duration(milliseconds: 250),
      );

      await _nudgeOffScrollEdge(amount: 120);

      // 2) Let the frame build, then ensureVisible for precise alignment
      await Future<void>.delayed(const Duration(milliseconds: 16));
      final key = _bubbleKeys[id];
      if (key?.currentContext != null) {
        await _ensureVisibleWithRetry(key!, attempts: 2);
      }
    } finally {
      _isJumping = false;
    }
  }

  late final AutoScrollController _chatScrollController;

  // Event constants - adjust if server names change
  static const evGetMessages = 'get_messages';
  static const evMessagesResult = 'conversation_messages';
  static const evSend = 'send_message';
  static const evNewMessage = 'setNewConversationMessage'; // from backend
  static const evTyping = 'typing';
  static const evMessageRead = 'message_read';
  static const evMessagesReadBroadcast = 'messages_read';
  static const evReaction = 'message_reaction';
  static const evMessageEdited = 'message_edited';
  static const evMessageDeleted = 'message_deleted';

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    conversation = args['conversation'] as ConversationItem;
    debugPrint("ownerId: ${conversation?.ownerId}");
    _registerSocketListeners();
    _loadInitial();
    socket.on(evTyping, _onTyping);
    _chatScrollController = AutoScrollController(
      axis: Axis.vertical,
      // Optional tuning:
      // suggestedRowHeight: 72,
      // viewportBoundaryGetter: () =>
      //   Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
    );
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

  void _loadInitial() {
    _loading = true;
    socket.emit(evGetMessages, {
      'conversation_id': conversation?.conversationId ?? '',
    });
    setState(() {});
  }

  void _onMessagesResult(dynamic payload) {
    debugPrint("_onMessagesResult payload: $payload");
    if (payload == null) return;
    if (payload['conversation_id']?.toString() != conversation?.conversationId)
      return;
    final list = (payload['messages'] as List?) ?? [];
    _messages.clear();
    for (final raw in list) {
      final msg = ConversationMessageFactory.fromSocket(raw);
      _messages.insert(0, msg);
      _lastMessageId = msg.id;
    }
    _initialLoaded = true;
    _loading = false;
    setState(() {});
    _markRead();
    for (final m in _messages) {
      _knownUsers[m.author.id] = m.author;
    }
    _syncBubbleKeys();
    _pruneBubbleKeys(_messages.map((m) => m.id));
  }

  void _onNewMessage(dynamic data) {
    debugPrint("_onNewMessage:$data");
    final raw = data['resData'] ?? data;
    if (raw == null) return;
    if (raw['conversation_id']?.toString() != conversation?.conversationId)
      return;

    final msg = ConversationMessageFactory.fromSocket(raw);
    _messages.insert(0, msg);
    _lastMessageId = msg.id;

    // Mark read if it's from someone else
    if (msg.author.id != user.id) {
      Future.delayed(const Duration(milliseconds: 250), _markRead);
    }
    setState(() {});
    _syncBubbleKeys();
  }

  void _onTyping(dynamic data) {
    if (data == null) return;

    final cid = data['conversation_id']?.toString();
    if (cid != conversation?.conversationId) return;

    final uid = data['user_id']?.toString();
    if (uid == null || uid == user.id) return; // ignore myself

    final isTyping = data['isTyping'] == true;

    if (isTyping) {
      // Prefer a known user (with name/avatar) if we have one
      final known = _knownUsers[uid] ?? types.User(id: uid);

      _typingUsers[uid] = known;

      // Refresh expiry timer
      _typingTimers[uid]?.cancel();
      _typingTimers[uid] = Timer(_typingTTL, () {
        _typingUsers.remove(uid);
        _typingTimers.remove(uid);
        if (mounted) setState(() {});
      });
    } else {
      _typingUsers.remove(uid);
      _typingTimers.remove(uid)?.cancel();
    }

    if (mounted) setState(() {});
  }

  void _onMessagesRead(dynamic data) {
    if (data['conversation_id']?.toString() != conversation?.conversationId)
      return;
    // data: {conversation_id, user_id, last_read_message_id}
    // Optional: show per-user read status badges
  }

  void _onReaction(dynamic data) {
    debugPrint("_onReaction data: $data");
    if (data == null) return;
    final mid = data['message_id']?.toString();
    if (mid == null) return;

    // Optional: if conversation_id is sent, ensure it matches current convo
    final cid = data['conversation_id']?.toString();
    if (cid != null && cid != conversation?.conversationId) return;

    final idx = _messages.indexWhere((m) => m.id == mid);
    if (idx == -1) return;

    // Prefer full authoritative list if provided
    List reactions;
    if (data['reactions'] is List) {
      reactions = List.from(data['reactions'].map((r) => {
            'user_id': r['user_id'].toString(),
            'reaction': r['reaction'],
          }));
    } else {
      // Legacy fallback: append single reaction
      final existing = _messages[idx].metadata?['reactions'] as List? ?? [];
      reactions = [
        ...existing,
        {
          'user_id': data['user_id'].toString(),
          'reaction': data['reaction_type']
        }
      ];
    }

    // Deduplicate by user_id (keep last one)
    final map = <String, Map<String, dynamic>>{};
    for (final r in reactions) {
      final uid = r['user_id'].toString();
      map[uid] = {'user_id': uid, 'reaction': r['reaction']};
    }
    final normalized = map.values.toList();

    _messages[idx] =
        ConversationMessageFactory.applyReactions(_messages[idx], normalized);
    setState(() {});

    debugPrint("_onReaction:$reactions");
  }

  void _markRead() {
    if (_lastMessageId == null) return;
    socket.emit(evMessageRead, {
      'conversation_id': conversation?.conversationId ?? '',
      'last_read_message_id': _lastMessageId,
    });
  }

  void _onSendPressed(types.PartialText partial) {
    _typingDebounce?.cancel();
    if (_isTyping) {
      socket.emit(evTyping, {
        'conversation_id': conversation?.conversationId ?? '',
        'isTyping': false
      });
      _isTyping = false;
    }
    socket.emit(evSend, {
      'conversation_id': conversation?.conversationId ?? '',
      'msg': partial.text,
      'msg_type': 'text',
    });
  }

  void _emitMessageReaction(String messageId, String reaction) {
    socket.emit(evReaction, {
      'message_id': messageId,
      'reaction_type': reaction,
    });
  }

  void _onMessageEdited(dynamic data) {
    debugPrint("_onMessageEdited data: $data");
    final raw = data['resData'] ?? data;
    if (raw == null) return;
    if (raw['conversation_id']?.toString() != conversation?.conversationId)
      return;

    final id = raw['message_id']?.toString();
    if (id == null) return;

    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx == -1) return;

    final old = _messages[idx];
    final newText = (raw['msg'] ?? '').toString();

    final newMeta = {
      ...?old.metadata,
      'raw_msg': newText,
      'edited': true,
      'updated_at': raw['updated_at'],
    };

    if (old is types.TextMessage) {
      _messages[idx] = old.copyWith(text: newText, metadata: newMeta);
    } else if (old is types.ImageMessage) {
      _messages[idx] = old.copyWith(metadata: newMeta);
    } else if (old is types.FileMessage) {
      _messages[idx] = old.copyWith(metadata: newMeta);
    }

    setState(() {});
  }

  Future<void> _deleteMessage(types.Message message) async {
    if (!_canDelete(message)) {
      AppToast.showAppToast('You can only delete your own messages.');
      return;
    }
    socket.emit('delete_message', {
      'message_id': message.id,
    });
  }

  void _onMessageDeleted(dynamic data) {
    final raw = data['resData'] ?? data;
    if (raw == null) return;
    if (raw['conversation_id']?.toString() != conversation?.conversationId)
      return;

    final id = raw['message_id']?.toString();
    if (id == null) return;

    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx == -1) return;

    final old = _messages[idx];
    final newMeta = {
      ...?old.metadata,
      'deleted': true,
      'deleted_at': raw['deleted_at'],
      'deleted_by': raw['deleted_by'],
      'reactions': <dynamic>[], // hide reactions
    };

    if (old is types.TextMessage) {
      _messages[idx] = old.copyWith(text: '', metadata: newMeta);
    } else if (old is types.ImageMessage) {
      _messages[idx] = old.copyWith(metadata: newMeta);
    } else if (old is types.FileMessage) {
      _messages[idx] = old.copyWith(metadata: newMeta);
    }

    setState(() {});
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Gap(4),
            TextButton(
              onPressed: () {
                Get.back();
                _handleImageSelection();
              },
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'Photo',
                  style:
                      TextStyle().normal14w500.textColor(AppColor.black12Color),
                ),
              ),
            ),
            Gap(4),
            TextButton(
              onPressed: () {
                Get.back();
                _handleFileSelection();
              },
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'File',
                  style:
                      TextStyle().normal14w500.textColor(AppColor.black12Color),
                ),
              ),
            ),
            Gap(4),
          ],
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    try {
      setState(() => _loading = true);

      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['pdf'],
      );
      setState(() => _loading = false);
      if (res == null || res.files.isEmpty || res.files.single.path == null)
        return;
      final file = res.files.single;
      final draft = MediaDraft.file(file);
      final result =
          await showMediaPreviewSheet(context: context, draft: draft);
      if (result == null || !result.confirmed) return;

      setState(() => _loading = true);
      final url = await chatController.setMediaChatApiCall(result: file);

      if (url.isNotEmpty) {
        socket.emit(evSend, {
          'conversation_id': conversation?.conversationId ?? '',
          'msg': result.caption ?? url.split('/').last,
          'msg_type': "file",
          'file_url': url,
        });
      }
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _handleImageSelection() async {
    try {
      setState(() => _loading = true);

      final picked = await ImagePicker().pickImage(
        imageQuality: 70,
        maxWidth: 1440,
        source: ImageSource.gallery,
      );
      setState(() => _loading = false);
      final draft = MediaDraft.image(picked);
      final result =
          await showMediaPreviewSheet(context: context, draft: draft);
      if (result == null || !result.confirmed) return;

      setState(() => _loading = true);
      final url = await chatController.setMediaChatApiCall(result: picked);
      setState(() => _loading = false);
      if (url.isNotEmpty) {
        socket.emit("send_message", {
          'conversation_id': conversation?.conversationId ?? '',
          'msg': result.caption ?? url.split('/').last,
          'msg_type': "image",
          'file_url': url,
        });
      }
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<MediaPreviewResult?> showMediaPreviewSheet({
    required BuildContext context,
    required MediaDraft draft,
  }) {
    final captionController = TextEditingController();
    return Get.bottomSheet<MediaPreviewResult>(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Row(
                children: [
                  const Expanded(
                    child: Text('Preview',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.appBarBlackColor)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        Get.back(result: MediaPreviewResult(confirmed: false)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Content preview
              if (draft.kind == 'image' && draft.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(draft.image!.path),
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else if (draft.kind == 'file' && draft.file != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          draft.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColor.black12Color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Optional caption
              CommonTextField(
                controller: captionController,
                hintText: "Add a caption (optional)",
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 12),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(
                          result: MediaPreviewResult(confirmed: false)),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(
                          result: MediaPreviewResult(
                            confirmed: true,
                            caption: captionController.text.trim(),
                          ),
                        );
                      },
                      child: const Text('Send'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _onUserTyping(String currentText) {
    final convId = conversation?.conversationId ?? '';
    final now = DateTime.now();

    // If input cleared, immediately stop typing
    if (currentText.isEmpty) {
      _typingDebounce?.cancel();
      if (_isTyping) {
        socket.emit(evTyping, {'conversation_id': convId, 'isTyping': false});
        _isTyping = false;
      }
      return;
    }

    // Start or refresh a “true” heartbeat every _typingHeartbeat
    if (!_isTyping ||
        _lastTypingTrue == null ||
        now.difference(_lastTypingTrue!) >= _typingHeartbeat) {
      socket.emit(evTyping, {'conversation_id': convId, 'isTyping': true});
      _isTyping = true;
      _lastTypingTrue = now;
    }

    // Debounce sending “false” after user stops typing for 2s
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(seconds: 2), () {
      socket.emit(evTyping, {'conversation_id': convId, 'isTyping': false});
      _isTyping = false;
    });
  }

  void _onMessageTap(BuildContext ctx, types.Message message) {
    return;
    debugPrint("_onMessageTap message: $message");
    final meta = message.metadata ?? {};
    final msgType = meta['msg_type'];
    final rawMsg = meta['raw_msg'] as String?;
    if (msgType == 'pdf') {
      final url = meta['file_url'] ?? meta['raw_msg'];
      if (url != null) {
        // openPdf(url);
      }
    }
    if (msgType == 'text' && _isValidUrl(rawMsg)) {
      //Get.toNamed(AppRouter.webViewScreen, arguments: {"url": rawMsg});
    }
  }

  Widget buildLinkifyMessage(String text) {
    return Linkify(
      text: text,
      linkifiers: const [UrlLinkifier()],
      options: const LinkifyOptions(looseUrl: true, defaultToHttps: true),
      style: TextStyle(color: Colors.black),
      linkStyle: TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      onOpen: (link) async {
        final uri = Uri.parse(
            link.url.startsWith('http') ? link.url : 'https://${link.url}');
        Get.toNamed(AppRouter.webViewScreen,
            arguments: {"url": uri.toString()});
      },
    );
  }

  bool _isValidUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    String raw = url.trim();
    if (raw.startsWith('www.')) {
      raw = 'https://$raw';
    } else if (!raw.contains('://') && raw.contains('.')) {
      raw = 'https://$raw';
    }

    final uri = Uri.tryParse(raw);
    return uri != null &&
        uri.hasAbsolutePath &&
        (uri.isScheme('http') || uri.isScheme('https'));
  }

  String _reactionToEmoji(String reaction) {
    if (reaction.isEmpty) return reaction;
    if (!reaction.contains('U+'))
      return reaction; // already emoji, just show it

    final parts =
        reaction.split(RegExp(r'\s+')).where((p) => p.trim().isNotEmpty);
    final codePoints = <int>[];
    for (final p in parts) {
      final hex = p.toUpperCase().replaceFirst('U+', '');
      final val = int.tryParse(hex, radix: 16);
      if (val != null) codePoints.add(val);
    }
    return codePoints.isEmpty ? reaction : String.fromCharCodes(codePoints);
  }

  Future<void> _beginEditMessage(types.Message message) async {
    // Do not allow editing non-authored messages
    if (message.author.id != user.id) return;

    // Prefill with text or caption
    final initial = message.metadata?['raw_msg']?.toString() ??
        (message is types.TextMessage ? message.text : '');
    if (initial.isEmpty) return;

    final newText = await _showEditMessageSheet(initialText: initial);
    if (newText == null) return;
    final trimmed = newText.trim();
    if (trimmed == initial.trim()) return;

    debugPrint("_beginEditMessage:$trimmed");
    socket.emit('edit_message', {
      'message_id': message.id,
      'new_text': trimmed,
    });
  }

  bool _canDelete(types.Message m) {
    final me = user.id;
    if (m.author.id == me) return true; // self
    final ownerId = conversation?.ownerId?.toString();
    return ownerId != null && ownerId == me; // conversation owner (admin)
  }

  bool _withinEditWindow(types.Message m) {
    final isMine = m.author.id == user.id;
    if (!isMine) return false;

    DateTime? created;
    if (m.createdAt != null) {
      created = DateTime.fromMillisecondsSinceEpoch(m.createdAt!, isUtc: true);
    } else {
      final s = m.metadata?['created_at']?.toString();
      if (s != null && s.isNotEmpty) {
        created = DateTime.tryParse(s)?.toUtc();
      }
    }
    if (created == null) return false;

    final now = DateTime.now().toUtc();
    final elapsed = now.difference(created);
    return elapsed.inSeconds <= _editWindowSeconds;
  }

  bool _isEditedMessage(types.Message m) => (m.metadata?['edited'] == true);

  bool _isDeleted(types.Message m) => (m.metadata?['deleted_at'] != null);

  Future<String?> _showEditMessageSheet({required String initialText}) {
    final controller = TextEditingController(text: initialText);
    return Get.bottomSheet<String>(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Edit message',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.black12Color)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back<String?>(result: null),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CommonTextField(
                controller: controller,
                hintText: 'Update your message',
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CommonAppButton(
                      text: "Cancel",
                      color: AppColor.redColor,
                      onTap: () => Get.back<String?>(result: null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: CommonAppButton(
                    text: "Save",
                    onTap: () {
                      Get.back<String>(result: controller.text);
                    },
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _deletedMessageBubble(bool isSentByMe) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColor.greyF6Color,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(Get.context!).size.width * 0.7,
      ),
      child: const Text(
        'This message was deleted.',
        style: TextStyle(
          color: Colors.black45,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeSocketListeners();
    _typingDebounce?.cancel();
    // Stop all receiver-side timers
    for (final t in _typingTimers.values) {
      t.cancel();
    }
    _typingTimers.clear();
    if (_isTyping) {
      socket.emit(evTyping, {
        'conversation_id': conversation?.conversationId ?? '',
        'isTyping': false,
      });
      _isTyping = false;
    }

    socket.off(evTyping, _onTyping);
    super.dispose();
  }

  // Search handling
  /// Finds all case-insensitive occurrences of `needleLower` in `haystack`,
  /// returning TextRanges [start, end) for highlight.
  List<TextRange> _findAllOccurrences(String haystack, String needleLower) {
    final result = <TextRange>[];
    if (needleLower.isEmpty) return result;

    final lower = haystack.toLowerCase();
    int start = 0;
    while (true) {
      final idx = lower.indexOf(needleLower, start);
      if (idx == -1) break;
      result.add(TextRange(start: idx, end: idx + needleLower.length));
      start = idx + needleLower.length;
    }
    return result;
  }

  Widget _buildMessageItem(BuildContext context, int index) {
    final msg = _messages[index];

    // Ensure a stable key exists for EVERY message id
    final bubbleKey = _bubbleKeys.putIfAbsent(msg.id, () => GlobalKey());

    return AutoScrollTag(
      key: ValueKey(index),
      controller: _chatScrollController, // AutoScrollController
      index: index,
      child: KeyedSubtree(
        key: bubbleKey,
        child: buildSearchAwareMessage(
            msg.metadata?['raw_msg']), // your bubble widget
      ),
    );
  }

  Widget buildSearchAwareMessage(String text) {
    if (_searchQuery.isEmpty) {
      return buildLinkifyMessage(text);
    }
    return _buildHighlightedText(text, matchColor: const Color(0xFFFFF59D));
  }

  /// Builds RichText with background highlight for all occurrences of `_searchQuery`.
  Widget _buildHighlightedText(
    String text, {
    Color matchColor = const Color(0xFFFFF59D), // soft yellow
  }) {
    if (text.isEmpty) return const SizedBox.shrink();

    final query = _searchQuery;
    final spans = <TextSpan>[];

    if (query.isEmpty) {
      return Text(
        text,
        style: const TextStyle(color: Colors.black),
      );
    }

    final lower = text.toLowerCase();
    final needle = query.toLowerCase();

    int index = 0;
    while (true) {
      final matchIndex = lower.indexOf(needle, index);
      if (matchIndex < 0) {
        // tail
        if (index < text.length) {
          spans.add(TextSpan(
            text: text.substring(index),
            style: const TextStyle(color: Colors.black),
          ));
        }
        break;
      }

      // non-match head
      if (matchIndex > index) {
        spans.add(TextSpan(
          text: text.substring(index, matchIndex),
          style: const TextStyle(color: Colors.black),
        ));
      }

      // match span
      final matchText = text.substring(matchIndex, matchIndex + needle.length);
      spans.add(TextSpan(
        text: matchText,
        style: const TextStyle(
          color: Colors.black,
          backgroundColor: Color(0xFFFFF59D), // same as _matchColor
          fontWeight: FontWeight.w600,
        ),
      ));

      index = matchIndex + needle.length;
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  void _syncBubbleKeys() {
    for (final m in _messages) {
      _bubbleKeys.putIfAbsent(m.id, () => GlobalKey());
    }
  }

  void _onSearchChanged(String q) {
    debugPrint("_onSearchChanged: $q");

    final query = q.trim();
    _searchQuery = query;
    _matchRangesById.clear();
    _matchIds.clear();
    _currentMatchIndex = -1;

    if (query.isEmpty) {
      setState(() {}); // re-render to remove highlights
      return;
    }

    // Case-insensitive scan across messages; store ranges for highlight
    final lowerQ = query.toLowerCase();
    for (final m in _messages) {
      // We only highlight textual content (raw_msg or message.text)
      final meta = m.metadata ?? {};
      final raw = (meta['raw_msg']?.toString() ?? '').trim();
      final source =
          raw.isNotEmpty ? raw : (m is types.TextMessage ? m.text : '');

      if (source.isEmpty) continue;

      final ranges = _findAllOccurrences(source, lowerQ);
      if (ranges.isNotEmpty) {
        _matchRangesById[m.id] = ranges;
        _matchIds.add(m.id);
      }
    }

    // Optional: set current index to first match
    if (_matchIds.isNotEmpty) _currentMatchIndex = 0;

    setState(() {}); // re-render bubbles with highlights
  }

  Future<void> _nudgeOffScrollEdge({
    required double amount,
    Duration duration = const Duration(milliseconds: 1),
  }) async {
    debugPrint("_nudgeOffScrollEdge called with amount: $amount");
    if (!mounted || !_chatScrollController.hasClients) return;
    debugPrint("_nudgeOffScrollEdge: has clients");

    final p = _chatScrollController.position;
    final min = p.minScrollExtent, max = p.maxScrollExtent, px = p.pixels;
    const eps = 0.5;
    final atTop = (px - min).abs() <= eps;
    final atBottom = (max - px).abs() <= eps;
    if (!atTop && !atBottom) return;

    final target =
        (atTop ? px + amount : px - amount).clamp(min, max).toDouble();
    try {
      await _chatScrollController.animateTo(target,
          duration: duration, curve: Curves.easeOut);
    } catch (e) {
      debugPrint("exception in _nudgeOffScrollEdge:-> $e");
    }
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }

  Future<void> _nudgeOffScrollEdge123({
    required double amount,
    Duration duration = const Duration(milliseconds: 1),
  }) async {
    if (!mounted) return;

    // Prefer the primary controller, fallback to the nearest Scrollable
    ScrollPosition? position;
    final controller = PrimaryScrollController.of(context);
    if (controller != null && controller.hasClients) {
      position = controller.position;
    } else {
      final scrollable = Scrollable.of(context);
      position = scrollable?.position;
    }
    if (position == null) return;

    final min = position.minScrollExtent;
    final max = position.maxScrollExtent;
    final pixels = position.pixels;

    const epsilon = 0.5;
    final atTop = (pixels - min).abs() <= epsilon;
    final atBottom = (max - pixels).abs() <= epsilon;

    if (!atTop && !atBottom) return;

    final double target =
        (atTop ? pixels + amount : pixels - amount).clamp(min, max).toDouble();

    try {
      await position.animateTo(
        target,
        duration: duration,
        curve: Curves.easeOut,
      );
    } catch (_) {
      // Best-effort: some positions may not support animateTo early in build
    }

    await Future<void>.delayed(const Duration(milliseconds: 16));
  }

  Future<void> _ensureVisibleWithRetry(
    GlobalKey key, {
    int attempts = 3,
    Duration delayBetween = const Duration(milliseconds: 32),
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    double alignment = 0.05, // slight offset from edge
    ScrollPositionAlignmentPolicy alignmentPolicy =
        ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
  }) async {
    for (var i = 0; i < attempts; i++) {
      if (!mounted) return;
      final ctx = key.currentContext;
      if (ctx != null) {
        try {
          await Scrollable.ensureVisible(
            ctx,
            duration: duration,
            curve: curve,
            alignment: alignment,
            alignmentPolicy: alignmentPolicy,
          );
          await Future<void>.delayed(const Duration(milliseconds: 16));
          return;
        } catch (_) {
          // retry
        }
      }
      await Future<void>.delayed(delayBetween);
    }
  }

  /*  Move up or down in chat search */
  bool _isJumping = false;

  Future<void> _onNextMatch() async {
    if (_isJumping || _matchIds.isEmpty) return;
    final next = (_currentMatchIndex + 1) % _matchIds.length;
    setState(() => _currentMatchIndex = next);
    await _jumpToMatchIndex(next);
  }

  Future<void> _onPrevMatch() async {
    if (_isJumping || _matchIds.isEmpty) return;
    final prev = (_currentMatchIndex - 1 + _matchIds.length) % _matchIds.length;
    setState(() => _currentMatchIndex = prev);
    await _jumpToMatchIndex(prev);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hideKeyboard,
      child: Scaffold(
        appBar: ChatAppBar(
          conversation: conversation!,
          onSearchQuery: _onSearchChanged,
        ),
        body: Stack(
          children: [
            Chat(
              user: user,
              messages: _messages,
              onSendPressed: _onSendPressed,
              scrollController: _chatScrollController,
              onAttachmentPressed: _handleAttachmentPressed,
              onMessageTap: _onMessageTap,
              isAttachmentUploading: _loading,
              scrollToUnreadOptions: ScrollToUnreadOptions(
                  lastReadMessageId: conversation?.lastReadMessageId ?? '',
                  scrollOnOpen: true),
              onMessageLongPress: (v, message) {
                final isMine = message.author.id == user.id;
                final canEdit = _withinEditWindow(message);
                final canDelete = _canDelete(message);
                bool deleted = _isDeleted(message);
                if (deleted) return;

                Navigator.of(context).push(
                  HeroDialogRoute(
                    builder: (context) {
                      return ReactionsDialogWidget(
                        reactions: ['👍', '❤️', '😂', '😮', '😢', '👏'],
                        menuItems: isMine
                            ? [
                                if (canEdit)
                                  MenuItem(label: 'Edit', icon: Icons.edit),
                                if (canDelete)
                                  MenuItem(
                                      label: 'Delete',
                                      icon: CupertinoIcons.delete,
                                      isDestuctive: true),
                              ]
                            : [],
                        id: message.id,
                        messageWidget: const SizedBox.shrink(),
                        onReactionTap: (reaction) {
                          _emitMessageReaction(message.id.toString(), reaction);
                        },
                        onContextMenuTap: (menuItem) async {
                          if (menuItem.label == 'Edit') {
                            await _beginEditMessage(message);
                          } else if (menuItem.label == 'Delete') {
                            _deleteMessage(message);
                          }
                        },
                      );
                    },
                  ),
                );
              },
              //showUserAvatars: true,
              showUserNames: true,
              typingIndicatorOptions: TypingIndicatorOptions(
                typingMode: TypingIndicatorMode.name,
                typingUsers: _typingUsers.values.toList(),
              ),
              inputOptions: InputOptions(
                onTextChanged: _onUserTyping,
              ),
              customDateHeaderText: (d) => DateFormat('dd MMM yyyy').format(d),
              bubbleBuilder: (Widget child,
                  {required types.Message message,
                  required bool nextMessageInGroup}) {
                bool isSentByMe = message.author.id == user.id;
                return KeyedSubtree(
                  key: _keyFor(message.id),
                  child: _buildMessage(message, isSentByMe),
                );
                return _buildMessage(message, isSentByMe);
              },
            ),
            // Inside the Stack children (after Chat, before the loading overlay):
            if (_searchQuery.isNotEmpty && _matchIds.isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: Material(
                  color: Colors.black.withOpacity(0.01),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Counter: current/total
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '${_currentMatchIndex >= 0 ? (_currentMatchIndex + 1) : 0}/${_matchIds.length}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.keyboard_arrow_up,
                              color: Colors.white),
                          onPressed: () => _gotoMatch(-1),
                          tooltip: 'Previous match',
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white),
                          onPressed: () => _gotoMatch(1),
                          tooltip: 'Next match',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_loading || !_initialLoaded)
              Container(
                color: Colors.white10,
                child: Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColor.grey50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColor.black12Color,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Hero _buildMessage(types.Message message, bool isSentByMe) {
    return Hero(
      tag: message.id,
      child: _buildMessageList(isSentByMe, message),
    );
  }

  Align _buildMessageList(
    bool isSentByMe,
    types.Message message,
  ) {
    final deleted = _isDeleted(message);
    List reactions = message.metadata?['reactions'] ?? [];
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: deleted
          ? _deletedMessageBubble(isSentByMe)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isSentByMe)
                  ClipOval(
                    child: getImageView(
                      height: 30,
                      width: 30,
                      finalUrl: message.author.imageUrl ?? "",
                      fit: BoxFit.cover,
                      errorWidget: Icon(
                        Icons.account_circle,
                        size: 30,
                      ),
                    ),
                  ),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (!isSentByMe)
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 4, right: 6, left: 6),
                          child: Text(
                            message.author.firstName ?? "",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (message.metadata?['msg_type'] == 'file') ...[
                            GestureDetector(
                              onTap: () => openPdf(
                                message.metadata?['file_url'],
                              ),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 200,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: AppColor.greyF6Color,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.picture_as_pdf,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                "Document",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: AppColor.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        buildSearchAwareMessage(
                                            message.metadata?['raw_msg'] ?? ""),
                                        if (_isEditedMessage(message))
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: const Padding(
                                              padding: EdgeInsets.only(
                                                  left: 6, top: 2),
                                              child: Text('Edited',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.black38)),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  _buildChatReaction(reactions, message)
                                ],
                              ),
                            ),
                          ] else if (message.metadata?['msg_type'] ==
                              'image') ...[
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                message.metadata?['raw_msg'] == ""
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: getImageView(
                                            finalUrl:
                                                message.metadata?['file_url'],
                                            height: 200,
                                            width: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 200,
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 16),
                                        decoration: BoxDecoration(
                                          color: AppColor.greyF6Color,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: getImageView(
                                                  finalUrl: message
                                                      .metadata?['file_url'],
                                                  height: 200,
                                                  width: 200,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8),
                                              child: buildSearchAwareMessage(
                                                  message.metadata?[
                                                          'raw_msg'] ??
                                                      ""),
                                            ),
                                            if (_isEditedMessage(message))
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 6, top: 2),
                                                  child: Text('Edited',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              Colors.black38)),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                _buildChatReaction(reactions, message)
                              ],
                            )
                          ] else ...[
                            Flexible(
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: AppColor.greyF6Color,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(Get.context!)
                                                .size
                                                .width *
                                            0.7,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: isSentByMe
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.end,
                                        children: [
                                          buildSearchAwareMessage(
                                              message.metadata?['raw_msg'] ??
                                                  ""),
                                          if (_isEditedMessage(message))
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  left: 6, top: 2),
                                              child: Text('Edited',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.black38)),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _buildChatReaction(reactions, message)
                                ],
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Visibility _buildChatReaction(
      List<dynamic> reactions, types.Message message) {
    return Visibility(
      visible: reactions.isNotEmpty,
      child: GestureDetector(
        onTap: () => _showReactionDetailsSheet(
          oppositeUserName:
              '${message.author.firstName ?? ""} ${message.author.lastName ?? ""}',
          reactions: reactions,
          currentUserId: AppPref().userId.toString(),
          messageId: message.id,
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4.0,
            children: () {
              final maxVisible = 2;
              final total = reactions.length;
              final displayedReactions = reactions.take(maxVisible).toList();
              final remainingCount =
                  total > maxVisible ? total - maxVisible : 0;

              final children = <Widget>[];

              for (final reaction in displayedReactions) {
                final reactionString = (reaction['reaction'] ?? '').toString();
                final emoji = _reactionToEmoji(reactionString);

                final toShow = emoji.isNotEmpty ? emoji : reactionString;

                children.add(
                  Text(
                    toShow,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }

              if (remainingCount > 0) {
                children.add(
                  Text(
                    '+$remainingCount',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColor.black12Color,
                    ),
                  ),
                );
              }

              return children;
            }(),
          ),
        ),
      ),
    );
  }

  void _showReactionDetailsSheet({
    required List reactions,
    required String currentUserId,
    required String messageId,
    required String oppositeUserName,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Reactions",
              style: TextStyle().normal16w400.textColor(AppColor.black),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              itemCount: reactions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final reaction = reactions[index];
                final reactionString = (reaction['reaction'] ?? '').toString();
                final emoji = _reactionToEmoji(reactionString);

                final toShow = emoji.isNotEmpty ? emoji : reactionString;

                final userId = reaction['user_id'].toString();
                final isMine = userId == currentUserId;
                final userName = isMine ? "You" : oppositeUserName ?? "NA";

                return ListTile(
                  leading: Text(toShow, style: TextStyle(fontSize: 20)),
                  title: Text(
                    userName,
                    style: TextStyle()
                        .normal16w400
                        .textColor(AppColor.black12Color),
                  ),
                  trailing: isMine
                      ? TextButton(
                          onPressed: () {
                            _emitMessageReaction(messageId, toShow);
                            Get.back();
                          },
                          child: Text(
                            "Remove",
                            style: TextStyle()
                                .normal16w400
                                .textColor(AppColor.red10Color),
                          ),
                        )
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
