import 'dart:async';
import 'package:base_code/main.dart'; // for socket/AppPref if you centralize them
import 'package:base_code/model/conversation_item.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'chat_controller.dart';
import 'chat_screen.dart';

/// Factory to convert socket payloads into flutter_chat_ui messages.
class ConversationMessageFactory {
  static types.Message fromSocket(dynamic raw) {
    final msgType = (raw['msg_type'] ?? 'text').toString();
    final senderId = raw['sender_id'].toString();
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
    };

    if (msgType == 'image') {
      return types.ImageMessage(
        id: id,
        author: types.User(id: senderId),
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
        author: types.User(id: senderId),
        createdAt: createdAt,
        uri: raw['file_url'] ?? raw['msg'] ?? '',
        name: 'document.pdf',
        size: 0,
        metadata: metadata,
      );
    }
    return types.TextMessage(
      id: id,
      author: types.User(id: senderId),
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

  // Event constants - adjust if server names change
  static const evGetMessages = 'get_messages';
  static const evMessagesResult = 'conversation_messages';
  static const evSend = 'send_message';
  static const evNewMessage = 'setNewConversationMessage'; // from backend
  static const evTyping = 'typing';
  static const evMessageRead = 'message_read';
  static const evMessagesReadBroadcast = 'messages_read';
  static const evReaction = 'message_reaction';

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    conversation = args['conversation'] as ConversationItem;
    debugPrint(
        "_ConversationDetailScreenState conv: ${conversation?.conversationId}: ${conversation?.title}");
    _registerSocketListeners();
    _loadInitial();
  }

  void _registerSocketListeners() {
    socket.on(evMessagesResult, _onMessagesResult);
    socket.on(evNewMessage, _onNewMessage);
    socket.on(evTyping, _onTyping);
    socket.on(evMessagesReadBroadcast, _onMessagesRead);
    socket.on(evReaction, _onReaction);
  }

  void _removeSocketListeners() {
    socket.off(evMessagesResult, _onMessagesResult);
    socket.off(evNewMessage, _onNewMessage);
    socket.off(evTyping, _onTyping);
    socket.off(evMessagesReadBroadcast, _onMessagesRead);
    socket.off(evReaction, _onReaction);
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
  }

  void _onNewMessage(dynamic data) {
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
  }

  void _onTyping(dynamic data) {
    if (data['conversation_id']?.toString() != conversation?.conversationId)
      return;
    // data: {conversation_id, user_id, isTyping}
    // Implement optional UI indicator here.
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
  }

  void _markRead() {
    if (_lastMessageId == null) return;
    socket.emit(evMessageRead, {
      'conversation_id': conversation?.conversationId ?? '',
      'last_read_message_id': _lastMessageId,
    });
  }

  void _sendText(types.PartialText partial) {
    socket.emit(evSend, {
      'conversation_id': conversation?.conversationId ?? '',
      'msg': partial.text,
      'msg_type': 'text',
    });
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
                  style: TextStyle().normal14w500.textColor(AppColor.black12Color),
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
                  style: TextStyle().normal14w500.textColor(AppColor.black12Color),
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

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final url = await chatController.setMediaChatApiCall(result: result.files[0]);
        if (url.isNotEmpty) {
          socket.emit(evSend, {
            'conversation_id': conversation?.conversationId ?? '',
            'msg': url.split('/').last,
            'msg_type': "file",
            'file_url': url,
          });
        }
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

      final result = await ImagePicker().pickImage(
        imageQuality: 70,
        maxWidth: 1440,
        source: ImageSource.gallery,
      );

      if (result != null) {
        final url = await chatController.setMediaChatApiCall(result: result);
        if (url.isNotEmpty) {
          socket.emit(evSend, {
            'conversation_id': conversation?.conversationId ?? '',
            'msg': url.split('/').last,
            'msg_type': "image",
            'file_url': url,
          });

        }
      }
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onUserTyping(String currentText) {
    if (_typingDebounce?.isActive ?? false) _typingDebounce!.cancel();
    if (!_typingSent) {
      socket.emit(evTyping, {
        'conversation_id': conversation?.conversationId ?? '',
        'isTyping': true,
      });
      _typingSent = true;
    }
    _typingDebounce = Timer(const Duration(seconds: 2), () {
      socket.emit(evTyping, {
        'conversation_id': conversation?.conversationId ?? '',
        'isTyping': false,
      });
      _typingSent = false;
    });
  }


  void _onMessageTap(BuildContext ctx, types.Message message) {
    final meta = message.metadata ?? {};
    final msgType = meta['msg_type'];
    if (msgType == 'pdf') {
      final url = meta['file_url'] ?? meta['raw_msg'];
      if (url != null) {
        // openPdf(url);
      }
    }
  }

  void _onMessageLongPress(BuildContext ctx, types.Message message) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: ['👍', '❤️', '😂', '😮', '😢', '👏'].map((e) {
          return ListTile(
            title: Text(e, style: const TextStyle(fontSize: 22)),
            onTap: () {
              debugPrint("Reacting with $e to message ${message.id}");
              socket.emit('message_reaction', {
                'message_id': message.id,
                'reaction_type': e,
              });
              Get.back();
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _removeSocketListeners();
    _typingDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "Building ConversationDetailScreen:${conversation?.ownerId} :: ${AppPref().userId}");
    return GestureDetector(
      onTap: hideKeyboard,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${conversation?.title}"),
          actions: [
            if (conversation?.ownerId == "${AppPref().userId}")
              IconButton(
                  onPressed: () {
                    Get.toNamed(AppRouter.editGroupChatScreen,
                        arguments: {"conversation": conversation});
                  },
                  icon: Icon(
                    CupertinoIcons.settings,
                  )),
            Gap(12)
          ],
        ),
        body: Stack(
          children: [
            Chat(
              user: user,
              messages: _messages,
              onSendPressed: _sendText,
              onAttachmentPressed: _handleAttachmentPressed,
              onMessageTap: _onMessageTap,
              onMessageLongPress: _onMessageLongPress,
              showUserAvatars: true,
              showUserNames: true,
              inputOptions: InputOptions(
                onTextChanged: _onUserTyping,
              ),
              customDateHeaderText: (d) => DateFormat('dd MMM yyyy').format(d),
            ),
            if (_loading && !_initialLoaded)
              const Center(child: CircularProgressIndicator()),

          ],
        ),
      ),
    );
  }
}
