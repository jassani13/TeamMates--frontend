import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class TeamCodeController extends GetxController {
  RxBool isTap = true.obs;
  Rx<TextEditingController> codeController = TextEditingController().obs;

  Future<void> checkPlayerCode() async {
    try {
      var data = FormData.fromMap({
        "player_code": codeController.value.text.toString(),
      });
      var res = await callApi(
        dio.post(
          ApiEndPoint.checkPlayerCode,
          data: data,
        ),
        true,
      );

      if (res?.statusCode == 200) {
        UserModel userModel = UserModel.fromJson(res?.data["data"]['player_data']);
        AppPref().userModel = userModel;
        AppPref().userId = userModel.userId;
        AppPref().isLogin = true;
        AppPref().role = 'player';
        Get.offAllNamed(AppRouter.bottom);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void showTeamCodeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ask for your team’s\njoin code.",
                style: TextStyle(height: 1).normal32w500s.textColor(
                      AppColor.black12Color,
                    ),
              ),
              Gap(16),
              Text(
                "Contact your teammates to get the unique code and join the team.",
                style: TextStyle().normal16w500.textColor(
                      AppColor.grey4EColor,
                    ),
              ),
              Gap(32),
              CommonAppButton(
                text: "Okay",
                onTap: () {
                  Get.back();
                },
              )
            ],
          ),
        );
      },
    );
  }
}
