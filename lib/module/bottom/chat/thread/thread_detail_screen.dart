import 'package:base_code/module/bottom/chat/thread/thread_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../../../../utils/common_function.dart';

class ThreadDetailScreen extends StatelessWidget {
  const ThreadDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final parentMessageData = args['parent_message'] as Map<String, dynamic>;
    final messageId = args['message_id'] as int;
    final initialRepliesCount = parentMessageData['replies_count'] is int
        ? parentMessageData['replies_count'] as int
        : int.tryParse(parentMessageData['replies_count']?.toString() ?? '0') ??
            0;

    // Create parent message object
    final parentMessage = types.TextMessage(
      id: messageId.toString(),
      author: types.User(
        id: parentMessageData['sender_id'].toString(),
        firstName: parentMessageData['sender_name'],
        imageUrl: parentMessageData['sender_profile'],
      ),
      text: parentMessageData['msg'],
      createdAt: DateTime.parse(parentMessageData['created_at'])
          .toUtc()
          .millisecondsSinceEpoch,
    );

    // Initialize controller with tag to avoid conflicts
    final controller = Get.put(
      ThreadController(
        parentMessageId: messageId,
        parentMessage: parentMessage,
        initialRepliesCount: initialRepliesCount,
      ),
      tag: 'thread_$messageId',
    );

    final currentUser = AppPref().userModel;
    final user = types.User(
      id: currentUser?.userId?.toString() ?? '',
      firstName: currentUser?.firstName,
      lastName: currentUser?.lastName,
      imageUrl: currentUser?.profile ?? '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Thread'),
        elevation: 1,
      ),
      body: Column(
        children: [
          // Parent message display
          _buildParentMessage(parentMessageData, controller),
          Divider(height: 1, thickness: 1),

          // Thread replies
          Expanded(
            child: Obx(() {
              if (controller.loading.value && controller.replies.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              return Chat(
                messages: controller.replies,
                onSendPressed: controller.sendThreadReply,
                onAttachmentPressed: () =>
                    _showAttachmentSheet(context, controller),
                onMessageTap: (context, message) {
                  if (message is types.FileMessage) {
                    final url = (message.uri.isNotEmpty
                            ? message.uri
                            : (message.metadata?['file_url']?.toString() ?? ''))
                        .trim();
                    if (url.isNotEmpty) {
                      openPdf(url);
                    }
                  }
                },
                user: user,
                theme: DefaultChatTheme(
                  backgroundColor: Colors.white,
                  primaryColor: AppColor.primaryColor,
                  secondaryColor: AppColor.greyF6Color,
                ),
                customDateHeaderText: (val) {
                  return DateFormat("dd EEE, yyyy hh:mm a").format(val);
                },
              );
            }),
          ),

          Obx(() {
            if (!controller.sendingAttachment.value) {
              return SizedBox.shrink();
            }
            return const LinearProgressIndicator(minHeight: 2);
          }),

          // Load more indicator
          Obx(() {
            if (controller.loading.value && controller.replies.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              );
            }

            if (controller.hasMore.value) {
              return TextButton(
                onPressed: controller.loadMoreReplies,
                child: Text('Load more replies'),
              );
            }

            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  void _showAttachmentSheet(BuildContext context, ThreadController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo, color: AppColor.black12Color),
                title: const Text('Image',
                    style: TextStyle(color: AppColor.black12Color)),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.pickImageAttachment();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.attach_file, color: AppColor.black12Color),
                title: const Text('File',
                    style: TextStyle(color: AppColor.black12Color)),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.pickDocumentAttachment();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParentMessage(
      Map<String, dynamic> parentMessageData, ThreadController controller) {
    return Obx(() {
      final replies = controller.totalReplies.value;
      final replyLabel = replies == 1 ? 'reply' : 'replies';
      return Container(
        padding: EdgeInsets.all(16),
        color: AppColor.greyF6Color.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: parentMessageData['sender_profile'] != null
                      ? NetworkImage(parentMessageData['sender_profile'])
                      : null,
                  child: parentMessageData['sender_profile'] == null
                      ? Icon(Icons.person, size: 16)
                      : null,
                ),
                Gap(8),
                Text(
                  parentMessageData['sender_name'] ?? 'Unknown',
                  style:
                      TextStyle().normal14w600.textColor(AppColor.black12Color),
                ),
                Spacer(),
                Text(
                  DateUtilities.getTimeAgo(
                      parentMessageData['created_at'] ?? ''),
                  style:
                      TextStyle().normal12w500.textColor(AppColor.grey4EColor),
                ),
              ],
            ),
            Gap(8),
            Text(
              parentMessageData['msg'] ?? '',
              style: TextStyle().normal14w500.textColor(AppColor.black12Color),
            ),
            Gap(8),
            Text(
              '$replies $replyLabel',
              style: TextStyle().normal12w500.textColor(AppColor.primaryColor),
            ),
          ],
        ),
      );
    });
  }
}
