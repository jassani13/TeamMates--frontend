import 'package:base_code/package/config_packages.dart';

class SearchScreenController extends GetxController {
  AutoScrollController controller=AutoScrollController();

  RxList<SearchData> searchList = <SearchData>[
    SearchData(value: "Location", image: AppImage.location),
    SearchData(value: "Teams", image: AppImage.bottom3),
    SearchData(value: "Upcoming Events ", image: AppImage.event),
    SearchData(value: "Player", image: AppImage.player),
  ].obs;

  RxInt selectedSearchMethod= 0.obs;
}

class SearchData {
  String image;
  String value;

  SearchData({
    required this.value,
    required this.image,
  });
}
