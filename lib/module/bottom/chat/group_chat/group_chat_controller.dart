import 'package:base_code/model/conversation_item.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:path/path.dart';

import '../chat_screen.dart';

class GroupChatController extends GetxController {
  Rx<String> groupImagePath = "".obs;
  final ImagePicker picker = ImagePicker();
  RxList<UserModel> members = <UserModel>[].obs;

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

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        debugPrint("createGroupChat jsonData: $jsonData");
        ConversationItem conv =
            ConversationItem.fromJson(jsonData['conversation']);
        AppToast.showAppToast(
            jsonData['message'] ?? 'Chat Group created successfully');
        Get.put(SearchChatController()).selectedPlayersIDsForGroupChat.clear();
        Get.back();
        socket.emit('get_conversations', {'user_id': AppPref().userId});
        Get.toNamed(
          AppRouter.conversationDetailScreen,
          arguments: {
            'conversation': conv,
          },
        );
      }
    } catch (e) {
      debugPrint(
          "Exception - group_chat_controller.dart - createGroupChat(): $e");
    }
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

      if (res?.statusCode == 200) {
        AppToast.showAppToast('Chat Group created successfully');
        socket.emit('get_conversations', {'user_id': AppPref().userId});

      }
    } catch (e) {
      debugPrint(
          "Exception - group_chat_controller.dart - createGroupChat(): $e");
    }
  }

  Future<void> removeGroupMember(String conversationId, String memberId) async {
    try {
      final Map<String, dynamic> payload = {
        "conversation_id": conversationId,
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
        await fetchConversationMembers(conversationId);
      }
    } catch (e) {
      debugPrint(
          "Exception - group_chat_controller.dart - removeGroupMember(): $e");
    }
  }

  Future<void> addGroupMembers(
      List<String> playerIDs, String conversationID) async {
    try {
      final Map<String, dynamic> payload = {
        "conversation_id": conversationID,
        "owner_id": AppPref().userId,
      };
      for (int i = 0; i < playerIDs.length; i++) {
        payload["member_ids[$i]"] = playerIDs[i];
      }
      final data = FormData.fromMap({
        ...payload,
      });

      var res = await callApi(
        dio.post(
          ApiEndPoint.addGroupMembers,
          data: data,
        ),
        true,
      );

      debugPrint("addGroupMembers response: $res");
      if (res?.statusCode == 200) {
        AppToast.showAppToast('Member added successfully');
        await fetchConversationMembers(payload['conversation_id'].toString());
      }
    } catch (e) {
      debugPrint(
          "Exception - group_chat_controller.dart - addGroupMember(): $e");
    }
  }
}
