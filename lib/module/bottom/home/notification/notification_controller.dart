import 'package:base_code/model/noti_model.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class NotificationController extends GetxController {
  RxList<NotificationModel> notificationList = <NotificationModel>[].obs;
  RxBool isShimmer = false.obs;

  Future<void> getNotiApiCall() async {
    try {
      isShimmer.value = true;
      var data = {
        "user_id": AppPref().userId,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.getNotificationList,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        notificationList.value = (jsonData['data'] as List).map((e) => NotificationModel.fromJson(e)).toList();
        isShimmer.value = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      isShimmer.value = false;
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getNotiApiCall();
  }
}
