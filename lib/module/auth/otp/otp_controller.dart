import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class OtpController extends GetxController {
  RxString email = ''.obs;
  TextEditingController passwordController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  RxBool isShowPassword = false.obs;

  Future<void> updatePasswordApiCall() async {
    try {
      var data = {
        "email": email.value,
        "otp": otpController.text.trim(),
        "new_password": passwordController.text.toString(),
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.updatePassword,
          data: data,
        ),
        true,
      );

      if (res?.statusCode == 200) {
        AppToast.showAppToast(res?.data["ResponseMsg"]);
        Get.back();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void onInit() {
    if (Get.arguments != null) {
      email.value = Get.arguments['email'];
    }
    super.onInit();
  }
}
