import 'package:base_code/package/screen_packages.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:path/path.dart';

import '../../../../package/config_packages.dart';
import '../chat_screen.dart';

class GroupChatController extends GetxController {
  Rx<String> groupImagePath = "".obs;
  RxList<UserModel> members = <UserModel>[].obs;
  final picker = ImagePicker();

  Future getImage({required ImageSource source}) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      groupImagePath.value = pickedFile.path;
      //documentImage.value = File(pickedFile.path);
    }
  }

  Future showOptions(context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text(
              'Photo Gallery',
              style: TextStyle().normal14w500.textColor(AppColor.black12Color),
            ),
            onPressed: () {
              Get.back();
              getImage(source: ImageSource.gallery);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              'Camera',
              style: TextStyle().normal14w500.textColor(AppColor.black12Color),
            ),
            onPressed: () {
              Get.back();
              getImage(source: ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }

  Future<void> createGroupChat(
      List<String> selectedPlayers, String groupName) async {
    try {
      final Map<String, dynamic> payload = {
        "owner_id": AppPref().userId,
        "name": groupName,
      };
      for (int i = 0; i < selectedPlayers.length; i++) {
        payload["members[$i]"] = selectedPlayers[i];
      }
      final data = FormData.fromMap({
        ...payload,
        if (groupImagePath.value.isNotEmpty) // make sure it's a String path
          'image': await MultipartFile.fromFile(
            groupImagePath.value,
            filename: basename(groupImagePath.value),
          ),
      });
      var res = await callApi(
        dio.post(
          ApiEndPoint.createGroupChat,
          data: data,
        ),
        true,
      );
      debugPrint("createGroupChat response: $res");
      if (res?.statusCode == 200) {
        AppToast.showAppToast('Chat Group created successfully');
        socket.emit('getGroupChatList', AppPref().userId);
        //var jsonData = res?.data;
        //String groupId = jsonData['data']['group_id'].toString();
        //userModel.value = UserModel.fromJson(jsonData['data']);
        //AppPref().userModel = userModel.value;

        //Get.back(result: userModel.value);
      }
    } catch (e) {
      debugPrint(
          "Exception - group_chat_controller.dart - createGroupChat(): $e");
    }
  }

  Future<void> editGroupChat(String groupName, String groupId) async {
    try {
      final Map<String, dynamic> payload = {
        "owner_id": AppPref().userId,
        "group_id": groupId,
        if (groupName.isNotEmpty) "name": groupName,
      };
      final data = FormData.fromMap({
        ...payload,
        if (groupImagePath.value.isNotEmpty)
          'image': await MultipartFile.fromFile(
            groupImagePath.value,
            filename: basename(groupImagePath.value),
          ),
      });
      var res = await callApi(
        dio.post(
          ApiEndPoint.editGroupChat,
          data: data,
        ),
        true,
      );
      debugPrint("editGroupChat response: $res");
      if (res?.statusCode == 200) {
        AppToast.showAppToast('Chat Group created successfully');
        socket.emit('getGroupChatList', AppPref().userId);
        //var jsonData = res?.data;
        //String groupId = jsonData['data']['group_id'].toString();
        //userModel.value = UserModel.fromJson(jsonData['data']);
        //AppPref().userModel = userModel.value;

        //Get.back(result: userModel.value);
      }
    } catch (e) {
      debugPrint(
          "Exception - group_chat_controller.dart - createGroupChat(): $e");
    }
  }

  Future<void> getGroupMembers(String groupId) async {
    try {
      final Map<String, dynamic> payload = {
        "group_id": groupId,
        "owner_id": AppPref().userId,
      };

      var res = await callApi(
        dio.post(
          ApiEndPoint.getGroupMembers,
          data: payload,
        ),
        true,
      );
      if (res?.statusCode == 200) {
        final map = (res?.data as Map<String, dynamic>);
        final list = (map['data'] as List<dynamic>);
        members.assignAll(
            list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)));
      }
    } catch (e) {
      debugPrint(
          "Exception - group_chat_controller.dart - getGroupMembers(): $e");
      members.clear();
    }
  }
  Future<void> addMembersToGroup({
    required String groupId,
    required List<String> memberIds,
  }) async {
    try {
      final map = <String, dynamic>{
        'group_id': groupId,
        'added_by': AppPref().userId,
      };
      for (int i = 0; i < memberIds.length; i++) {
        map['members[$i]'] = memberIds[i];
      }
      final form = FormData.fromMap(map);
      final res = await callApi(dio.post(ApiEndPoint.addGroupMembers, data: form), true);
      if (res?.statusCode == 200) {
        AppToast.showAppToast('Members added');
        // Optionally refresh members list:
        await getGroupMembers(groupId);
      } else {
        AppToast.showAppToast('Failed to add members');
      }
    } catch (e) {
      debugPrint('Exception - addMembersToGroup(): $e');
      AppToast.showAppToast('Error adding members');
    }
  }
  Future<void> removeGroupMember(String groupId, String memberId) async {
    try {
      final Map<String, dynamic> payload = {
        "group_id": groupId,
        "member_id": memberId,
        "owner_id": AppPref().userId,
      };

      var res = await callApi(
        dio.post(
          ApiEndPoint.removeGroupMember,
          data: payload,
        ),
        true,
      );
      if (res?.statusCode == 200) {
        AppToast.showAppToast('Member removed successfully');
        await getGroupMembers(groupId);
      }
    } catch (e) {
      debugPrint(
          "Exception - group_chat_controller.dart - removeGroupMember(): $e");
    }
  }
}
