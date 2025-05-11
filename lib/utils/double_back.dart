import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class DoubleBack extends StatefulWidget {
  final Widget child;
  final String message;
  final int waitForSecondBackPress;
  final Function? onFirstBackPress;
  final bool condition;
  final VoidCallback? onConditionFail;
  final TextStyle textStyle;
  final Color background;
  final double backgroundRadius;

  const DoubleBack({
    super.key,
    required this.child,
    this.message = "Press back again to exit",
    this.waitForSecondBackPress = 2,
    this.onFirstBackPress,
    this.condition = true,
    this.onConditionFail,
    this.textStyle = const TextStyle(fontSize: 14, color: Colors.white),
    this.background = const Color(0xAA000000),
    this.backgroundRadius = 20,
  });

  @override
  State<DoubleBack> createState() => _DoubleBackState();
}

class _DoubleBackState extends State<DoubleBack> {
  bool tapped = false;

  bool get _isAndroid => Theme.of(context).platform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    if (_isAndroid) {
      return WillPopScope(
        onWillPop: () async {
          if (widget.condition) {
            if (tapped) {
              return true;
            } else {
              tapped = true;
              Timer(
                Duration(
                  seconds: widget.waitForSecondBackPress,
                ),
                resetBackTimeout,
              );

              if (widget.onFirstBackPress != null) {
                widget.onFirstBackPress!(context);
              } else {
                AppToast.showAppToast(widget.message);
              }

              return false;
            }
          } else {
            if (widget.onConditionFail != null) {
              widget.onConditionFail!();
            }
            return false;
          }
        },
        child: widget.child,
      );
    } else {
      return widget.child;
    }
  }

  void resetBackTimeout() {
    tapped = false;
  }
}
