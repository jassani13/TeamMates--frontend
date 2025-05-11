import 'package:base_code/package/config_packages.dart';

class VolunteerAssignmentsController extends GetxController {
  RxList<Data> dataList = <Data>[
    Data(
      isCheck: false,
      title: "Attendance",
    ),
    Data(
      isCheck: false,
      title: "Clock",
    ),
    Data(
      isCheck: false,
      title: "Photographer",
    ),
    Data(
      isCheck: false,
      title: "Sanitizer",
    ),
    Data(
      isCheck: false,
      title: "Scorekeeper",
    ),
    Data(
      isCheck: false,
      title: "Snacks",
    ),
    Data(
      isCheck: false,
      title: "Temperature checker",
    ),
    Data(
      isCheck: false,
      title: "Water",
    ),
    Data(
      isCheck: false,
      title: "Custom assignment",
    ),
  ].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    if (Get.arguments != null) {
      List<String> selectedItems =
          (Get.arguments as String).split(',').map((e) => e.trim()).toList();

      for (var item in dataList) {
        if (selectedItems.contains(item.title)) {
          item.isCheck = true;
        }
      }
      dataList.refresh();
    }
  }
}

class Data {
  bool isCheck;
  String title;

  Data({
    required this.isCheck,
    required this.title,
  });
}
