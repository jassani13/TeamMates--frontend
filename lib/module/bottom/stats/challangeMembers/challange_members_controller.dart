import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class ChallengeMembersController extends GetxController {
  final Rx<Challenge> challengeDetails = Challenge().obs;
  final RxBool isLoading = false.obs;
  final RxBool isLive = false.obs;

  int cID = 0;
  bool isHome = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = Get.arguments;
      cID = args['challenge_id'];
      isHome = args['isHome'];
      await getChallengeDetailApiCall();
    });
  }

  void deleteChallenge(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SimpleCommonDialog(
        title: "Deleting challenge?",
        subTitle: "Are you sure you want to\ndelete this challenge?",
        btn1Text: "Cancel",
        btn2Text: "Yes",
        btn2Tap: () {
          Get.back();
          deleteDetailApiCall();
        },
      ),
    );
  }

  Future<void> getChallengeDetailApiCall() async {
    await _performApiCall(
      apiCall: () async {
        final data = {
          "user_id": AppPref().userId,
          "challenge_id": cID,
        };
        final res = await callApi(
          dio.post(ApiEndPoint.getChallengeDetails, data: data),
          true,
        );
        if (res?.statusCode == 200) {
          challengeDetails.value = Challenge.fromJson(res?.data["data"]);
        }
      },
    );
  }

  Future<void> deleteDetailApiCall() async {
    await _performApiCall(
      apiCall: () async {
        final data = {
          "user_id": AppPref().userId,
          "challenge_id": cID,
        };
        final res = await callApi(
          dio.post(ApiEndPoint.removeChallenge, data: data),
          true,
        );
        if (res?.statusCode == 200) {
          _removeChallengeFromUI();
          AppToast.showAppToast(res?.data['ResponseMsg']);
          Get.back();
        }
      },
    );
  }

  Future<void> statusChangeApiCall({required String status}) async {
    await _performApiCall(
      apiCall: () async {
        final data = {
          "user_id": AppPref().userId,
          "challenge_id": cID,
          "status": status,
        };
        final res = await callApi(
          dio.post(ApiEndPoint.setChallengeStatus, data: data),
          true,
        );
        if (res?.statusCode == 200) {
          _updateChallengeStatusInUI(status);
          AppToast.showAppToast(res?.data['ResponseMsg']);
          Get.back();
        }
      },
    );
  }

  Future<void> _performApiCall({required Future<void> Function() apiCall}) async {
    try {
      isLoading.value = true;
      await apiCall();
    } catch (e) {
      if (kDebugMode) print(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _removeChallengeFromUI() {
    if (isHome) {
      final homeController = Get.find<HomeController>();
      final index = homeController.homeModel.value?.data?.challenges?.indexWhere((e) => e.challengeId == cID) ?? -1;
      if (index != -1) {
        homeController.homeModel.value?.data?.challenges?.removeAt(index);
        homeController.homeModel.refresh();
      }
    } else {
      final statsController = Get.find<StatsController>();
      final index = statsController.allChallengeDetail.value.list?.indexWhere((e) => e.challengeId == cID) ?? -1;
      if (index != -1) {
        statsController.allChallengeDetail.value.list?.removeAt(index);
        statsController.allChallengeDetail.refresh();
      }
    }
  }

  void _updateChallengeStatusInUI(String status) {
    if (isHome) {
      final homeController = Get.find<HomeController>();
      final index = homeController.homeModel.value?.data?.challenges?.indexWhere((e) => e.challengeId == cID) ?? -1;
      if (index != -1) {
        homeController.homeModel.value?.data?.challenges?[index].participateStatus = status;
        homeController.homeModel.refresh();
      }
    } else {
      final statsController = Get.find<StatsController>();
      final index = statsController.allChallengeDetail.value.list?.indexWhere((e) => e.challengeId == cID) ?? -1;
      if (index != -1) {
        statsController.allChallengeDetail.value.list?[index].participateStatus = status;
        statsController.allChallengeDetail.refresh();
        if (status == "Completed") {
          statsController.refreshKey.currentState?.show();
        }
      }
    }
  }
}
