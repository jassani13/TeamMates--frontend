import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/package/config_packages.dart';

class CommonProgressBar extends StatelessWidget {
  final double? width;
  final String value;

  const CommonProgressBar({
    super.key,
    this.width,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: width ?? MediaQuery.of(context).size.width,
          height: 12,
          margin: EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColor.white.withOpacity(0.6),
            boxShadow: [
              BoxShadow(
                color: AppColor.black12Color.withOpacity(0.7),
                blurRadius: 1,
                spreadRadius: 0,
                offset: Offset(0, -2),
              ),
              BoxShadow(
                color: AppColor.white,
                blurRadius: 20,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: LinearPercentIndicator(
            padding: EdgeInsets.zero,
            width: width ?? MediaQuery.of(context).size.width - 72,
            animation: true,
            barRadius: Radius.circular(12),
            lineHeight: 12.0,
            backgroundColor: Colors.transparent,
            animationDuration: 2500,
            percent: double.parse(value) / 100,
            linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: AppColor.black12Color,
          ),
        ),
      ],
    );
  }
}