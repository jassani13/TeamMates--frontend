import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class SimpleCommonDialog extends StatelessWidget {
  const SimpleCommonDialog({
    super.key,
    this.icon,
    this.title,
    this.subTitle,
    this.btn1Text,
    this.btn2Text,
    this.btn1Tap,
    this.btn2Tap,
  });

  final Function()? btn1Tap, btn2Tap;
  final String? icon, title, subTitle, btn1Text, btn2Text;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: AppColor.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: SizedBox(),
      content: Text(
        subTitle ?? "",
        style: TextStyle().normal18w400.textColor(AppColor.black12Color),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        Column(
          children: [
            Gap(16),
            Row(
              children: [
                Expanded(
                  child: CommonAppButton(
                    onTap: btn1Tap ??
                        () {
                          Get.back();
                        },
                    color: Colors.transparent,
                    border: Border.all(width: 1, color: AppColor.black12Color),
                    buttonType: ButtonType.enable,
                    style: const TextStyle().normal14w600.textColor(AppColor.black12Color),
                    text: btn1Text,
                  ),
                ),
                Gap(6),
                Expanded(
                  child: CommonAppButton(
                    onTap: btn2Tap,
                    buttonType: ButtonType.enable,
                    text: btn2Text,
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
