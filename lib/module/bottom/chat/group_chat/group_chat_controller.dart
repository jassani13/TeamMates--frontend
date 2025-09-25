import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:path/path.dart';

import '../chat_screen.dart';

class GroupChatController extends GetxController {
  Rx<String> groupImagePath = "".obs;
  final ImagePicker picker = ImagePicker();
  RxList<UserModel> members = <UserModel>[].obs;

  // Future<String> setMediaChatApiCall({
  //   required result,
  // }) async {
  //   try {
  //     FormData formData = FormData.fromMap({
  //       'media': [
  //         await MultipartFile.fromFile(
  //           result?.path ?? "",
  //           filename: basename(result?.path ?? ""),
  //         ),
  //       ]
  //     });
  //     var res = await callApi(
  //       dio.post(
  //         ApiEndPoint.setChatMedia,
  //         data: formData,
  //       ),
  //       false,
  //     );
  //     if (res?.statusCode == 200) {
  //       return res?.data["data"]["media_name"];
  //     }
  //     return "";
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(e);
  //     }
  //     return "";
  //   } finally {}
  // }

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

  Future<String?> createGroupChat(
      List<String> selectedPlayers, String groupName) async {
    try {
      final Map<String, dynamic> payload = {
        "owner_id": AppPref().userId,
        "title": groupName,
      };
      for (int i = 0; i < selectedPlayers.length; i++) {
        payload["member_ids[$i]"] = selectedPlayers[i];
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
        //socket.emit('getGroupChatList', AppPref().userId);
        var jsonData = res?.data;
        String conversationId = jsonData['data']['conversation_id'].toString();
        return conversationId;
      }
    } catch (e) {
      debugPrint(
          "Exception - group_chat_controller.dart - createGroupChat(): $e");
    }
    return null;
  }

  Future<void> fetchConversationMembers(String conversationId) async {
    try {
      final Map<String, dynamic> payload = {
        "conversation_id": conversationId,
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

  Future<void> editGroupConversation(
    String groupId,
    String groupName,
  ) async {
    try {
      final Map<String, dynamic> payload = {
        "owner_id": AppPref().userId,
        "conversation_id": groupId,
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
          ApiEndPoint.updateGroup,
          data: data,
        ),
        true,
      );
      debugPrint("editGroupChat response: $res");
      if (res?.statusCode == 200) {
        AppToast.showAppToast('Chat Group created successfully');
        //socket.emit('getGroupChatList', AppPref().userId);
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
        await fetchConversationMembers(groupId);
      }
    } catch (e) {
      debugPrint(
          "Exception - group_chat_controller.dart - removeGroupMember(): $e");
    }
  }
}
