import 'package:base_code/components/socket_service.dart';
import 'package:base_code/module/bottom/bottom_controller.dart';
import 'package:base_code/module/bottom/chat/chat_screen.dart';
import 'package:base_code/module/bottom/home/home_screen.dart';
import 'package:base_code/module/bottom/roster/roster_screen.dart';
import 'package:base_code/module/bottom/schedule/schedule_screen.dart';
import 'package:base_code/module/bottom/stats/stats_screen.dart';
import 'package:base_code/module/subscription/subscription_screen.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/utils/double_back.dart';

class BottomScreen extends StatelessWidget {
  BottomScreen({super.key});

  final bottomController = Get.put<BottomController>(BottomController());
  final String storedPasscode = "1234";
  bool isAuthenticated = false;
  final List<Widget> pages = [
    HomeScreen(),
    ScheduleScreen(),
    RosterScreen(),
    ChatScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // SocketService().connect();

    return Scaffold(
        bottomNavigationBar: buildBottom(),
        body: DoubleBack(
          child: Obx(
            () => IndexedStack(
              index: bottomController.selectedIndex.value,
              children: pages,
            ),
          ),
        ));
  }

  Obx buildBottom() {
    return Obx(
      () => BottomNavigationBar(
        backgroundColor: AppColor.white,
        items: [
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                bottomController.selectedIndex.value == 0 ? AppImage.bottom11 : AppImage.bottom1,
                colorFilter:
                    ColorFilter.mode(bottomController.selectedIndex.value == 0 ? AppColor.black12Color : AppColor.grey6EColor, BlendMode.srcIn),
              ),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                bottomController.selectedIndex.value == 1 ? AppImage.bottom22 : AppImage.bottom2,
                colorFilter:
                    ColorFilter.mode(bottomController.selectedIndex.value == 1 ? AppColor.black12Color : AppColor.grey6EColor, BlendMode.srcIn),
              ),
              label: 'Schedule'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                bottomController.selectedIndex.value == 2 ? AppImage.bottom33 : AppImage.bottom3,
                colorFilter:
                    ColorFilter.mode(bottomController.selectedIndex.value == 2 ? AppColor.black12Color : AppColor.grey6EColor, BlendMode.srcIn),
              ),
              label: 'Roster'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                bottomController.selectedIndex.value == 3 ? AppImage.bottom44 : AppImage.bottom4,
                colorFilter:
                    ColorFilter.mode(bottomController.selectedIndex.value == 3 ? AppColor.black12Color : AppColor.grey6EColor, BlendMode.srcIn),
              ),
              label: 'Chat'),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              bottomController.selectedIndex.value == 4 ? AppImage.bottom55 : AppImage.bottom5,
              colorFilter:
                  ColorFilter.mode(bottomController.selectedIndex.value == 4 ? AppColor.black12Color : AppColor.grey6EColor, BlendMode.srcIn),
            ),
            label: AppPref().role == 'coach' ? 'Challenges' : 'My Stats',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: bottomController.selectedIndex.value,
        unselectedLabelStyle: const TextStyle().normal12w500.textColor(AppColor.grey6EColor),
        selectedLabelStyle: const TextStyle().normal12w600.textColor(AppColor.black12Color),
        selectedItemColor: AppColor.black12Color,
        unselectedItemColor: AppColor.grey6EColor,
        onTap: bottomController.onItemTapped,
      ),
    );
  }
}
