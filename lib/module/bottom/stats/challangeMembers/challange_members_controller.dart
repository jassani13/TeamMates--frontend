import 'package:base_code/model/challenge_model.dart';
import 'package:base_code/module/bottom/home/home_controller.dart';
import 'package:base_code/module/bottom/stats/stats_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/utils/common_simple_dialog.dart';

class ChallengeMembersController extends GetxController {
  Rx<Challenge> challengeDetails = Challenge().obs;

  RxBool isLoading = false.obs;
  RxBool isLive = false.obs;

  int cID = 0;
  bool isHome = false;

  void deleteChallenge(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleCommonDialog(
            btn1Text: "Cancel",
            btn2Text: "Yes",
            title: "Deleting challenge?",
            btn2Tap: () {
              Get.back();
              deleteDetailApiCall();
            },
            subTitle: "Are you sure you want to\ndelete this challenge?",
          );
        });
  }

  Future<void> getChallengeDetailApiCall() async {
    try {
      isLoading.value = true;
      var data = {
        "user_id": AppPref().userId,
        "challenge_id": cID,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.getChallengeDetails,
          data: data,
        ),
        true,
      );
      if (res?.statusCode == 200) {
        var jsonData = res?.data["data"];
        challengeDetails.value = Challenge.fromJson(jsonData);

        isLoading.value = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDetailApiCall() async {
    try {
      isLoading.value = true;
      var data = {
        "user_id": AppPref().userId,
        "challenge_id": cID,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.removeChallenge,
          data: data,
        ),
        true,
      );
      if (res?.statusCode == 200) {
        if(isHome==false){
          int index = (Get.find<StatsController>()
              .allChallengeDetail.value.list??[])
              .indexWhere((e) => e.challengeId == cID);
          Get.find<StatsController>().allChallengeDetail.value.list?.removeAt(index);
          Get.find<StatsController>().allChallengeDetail.refresh();
        }
        else{
          int index = (Get.find<HomeController>()
              .homeModel.value?.data?.challenges??[])
              .indexWhere((e) => e.challengeId == cID);
          Get.find<HomeController>().homeModel.value?.data?.challenges?.removeAt(index);
          Get.find<HomeController>().homeModel.refresh();
        }

        AppToast.showAppToast(res?.data['ResponseMsg']);
        Get.back();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> statusChangeApiCall({
    required String status,
  }) async {
    try {
      isLoading.value = true;
      var data = {
        "user_id": AppPref().userId,
        "challenge_id": cID,
        "status": status,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.setChallengeStatus,
          data: data,
        ),
        true,
      );
      if (res?.statusCode == 200) {
        if(isHome==false){
          int index= (Get.find<StatsController>().allChallengeDetail.value.list??[]).indexWhere((e)=>e.challengeId==cID);
          Get.find<StatsController>().allChallengeDetail.value.list?[index]
              .participateStatus =status;
          Get.find<StatsController>().allChallengeDetail.refresh();
          if(status=="Completed"){
            Get.find<StatsController>().refreshKey.currentState?.show();
          }
        }
        else{
          int index = (Get.find<HomeController>()
              .homeModel.value?.data?.challenges??[])
              .indexWhere((e) => e.challengeId == cID);
          Get.find<HomeController>()
              .homeModel.value?.data?.challenges?[index]
              .participateStatus =status;
          Get.find<HomeController>().homeModel.refresh();
        }

        AppToast.showAppToast(res?.data['ResponseMsg']);
        Get.back();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((val) async {
      cID = Get.arguments['challenge_id'];
      isHome = Get.arguments['isHome'];
      await getChallengeDetailApiCall();
    });
    super.onInit();
  }
}
