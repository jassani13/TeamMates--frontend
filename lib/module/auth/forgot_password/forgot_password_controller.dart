import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class ForgotPasswordController extends GetxController {
  TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();

  Future<void> forgotPasswordApiCall() async {
    try {
      var data = {
        Param.email: emailController.text.trim().toString(),
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.forgotPassword,
          data: data,
        ),
        true,
      );

      if (res?.statusCode == 200) {
        AppToast.showAppToast(res?.data["ResponseMsg"]);
        Get.offNamed(AppRouter.otp, arguments: {
          'email': emailController.text.trim(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
