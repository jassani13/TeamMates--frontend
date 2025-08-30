import 'package:base_code/module/bottom/chat/group_management/group_management_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class GroupManagementScreen extends StatelessWidget {
  GroupManagementScreen({super.key});

  final controller = Get.put<GroupManagementController>(GroupManagementController());

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: GestureDetector(
          onTap: hideKeyboard,
          child: Scaffold(
            backgroundColor: AppColor.white,
            appBar: AppBar(
              backgroundColor: AppColor.white,
              title: const CommonTitleText(text: 'Group Management'),
              centerTitle: false,
              bottom: TabBar(
                labelColor: AppColor.black12Color,
                unselectedLabelColor: AppColor.grey4EColor,
                indicatorColor: AppColor.black12Color,
                tabs: const [
                  Tab(text: 'Details'),
                  Tab(text: 'Members'),
                  Tab(text: 'Add Members'),
                ],
              ),
            ),
            body: Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _buildGroupDetailsTab(),
                      _buildMembersTab(),
                      _buildAddMembersTab(),
                    ],
                  )),
          ),
        ),
      );

  Widget _buildGroupDetailsTab() => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Information',
              style: TextStyle().normal18w500.textColor(AppColor.black12Color),
            ),
            const Gap(16),
            
            // Group icon
            _buildGroupIconEditor(),
            const Gap(20),
            
            // Group name
            CommonTextField(
              controller: controller.groupNameController,
              hintText: 'Group Name',
              labelText: 'Group Name *',
              enabled: controller.isCurrentUserAdmin,
            ),
            const Gap(16),
            
            // Group description
            CommonTextField(
              controller: controller.groupDescriptionController,
              hintText: 'Group Description',
              labelText: 'Group Description',
              maxLines: 3,
              enabled: controller.isCurrentUserAdmin,
            ),
            const Gap(20),
            
            // Group stats
            _buildGroupStats(),
            
            if (controller.isCurrentUserAdmin) ...[
              const Gap(30),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isUpdatingGroup.value 
                          ? null 
                          : controller.updateGroupDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.black12Color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isUpdatingGroup.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Update Group',
                              style: TextStyle().normal16w500.textColor(Colors.white),
                            ),
                    ),
                  )),
            ],
          ],
        ),
      );

  Widget _buildGroupIconEditor() => Row(
        children: [
          Obx(() => GestureDetector(
                onTap: controller.isCurrentUserAdmin ? controller.pickGroupIcon : null,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColor.greyF6Color,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: AppColor.greyF6Color),
                  ),
                  child: controller.selectedGroupIcon.value != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.file(
                            controller.selectedGroupIcon.value!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : controller.groupData.value.groupIcon?.isNotEmpty == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: getImageView(
                                finalUrl: controller.groupData.value.groupIcon!,
                                fit: BoxFit.cover,
                                errorWidget: const Icon(Icons.group, size: 32),
                              ),
                            )
                          : const Icon(
                              Icons.group,
                              color: AppColor.grey4EColor,
                              size: 32,
                            ),
                ),
              )),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Group Icon',
                  style: TextStyle().normal16w500.textColor(AppColor.black12Color),
                ),
                const Gap(4),
                Text(
                  controller.isCurrentUserAdmin 
                      ? 'Tap to change group icon'
                      : 'Group icon (read-only)',
                  style: TextStyle().normal14w400.textColor(AppColor.grey4EColor),
                ),
                if (controller.selectedGroupIcon.value != null && controller.isCurrentUserAdmin) ...[
                  const Gap(8),
                  GestureDetector(
                    onTap: controller.removeSelectedIcon,
                    child: Text(
                      'Remove New Icon',
                      style: TextStyle().normal14w500.textColor(Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );

  Widget _buildGroupStats() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.greyF6Color.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.people, color: AppColor.grey4EColor, size: 20),
                Gap(8),
                Text(
                  'Total Members',
                  style: TextStyle().normal16w400.textColor(AppColor.grey4EColor),
                ),
                Spacer(),
                Obx(() => Text(
                      '${controller.participants.length + 1}', // +1 for admin
                      style: TextStyle().normal16w500.textColor(AppColor.black12Color),
                    )),
              ],
            ),
            Gap(8),
            Row(
              children: [
                Icon(Icons.admin_panel_settings, color: AppColor.grey4EColor, size: 20),
                Gap(8),
                Text(
                  'Group Admin',
                  style: TextStyle().normal16w400.textColor(AppColor.grey4EColor),
                ),
                Spacer(),
                Text(
                  controller.isCurrentUserAdmin ? 'You' : 'Other',
                  style: TextStyle().normal16w500.textColor(AppColor.black12Color),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildMembersTab() => Obx(() => controller.participants.isEmpty
      ? const Center(
          child: Text('No participants loaded'),
        )
      : ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.participants.length,
          separatorBuilder: (context, index) => const Gap(8),
          itemBuilder: (context, index) {
            final participant = controller.participants[index];
            return _buildMemberTile(participant);
          },
        ));

  Widget _buildMemberTile(GroupParticipant participant) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.greyF6Color),
        ),
        child: Row(
          children: [
            ClipOval(
              child: getImageView(
                finalUrl: participant.profile ?? '',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorWidget: const Icon(Icons.person, size: 48),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        participant.fullName,
                        style: TextStyle().normal16w500.textColor(AppColor.black12Color),
                      ),
                      if (participant.isAdmin) ...[
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColor.black12Color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Admin',
                            style: TextStyle().normal12w500.textColor(AppColor.black12Color),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (participant.joinedAt != null) ...[
                    const Gap(4),
                    Text(
                      'Joined ${DateUtilities.getTimeAgo(participant.joinedAt!)}',
                      style: TextStyle().normal14w400.textColor(AppColor.grey4EColor),
                    ),
                  ],
                ],
              ),
            ),
            if (controller.isCurrentUserAdmin && !participant.isAdmin) ...[
              const Gap(12),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'remove') {
                    _showRemoveParticipantDialog(participant);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle, color: Colors.red, size: 20),
                        Gap(8),
                        Text('Remove', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert, color: AppColor.grey4EColor),
              ),
            ],
          ],
        ),
      );

  Widget _buildAddMembersTab() => controller.isCurrentUserAdmin
      ? Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search field
                  CommonTextField(
                    controller: controller.searchController,
                    hintText: 'Search participants to add...',
                    prefixIcon: const Icon(Icons.search, color: AppColor.grey4EColor),
                    onChange: (value) => controller.searchQuery.value = value?.toLowerCase() ?? '',
                  ),
                  const Gap(16),
                  
                  // Selected participants
                  Obx(() => controller.selectedNewParticipants.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Selected to Add',
                                  style: TextStyle().normal16w500.textColor(AppColor.black12Color),
                                ),
                                Spacer(),
                                Text(
                                  '${controller.selectedNewParticipants.length} selected',
                                  style: TextStyle().normal14w400.textColor(AppColor.grey4EColor),
                                ),
                              ],
                            ),
                            const Gap(8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: controller.selectedNewParticipants
                                  .map((participant) => _buildSelectedParticipantChip(participant))
                                  .toList(),
                            ),
                            const Gap(16),
                            SizedBox(
                              width: double.infinity,
                              child: Obx(() => ElevatedButton(
                                    onPressed: controller.isUpdatingGroup.value 
                                        ? null 
                                        : controller.addParticipants,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.black12Color,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: controller.isUpdatingGroup.value
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Add Selected Members',
                                            style: TextStyle().normal16w500.textColor(Colors.white),
                                          ),
                                  )),
                            ),
                            const Gap(16),
                            const Divider(),
                            const Gap(16),
                          ],
                        )
                      : const SizedBox()),
                ],
              ),
            ),
            
            // Available participants
            Expanded(
              child: Obx(() {
                final participants = controller.filteredAvailableParticipants;
                
                if (controller.isLoadingParticipants.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (participants.isEmpty) {
                  return Center(
                    child: Text(
                      'No available participants to add',
                      style: TextStyle().normal16w400.textColor(AppColor.grey4EColor),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: participants.length,
                  separatorBuilder: (context, index) => const Gap(4),
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return _buildAvailableParticipantTile(participant);
                  },
                );
              }),
            ),
          ],
        )
      : const Center(
          child: Text(
            'Only group admins can add members',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );

  Widget _buildSelectedParticipantChip(PlayerTeams participant) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColor.black12Color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: getImageView(
                finalUrl: participant.profile ?? '',
                width: 20,
                height: 20,
                fit: BoxFit.cover,
                errorWidget: const Icon(Icons.person, size: 20),
              ),
            ),
            const Gap(6),
            Text(
              '${participant.firstName} ${participant.lastName}',
              style: TextStyle().normal14w500.textColor(AppColor.black12Color),
            ),
            const Gap(4),
            GestureDetector(
              onTap: () => controller.toggleNewParticipant(participant),
              child: const Icon(Icons.close, size: 16, color: AppColor.grey4EColor),
            ),
          ],
        ),
      );

  Widget _buildAvailableParticipantTile(PlayerTeams participant) => Obx(() {
        final isSelected = controller.isNewParticipantSelected(participant);
        
        return GestureDetector(
          onTap: () => controller.toggleNewParticipant(participant),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppColor.black12Color.withOpacity(0.05) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected 
                  ? Border.all(color: AppColor.black12Color.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                ClipOval(
                  child: getImageView(
                    finalUrl: participant.profile ?? '',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorWidget: const Icon(Icons.person, size: 48),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${participant.firstName} ${participant.lastName}',
                        style: TextStyle().normal16w500.textColor(AppColor.black12Color),
                      ),
                      if (participant.email != null) ...[
                        const Gap(2),
                        Text(
                          participant.email!,
                          style: TextStyle().normal14w400.textColor(AppColor.grey4EColor),
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap(12),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.black12Color : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColor.black12Color : AppColor.grey4EColor,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      });

  void _showRemoveParticipantDialog(GroupParticipant participant) {
    Get.defaultDialog(
      title: 'Remove Member',
      titleStyle: TextStyle().normal20w500.textColor(AppColor.black12Color),
      middleText: 'Are you sure you want to remove ${participant.fullName} from this group?',
      middleTextStyle: TextStyle().normal16w400.textColor(AppColor.grey4EColor),
      textConfirm: 'Remove',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: AppColor.black12Color,
      onConfirm: () {
        Get.back();
        controller.removeParticipant(participant);
      },
    );
  }
}