import 'package:base_code/module/bottom/roster/allPlayer/all_player_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/utils/common_simple_dialog.dart';

class PlayerOverviewController extends GetxController {
  RxBool isCoach = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (AppPref().role == "coach") {
      isCoach.value = true;
    }
  }

  Future<void> removePlayerFromTeam(
    BuildContext context, {
    required int tID,
    required int mID,
  }) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleCommonDialog(
            icon: AppImage.logOut,
            btn1Text: "Cancel",
            btn2Text: "Yes",
            btn2Tap: () async {
              Get.back();
              await Get.find<AllPlayerController>().removePlayerApiCall(tID: tID, mID: mID);
            },
            subTitle: "Are you sure you want to\nremove this player from the team?",
          );
        });
  }
}
