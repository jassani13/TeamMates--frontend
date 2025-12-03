import 'package:base_code/module/bottom/chat/thread/thread_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ThreadDetailScreen extends StatelessWidget {
  const ThreadDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final parentMessageData = args['parent_message'] as Map<String, dynamic>;
    final messageId = args['message_id'] as int;

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
          _buildParentMessage(parentMessageData),
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

  Widget _buildParentMessage(Map<String, dynamic> parentMessageData) {
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
                DateUtilities.getTimeAgo(parentMessageData['created_at'] ?? ''),
                style: TextStyle().normal12w500.textColor(AppColor.grey4EColor),
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
            '${parentMessageData['replies_count'] ?? 0} ${(parentMessageData['replies_count'] ?? 0) == 1 ? 'reply' : 'replies'}',
            style: TextStyle().normal12w500.textColor(AppColor.primaryColor),
          ),
        ],
      ),
    );
  }
}
