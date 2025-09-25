import 'dart:io';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

import 'group_chat_controller.dart';

class EditGroupChatScreen extends StatefulWidget {
  const EditGroupChatScreen({super.key});

  @override
  State<EditGroupChatScreen> createState() => _EditGroupChatScreenState();
}

class _EditGroupChatScreenState extends State<EditGroupChatScreen> {
  final TextEditingController groupNameController = TextEditingController();
  final controller = Get.put<GroupChatController>(GroupChatController());

  String? conversationId;
  String? existingImageUrl;
  String? initialName;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null) {
      initialName = args['title'];
      existingImageUrl = args['imageUrl'];
      conversationId = args['conversationId'];
      if (initialName != null) {
        groupNameController.text = initialName ?? '';
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchConversationMembers(conversationId ?? '');
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
        actions: [
          CommonIconButton(
            image: AppImage.plus,
            onTap: () {
              // Get.toNamed(AppRouter.addGroupMembersScreen, arguments: {
              //   "group_id": conversationId ?? "",
              //   "players": Get.put<SearchChatController>(SearchChatController())
              //       .allPlayerModelList
              // });
            },
          ),
          Gap(16)
          //controller.members
        ],
      ),
      // in _EditGroupChatScreenState.build (replace body:)
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Group image picker (unchanged)
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
                        ? Image.file(File(pickedPath),
                            fit: BoxFit.cover, width: 120, height: 120)
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
            const Gap(16),
            CommonTextField(
              controller: groupNameController,
              hintText: "Group name",
              prefixIcon: const Icon(Icons.group, color: AppColor.grey4EColor),
            ),
            const Gap(16),
            Row(
              children: const [
                Text("Members",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.black12Color)),
              ],
            ),
            const Gap(8),
            Expanded(
              child: Obx(() {
                final items = controller.members;
                if (items.isEmpty) {
                  return const Center(child: Text("No members found"));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchConversationMembers(conversationId ?? '');
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final m = items[i];
                      final isOwner = (m.role?.toLowerCase() == 'owner');
                      final initials = ((m.firstName ?? '').isNotEmpty
                              ? m.firstName![0]
                              : '?') +
                          ((m.lastName ?? '').isNotEmpty ? m.lastName![0] : '');
                      final imageUrl =
                          (m.profile ?? '').isNotEmpty ? m.profile! : '';

                      return Container(
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: getImageView(
                                finalUrl: imageUrl ?? '',
                                fit: BoxFit.cover,
                                height: 48,
                                width: 48,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${m.firstName ?? ''} ${m.lastName ?? ''}"
                                          .trim(),
                                      style: TextStyle()
                                          .normal20w500
                                          .textColor(AppColor.black12Color)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isOwner
                                          ? Colors.blue.shade50
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      (m.role ?? 'member').capitalize!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isOwner
                                            ? Colors.blue
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!isOwner)
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red.shade600,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side:
                                        BorderSide(color: Colors.red.shade100),
                                  ),
                                  backgroundColor: Colors.red.shade50,
                                ),
                                icon: const Icon(Icons.person_remove_rounded,
                                    size: 16),
                                label: const Text("Remove",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12)),
                                onPressed: () async {
                                  controller.removeGroupMember(
                                      conversationId ?? "", "${m.userId}");
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
            const Gap(12),
            // Show only when name or image updated
            Obx(() {
              final imageChanged = controller.groupImagePath.value.isNotEmpty;
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: groupNameController,
                builder: (_, __, ___) {
                  final nameChanged = groupNameController.text.trim() !=
                      (initialName ?? '').trim();
                  final show = nameChanged || imageChanged;
                  if (!show) return const SizedBox.shrink();

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.black12Color,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final name = groupNameController.text.trim();
                        if ((conversationId ?? '').isEmpty) {
                          Get.snackbar("Error", "Invalid group");
                          return;
                        }
                        if (name.isEmpty) {
                          Get.snackbar("Error", "Please enter a group name");
                          return;
                        }
                        controller.editGroupConversation(conversationId ?? '',name);
                      },
                      child: const Text(
                        "Save changes",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
