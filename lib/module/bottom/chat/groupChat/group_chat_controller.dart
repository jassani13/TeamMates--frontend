import 'package:base_code/package/screen_packages.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:path/path.dart';

import '../../../../package/config_packages.dart';

class GroupChatController extends GetxController {
  Rx<String> groupImagePath = "".obs;
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
        var jsonData = res?.data;
        String groupId = jsonData['data']['group_id'].toString();
        //userModel.value = UserModel.fromJson(jsonData['data']);
        //AppPref().userModel = userModel.value;

        //Get.back(result: userModel.value);
      }
    } catch (e) {
      debugPrint(
          "Exception - group_chat_controller.dart - createGroupChat(): $e");
    }
  }
}
