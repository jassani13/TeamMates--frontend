import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';

class CalendarViewController extends GetxController {
  Rx<DateTime?> selectedDate = Rx<DateTime?>(DateTime.now());
  Rx<DateTime> focusedDay = DateTime.now().obs;
  RxList<dynamic> selectedDayEvents = <dynamic>[].obs;
  RxList<Map<String, dynamic>> calendarLinks = <Map<String, dynamic>>[].obs;

  RxMap events = {}.obs;

  void updateSelectedDayEvents(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    selectedDayEvents.value = events[key] ?? [];
  }

  Future<void> loadICSFromUrl({required String url, required int urlId}) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final String icsData = response.body;
        final ICalendar ical = ICalendar.fromString(icsData);

        for (var event in ical.data) {
          if (event['type'] != 'VEVENT') continue;

          final startObj = event['dtstart'];
          DateTime? start;

          if (startObj is DateTime) {
            start = startObj;
          } else if (startObj is IcsDateTime) {
            start = startObj.toDateTime();
          }

          if (start == null) continue;

          final eventDate = DateTime(start.year, start.month, start.day);
          final summary = {
            ...event,
            'link': url,
            'web_cal_id': urlId,
          };

          final existing = events[eventDate]?.toSet() ?? <dynamic>{};
          existing.add(summary);
          events[eventDate] = existing.toList();
        }
        if (kDebugMode) {
          print("Events added from $url");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to load ICS: $e");
      }
    }
  }

  Future<void> unsubscribeLink(int linkId) async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': AppPref().userId,
        'web_cal_id': linkId,
      });
      var response = await callApi(dio.post(
        ApiEndPoint.removeWebCalList,
        data: formData,
      ));
      if (response?.statusCode == 200) {
        calendarLinks.removeWhere((e) => e['web_cal_id'] == linkId);
        events.removeWhere((key, value) {
          return value.any((event) => event['web_cal_id'] == linkId);
        });

        AppToast.showAppToast(response?.data['ResponseMsg']);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> addWebCallUrl({required String link}) async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': AppPref().userId,
        'link': link,
      });
      var response = await callApi(dio.post(
        ApiEndPoint.setWebCalLink,
        data: formData,
      ));
      if (response?.statusCode == 200) {
        AppToast.showAppToast(response?.data['ResponseMsg']);
        calendarLinks.add(
          {
            'link': response?.data['data']['link'] as String,
            "web_cal_id": response?.data['data']['web_cal_id'],
          },
        );
        await loadICSFromUrl(url: link, urlId: response?.data['data']['web_cal_id']);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> getWebCallUrl() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': AppPref().userId,
      });
      var response = await callApi(dio.post(
        ApiEndPoint.getWebCalList,
        data: formData,
      ));
      if (response?.statusCode == 200) {
        final List<dynamic> data = response?.data['data'];
        if (data.isNotEmpty) {
          calendarLinks.value = data
              .map(
                (item) => {
                  'link': item['link'] as String,
                  "web_cal_id": item['web_cal_id'],
                },
              )
              .toList();
          for (var item in data) {
            final String link = item['link'];
            await loadICSFromUrl(
              url: link,
              urlId: item['web_cal_id'],
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((val) {
      getWebCallUrl();
    });
  }
}
