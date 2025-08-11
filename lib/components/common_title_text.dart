import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/package/config_packages.dart';

class CommonTitleText extends StatelessWidget {
  final String? text;

  const CommonTitleText({
    super.key,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      style: TextStyle().normal20w500.textColor(
        AppColor.black12Color,
      ),
    );
  }
}
