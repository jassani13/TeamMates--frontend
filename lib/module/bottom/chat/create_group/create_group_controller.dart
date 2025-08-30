import 'package:base_code/model/custom_group_model.dart';
import 'package:base_code/model/roster.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'dart:io';

class CreateGroupController extends GetxController {
  // Form fields
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupDescriptionController = TextEditingController();
  
  // Selected participants (minimum 3 including creator)
  RxList<PlayerTeams> selectedParticipants = <PlayerTeams>[].obs;
  RxList<PlayerTeams> availableParticipants = <PlayerTeams>[].obs;
  
  // Group settings
  Rx<File?> selectedGroupIcon = Rx<File?>(null);
  RxString groupIconUrl = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isCreatingGroup = false.obs;
  
  // Search functionality
  RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    loadAvailableParticipants();
  }
  
  @override
  void onClose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    searchController.dispose();
    super.onClose();
  }
  
  // Load available participants from teams
  Future<void> loadAvailableParticipants() async {
    try {
      isLoading.value = true;
      
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
        
        // Filter out current user if they're in the list
        list.removeWhere((player) => player.userId.toString() == AppPref().userId.toString());
        
        availableParticipants.assignAll(list);
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
  
  // Filter participants based on search query
  List<PlayerTeams> get filteredParticipants {
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
  
  // Toggle participant selection
  void toggleParticipant(PlayerTeams participant) {
    if (selectedParticipants.contains(participant)) {
      selectedParticipants.remove(participant);
    } else {
      selectedParticipants.add(participant);
    }
  }
  
  // Check if participant is selected
  bool isParticipantSelected(PlayerTeams participant) {
    return selectedParticipants.contains(participant);
  }
  
  // Validate form before creation
  bool validateForm() {
    if (groupNameController.text.trim().isEmpty) {
      AppToast.showAppToast('Please enter a group name');
      return false;
    }
    
    if (selectedParticipants.length < 2) {
      AppToast.showAppToast('Please select at least 2 other participants');
      return false;
    }
    
    return true;
  }
  
  // Pick group icon from gallery
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
  
  // Upload group icon and get URL
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
  
  // Create the group
  Future<void> createGroup() async {
    if (!validateForm()) return;
    
    try {
      isCreatingGroup.value = true;
      
      // Upload icon if selected
      String iconUrl = '';
      if (selectedGroupIcon.value != null) {
        iconUrl = await uploadGroupIcon();
      }
      
      // Prepare participant IDs
      List<String> participantIds = selectedParticipants
          .map((p) => p.userId.toString())
          .toList();
      
      // Add current user as admin
      participantIds.add(AppPref().userId.toString());
      
      var data = {
        "group_name": groupNameController.text.trim(),
        "group_description": groupDescriptionController.text.trim(),
        "group_icon": iconUrl,
        "created_by": AppPref().userId.toString(),
        "participant_ids": participantIds,
      };
      
      var res = await callApi(
        dio.post(
          ApiEndPoint.createCustomGroup,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        AppToast.showAppToast('Group created successfully');
        
        // Navigate to the new group chat
        var groupData = ChatListData(
          groupId: res?.data["data"]["group_id"]?.toString(),
          groupName: groupNameController.text.trim(),
          groupIcon: iconUrl,
          chatType: 'custom_group',
        );
        
        Get.back(); // Close create group screen
        Get.toNamed(AppRouter.grpChat, arguments: {'chatData': groupData});
      } else {
        AppToast.showAppToast('Failed to create group');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating group: $e');
      }
      AppToast.showAppToast('Failed to create group');
    } finally {
      isCreatingGroup.value = false;
    }
  }
  
  // Remove selected icon
  void removeSelectedIcon() {
    selectedGroupIcon.value = null;
  }
}