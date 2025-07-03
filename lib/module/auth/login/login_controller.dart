import 'package:base_code/data/network/api_client.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  final FocusNode fNameFocusNode = FocusNode();
  final FocusNode lNameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode numberFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode cPasswordFocusNode = FocusNode();
  final FocusNode loginEmailFocus = FocusNode();
  final FocusNode loginPasswordFocus = FocusNode();

  TextEditingController lEmailController = TextEditingController();
  TextEditingController lPasswordController = TextEditingController();
  RxBool isLShowPassword = false.obs;
  RxBool isShowPassword = false.obs;
  RxBool isShowCPassword = false.obs;
  RxBool selectedMethod = false.obs;
  RxBool isChecked = false.obs;

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      final String email = googleUser.email;
      final String firstName = googleUser.displayName?.split(" ").first ?? "";
      final String lastName = googleUser.displayName?.split(" ").skip(1).join(" ") ?? "";

      await checkUserExistsOrNotApiCall(
        email: email,
        firstName: firstName,
        lastName: lastName,
        user: userCredential,
      );
    } catch (e) {
      print("Google sign-in failed: $e");
    }
  }

  Future signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider("apple.com");
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      final email = appleCredential.email ?? userCredential.user?.email ?? "";

      String firstName = appleCredential.givenName ?? "";
      String lastName = appleCredential.familyName ?? "";

      if (firstName.isEmpty && lastName.isEmpty && email.contains("@")) {
        final nameFromEmail = email.split("@").first;
        firstName = nameFromEmail;
        lastName = nameFromEmail;
      }
      await checkUserExistsOrNotApiCall(
        email: email,
        firstName: firstName,
        lastName: lastName,
        user: userCredential,
      );
    } catch (e) {
      print("Apple sign in failed: $e");
      return null;
    }
  }

  Future<void> loginApiCall() async {
    try {
      var data = {
        "email": lEmailController.text.toString(),
        "password": lPasswordController.text.toString(),
        "fcm_token": AppPref().fcmToken,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.logIn,
          data: data,
        ),
        true,
      );

      if (res?.statusCode == 200) {
        UserModel userModel = UserModel.fromJson(res?.data["data"]);
        AppPref().userModel = userModel;
        AppPref().userId = userModel.userId;
        if (userModel.role == null) {
          Get.toNamed(AppRouter.selectRole);
        } else if (userModel.role == 'family') {
          AppPref().role = "family";

          Get.toNamed(AppRouter.teamCode);
        } else if (userModel.role == 'team') {
          AppPref().role = "team";
          AppPref().isLogin = true;

          Get.offAllNamed(AppRouter.bottom);
        } else {
          AppPref().role = "coach";
          AppPref().isLogin = true;
          Get.offAllNamed(AppRouter.bottom);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> checkUserExistsOrNotApiCall({
    required String email,
    required String firstName,
    required String lastName,
    UserCredential? user,
  }) async {
    try {
      var data = {
        "email": email,
      };

      var res = await callApi(
        dio.post(ApiEndPoint.checkUser, data: data),
        true,
      );

      if (res?.statusCode == 200) {
        if (res?.data["data"]["is_register"] == true) {
          UserModel userModel = UserModel.fromJson(res?.data['data']["details"]);
          AppPref().userModel = userModel;
          AppPref().userId = userModel.userId;

          if (userModel.role == null) {
            Get.toNamed(AppRouter.selectRole);
          } else if (userModel.role == 'family') {
            AppPref().role = "family";
            Get.toNamed(AppRouter.teamCode);
          } else {
            AppPref().role = userModel.role!;
            AppPref().isLogin = true;
            Get.offAllNamed(AppRouter.bottom);
          }
        } else {
          await registerApiCall(
            isFromSSO: true,
            firstName: firstName,
            lastName: lastName,
            email: email,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future<void> registerApiCall({
    bool isFromSSO = false,
    required String firstName,
    required String lastName,
    required String email,
    String? password,
  }) async {
    try {
      if (!isChecked.value) {
        showErrorSheet("Please accept the Terms and Conditions to proceed.");
        return;
      }
      var data = {
        Param.firstName: firstName,
        Param.lastName: lastName,
        Param.email: email,
        Param.password: password,
        Param.fcmToken: AppPref().fcmToken,
        'is_sso': isFromSSO ? "1" : "0",
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.register,
          data: data,
        ),
        true,
      );

      if (res?.statusCode == 200) {
        UserModel userModel = UserModel.fromJson(res?.data["data"]);
        AppPref().userModel = userModel;
        AppPref().userId = userModel.userId;
        if (userModel.role == null) {
          Get.toNamed(AppRouter.selectRole);
        } else {
          AppPref().isLogin = true;
          Get.offAllNamed(AppRouter.bottom);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
