import 'package:base_code/module/auth/forgot_password/forgot_password_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final forgotPasswordController = Get.put<ForgotPasswordController>(ForgotPasswordController());
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(),
      child: Scaffold(
        appBar: AppBar(),

        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(Platform.isAndroid ? ScreenUtil().statusBarHeight + 20 : ScreenUtil().statusBarHeight + 10),
                    Align(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        AppImage.login,
                      ),
                    ),
                    Gap(48),
                    buildLogin(context),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildLogin(context) {
    return Form(
      key: formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Forget Password",
              style: TextStyle().normal22w200.textColor(
                    AppColor.black12Color,
                  ),
            ),
          ),
          Gap(12),
          Text(
            "Provide your account's email for which ypu want to reset your password",
            style: TextStyle().normal16w500.textColor(
              AppColor.black12Color,
            ),
            textAlign: TextAlign.center,
          ),
          Gap(24),
          CommonTextField(
              autofillHints: const [
                AutofillHints.email,
              ],
              inputFormatters: [
                NoSpaceFormatter()
              ],
              textInputAction: TextInputAction.done,
              controller: forgotPasswordController.emailController,
              hintText: "E-mail",
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if ((val ?? "").isEmpty) {
                  return "Please enter your email address";
                } else if (!(val ?? "").isEmail) {
                  return "Please enter your valid email address";
                } else {
                  return null;
                }
              }),
          Gap(24),
          CommonAppButton(
            text: "Next",
            onTap: () async {
              hideKeyboard();

              if (formKey1.currentState!.validate()) {
                await forgotPasswordController.forgotPasswordApiCall();
              }
            },
          ),
        ],
      ),
    );
  }
}
