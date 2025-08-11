import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

CachedNetworkImage getImageView({
  required String finalUrl,
  double height = 40,
  double width = 40,
  fit = BoxFit.none,
  Decoration? shape,
  Color? color,
  Widget? errorWidget,
}) {
  return CachedNetworkImage(
    imageUrl: finalUrl,
    fit: fit,
    height: height,
    width: width,
    placeholder: (context, url) => Container(
      margin: const EdgeInsets.all(10),
      height: height,
      width: width,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColor.black12Color,
        ),
      ),
    ),
    errorWidget: (context, url, error) =>
        errorWidget ??
        SizedBox(
          height: height,
          width: width,
          child: const Icon(Icons.error),
        ),
  );
}
