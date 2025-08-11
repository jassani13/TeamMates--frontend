import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class AccountController extends GetxController {
  RxBool isNoti = false.obs;
  Rx<UserModel> userModel = Rx<UserModel>(UserModel());

  Future<void> deleteAccount() async {
    try {
      FormData formData = FormData.fromMap({
        "user_id": AppPref().userId,
      });
      var response = await callApi(dio.post(
        ApiEndPoint.deleteAccount,
        data: formData,
      ));
      if (response?.statusCode == 200) {
        AppPref().clear();
        AppPref().isFirstTime = true;
        Get.offAllNamed(AppRouter.login);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    if (AppPref().userModel != null) {
      userModel.value = AppPref().userModel ?? UserModel();
    }
    super.onInit();
  }
}
