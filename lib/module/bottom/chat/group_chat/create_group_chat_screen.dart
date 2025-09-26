import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

import 'group_chat_controller.dart';

class CreateGroupChatScreen extends StatefulWidget {
  CreateGroupChatScreen({super.key});

  @override
  State<CreateGroupChatScreen> createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  final TextEditingController groupNameController = TextEditingController();
  final controller = Get.put<GroupChatController>(GroupChatController());
  List<String> selectedPlayers = [];

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      selectedPlayers = Get.arguments['selectedPlayers'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0,
        title: const Text(
          "New Group",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                controller.showOptions(context);
              },
              child: Obx(() {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColor.greyF6Color,
                    child: controller.groupImagePath.value.isEmpty
                        ? const Icon(Icons.camera_alt,
                        color: Colors.grey, size: 30)
                        : Image.file(
                      File(controller.groupImagePath.value),
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    ),
                  ),
                );
              }),
            ),
            const Gap(20),

            // Group Name Field
            CommonTextField(
              controller: groupNameController,
              hintText: "Group name",
              prefixIcon: const Icon(Icons.group, color: AppColor.grey4EColor),
            ),
            const Spacer(),

            // Create Button
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
                  final groupName = groupNameController.text.trim();
                  if (groupName.isEmpty) {
                    Get.snackbar("Error", "Please enter a group name");
                    return;
                  }

                  await controller.createGroupChat(selectedPlayers, groupName);

                },
                child: const Text(
                  "Create",
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