import 'dart:io';
import 'package:base_code/model/group_chat_model.dart';
import 'package:base_code/module/bottom/chat/groupChat/group_chat_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class EditGroupChatScreen extends StatefulWidget {
  const EditGroupChatScreen({super.key});

  @override
  State<EditGroupChatScreen> createState() => _EditGroupChatScreenState();
}

class _EditGroupChatScreenState extends State<EditGroupChatScreen> {
  final TextEditingController groupNameController = TextEditingController();
  final controller = Get.put<GroupChatController>(GroupChatController());

  String? groupId;
  String? existingImageUrl;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null) {
      final data = args['groupData'];
      if (data is GroupChatModel) {
        groupId = data.groupId;
        groupNameController.text = data.groupName ?? '';
        existingImageUrl = data.groupImage;
      } else if (data is Map) {
        groupId = (data['group_id'] ?? '').toString();
        groupNameController.text = (data['group_name'] ?? '').toString();
        existingImageUrl = (data['group_image'] ?? '').toString();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.getGroupMembers(groupId ?? '');
      });
    }
    // Clear any previous selection
    controller.groupImagePath.value = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0,
        title: const Text(
          "Edit Group",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => controller.showOptions(context),
              child: Obx(() {
                final pickedPath = controller.groupImagePath.value;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColor.greyF6Color,
                    child: pickedPath.isNotEmpty
                        ? Image.file(
                            File(pickedPath),
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          )
                        : (existingImageUrl != null &&
                                existingImageUrl!.isNotEmpty)
                            ? getImageView(
                                finalUrl: existingImageUrl!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                                errorWidget: const Icon(Icons.groups, size: 40),
                              )
                            : const Icon(Icons.camera_alt,
                                color: Colors.grey, size: 30),
                  ),
                );
              }),
            ),
            const Gap(20),
            CommonTextField(
              controller: groupNameController,
              hintText: "Group name",
              prefixIcon: const Icon(Icons.group, color: AppColor.grey4EColor),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.black12Color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  final name = groupNameController.text.trim();
                  if ((groupId ?? '').isEmpty) {
                    Get.snackbar("Error", "Invalid group");
                    return;
                  }
                  if (name.isEmpty) {
                    Get.snackbar("Error", "Please enter a group name");
                    return;
                  }

                  // await controller.updateGroupChat(
                  //   groupId: groupId!,
                  //   name: name,
                  // );
                },
                child: const Text(
                  "Save changes",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
