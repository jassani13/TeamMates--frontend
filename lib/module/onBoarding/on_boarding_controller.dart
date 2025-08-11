import 'package:base_code/package/config_packages.dart';

class OnBoardingController extends GetxController {
  RxList<OBData> obList = <OBData>[
    OBData(
      image: AppImage.ob1,
      title: "Schedule & Event\nManagement",
      description: "Organize Your Team’s Events",
      description2: "Effortlessly manage games, practices, and team events with a few taps",
    ),
    OBData(
      image: AppImage.ob2,
      title: "Team & Family Chat –\nCheers Included",
      description: "Stay Connected",
      description2: "Real-time messaging for players, coaches, and\nfamilies to stay connected.",
    ),
    OBData(
      image: AppImage.ob3,
      title: "Player Performance\nTracking",
      description: "Track Your Progress",
      description2: "Monitor individual and team performance with\ndetailed stats and achievements",
    ),
  ].obs;
  RxInt selectedIndex = 0.obs;
  PageController controller = PageController();
}
