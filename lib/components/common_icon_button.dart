import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/package/config_packages.dart';

class CommonIconButton extends StatelessWidget {
  final String? image;
  final Function()? onTap;

  const CommonIconButton({
    super.key,
    this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 1),
              blurRadius: 8.2,
              spreadRadius: -4,
              color: AppColor.black.withOpacity(0.25),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: SvgPicture.asset(
            image ?? AppImage.noti,
          ),
        ),
      ),
    );
  }
}
