import 'package:base_code/module/bottom/chat/create_group/create_group_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class CreateGroupScreen extends StatelessWidget {
  CreateGroupScreen({super.key});

  final controller = Get.put<CreateGroupController>(CreateGroupController());

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: hideKeyboard,
        child: Scaffold(
          backgroundColor: AppColor.white,
          appBar: AppBar(
            backgroundColor: AppColor.white,
            title: const CommonTitleText(text: 'Create Group'),
            centerTitle: false,
            actions: [
              Obx(() => TextButton(
                    onPressed: controller.isCreatingGroup.value 
                        ? null 
                        : controller.createGroup,
                    child: controller.isCreatingGroup.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Create',
                            style: TextStyle().normal16w500.textColor(AppColor.black12Color),
                          ),
                  )),
              const Gap(16),
            ],
          ),
          body: Obx(() => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGroupDetails(),
                      const Gap(24),
                      _buildParticipantSelection(),
                    ],
                  ),
                )),
        ),
      );

  Widget _buildGroupDetails() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group Details',
            style: TextStyle().normal18w500.textColor(AppColor.black12Color),
          ),
          const Gap(16),
          
          // Group icon selection
          _buildGroupIconSelector(),
          const Gap(16),
          
          // Group name
          CommonTextField(
            controller: controller.groupNameController,
            hintText: 'Group Name',
            labelText: 'Group Name *',
          ),
          const Gap(16),
          
          // Group description (optional)
          CommonTextField(
            controller: controller.groupDescriptionController,
            hintText: 'Group Description (Optional)',
            labelText: 'Group Description',
            maxLines: 3,
          ),
        ],
      );

  Widget _buildGroupIconSelector() => Row(
        children: [
          Obx(() => GestureDetector(
                onTap: controller.pickGroupIcon,
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
                      : const Icon(
                          Icons.camera_alt,
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
                  'Tap to add a group icon',
                  style: TextStyle().normal14w400.textColor(AppColor.grey4EColor),
                ),
                if (controller.selectedGroupIcon.value != null) ...[
                  const Gap(8),
                  GestureDetector(
                    onTap: controller.removeSelectedIcon,
                    child: Text(
                      'Remove Icon',
                      style: TextStyle().normal14w500.textColor(Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );

  Widget _buildParticipantSelection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Add Participants',
                style: TextStyle().normal18w500.textColor(AppColor.black12Color),
              ),
              const Spacer(),
              Obx(() => Text(
                    '${controller.selectedParticipants.length} selected',
                    style: TextStyle().normal14w400.textColor(AppColor.grey4EColor),
                  )),
            ],
          ),
          const Gap(8),
          Text(
            'Select at least 2 participants to create a group',
            style: TextStyle().normal14w400.textColor(AppColor.grey4EColor),
          ),
          const Gap(16),
          
          // Search field
          CommonTextField(
            controller: controller.searchController,
            hintText: 'Search participants...',
            prefixIcon: const Icon(Icons.search, color: AppColor.grey4EColor),
            onChange: (value) => controller.searchQuery.value = value?.toLowerCase() ?? '',
          ),
          const Gap(16),
          
          // Selected participants preview
          Obx(() => controller.selectedParticipants.isNotEmpty
              ? _buildSelectedParticipants()
              : const SizedBox()),
              
          // Available participants
          _buildAvailableParticipants(),
        ],
      );

  Widget _buildSelectedParticipants() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Participants',
            style: TextStyle().normal16w500.textColor(AppColor.black12Color),
          ),
          const Gap(8),
          Container(
            constraints: const BoxConstraints(maxHeight: 120),
            child: Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.selectedParticipants
                      .map((participant) => _buildSelectedParticipantChip(participant))
                      .toList(),
                )),
          ),
          const Gap(16),
          const Divider(),
          const Gap(16),
        ],
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
              onTap: () => controller.toggleParticipant(participant),
              child: const Icon(Icons.close, size: 16, color: AppColor.grey4EColor),
            ),
          ],
        ),
      );

  Widget _buildAvailableParticipants() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Participants',
            style: TextStyle().normal16w500.textColor(AppColor.black12Color),
          ),
          const Gap(12),
          Obx(() {
            final participants = controller.filteredParticipants;
            
            if (participants.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No participants available',
                    style: TextStyle().normal16w400.textColor(AppColor.grey4EColor),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: participants.length,
              separatorBuilder: (context, index) => const Gap(4),
              itemBuilder: (context, index) {
                final participant = participants[index];
                return _buildParticipantTile(participant);
              },
            );
          }),
        ],
      );

  Widget _buildParticipantTile(PlayerTeams participant) => Obx(() {
        final isSelected = controller.isParticipantSelected(participant);
        
        return GestureDetector(
          onTap: () => controller.toggleParticipant(participant),
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
}