import 'package:base_code/model/custom_group_model.dart';
import 'package:base_code/model/roster.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'dart:io';

class GroupManagementController extends GetxController {
  // Group data
  Rx<ChatListData> groupData = ChatListData().obs;
  RxList<GroupParticipant> participants = <GroupParticipant>[].obs;
  
  // Form fields for editing
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupDescriptionController = TextEditingController();
  
  // Available participants to add
  RxList<PlayerTeams> availableParticipants = <PlayerTeams>[].obs;
  RxList<PlayerTeams> selectedNewParticipants = <PlayerTeams>[].obs;
  
  // UI states
  RxBool isLoading = false.obs;
  RxBool isUpdatingGroup = false.obs;
  RxBool isLoadingParticipants = false.obs;
  
  // Group icon
  Rx<File?> selectedGroupIcon = Rx<File?>(null);
  
  // Search functionality
  RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      groupData.value = Get.arguments['chatData'];
      _initializeGroupData();
      loadParticipants();
      loadAvailableParticipants();
    }
  }
  
  @override
  void onClose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    searchController.dispose();
    super.onClose();
  }
  
  void _initializeGroupData() {
    groupNameController.text = groupData.value.groupName ?? '';
    groupDescriptionController.text = groupData.value.groupDescription ?? '';
  }
  
  // Load current group participants
  Future<void> loadParticipants() async {
    try {
      isLoading.value = true;
      
      var data = {
        "group_id": groupData.value.groupId,
        "user_id": AppPref().userId.toString(),
      };
      
      var res = await callApi(
        dio.post(
          ApiEndPoint.getGroupParticipants,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        if (jsonData['participants'] != null) {
          var list = (jsonData['participants'] as List)
              .map((e) => GroupParticipant.fromJson(e))
              .toList();
          participants.assignAll(list);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading participants: $e');
      }
      AppToast.showAppToast('Failed to load participants');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load available participants to add
  Future<void> loadAvailableParticipants() async {
    try {
      isLoadingParticipants.value = true;
      
      var data = {
        "coach_id": AppPref().userId,
      };
      
      var res = await callApi(
        dio.post(
          ApiEndPoint.getTeamPlayers,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        var list = (jsonData['data']['player_teams'] as List)
            .map((e) => PlayerTeams.fromJson(e))
            .toList();
        
        // Filter out current participants and current user
        final currentParticipantIds = participants.map((p) => p.userId).toSet();
        list.removeWhere((player) => 
          currentParticipantIds.contains(player.userId.toString()) ||
          player.userId.toString() == AppPref().userId.toString());
        
        availableParticipants.assignAll(list);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading available participants: $e');
      }
    } finally {
      isLoadingParticipants.value = false;
    }
  }
  
  // Filter available participants based on search
  List<PlayerTeams> get filteredAvailableParticipants {
    if (searchQuery.value.isEmpty) {
      return availableParticipants;
    }
    
    return availableParticipants
        .where((participant) => 
            '${participant.firstName} ${participant.lastName}'
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()))
        .toList();
  }
  
  // Toggle participant selection for adding
  void toggleNewParticipant(PlayerTeams participant) {
    if (selectedNewParticipants.contains(participant)) {
      selectedNewParticipants.remove(participant);
    } else {
      selectedNewParticipants.add(participant);
    }
  }
  
  // Check if participant is selected for adding
  bool isNewParticipantSelected(PlayerTeams participant) {
    return selectedNewParticipants.contains(participant);
  }
  
  // Add selected participants to group
  Future<void> addParticipants() async {
    if (selectedNewParticipants.isEmpty) {
      AppToast.showAppToast('Please select participants to add');
      return;
    }
    
    try {
      isUpdatingGroup.value = true;
      
      var participantIds = selectedNewParticipants
          .map((p) => p.userId.toString())
          .toList();
      
      var data = {
        "group_id": groupData.value.groupId,
        "participant_ids": participantIds,
        "added_by": AppPref().userId.toString(),
      };
      
      var res = await callApi(
        dio.post(
          ApiEndPoint.addGroupParticipant,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        AppToast.showAppToast('Participants added successfully');
        selectedNewParticipants.clear();
        searchController.clear();
        searchQuery.value = '';
        await loadParticipants();
        await loadAvailableParticipants();
      } else {
        AppToast.showAppToast('Failed to add participants');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding participants: $e');
      }
      AppToast.showAppToast('Failed to add participants');
    } finally {
      isUpdatingGroup.value = false;
    }
  }
  
  // Remove participant from group
  Future<void> removeParticipant(GroupParticipant participant) async {
    try {
      isUpdatingGroup.value = true;
      
      var data = {
        "group_id": groupData.value.groupId,
        "participant_id": participant.userId,
        "removed_by": AppPref().userId.toString(),
      };
      
      var res = await callApi(
        dio.post(
          ApiEndPoint.removeGroupParticipant,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        AppToast.showAppToast('Participant removed successfully');
        await loadParticipants();
        await loadAvailableParticipants();
      } else {
        AppToast.showAppToast('Failed to remove participant');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing participant: $e');
      }
      AppToast.showAppToast('Failed to remove participant');
    } finally {
      isUpdatingGroup.value = false;
    }
  }
  
  // Update group details
  Future<void> updateGroupDetails() async {
    if (groupNameController.text.trim().isEmpty) {
      AppToast.showAppToast('Please enter a group name');
      return;
    }
    
    try {
      isUpdatingGroup.value = true;
      
      // Upload new icon if selected
      String iconUrl = groupData.value.groupIcon ?? '';
      if (selectedGroupIcon.value != null) {
        iconUrl = await uploadGroupIcon();
      }
      
      var data = {
        "group_id": groupData.value.groupId,
        "group_name": groupNameController.text.trim(),
        "group_description": groupDescriptionController.text.trim(),
        "group_icon": iconUrl,
        "updated_by": AppPref().userId.toString(),
      };
      
      var res = await callApi(
        dio.post(
          ApiEndPoint.updateCustomGroup,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        AppToast.showAppToast('Group updated successfully');
        
        // Update local group data
        groupData.value.groupName = groupNameController.text.trim();
        groupData.value.groupIcon = iconUrl;
        groupData.refresh();
        
        Get.back(result: groupData.value);
      } else {
        AppToast.showAppToast('Failed to update group');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating group: $e');
      }
      AppToast.showAppToast('Failed to update group');
    } finally {
      isUpdatingGroup.value = false;
    }
  }
  
  // Pick new group icon
  Future<void> pickGroupIcon() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );
      
      if (pickedFile != null) {
        selectedGroupIcon.value = File(pickedFile.path);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking group icon: $e');
      }
      AppToast.showAppToast('Failed to pick image');
    }
  }
  
  // Upload group icon
  Future<String> uploadGroupIcon() async {
    if (selectedGroupIcon.value == null) return '';
    
    try {
      FormData formData = FormData.fromMap({
        'media': [
          await MultipartFile.fromFile(
            selectedGroupIcon.value!.path,
            filename: 'group_icon_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ]
      });
      
      var res = await callApi(
        dio.post(
          ApiEndPoint.setChatMedia,
          data: formData,
        ),
        false,
      );
      
      if (res?.statusCode == 200) {
        return res?.data["data"]["media_name"] ?? '';
      }
      return '';
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading group icon: $e');
      }
      return '';
    }
  }
  
  // Remove selected icon
  void removeSelectedIcon() {
    selectedGroupIcon.value = null;
  }
  
  // Check if current user is admin
  bool get isCurrentUserAdmin {
    final currentUserId = AppPref().userId.toString();
    return groupData.value.createdBy == currentUserId ||
        participants.any((p) => p.userId == currentUserId && p.isAdmin);
  }
}