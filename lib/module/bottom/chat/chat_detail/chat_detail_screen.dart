import 'package:base_code/module/bottom/chat/utils/chat_app_bar.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:flutter_chat_reactions/model/menu_item.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';
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
    final args = Get.arguments ?? {};
    if (args['conversation'] != null) {
      controller.conversation = args['conversation'] as dynamic;
    }
    controller.loadInitial();
  }

  @override
  void dispose() {
    try {
      final msgs = controller.messages;
      final hasManualUnread = controller.manualUnreadMessageId.value.isNotEmpty;
      if (!hasManualUnread &&
          msgs.isNotEmpty &&
          msgs.first.author.id != AppPref().userId.toString()) {
        controller.markRead();
      }
    } catch (_) {}
    super.dispose();
  }

  bool _canEditMessage(types.Message msg) {
    final isMine = msg.author.id == AppPref().userId.toString();
    if (!isMine) return false;
    // Disallow editing for non-text messages (images, pdf/files)
    final msgType = (msg.metadata?['msg_type']?.toString().toLowerCase() ??
        (msg is types.TextMessage
            ? 'text'
            : (msg is types.ImageMessage
                ? 'image'
                : (msg is types.FileMessage ? 'file' : 'text'))));
    if (msgType != 'text') return false;
    final createdAt = msg.createdAt;
    if (createdAt == null) return false;
    const window = Duration(minutes: 15);
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    return nowMs - createdAt <= window.inMilliseconds;
  }

  Widget _buildList() {
    return Obx(() {
      final showFlaggedOnly = controller.showFlaggedOnly.value;
      final showPinnedOnly = controller.showPinnedOnly.value;
      List<types.Message> msgs = controller.messages;
      if (showFlaggedOnly) {
        msgs = msgs.where((m) => (m.metadata?['flagged'] == true)).toList();
      }
      if (showPinnedOnly) {
        msgs = msgs.where((m) => (m.metadata?['pinned'] == true)).toList();
      }
      final query = controller.searchQuery.value;
      controller.lastReadMessageId.value;
      if (controller.loading.value && msgs.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      final filtersOn = showFlaggedOnly || showPinnedOnly;
      final firstUnreadIndex =
          filtersOn ? null : controller.getFirstUnreadIndex();

      return ScrollablePositionedList.separated(
        itemScrollController: controller.itemScrollController,
        itemPositionsListener: controller.itemPositionsListener,
        reverse: true,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        itemCount: msgs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, idx) {
          final msg = msgs[idx];
          final isMe = msg.author.id == AppPref().userId.toString();
          controller.msgIdToIndex.putIfAbsent(msg.id, () => idx);

          final bubble = MessageBubble(
            message: msg,
            isMe: isMe,
            highlightQuery: query,
            onTap: () {},
            onLongPress: () {
              final isMine = isMe;
              final canEdit = _canEditMessage(msg);
              final isFlagged = (msg.metadata?['flagged'] == true);
              final isPinned = (msg.metadata?['pinned'] == true);

              Navigator.of(context).push(
                HeroDialogRoute(
                  builder: (context) {
                    final theme = Theme.of(context);
                    return Theme(
                      data: theme.copyWith(
                        textTheme: theme.textTheme.apply(
                          bodyColor: AppColor.black12Color,
                          displayColor: AppColor.black12Color,
                        ),
                        listTileTheme: const ListTileThemeData(
                          textColor: AppColor.black12Color,
                          iconColor: AppColor.black12Color,
                        ),
                      ),
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(color: AppColor.black12Color),
                        child: ReactionsDialogWidget(
                          reactions: const ['👍', '❤️', '😂', '😮', '😢', '👏'],
                          menuItems: [
                            if (isMine && canEdit)
                              MenuItem(label: 'Edit', icon: Icons.edit),
                            if (isMine)
                              MenuItem(
                                label: 'Delete',
                                icon: Icons.delete_outline,
                                isDestuctive: true,
                              ),
                            MenuItem(
                              label: isFlagged ? 'Unflag' : 'Flag',
                              icon:
                                  isFlagged ? Icons.flag : Icons.flag_outlined,
                            ),
                            MenuItem(
                              label: isPinned ? 'Unpin' : 'Pin',
                              icon: isPinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                            ),
                            if (!isMine)
                              MenuItem(
                                label: 'Mark as unread',
                                icon: Icons.mark_email_unread_outlined,
                              ),
                          ],
                          id: msg.id,
                          messageWidget: const SizedBox.shrink(),
                          onReactionTap: (reaction) {
                            controller.sendReaction(msg.id, reaction);
                          },
                          onContextMenuTap: (menuItem) async {
                            switch (menuItem.label) {
                              case 'Edit':
                                final newText = await _showEditSheet(msg);
                                if (newText != null &&
                                    newText.trim().isNotEmpty) {
                                  controller.editMessage(
                                      msg.id, newText.trim());
                                }
                                break;
                              case 'Delete':
                                controller.deleteMessage(msg.id);
                                break;
                              case 'Flag':
                              case 'Unflag':
                                controller.toggleFlag(
                                    msg.id, (msg.metadata?['flagged'] == true));
                                break;
                              case 'Pin':
                              case 'Unpin':
                                controller.togglePin(
                                    msg.id, (msg.metadata?['pinned'] == true));
                                break;
                              case 'Mark as unread':
                                controller.markAsUnread(msg.id);
                                break;
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            onReact: (messageId, reaction) {
              controller.sendReaction(messageId, reaction);
            },
            onReactionsTap: () {
              _showReactionDetailsSheet(msg);
            },
            onReadByTap: () {
              _showReadByDetailsSheet(msg);
            },
          );

          if (firstUnreadIndex != null && idx == firstUnreadIndex) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _UnreadSeparator(),
                const SizedBox(height: 6),
                Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: bubble,
                ),
              ],
            );
          }

          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: bubble,
          );
        },
      );
    });
  }

  Widget _UnreadSeparator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'New messages',
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonAppButton(
                      text: 'Save',
                      onTap: () =>
                          Get.back<String?>(result: controllerText.text),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _onSearchChanged(String q) {
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
          onSearchQuery: _onSearchChanged,
          onSearchPrev: controller.goToPrevMatch,
          onSearchNext: controller.goToNextMatch,
          searchCurrent: controller.currentMatchNumber,
          searchTotal: controller.totalMatches),
      body: Column(
        children: [
          Obx(() {
            final flagged = controller.showFlaggedOnly.value;
            final pinned = controller.showPinnedOnly.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      selected: flagged,
                      label: const Text('Flagged only'),
                      onSelected: (v) => controller.showFlaggedOnly.value = v,
                    ),
                    FilterChip(
                      selected: pinned,
                      label: const Text('Pinned only'),
                      onSelected: (v) => controller.showPinnedOnly.value = v,
                    ),
                  ],
                ),
              ),
            );
          }),
          Expanded(
            child: Stack(
              children: [
                _buildList(),
                Obx(() {
                  final filtersOn = controller.showFlaggedOnly.value ||
                      controller.showPinnedOnly.value;
                  if (filtersOn || !controller.showJumpToUnreadButton.value) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    bottom: 0,
                    right: 12,
                    child: SafeArea(
                      child: ElevatedButton.icon(
                        onPressed: controller.jumpToFirstUnread,
                        icon: const Icon(Icons.keyboard_double_arrow_up,
                            size: 18),
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
            ),
          ),
          Obx(() {
            final typing = controller.typingUsers.values.toList();
            if (typing.isNotEmpty) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${typing.first.firstName ?? 'User'} is typing...',
                    style: TextStyle(color: AppColor.black12Color),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() => controller.loading.value
              ? const LinearProgressIndicator()
              : const SizedBox.shrink()),
          ChatInput(
            onSend: (t) => controller.sendText(t),
            onAttachImage: () async => controller.sendImage(),
            onAttachFile: () async => controller.sendFile(),
            onTextChanged: controller.onUserTyping,
          ),
        ],
      ),
    );
  }
}

// --- Reactions bottom sheet (details) helpers ---
extension _ChatDetailReactionUI on _ChatDetailScreenState {
  String _reactionToEmoji(String reactionStr) {
    try {
      if (reactionStr.contains('U+')) {
        final codePoints = reactionStr
            .split(' ')
            .where((p) => p.trim().isNotEmpty)
            .map((e) => int.parse(e.replaceFirst('U+', ''), radix: 16))
            .toList();
        return String.fromCharCodes(codePoints);
      }
      return reactionStr;
    } catch (_) {
      return reactionStr;
    }
  }

  void _showReactionDetailsSheet(types.Message message) {
    final reactions = (message.metadata?['reactions'] as List?) ?? [];
    if (reactions.isEmpty) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Reactions',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black12Color),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              itemCount: reactions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final r = reactions[index] as Map;
                final reactionStr = (r['reaction'] ?? '').toString();
                final emoji = _reactionToEmoji(reactionStr);
                final userId = r['user_id']?.toString() ?? '';
                final isMine = userId == AppPref().userId.toString();
                final userName =
                    _nameForUserId(userId) ?? (isMine ? 'You' : 'User $userId');

                return ListTile(
                  leading: Text(emoji, style: const TextStyle(fontSize: 20)),
                  title: Text(userName,
                      style: const TextStyle(color: AppColor.black12Color)),
                  trailing: isMine
                      ? TextButton(
                          onPressed: () {
                            controller.sendReaction(message.id, emoji);
                            Get.back();
                          },
                          child: const Text(
                            'Remove',
                            style: TextStyle(color: AppColor.red10Color),
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

  String? _nameForUserId(String uid) {
    try {
      final idx = controller.messages.indexWhere((m) => m.author.id == uid);
      if (idx != -1) {
        final a = controller.messages[idx].author;
        final first = a.firstName ?? '';
        final last = a.lastName ?? '';
        final name = (first + ' ' + last).trim();
        if (name.isNotEmpty) return name;
      }
    } catch (_) {}
    return null;
  }

  void _showReadByDetailsSheet(types.Message message) {
    final raw = (message.metadata?['read_by'] as List?) ?? [];
    final ids =
        raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    if (ids.isEmpty) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Read by',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black12Color),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              itemCount: ids.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final uid = ids[index];
                final isMe = uid == AppPref().userId.toString();
                final name =
                    _nameForUserId(uid) ?? (isMe ? 'You' : 'User $uid');
                return ListTile(
                  leading:
                      const Icon(Icons.check, color: AppColor.black12Color),
                  title: Text(name,
                      style: const TextStyle(color: AppColor.black12Color)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
