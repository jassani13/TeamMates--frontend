import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

int noOfCallRunning = 0;

class AppLoader {
  Future<void> showCustomLoader(context, {int second = 3}) async {
    await showSimpleLoadingDialog<String>(
      context: context,
      future: () async {
        await Future<void>.delayed(Duration(seconds: second));
        return '';
      },
      dialogBuilder: (context, _) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: AppColor.primaryColor),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: const TextStyle().normal14w500.textColor(AppColor.black),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  showLoader({bool isCancelable = false}) {
    if (!(Get.isDialogOpen ?? false)) noOfCallRunning = 0;
    noOfCallRunning++;
    if (noOfCallRunning == 1) _showLoadingDialog(isCancelable);
  }

  dismissLoader() {
    if (noOfCallRunning == 1) Get.back();
    noOfCallRunning--;
  }

  void _showLoadingDialog(bool isCancelable) {
    Get.dialog(
      WillPopScope(
        onWillPop: () => Future.value(isCancelable),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: (Get.width - 240) / 2),
            height: 120,
            child: const LoaderCircles(AppColor.black12Color),
          ),
        ),
      ),
      barrierDismissible: isCancelable,
    );
  }
}

class LoaderCircles extends StatefulWidget {
  final Color dotColor;
  final Duration duration;

  const LoaderCircles(
    this.dotColor, {
    this.duration = const Duration(milliseconds: 1000),
    super.key,
  });

  @override
  State<LoaderCircles> createState() => _LoaderCirclesState();
}

class _LoaderCirclesState extends State<LoaderCircles> with SingleTickerProviderStateMixin {
  late Animation<double> animation_1;
  late Animation<double> animation_2;
  late Animation<double> animation_3;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: widget.duration, vsync: this);

    animation_1 = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: controller, curve: const Interval(0.0, 0.80, curve: Curves.ease)));
    animation_2 = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: controller, curve: const Interval(0.1, 0.9, curve: Curves.ease)));
    animation_3 = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: controller, curve: const Interval(0.2, 1.0, curve: Curves.ease)));

    controller.addListener(() {
      setState(() {
      });
    });

    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Transform.translate(
          offset: Offset(
            0.0,
            -30 * (animation_1.value <= 0.50 ? animation_1.value : 1.0 - animation_1.value),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Dot(
              radius: 10.0,
              color: widget.dotColor,
              icon: const Icon(Icons.blur_on),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(
            0.0,
            -30 * (animation_2.value <= 0.50 ? animation_2.value : 1.0 - animation_2.value),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Dot(
              radius: 10.0,
              color: widget.dotColor,
              icon: const Icon(Icons.blur_on),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(
            0.0,
            -30 * (animation_3.value <= 0.50 ? animation_3.value : 1.0 - animation_3.value),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Dot(
              radius: 10.0,
              color: widget.dotColor,
              icon: const Icon(Icons.blur_on),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Dot extends StatelessWidget {
  final double? radius;
  final Color? color;
  final Icon? icon;

  const Dot({super.key, this.radius, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: 0.0,
        child: Container(
          width: radius,
          height: radius,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
