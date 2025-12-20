import 'package:base_code/module/bottom/chat/chat_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';

import '../../../data/network/server_config.dart';
import '../../../components/search_input.dart';

import '../../../model/conversation_item.dart';
import '../../../model/search_message_hit.dart';

late IO.Socket socket;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final chatController = Get.put<ChatScreenController>(ChatScreenController());
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _joinedConversations = <String>{};

  void initUnifiedSocket() {
    final String url = ServerConfig.socketBaseUrl;

    debugPrint("[SOCKET] init url:$url");

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
      debugPrint('[SOCKET] connected');
      socket.emit('register', {'user_id': AppPref().userId});
      chatController.attachSearchSocket();

      // Request conversations explicitly (server also emits on register)
      try {
        socket.emit('get_conversations', {'user_id': AppPref().userId});
      } catch (e) {
        debugPrint("get_conversations emit error:$e");
      }

      // Listen for full conversation list
      socket.off('conversation_list');
      socket.on('conversation_list', (data) {
        debugPrint("conversation_list:$data");
        try {
          if (data is List) {
            chatController.setConversations(data);
            // Join conversation rooms so we can receive typing events for list rows
            for (final item in data) {
              try {
                if (item is Map) {
                  final id = (item['conversation_id'] ?? '').toString();
                  if (id.isNotEmpty && !_joinedConversations.contains(id)) {
                    socket.emit('join_chat_room', {'conversation_id': id});
                    _joinedConversations.add(id);
                  }
                }
              } catch (_) {}
            }
          }
        } catch (e) {
          if (kDebugMode) debugPrint('conversation_list parse error: $e');
        }
      });

      // Listen for incremental conversation updates (unread, last message etc.)
      socket.off('updateConversationList');
      socket.on('updateConversationList', (payload) {
        try {
          final res = payload is Map ? payload['resData'] ?? payload : payload;
          if (res is Map) {
            chatController.patchConversation(
              convId: (res['conversation_id'] ?? '').toString(),
              lastMessage: (res['last_message'] ?? '').toString(),
              msgType: (res['msg_type'] ?? 'text').toString(),
              fileUrl: (res['last_message_file_url'] ?? '').toString(),
              type: (res['type'] ?? '').toString(),
              ownerId: res['owner_id']?.toString(),
              title: (res['title'] ?? '').toString(),
              image: (res['image'] ?? '').toString(),
              createdAt: (res['created_at'] ?? '').toString(),
              unreadCount:
                  int.tryParse((res['unread_count'] ?? '0').toString()),
            );
            // Ensure we are subscribed to typing events for this conversation
            final id = (res['conversation_id'] ?? '').toString();
            if (id.isNotEmpty && !_joinedConversations.contains(id)) {
              socket.emit('join_chat_room', {'conversation_id': id});
              _joinedConversations.add(id);
            }
          }
        } catch (e) {
          if (kDebugMode) debugPrint('updateConversationList error: $e');
        }
      });

      // Typing events from joined conversation rooms -> show in list
      socket.off('typing');
      socket.on('typing', (payload) {
        try {
          if (payload is! Map) return;
          final convId =
              (payload['conversation_id'] ?? payload['chat_room_id'] ?? '')
                  .toString();
          if (convId.isEmpty) return;
          final isTyping = payload['isTyping'] == true;
          final uid = (payload['user_id'] ?? '').toString();
          final first = (payload['sender_first_name'] ?? '').toString();
          final last = (payload['sender_last_name'] ?? '').toString();
          final display = (first + ' ' + last).trim();
          chatController.setTypingForConversation(
            conversationId: convId,
            isTyping: isTyping,
            typingUserId: uid,
            displayName: display.isNotEmpty ? display : null,
          );
        } catch (e) {
          if (kDebugMode) debugPrint('typing(list) error: $e');
        }
      });


      // Presence (if you keep existing events)
      socket.emit('userOnline', [AppPref().userId]);
      socket.on('updateUserStatus', (data) {
        chatController.onlineUsers.clear();
        chatController.onlineUsers.addAll(data as Map);
      });
    });

    socket.onConnectError((e){
      debugPrint('[SOCKET] connect error:$e');
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
    _searchCtrl.dispose();
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
                  CommonIconButton(
                    image: AppImage.plus,
                    onTap: () {
                      Get.toNamed(AppRouter.searchChatScreen);
                    },
                  ),
                  Gap(16),
                ],
              ),
              Gap(16),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CommonSearchField(
                  controller: _searchCtrl,
                  hintText: 'Search conversations',
                  onChanged: (text) => chatController.setSearchQuery(text),
                ),
              ),
              Gap(12),
              Expanded(child: buildConversationList())
            ],
          ),
        ],
      ),
    );
  }

  Widget buildConversationList() {
    return Obx(() {
      final query = chatController.searchQuery.value.trim();
      final items = chatController.filtered;
      final hits = chatController.messageHits;

      if (query.isEmpty && items.isEmpty) {
        return Center(
            child: Text('No Conversations Yet',
                style: TextStyle(color: AppColor.black12Color)));
      }

      return ListView(
        key:
            ValueKey("conversation_${chatController.selectedChatMethod.value}"),
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          //   child: Text('Chats',
          //       style:
          //           const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
          //               .textColor(AppColor.grey4EColor)),
          // ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('No chats match',
                  style:
                      TextStyle().normal14w500.textColor(AppColor.grey4EColor)),
            )
          else
            ...items.map(_conversationTile),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Messages',
                  style:
                      const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
                          .textColor(AppColor.grey4EColor)),
            ),
            if (hits.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('No matching messages',
                    style: TextStyle()
                        .normal14w500
                        .textColor(AppColor.grey4EColor)),
              )
            else
              ...hits.map((h) => _messageHitTile(h, query)).toList(),
          ],
        ],
      );
    });
  }

  Widget _conversationTile(ConversationItem c) {
    final timeAgo = c.createdAt == null
        ? ''
        : DateUtilities.getTimeAgo(c.createdAt!.toIso8601String());
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRouter.conversationDetailScreen,
            arguments: {'conversation': c});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            ClipOval(
              child: getImageView(
                  errorWidget: const Icon(Icons.account_circle, size: 40),
                  finalUrl: c.image ?? '',
                  fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title == '' ? '(Untitled ${c.type})' : c.title ?? '',
                      style: TextStyle()
                          .normal16w500
                          .textColor(AppColor.black12Color)),
                  Obx(() {
                    final typingText =
                        chatController.typingDisplay[c.conversationId ?? ''] ??
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
                      style: TextStyle().normal14w500.textColor(
                          showTyping ? Colors.green : AppColor.grey4EColor),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColor.greyF6Color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('${c.unreadCount}',
                        style:
                            TextStyle().normal14w500.textColor(AppColor.black)),
                  )
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _messageHitTile(SearchMessageHit hit, String query) {
    final dateStr = hit.createdAt == null
        ? ''
        : DateFormat('dd/MM/yyyy').format(hit.createdAt!.toLocal());
    final qLower = query.toLowerCase();
    final source = hit.text;
    final idx = source.toLowerCase().indexOf(qLower);
    final before = idx >= 0 ? source.substring(0, idx) : source;
    final match = idx >= 0 ? source.substring(idx, idx + query.length) : '';
    final after = idx >= 0 ? source.substring(idx + query.length) : '';
    InlineSpan span = match.isEmpty
        ? TextSpan(text: source)
        : TextSpan(children: [
            TextSpan(text: before),
            TextSpan(
                text: match,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: after),
          ]);
    return GestureDetector(
      onTap: () {
        final conv = chatController.conversations
            .firstWhereOrNull((c) => c.conversationId == hit.conversationId);
        if (conv != null) {
          Get.toNamed(AppRouter.conversationDetailScreen, arguments: {
            'conversation': conv,
            'focus_message_id': hit.messageId,
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(hit.senderDisplayName,
                      style: const TextStyle(fontWeight: FontWeight.w600)
                          .textColor(AppColor.black12Color)),
                ),
                const SizedBox(width: 8),
                Text(dateStr,
                    style: const TextStyle(fontSize: 12)
                        .textColor(AppColor.grey4EColor)),
              ],
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColor.black12Color),
                children: [span],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
