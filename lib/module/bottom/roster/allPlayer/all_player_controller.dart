import 'package:base_code/model/roster.dart';
import 'package:base_code/module/bottom/roster/roster_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/utils/common_simple_dialog.dart';

import '../../../../utils/app_toast.dart';

class AllPlayerController extends GetxController {
  Rx<RosterDetailModel> rosterDetailModel = Rx<RosterDetailModel>(RosterDetailModel());

  TextEditingController searchController = TextEditingController();
  RxBool isShimmer = false.obs;
  var searchQuery = ''.obs;

  Future<void> getRosterApiCall({required int teamId}) async {
    isShimmer.value = true;
    try {
      var data = {
        "team_id": teamId,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.getRosterDetails,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        rosterDetailModel.value = RosterDetailModel.fromJson(res?.data);
        isShimmer.value = false;
      }
    } catch (e) {
      isShimmer.value = false;

      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> removePlayerApiCall({
    required int tID,
    required int mID,
  }) async {
    try {
      var data = {
        "user_id": AppPref().userId,
        "member_id": mID,
        "team_id": tID,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.removeMemberFromTeam,
          data: data,
        ),
        true,
      );
      if (res?.statusCode == 200) {
        Get.back();

        int index = (rosterDetailModel.value.data?[0].playerTeams ?? []).indexWhere((e) => e.userId == mID);

        if (index != -1) {
          (rosterDetailModel.value.data?[0].playerTeams ?? []).removeAt(index);
          rosterDetailModel.refresh();
          Get.find<RoasterController>().refreshKey.currentState?.show();
          AppToast.showAppToast(res?.data['ResponseMsg']);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {}
  }

  Future<void> removeTeamApiCall({
    required int tID,
  }) async {
    try {
      var data = {
        "user_id": AppPref().userId,
        "team_id": tID,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.removeTeam,
          data: data,
        ),
        true,
      );
      if (res?.statusCode == 200) {
        int index = Get.find<RoasterController>().allRosterModelList.indexWhere((e) => e.teamId == tID);
        if (index != -1) {
          Get.find<RoasterController>().allRosterModelList.removeAt(index);
          Get.find<RoasterController>().allRosterModelList.refresh();
        }

        AppToast.showAppToast(res?.data['ResponseMsg']);
        Get.back();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {}
  }

  void deleteTeam(
    BuildContext context, {
    required int tID,
  }) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleCommonDialog(
            btn1Text: "Cancel",
            btn2Text: "Yes",
            btn2Tap: () {
              Get.back();
              removeTeamApiCall(tID: tID);
            },
            subTitle: "Are you sure you want to\ndelete this team?",
          );
        });
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((val) async {
      await getRosterApiCall(teamId: Get.arguments[0]);
    });
  }
}
