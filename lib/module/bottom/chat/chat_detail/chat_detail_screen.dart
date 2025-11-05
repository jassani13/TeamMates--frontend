import 'package:base_code/module/bottom/chat/utils/chat_app_bar.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter/material.dart';
import '../../../../model/conversation_item.dart';
import 'chat_detail_controller.dart';
import 'message_bubble.dart';
import 'chat_input.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({Key? key}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final controller = Get.put(ChatDetailController());
  // Scrolling is handled in the controller for readability.
  // controller.itemScrollController
  // controller.itemPositionsListener
  // controller.msgIdToIndex

  @override
  void initState() {
    super.initState();
    // put conversation from args into controller if present
    final args = Get.arguments ?? {};
    if (args['conversation'] != null) {
      controller.conversation = args['conversation'] as dynamic;
    }
    // ensure controller loads
    controller.loadInitial();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildList() {
    return Obx(() {
      final msgs = controller.messages;
      final query = controller.searchQuery
          .value; // make Obx depend on searchQuery so it rebuilds highlight
      if (controller.loading.value && msgs.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return ScrollablePositionedList.separated(
        itemScrollController: controller.itemScrollController,
        itemPositionsListener: controller.itemPositionsListener,
        //itemPositionsListener: itemPositionsListener,
        reverse: true,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        itemCount: msgs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, idx) {
          final msg = msgs[idx];
          final isMe = msg.author.id == AppPref().userId.toString();
          debugPrint(
              "msg->id:${msg.id} :: idx:$idx :: msg->${msg.metadata?['raw_msg']}");
          controller.msgIdToIndex.putIfAbsent(msg.id, () => idx);

          return MessageBubble(
            message: msg,
            isMe: isMe,
            highlightQuery: query,
            onTap: () {
              // open attachments or links
            },
            onLongPress: () async {
              // show reaction sheet + edit/delete for own messages
              final isMine = msg.author.id == AppPref().userId.toString();
              final canEdit = isMine; // keep simple; original had window check
              final options = <String>[];
              options.addAll(['👍', '❤️', '😂', '😮', '😢', '👏']);
              if (canEdit) options.add('Edit');
              if (controller.conversation?.ownerId?.toString() ==
                      AppPref().userId.toString() ||
                  isMine) options.add('Delete');

              final res = await showModalBottomSheet<String>(
                context: context,
                builder: (_) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: options
                          .map((o) => ListTile(
                                title: Text(o),
                                onTap: () => Navigator.of(context).pop(o),
                              ))
                          .toList(),
                    ),
                  );
                },
              );

              if (res == null) return;
              if (['👍', '❤️', '😂', '😮', '😢', '👏'].contains(res)) {
                controller.sendReaction(msg.id, res);
              } else if (res == 'Edit') {
                final newText = await _showEditSheet(msg);
                if (newText != null && newText.trim().isNotEmpty) {
                  controller.editMessage(msg.id, newText.trim());
                }
              } else if (res == 'Delete') {
                controller.deleteMessage(msg.id);
              }
            },
            onReact: (messageId, reaction) {
              controller.sendReaction(messageId, reaction);
            },
          );
        },
      );
    });
  }

  Future<String?> _showEditSheet(types.Message message) {
    final controllerText = TextEditingController(
        text: message.metadata?['raw_msg'] ??
            (message is types.TextMessage ? message.text : ''));
    return Get.bottomSheet<String?>(
      SafeArea(
          child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonTextField(controller: controllerText),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: CommonAppButton(
                  text: 'Cancel',
                  color: AppColor.redColor,
                  onTap: () => Get.back<String?>(result: null),
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: CommonAppButton(
                  text: 'Save',
                  onTap: () => Get.back<String?>(result: controllerText.text),
                )),
              ],
            )
          ],
        ),
      )),
      isScrollControlled: true,
    );
  }

  void _onSearchChanged(String q) {
    debugPrint("_onSearchChanged: $q");
    controller.setSearchQuery(q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(
          conversation: controller.conversation ??
              ConversationItem(
                  conversationId: '',
                  type: '',
                  title: '',
                  image: '',
                  lastMessage: '',
                  lastReadMessageId: '',
                  msgType: '',
                  createdAt: null,
                  unreadCount: null,
                  lastMessageFileUrl: ''),
          onSearchQuery: _onSearchChanged),
      body: Column(
        children: [
          Expanded(
              child: Stack(
            children: [
              _buildList(),
              // Show the jump button only when meaningful. Use Obx so it reacts to conversation/messages changes.
              Obx(() {
                if (!controller.showJumpToUnreadButton.value) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  bottom: 0,
                  right: 12,
                  child: SafeArea(
                    child: ElevatedButton.icon(
                      onPressed: controller.jumpToFirstUnread,
                      icon:
                          const Icon(Icons.keyboard_double_arrow_up, size: 18),
                      label: const Text('Jump to first unread'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                );
              }),
            ],
          )),
          Obx(() {
            final typing = controller.typingUsers.values.toList();
            if (typing.isNotEmpty) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child:
                      Text('${typing.first.firstName ?? 'User'} is typing...'),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() => controller.loading.value
              ? const LinearProgressIndicator()
              : const SizedBox.shrink()),
          ChatInput(
            onSend: (t) {
              controller.sendText(t);
            },
            onAttachImage: () async {
              await controller.sendImage();
            },
            onAttachFile: () async {
              await controller.sendFile();
            },
            onTextChanged: controller.onUserTyping,
          )
        ],
      ),
    );
  }
}
