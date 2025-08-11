import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final splashController = Get.put<SplashController>(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          _backgroundImage(),
          _buildAppLogoAnimation(),
        ],
      ),
    );
  }

  Padding _buildAppLogoAnimation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 170.0),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 1),
        curve: Curves.easeOutBack,
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Image.asset(
          AppImage.whiteBgIcon,
          height: 300,
          width: 300,
        ),
      ),
    );
  }

  SvgPicture _backgroundImage() {
    return SvgPicture.asset(
      AppImage.splashBg,
      height: double.infinity,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
