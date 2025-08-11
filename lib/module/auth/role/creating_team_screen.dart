import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class CreatingTeamScreen extends StatefulWidget {
  const CreatingTeamScreen({super.key});

  @override
  State<CreatingTeamScreen> createState() => _CreatingTeamScreenState();
}

class _CreatingTeamScreenState extends State<CreatingTeamScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: const Offset(1, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    4.delay(() {
      Get.offAllNamed(AppRouter.bottom);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(),
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              Gap(MediaQuery.of(context).size.height / 3),
              Text(
                AppPref().role == 'coach'
                    ? "Building your dream team"
                    : AppPref().role == 'family'
                        ? "Supporting your champion"
                        : "Getting ready to play",
                style: TextStyle().normal32w500s.textColor(
                      AppColor.black12Color,
                    ),
              ),
              Gap(60),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        _animation.value.dx *
                            MediaQuery.of(context).size.width /
                            2,
                        0),
                    child: SvgPicture.asset(
                      AppImage.cTeam,
                      // height: 50,
                      // width: 50,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
