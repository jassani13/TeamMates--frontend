import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:path/path.dart';

class GroupChatController extends GetxController {
  Rx<String> groupImagePath = "".obs;
  final ImagePicker picker = ImagePicker();
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
}
