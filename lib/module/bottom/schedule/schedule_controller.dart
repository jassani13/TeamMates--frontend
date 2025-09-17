import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';

class ScheduleController extends GetxController {
  List selectedMethod1List = [
    "Today",
    "Past",
    "Upcoming",
  ];
  AutoScrollController controller1 = AutoScrollController();
  RxInt selectedSearchMethod1 = 0.obs;
  RxList<ShortedData> sortedScheduleList = <ShortedData>[].obs;

  // External calendar data
  RxList<Map<String, dynamic>> calendarLinks = <Map<String, dynamic>>[].obs;
  RxMap externalEvents = {}.obs; // ICS events stored by date key
  RxBool isLoadingExternal = false.obs;

  RxBool isLoading = false.obs;

  // Load external calendar events
  Future<void> loadExternalCalendarEvents() async {
    try {
      isLoadingExternal.value = true;
      externalEvents.clear();

      // Get calendar links first
      await getWebCallUrl();

      // Load events from each link
      for (var linkData in calendarLinks) {
        final String link = linkData['link'];
        final int urlId = linkData['web_cal_id'];
        await loadICSFromUrl(url: link, urlId: urlId);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to load external calendar events: $e");
      }
    } finally {
      isLoadingExternal.value = false;
    }
  }


  Future<void> loadICSFromUrl({
    required String url,
    required int urlId,
  }) async {
    try {
      var response = await callApi(dio.get<String>(url));
      if (response != null && response.statusCode == 200 && response.data != null) {
      final String icsData = response.data!;
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

        final eventDateKey =
            "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";

        final externalEvent = {
          'type': 'external_calendar',
          'summary': event['summary'] ?? 'External Event',
          'description': event['description'] ?? '',
          'location': event['location'] ?? '',
          'dtstart': event['dtstart'],
          'dtend': event['dtend'],
          'link': url,
          'web_cal_id': urlId,
          'is_external': true,
        };

        if (externalEvents[eventDateKey] == null) {
          externalEvents[eventDateKey] = [];
        }
        externalEvents[eventDateKey].add(externalEvent);
      }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("❌ Failed to load ICS from $url: $e");
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
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> getScheduleListApiCall(
      {String? filter, startDate, endDate}) async {
    try {
      isLoading.value = true;
      sortedScheduleList.clear();

      // Load external events if not already loaded
      if (externalEvents.isEmpty) {
        await loadExternalCalendarEvents();
      }

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
        var list = (jsonData['data'] as List)
            .map((e) => ScheduleData.fromJson(e))
            .toList();

        if (filter?.toLowerCase() == "past") {
          for (var item in list) {
            item.isLive = 0;
          }
        }

        Map<String, List<dynamic>> groupedData = {};

        // Process internal schedule events
        for (var item in list) {
          if (item.isMultiDayEvent) {
            // Multi-day event processing
            try {
              DateTime start = DateTime.parse(item.startDate!);
              DateTime end = DateTime.parse(item.endDate!);

              for (DateTime date = start;
              date.isBefore(end.add(Duration(days: 1)));
              date = date.add(Duration(days: 1))) {
                String dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                if (!groupedData.containsKey(dateKey)) {
                  groupedData[dateKey] = [];
                }
                groupedData[dateKey]!.add({
                  'type': 'internal_schedule',
                  'data': item,
                  'is_external': false,
                });
              }
            } catch (e) {
              String date = item.effectiveStartDate ?? "";
              if (date.isNotEmpty) {
                if (!groupedData.containsKey(date)) {
                  groupedData[date] = [];
                }
                groupedData[date]!.add({
                  'type': 'internal_schedule',
                  'data': item,
                  'is_external': false,
                });
              }
            }
          } else {
            // Single-day event
            String date = item.effectiveStartDate ?? "";
            if (date.isNotEmpty) {
              if (!groupedData.containsKey(date)) {
                groupedData[date] = [];
              }
              groupedData[date]!.add({
                'type': 'internal_schedule',
                'data': item,
                'is_external': false,
              });
            }
          }
        }

        // Add external events to grouped data
        externalEvents.forEach((dateKey, externalEventList) {
          if (!groupedData.containsKey(dateKey)) {
            groupedData[dateKey] = [];
          }
          for (var externalEvent in externalEventList) {
            groupedData[dateKey]!.add({
              'type': 'external_calendar',
              'data': externalEvent,
              'is_external': true,
            });
          }
        });

        // Convert to sorted list and format dates for display
        var sortedEntries = groupedData.entries.toList();
        sortedEntries.sort((a, b) => a.key.compareTo(b.key));

        // Apply filtering
        if (filter != null) {
          sortedEntries = _filterEntriesByDate(sortedEntries, filter.toLowerCase());
        } else if (startDate != null && endDate != null) {
          sortedEntries = _filterEntriesByDateRange(sortedEntries, startDate, endDate);
        }

        sortedScheduleList.assignAll(sortedEntries.map((entry) {
          String displayDate = _formatDateForDisplay(entry.key);
          return ShortedData(date: displayDate, data: entry.value);
        }).toList());
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods (keep your existing ones but ensure they work with mixed data)
  String _formatDateForDisplay(String dateKey) {
    try {
      if (dateKey.isEmpty) return "No Date";

      DateTime date = DateTime.parse(dateKey);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime eventDate = DateTime(date.year, date.month, date.day);

      if (eventDate == today) {
        return "Today - ${DateFormat('MMM d, y').format(date)}";
      } else if (eventDate == today.subtract(Duration(days: 1))) {
        return "Yesterday - ${DateFormat('MMM d, y').format(date)}";
      } else if (eventDate == today.add(Duration(days: 1))) {
        return "Tomorrow - ${DateFormat('MMM d, y').format(date)}";
      } else {
        return DateFormat('EEEE, MMM d, y').format(date);
      }
    } catch (e) {
      return dateKey.isEmpty ? "No Date" : dateKey;
    }
  }

  List<MapEntry<String, List<dynamic>>> _filterEntriesByDate(
      List<MapEntry<String, List<dynamic>>> entries, String filter) {
    try {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      String todayString = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      switch (filter) {
        case 'today':
          return entries.where((entry) => entry.key == todayString).toList();

        case 'past':
          return entries.where((entry) {
            try {
              DateTime entryDate = DateTime.parse(entry.key);
              return entryDate.isBefore(today);
            } catch (e) {
              return false;
            }
          }).toList();

        case 'upcoming':
          return entries.where((entry) {
            try {
              DateTime entryDate = DateTime.parse(entry.key);
              return entryDate.isAfter(today) || entryDate.isAtSameMomentAs(today);
            } catch (e) {
              return false;
            }
          }).toList();

        default:
          return entries;
      }
    } catch (e) {
      return entries;
    }
  }

  List<MapEntry<String, List<dynamic>>> _filterEntriesByDateRange(
      List<MapEntry<String, List<dynamic>>> entries,
      String startDate,
      String endDate) {
    try {
      DateTime start = DateTime.parse(startDate);
      DateTime end = DateTime.parse(endDate);

      return entries.where((entry) {
        try {
          DateTime entryDate = DateTime.parse(entry.key);
          return (entryDate.isAfter(start) || entryDate.isAtSameMomentAs(start)) &&
              (entryDate.isBefore(end) || entryDate.isAtSameMomentAs(end));
        } catch (e) {
          return false;
        }
      }).toList();
    } catch (e) {
      return entries;
    }
  }


  final GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<void> statusChangeApiCall({
    required String status,
    required int aId,
    required bool isHome,
    String? rsvpNote, // NEW: Add this optional parameter
  }) async {
    try {
      var data = {
        "user_id": AppPref().userId,
        "activity_id": aId,
        "status": status,
      };

      // NEW: Add note if provided (backward compatible)
      if (rsvpNote != null && rsvpNote.trim().isNotEmpty) {
        data["rsvp_note"] = rsvpNote.trim();
      }

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

  Future<void> sendRsvpNudgeApiCall({
    required int activityId,
  }) async {
    try {
      var data = {
        "user_id": AppPref().userId,
        "activity_id": activityId,
      };

      var res = await callApi(
        dio.post(
          ApiEndPoint.sendRsvpNudge,
          data: data,
        ),
        true, // Show loading
      );

      if (res?.statusCode == 200) {
        var responseData = res?.data;
        var recipientCount = responseData['data']?['recipients_count'] ?? 0;
        AppToast.showAppToast(
            "Nudge sent successfully to $recipientCount team members!");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      AppToast.showAppToast("Failed to send nudge. Please try again.");
    }
  }


  @override
  void onInit() {
    getScheduleListApiCall(filter: 'today');
    super.onInit();
  }
}



class ShortedData {
  String date;
  List<dynamic> data;

  ShortedData({
    required this.date,
    required this.data,
  });
}