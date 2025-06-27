import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter/foundation.dart';

class SelectRoleController extends GetxController {
  Rx<Role> selectedRole = Rx<Role>(Role());
  List<Role> roleList = <Role>[
    Role(
      role: 'coach',
      image: AppImage.role1,
      title: "Coach or Manager",
      description: "Manage team events, communication, and performance with ease",
    ),
    Role(
      role: 'team',
      image: AppImage.role2,
      title: "Team Member",
      description: "Stay updated with events, track your progress, and engage with your team",
    ),
    Role(
      role: 'family',
      image: AppImage.role3,
      title: "Family Member",
      description: "Stay updated on your child's game and event schedule to never miss a moment!",
    ),
  ];

  Future<void> updateRole() async {
    try {
      if ((selectedRole.value.role ?? "").isEmpty) {
        AppToast.showAppToast("Please select role first",);
        return;
      }
      var data = FormData.fromMap({
        "user_id": AppPref().userId,
        "role": selectedRole.value.role,
      });
      var res = await callApi(
        dio.post(
          ApiEndPoint.updateProfile,
          data: data,
        ),
        true,
      );

      if (res?.statusCode == 200) {
        UserModel userModel = UserModel.fromJson(res?.data["data"]);
        AppPref().userModel = userModel;
        AppPref().role = selectedRole.value.role;

        // Check subscription status after role update
        try {
          final purchaseController = Get.find<InAppPurchaseController>();
          await purchaseController.checkActiveSubscription();
        } catch (e) {
          if (kDebugMode) {
            print("Error checking subscription after role update: $e");
          }
        }

        if (AppPref().role != 'family') {
          AppPref().isLogin = true;
          Get.offAllNamed(AppRouter.creatingTeam);
        } else {
          Get.offNamed(AppRouter.teamCode);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
