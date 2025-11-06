import 'package:base_code/module/bottom/chat/chat_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../model/conversation_item.dart';

late IO.Socket socket;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final chatController = Get.put<ChatScreenController>(ChatScreenController());

  void initUnifiedSocket() {
    //    //socket .220.132.157:3000', <String, dynamic>{ // Production server
    //    socket = IO.io('http://127.0.0.1:3000', <String, dynamic>{ // ios server
    //   //socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
    String url = "http://10.0.2.2:3000";
    if (Platform.isIOS) {
      url = "http://127.0.0.1:3000";
    }

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

    socket.connect();

    socket.onConnect((_) {
      if (kDebugMode) print('[SOCKET] connected');
      socket.emit('register', {'user_id': AppPref().userId});
    });

    socket.onDisconnect((_) {
      if (kDebugMode) print('[SOCKET] disconnected');
    });

    socket.on('conversation_list', (payload) {
      debugPrint("conversation_list: $payload");
      final list =
          payload is Map && payload['data'] != null ? payload['data'] : payload;
      if (list is List) {
        chatController.setConversations(list);
        // Join all conversation rooms so we can receive typing events for list view
        try {
          for (final c in chatController.conversations) {
            final id = c.conversationId ?? '';
            if (id.isNotEmpty) socket.emit('joinConversation', id);
          }
        } catch (_) {}
      }
    });

    socket.on('updateConversationList', (payload) {
      final data = payload['resData'] ?? payload;
      debugPrint("updateConversationList: $data");
      if (data is Map) {
        final convId = data['conversation_id']?.toString();
        if (convId == null) return;
        chatController.patchConversation(
            convId: convId,
            type: data['type']?.toString(),
            ownerId: data['owner_id']?.toString(),
            title: data['title']?.toString(),
            image: data['image']?.toString(),
            lastMessage: data['last_message']?.toString() ?? '',
            msgType: data['msg_type']?.toString() ?? 'text',
            fileUrl: data['last_message_file_url']?.toString() ?? '',
            createdAt: data['created_at']?.toString(),
            unreadCount: data['unread_count'] is int
                ? data['unread_count'] as int
                : int.tryParse(data['unread_count']?.toString() ?? '0') ?? 0,
            lastReadMessageId: data['last_read_message_id']);
        // Ensure we joined this conversation room to get typing events
        socket.emit('joinConversation', convId);
      }
    });
    // New incoming message (server should emit new_message; if not adjust to your emitted event)
    socket.on('new_message', (msg) async {
      if (kDebugMode) print('[SOCKET] new_message $msg');
      final conversationId = msg['conversation_id']?.toString();
      if (conversationId == null) return;

      // Optionally optimistically update last message
      final idx = chatController.conversations
          .indexWhere((c) => c.conversationId == conversationId);
      if (idx >= 0) {
        final old = chatController.conversations[idx];
        final updated = ConversationItem(
            conversationId: old.conversationId,
            type: old.type,
            title: old.title,
            image: old.image,
            ownerId: old.ownerId,
            lastMessage: msg['msg_type'] == 'text'
                ? (msg['msg'] ?? '')
                : msg['msg_type'] ?? 'file',
            lastMessageFileUrl: msg['file_url'] ?? '',
            msgType: msg['msg_type'] ?? 'text',
            createdAt: DateTime.now(),
            unreadCount: old.unreadCount ??
                0 +
                    (msg['sender_id'].toString() == AppPref().userId.toString()
                        ? 0
                        : 1),
            lastReadMessageId: "${msg?['last_read_message_id']}");
        debugPrint("Updating_conversation_locally: ${updated.ownerId}");
        chatController.updateOrInsert(updated);
      } else {
        // Fallback: ask server for fresh list just for safety
        socket.emit('get_conversations', {'user_id': AppPref().userId});
      }
    });

    // Read receipts reducing unread
    socket.on('messages_read', (payload) {
      final convId = payload['conversation_id']?.toString();
      final userId = payload['user_id']?.toString();
      if (userId == AppPref().userId.toString()) {
        // our own read ack -> ensure local unread zero
        if (convId != null) chatController.markConversationRead(convId);
      }
    });

    // Reactions
    socket.on('message_reaction', (payload) {
      // update message-level UI in conversation screen (implement there)
    });

    // Typing for list view (requires being in conv_* rooms)
    socket.on('typing', (payload) {
      try {
        final convId = payload['conversation_id']?.toString() ?? '';
        final isTyping = payload['isTyping'] == true;
        final uid = payload['user_id']?.toString();
        final first = (payload['sender_first_name']?.toString() ?? '').trim();
        final last = (payload['sender_last_name']?.toString() ?? '').trim();
        final full = ((first.isNotEmpty || last.isNotEmpty)
                ? (first + (last.isNotEmpty ? ' ' + last : ''))
                : '')
            .trim();
        if (convId.isNotEmpty && uid != AppPref().userId.toString()) {
          chatController.setTypingForConversation(
            conversationId: convId,
            isTyping: isTyping,
            typingUserId: uid,
            displayName: full.isNotEmpty ? full : null,
          );
        }
      } catch (e) {
        debugPrint('typing handler error: $e');
      }
    });

    // Presence (if you keep existing events)
    socket.emit('userOnline', [AppPref().userId]);
    socket.on('updateUserStatus', (data) {
      chatController.onlineUsers.clear();
      chatController.onlineUsers.addAll(data as Map);
    });
  }

  void userOnline() {
    socket.emit('userOnline', [AppPref().userId]);
  }

  void updateUserStatus() {
    socket.on('updateUserStatus', (data) {
      chatController.onlineUsers = data;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    initUnifiedSocket();
    userOnline();
    updateUserStatus();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset(
            AppImage.bottomBg,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          Column(
            children: [
              Gap(Platform.isAndroid
                  ? ScreenUtil().statusBarHeight + 20
                  : ScreenUtil().statusBarHeight + 10),
              Row(
                children: [
                  Gap(16),
                  CommonTitleText(text: "Chat"),
                  const Spacer(),
                  Visibility(
                    visible: AppPref().role == 'coach',
                    child: CommonIconButton(
                      image: AppImage.plus,
                      onTap: () {
                        Get.toNamed(AppRouter.searchChatScreen);
                      },
                    ),
                  ),
                  Gap(16),
                ],
              ),
              Gap(24),
              Container(
                height: 63,
                width: double.infinity,
                padding: EdgeInsets.all(
                  16,
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColor.greyF6Color,
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
                child: HorizontalSelectionList(
                  items: chatController.chatList,
                  selectedIndex: chatController.selectedChatMethod,
                  controller: chatController.controller,
                  onItemSelected: (index) {
                    chatController.selectedChatMethod.value = index;
                  },
                ),
              ),
              Gap(24),
              Expanded(child: buildConversationList())
              // Obx(
              //   () => Expanded(
              //     child: Column(
              //       children: [
              //         if (chatController.selectedChatMethod.value == 0) ...[
              //           _tamChatList(),
              //         ] else ...[
              //           _personalChatList(),
              //         ]
              //       ],
              //     ),
              //   ),
              // )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildConversationList() {
    return Obx(() {
      final items = chatController.filtered;
      if (items.isEmpty) {
        return Center(child: Text('No Conversations Yet'));
      }
      return ListView.separated(
        key:
            ValueKey("conversation_${chatController.selectedChatMethod.value}"),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            Divider(color: AppColor.greyF6Color, height: 1),
        itemBuilder: (_, i) {
          ConversationItem c = items[i];
          debugPrint(
              "Rendering conversation: ${c.conversationId}::${c.ownerId}");
          final timeAgo = c.createdAt == null
              ? ''
              : DateUtilities.getTimeAgo(c.createdAt!.toIso8601String());
          return GestureDetector(
            onTap: () {
              debugPrint("Conversation tapped: ${c.ownerId}");
              Get.toNamed(
                AppRouter.conversationDetailScreen,
                arguments: {'conversation': c},
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  ClipOval(
                    child: getImageView(
                        errorWidget: Icon(
                          Icons.account_circle,
                          size: 40,
                        ),
                        finalUrl: c.image ?? '',
                        fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            c.title == ''
                                ? '(Untitled ${c.type})'
                                : c.title ?? '',
                            style: TextStyle()
                                .normal16w500
                                .textColor(AppColor.black12Color)),
                        Obx(() {
                          final typingText = chatController
                                  .typingDisplay[c.conversationId ?? ''] ??
                              '';
                          final showTyping = typingText.isNotEmpty;
                          final subtitleText = showTyping
                              ? typingText
                              : (c.msgType == 'text'
                                  ? (c.lastMessage ?? '')
                                  : (c.msgType == 'null'
                                      ? 'File'
                                      : (c.msgType ?? 'file')));
                          return Text(
                            subtitleText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle().normal14w500.textColor(showTyping
                                ? Colors.green
                                : AppColor.grey4EColor),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(timeAgo,
                          style: TextStyle()
                              .normal14w500
                              .textColor(AppColor.grey4EColor)),
                      if ((c.unreadCount ?? 0) > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColor.greyF6Color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('${c.unreadCount}',
                              style: TextStyle()
                                  .normal14w500
                                  .textColor(AppColor.black)),
                        )
                      ]
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
