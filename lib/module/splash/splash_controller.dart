import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class SplashController extends GetxController {
  goNextScreen() async {
    3.delay(
      () async {
        if (AppPref().isFirstTime == true) {
          if (AppPref().isLogin == true) {

            // if(AppPref().role=='family'){
            //   Get.offAllNamed(AppRouter.schedule);
            //
            // }else{
            Get.offAllNamed(AppRouter.bottom);

            // }
          } else {
            Get.offAllNamed(AppRouter.login);
          }
        } else {
          Get.offAllNamed(AppRouter.onBoarding);
        }
      },
    );
  }

  @override
  void onReady() {
    super.onReady();
    goNextScreen();
  }
}
