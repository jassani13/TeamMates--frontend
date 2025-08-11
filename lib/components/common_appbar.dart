import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor = AppColor.white;
  final Widget? title;
  final Widget? leading;
  final Widget? action;
  final bool automaticallyImplyLeading;
  final bool isImageOrNot = true;
  final TextStyle? textStyle;
  final bool deleteIcon;
  final bool showFilterIcon;
  final double? leadingWidth;
  final Callback? onTap;
  final Function()? onTapAction;
  final Callback? reloadOnTap;

  CommonAppBar({
    super.key,
    this.title,
    this.onTap,
    this.leading,
    this.action,
    this.leadingWidth,
    this.reloadOnTap,
    this.showFilterIcon = true,
    this.automaticallyImplyLeading = true,
    this.onTapAction,
    this.deleteIcon = false,
    this.textStyle,
  });

  final globalController = Get.find<GlobalController>();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: leadingWidth ?? 67,
      leading: automaticallyImplyLeading
          ? leading ??
              GestureDetector(
                onTap: onTap ??
                    () {
                      Get.back();
                    },
                behavior: HitTestBehavior.translucent,
                child: const Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Icon(Icons.arrow_back_ios, color: AppColor.defaultIconColor),
                ),
              )
          : Container(),
      backgroundColor: backgroundColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColor.black, size: 24),
      centerTitle: true,
      titleTextStyle: textStyle ?? const TextStyle(color: AppColor.black).normal18w500,
      title: title,
      actions: [
        showFilterIcon
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColor.defaultIconColor),
                      ),
                      child: Center(
                        child: Image.asset(
                          AppImage.appIcon,
                          height: 24,
                          width: 24,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
        action ?? Container()
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

}
