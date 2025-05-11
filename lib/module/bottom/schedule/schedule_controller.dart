import 'package:base_code/module/bottom/home/home_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class ScheduleController extends GetxController {
  List selectedMethod1List = [
    "Today",
    "Past",
    "Upcoming",
  ];
  AutoScrollController controller1 = AutoScrollController();
  RxInt selectedSearchMethod1 = 0.obs;
  RxList<ShortedData> sortedScheduleList = <ShortedData>[].obs;

  RxBool isLoading = false.obs;

  Future<void> getScheduleListApiCall({String? filter, startDate, endDate}) async {
    try {
      isLoading.value = true;
      sortedScheduleList.clear();

      var data = {
        "user_id": AppPref().userId,
        if (filter != null) "filter": filter.toLowerCase(),
        if (startDate != null) "start_date": startDate,
        if (endDate != null) "end_date": endDate,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.getScheduleList,
          data: data,
        ),
        false,
      );
      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        var list = (jsonData['data'] as List).map((e) => ScheduleData.fromJson(e)).toList();
        if (filter?.toLowerCase() == "past") {
          for (var item in list) {
            item.isLive = 0;
          }
        }
        Map<String, List<ScheduleData>> groupedData = {};

        for (var item in list) {
          String date = item.eventDate ?? "";
          if (!groupedData.containsKey(date)) {
            groupedData[date] = [];
          }
          groupedData[date]!.add(item);
        }

        sortedScheduleList.assignAll(groupedData.entries.map((entry) => ShortedData(date: entry.key, data: entry.value)).toList());
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      isLoading.value = false;
    }
  }

  final GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<void> statusChangeApiCall({
    required String status,
    required int aId,
    required bool isHome,
  }) async {
    try {
      var data = {
        "user_id": AppPref().userId,
        "activity_id": aId,
        "status": status,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.setActivityStatus,
          data: data,
        ),
        false,
      );
      if (res?.statusCode == 200) {
        if (isHome) {
          Get.find<ScheduleController>().refreshKey.currentState?.show();
        } else {
          Get.find<HomeController>().refreshKey.currentState?.show();
        }
        AppToast.showAppToast(res?.data['ResponseMsg']);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {}
  }

  @override
  void onInit() {
    getScheduleListApiCall(filter: 'today');
    super.onInit();
  }
}

class ShortedData {
  String date;
  List<ScheduleData> data;

  ShortedData({
    required this.date,
    required this.data,
  });
}
