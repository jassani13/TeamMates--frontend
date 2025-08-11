import 'package:base_code/data/network/api_client.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final loginController = Get.put<LoginController>(LoginController());
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(),
      child: Scaffold(
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
                      alignment: Alignment.centerRight,
                      child: SvgPicture.asset(
                        AppImage.login,
                        height: 120,
                      ),
                    ),
                    Gap(16),
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                loginController.selectedMethod.value = false;
                              },
                              behavior: HitTestBehavior.translucent,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: loginController.selectedMethod.value == false ? AppColor.black : Colors.transparent,
                                    ),
                                  ),
                                ),
                                child: Center(
                                    child: Text(
                                  "Create Account",
                                  style: TextStyle().normal22w500.textColor(AppColor.black12Color),
                                )),
                              ),
                            ),
                          ),
                          Gap(20),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                loginController.selectedMethod.value = true;
                              },
                              behavior: HitTestBehavior.translucent,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: loginController.selectedMethod.value == true ? AppColor.black : Colors.transparent,
                                    ),
                                  ),
                                ),
                                child: Center(
                                    child: Text(
                                  "Login",
                                  style: TextStyle().normal22w500.textColor(AppColor.black12Color),
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(20),
                    Obx(
                      () => loginController.selectedMethod.value == true ? buildLogin(context) : buildRegister(context),
                    ),
                    Gap(16),
                    if (Platform.isIOS) ...[
                      CommonAppButton(
                        text: "Continue with Apple",
                        onTap: () async {
                          if (!loginController.isChecked.value &&  loginController.selectedMethod.value ==false) {
                            showErrorSheet("Please accept the Terms and Conditions to proceed.");
                            return;
                          }
                          await loginController.signInWithApple();
                        },
                        isShowIcon: true,
                        icon: Icon(Icons.apple),
                        textColor: AppColor.black12Color,
                        color: AppColor.greyF6Color,
                      ),
                      Gap(24),
                    ],
                    CommonAppButton(
                      text: "Continue with Google",
                      onTap: () async {
                        if (!loginController.isChecked.value &&  loginController.selectedMethod.value ==false) {
                          showErrorSheet("Please accept the Terms and Conditions to proceed.");
                          return;
                        }
                        await loginController.signInWithGoogle();
                      },
                      isShowIcon: true,
                      icon: Image.asset(AppImage.google),
                      textColor: AppColor.black12Color,
                      color: AppColor.greyF6Color,
                    ),
                    Gap(24),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Obx _termsAndCondition() {
    return Obx(
      () => Row(
        children: [
          SizedBox(
            width: 20,
            child: Checkbox(
              value: loginController.isChecked.value,
              onChanged: (value) {
                loginController.isChecked.value = value!;
              },
              activeColor: Colors.black,
              checkColor: Colors.white,
            ),
          ),
          Gap(8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Get.toNamed(AppRouter.terms, arguments: [2]);
                // launchURL("https://www.teammatesapp.org/terms-of-service");
              },
              child: Text.rich(
                TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle().normal16w500.textColor(AppColor.black12Color),
                  children: [
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: TextStyle(decoration: TextDecoration.underline, decorationColor: AppColor.black12Color)
                          .normal16w500
                          .textColor(AppColor.black12Color),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRegister(context) {
    return Form(
      key: formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lets get started by filling your\ndetails",
            style: TextStyle().normal20w500.textColor(
                  AppColor.black12Color,
                ),
          ),
          Gap(16),
          CommonTextField(
            focusNode: loginController.fNameFocusNode,
            autofillHints: const [
              AutofillHints.namePrefix,
            ],
            inputFormatters: [
              NoSpaceFormatter(),
              CapitalizedTextFormatter(),
            ],
            controller: loginController.fNameController,
            hintText: "First name",
            onFieldSubmitted: (val) {
              FocusScope.of(context).requestFocus(loginController.lNameFocusNode);
            },
            validator: (val) {
              if ((val ?? "").isEmpty) {
                return "Please enter your first name";
              } else if (!isValidName(val)) {
                return "Please enter minimum 2 characters";
              }
              return null;
            },
          ),
          Gap(16),
          CommonTextField(
            focusNode: loginController.lNameFocusNode,
            autofillHints: const [
              AutofillHints.nameSuffix,
            ],
            inputFormatters: [
              NoSpaceFormatter(),
              CapitalizedTextFormatter(),
            ],
            controller: loginController.lNameController,
            hintText: "Last name",
            onFieldSubmitted: (val) {
              FocusScope.of(context).requestFocus(loginController.emailFocusNode);
            },
            validator: (val) {
              if ((val ?? "").isEmpty) {
                return "Please enter your last name";
              } else if (!isValidName(val)) {
                return "Please enter minimum 2 characters";
              }
              return null;
            },
          ),
          Gap(16),
          CommonTextField(
            focusNode: loginController.emailFocusNode,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(loginController.passwordFocusNode);
            },
            autofillHints: const [
              AutofillHints.email,
            ],
            controller: loginController.emailController,
            hintText: "E-mail",
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if ((val ?? "").isEmpty) {
                return "Please enter your email address";
              } else if (!(val ?? "").isEmail) {
                return "Please enter valid email address";
              } else if (!isValidEmail(val)) {
                return "Email should include at least one alphabetical character (a-z)";
              }
              return null;
            },
          ),
          Gap(16),
          Obx(
            () => CommonTextField(
              onFieldSubmitted: (val) {
                FocusScope.of(context).requestFocus(loginController.cPasswordFocusNode);
              },
              keyboardType: TextInputType.text,
              focusNode: loginController.passwordFocusNode,
              controller: loginController.passwordController,
              hintText: "Password",
              validator: (val) {
                if ((val ?? "").trim().isEmpty) {
                  return "Please enter your password";
                } else if ((val ?? "").length < 5) {
                  return "Password must be at least 5 characters";
                } else if (!isValidPassword(val)) {
                  return "Password must contain at least one alpha and one special character";
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              obscureText: !loginController.isShowPassword.value,
              suffixIcon: GestureDetector(
                onTap: () {
                  loginController.isShowPassword.value = !loginController.isShowPassword.value;
                },
                child: Icon(
                  loginController.isShowPassword.value ? Icons.remove_red_eye : Icons.visibility_off,
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
          Gap(16),
          Obx(
            () => CommonTextField(
              focusNode: loginController.cPasswordFocusNode,
              controller: loginController.cPasswordController,
              hintText: "Confirm password",
              validator: (val) {
                if ((val ?? "").trim().isEmpty) {
                  return "Please enter your confirm password";
                } else if (val != loginController.passwordController.text) {
                  return "Confirm password does not match with password";
                }
                return null;
              },
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              obscureText: !loginController.isShowCPassword.value,
              suffixIcon: GestureDetector(
                onTap: () {
                  loginController.isShowCPassword.value = !loginController.isShowCPassword.value;
                },
                child: Icon(
                  loginController.isShowCPassword.value ? Icons.remove_red_eye : Icons.visibility_off,
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
          Gap(4),
          _termsAndCondition(),
          Gap(16),
          CommonAppButton(
            text: "Continue",
            onTap: () async {
              if (formKey1.currentState!.validate()) {
                hideKeyboard();
                await loginController.registerApiCall(
                  firstName: loginController.fNameController.text.trim().toString(),
                  lastName: loginController.lNameController.text.trim().toString(),
                  email: loginController.emailController.text.trim().toString(),
                  isFromSSO: false,
                  password: loginController.cPasswordController.text.trim().toString(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildLogin(context) {
    return Form(
      key: formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lets get started by filling your\ndetails",
            style: TextStyle().normal20w500.textColor(
                  AppColor.black12Color,
                ),
          ),
          Gap(16),
          CommonTextField(
              focusNode: loginController.loginEmailFocus,
              onFieldSubmitted: (val) {
                FocusScope.of(context).requestFocus(loginController.loginPasswordFocus);
              },
              autofillHints: const [
                AutofillHints.email,
              ],
              inputFormatters: [NoSpaceFormatter()],
              controller: loginController.lEmailController,
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
          Gap(16),
          Obx(
            () => CommonTextField(
              focusNode: loginController.loginPasswordFocus,
              controller: loginController.lPasswordController,
              hintText: "Password",
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              obscureText: !loginController.isLShowPassword.value,
              validator: (val) {
                if ((val ?? "").isEmpty) {
                  return "Please enter your password";
                } else {
                  return null;
                }
              },
              suffixIcon: GestureDetector(
                onTap: () {
                  loginController.isLShowPassword.value = !loginController.isLShowPassword.value;
                },
                child: Icon(
                  loginController.isLShowPassword.value ? Icons.remove_red_eye : Icons.visibility_off,
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
          // Gap(4),
          // _termsAndCondition(),
          Gap(16),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Get.toNamed(AppRouter.forgotPassword);
              },
              child: Text(
                "Forgot password?",
                style: TextStyle().normal16w500.textColor(AppColor.black12Color),
              ),
            ),
          ),
          Gap(16),
          CommonAppButton(
            text: "Continue",
            onTap: () async {
              hideKeyboard();

              if (formKey2.currentState!.validate()) {
                await loginController.loginApiCall();
              }
            },
          ),
        ],
      ),
    );
  }
}
