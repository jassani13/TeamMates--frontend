import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class AppToast {
  static void showAppToast(
    String? msg, {
    Color? bgColor,
    Color? textColor,
    IconData? icon,
    Alignment? align,
  }) {
    if (msg == null || msg.isEmpty) {
      return;
    }
    toastification.show(

      context: Get.context,
      description: Text(
        msg,
        style: TextStyle().normal14w400.textColor(textColor ?? AppColor.white),
      ),
      autoCloseDuration: const Duration(milliseconds: 1500),
      type: ToastificationType.error,
      showProgressBar: false,
      icon: Icon(
        icon ?? Icons.check_circle_outline,
        color: textColor ?? AppColor.white,
      ),
      closeButtonShowType: CloseButtonShowType.none,
      alignment: align ?? Alignment.bottomCenter,
      backgroundColor: bgColor ?? AppColor.black12Color,
      borderSide: BorderSide.none,
    );
  }
}
