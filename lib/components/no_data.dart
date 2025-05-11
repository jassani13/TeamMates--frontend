import 'package:base_code/package/screen_packages.dart';

import '../package/config_packages.dart';

Text buildNoData({
  String? text
}) {
  return Text(
    text??   "No Team Found",
    style: TextStyle().normal16w500.textColor(
      AppColor.black12Color,
    ),
  );
}