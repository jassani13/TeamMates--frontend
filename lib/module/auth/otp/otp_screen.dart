import 'package:base_code/module/auth/otp/otp_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class OtpScreen extends StatelessWidget {
  OtpScreen({super.key});

  final otpController = Get.put<OtpController>(OtpController());
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
                    Gap(20),
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
              "Verify OTP & Set New Password",
              style: TextStyle().normal20w500.textColor(
                    AppColor.black12Color,
                  ),
            ),
          ),
          Gap(12),
          Text(
            "We have sent the verification code to your email address",
            style: TextStyle().normal16w500.textColor(
              AppColor.black12Color,
            ),
            textAlign: TextAlign.center,
          ),
          Gap(24),
          CommonTextField(
            keyboardType: TextInputType.number,
            autofillHints: [AutofillHints.oneTimeCode],
            inputFormatters: [
              NoSpaceFormatter(),
              LengthLimitingTextInputFormatter(6),
              FilteringTextInputFormatter.digitsOnly,
            ],
            controller: otpController.otpController,
            hintText: "OTP",
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "Please enter OTP";
              } else if (val.length != 6) {
                return "OTP must be exactly 6 digits";
              }
              return null;
            },
          ),
          Gap(24),
          Obx(
            () => CommonTextField(
              controller: otpController.passwordController,
              hintText: "New Password",
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              obscureText: !otpController.isShowPassword.value,
              validator: (val) {
                if ((val ?? "").trim().isEmpty) {
                  return "Please enter your new password";
                } else if ((val ?? "").length < 5) {
                  return "Password must be at least 5 characters";
                } else if (!isValidPassword(val)) {
                  return "Password must contain at least one alpha and one special character";
                }
                return null;
              },
              suffixIcon: GestureDetector(
                onTap: () {
                  otpController.isShowPassword.value = !otpController.isShowPassword.value;
                },
                child: Icon(
                  otpController.isShowPassword.value ? Icons.remove_red_eye : Icons.visibility_off,
                  color: AppColor.grey4EColor,
                  size: 20,
                ),
              ),
              inputFormatters: [NoSpaceFormatter()],
              autofillHints: const [
                AutofillHints.password,
              ],
            ),
          ),
          Gap(24),
          CommonAppButton(
            text: "Continue",
            onTap: () async {
              hideKeyboard();

              if (formKey1.currentState!.validate()) {
                await otpController.updatePasswordApiCall();
              }
            },
          ),
        ],
      ),
    );
  }
}
