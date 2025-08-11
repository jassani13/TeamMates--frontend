import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class GameProgressController extends GetxController {
  Rx<ActivityDetailsModel> activityDetails = ActivityDetailsModel().obs;

  RxBool isLoading = false.obs;
  RxBool isLive = false.obs;


  Future<void> deleteActivity() async {
    try {
      var data = {
        "user_id": AppPref().userId,
        "activity_id": activityDetails.value.data?.activityId ?? 0,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.deleteActivity,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        Get.back(result: "delete");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> getScheduleDetailApiCall() async {
    try {
      isLoading.value = true;
      var data = {
        "user_id": Get.arguments['user_id'],
        "activity_id": Get.arguments['activity_id'],
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.getActivityDetails,
          data: data,
        ),
        true,
      );
      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        activityDetails.value = ActivityDetailsModel.fromJson(jsonData);
        if(activityDetails.value.data?.isLive==1) {
          isLive.value = true;
        }

      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> gameLiveStatus()async{
    try {
      FormData formData = FormData.fromMap({
        "user_id": AppPref().userId,
        "activity_id": activityDetails.value.data?.activityId,
        "is_live": isLive.value == true ? 1 : 0,
      });
      var response = await callApi(dio.post(
        ApiEndPoint.updateActivity,
        data: formData,
      ));
      if (response?.statusCode == 200) {
        activityDetails.value.data?.isLive = isLive.value == true ? 1 : 0;
        activityDetails.refresh();
        ScheduleData scheduleData = ScheduleData.fromJson(response?.data['data']);
        Get.find<GlobalController>().updateScheduleData(scheduleData);
        if (isLive.value == true) {
          AppToast.showAppToast(
              "${activityDetails.value.data?.activityName} ${activityDetails.value.data?.activityType} is now live");
        } else {
          AppToast.showAppToast(
              "${activityDetails.value.data?.activityName} ${activityDetails.value.data?.activityType} is now off");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }


  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((val) async {
      await getScheduleDetailApiCall();
    });
    super.onInit();
  }
}
