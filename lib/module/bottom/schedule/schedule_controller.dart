import 'package:base_code/module/bottom/home/home_controller.dart';
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

  RxBool isLoading = false.obs;

  Future<void> getScheduleListApiCall(
      {String? filter, startDate, endDate}) async {
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
        var list = (jsonData['data'] as List)
            .map((e) => ScheduleData.fromJson(e))
            .toList();
        if (filter?.toLowerCase() == "past") {
          for (var item in list) {
            item.isLive = 0;
          }
        }

        Map<String, List<ScheduleData>> groupedData = {};

        for (var item in list) {
          if (item.isMultiDayEvent) {
            // Multi-day event: add to all dates in the range
            try {
              DateTime start = DateTime.parse(item.startDate!);
              DateTime end = DateTime.parse(item.endDate!);

              for (DateTime date = start;
                  date.isBefore(end.add(Duration(days: 1)));
                  date = date.add(Duration(days: 1))) {
                String dateKey =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                if (!groupedData.containsKey(dateKey)) {
                  groupedData[dateKey] = [];
                }
                groupedData[dateKey]!.add(item);
              }
            } catch (e) {
              // If date parsing fails, fall back to start date only
              String date = item.effectiveStartDate ?? "";
              if (date.isNotEmpty) {
                if (!groupedData.containsKey(date)) {
                  groupedData[date] = [];
                }
                groupedData[date]!.add(item);
              }
            }
          } else {
            // Single-day event: use effective start date
            String date = item.effectiveStartDate ?? "";
            if (date.isNotEmpty) {
              if (!groupedData.containsKey(date)) {
                groupedData[date] = [];
              }
              groupedData[date]!.add(item);
            }
          }
        }

        if ((filter?.toLowerCase() == 'upcoming') &&
            startDate == null &&
            endDate == null) {
          final externalEntries = await _fetchExternalUpcomingEvents();
          externalEntries.forEach((key, value) {
            if (!groupedData.containsKey(key)) {
              groupedData[key] = [];
            }
            groupedData[key]!.addAll(value);
          });
        }

        // Convert to sorted list and format dates for display
        var sortedEntries = groupedData.entries.toList();
        sortedEntries.sort((a, b) => a.key.compareTo(b.key));

        // Apply additional filtering based on the selected filter OR date range
        if (filter != null) {
          sortedEntries =
              _filterEntriesByDate(sortedEntries, filter.toLowerCase());
        } else if (startDate != null && endDate != null) {
          // Handle manual date range filtering
          sortedEntries =
              _filterEntriesByDateRange(sortedEntries, startDate, endDate);
        }

        sortedScheduleList.assignAll(sortedEntries.map((entry) {
          // Format date for display
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

// ADD this helper method to ScheduleController class:
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

// ADD this additional helper method:
  List<MapEntry<String, List<ScheduleData>>> _filterEntriesByDate(
      List<MapEntry<String, List<ScheduleData>>> entries, String filter) {
    try {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      String todayString =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

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
              return entryDate.isAfter(today) ||
                  entryDate.isAtSameMomentAs(today);
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

// ADD this method for manual date range filtering:
  List<MapEntry<String, List<ScheduleData>>> _filterEntriesByDateRange(
      List<MapEntry<String, List<ScheduleData>>> entries,
      String startDate,
      String endDate) {
    try {
      DateTime start = DateTime.parse(startDate);
      DateTime end = DateTime.parse(endDate);

      return entries.where((entry) {
        try {
          DateTime entryDate = DateTime.parse(entry.key);
          return (entryDate.isAfter(start) ||
                  entryDate.isAtSameMomentAs(start)) &&
              (entryDate.isBefore(end) || entryDate.isAtSameMomentAs(end));
        } catch (e) {
          return false;
        }
      }).toList();
    } catch (e) {
      return entries;
    }
  }

  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

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

  Future<Map<String, List<ScheduleData>>> _fetchExternalUpcomingEvents() async {
    final Map<String, List<ScheduleData>> grouped = {};
    if (AppPref().userId == null) {
      return grouped;
    }
    try {
      var response = await callApi(
        dio.post(
          ApiEndPoint.getWebCalList,
          data: {
            'user_id': AppPref().userId,
          },
        ),
        false,
      );

      if (response?.statusCode != 200) {
        return grouped;
      }

      final List<dynamic> links = response?.data['data'] ?? [];
      if (links.isEmpty) {
        return grouped;
      }

      final futures = links.map<Future<List<ScheduleData>>>((link) {
        final String rawLink = link['link']?.toString() ?? '';
        final int? webCalId = link['web_cal_id'];
        if (rawLink.isEmpty || webCalId == null) {
          return Future.value(<ScheduleData>[]);
        }
        return _loadIcsEventsFromUrl(rawLink, webCalId);
      }).toList();

      final results = await Future.wait(futures);
      final Set<String> seenExternalKeys = {};
      for (final scheduleList in results) {
        for (final schedule in scheduleList) {
          final String dedupKey = _buildExternalEventKey(schedule);
          if (dedupKey.isNotEmpty && seenExternalKeys.contains(dedupKey)) {
            continue;
          }
          if (dedupKey.isNotEmpty) {
            seenExternalKeys.add(dedupKey);
          }
          final String dateKey = schedule.effectiveStartDate ?? '';
          if (dateKey.isEmpty) continue;
          if (!grouped.containsKey(dateKey)) {
            grouped[dateKey] = [];
          }
          grouped[dateKey]!.add(schedule);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch external events: $e');
      }
    }
    return grouped;
  }

  Future<List<ScheduleData>> _loadIcsEventsFromUrl(
      String url, int webCalId) async {
    final List<ScheduleData> events = [];
    try {
      final normalizedUrl = url.startsWith('webcal://')
          ? url.replaceFirst('webcal://', 'https://')
          : url;
      final response = await http.get(Uri.parse(normalizedUrl));
      if (response.statusCode != 200) {
        return events;
      }

      final ICalendar ical = ICalendar.fromString(response.body);
      for (var event in ical.data) {
        if (event['type'] != 'VEVENT') continue;

        final DateTime? start = _extractDateTime(event['dtstart']);
        final DateTime? end = _extractDateTime(event['dtend']) ?? start;
        if (start == null) continue;

        final DateTime startLocal = start.toLocal();
        final DateTime endLocal = (end ?? start).toLocal();
        if (!_isUpcomingDate(startLocal)) {
          continue;
        }

        final String eventDate = DateFormat('yyyy-MM-dd').format(startLocal);
        final schedule = ScheduleData(
          activityType: 'external',
          activityName:
              (event['summary'] ?? 'External Event').toString().trim(),
          locationDetails: event['location']?.toString(),
          notes: event['description']?.toString(),
        )
          ..isExternal = true
          ..webCalId = webCalId
          ..externalCalendarLink = normalizedUrl
          ..externalDescription = event['description']?.toString()
          ..eventDate = eventDate
          ..startTime = DateFormat('HH:mm:ss').format(startLocal)
          ..endTime = DateFormat('HH:mm:ss').format(endLocal);

        final locationText = event['location']?.toString();
        if (locationText != null && locationText.isNotEmpty) {
          schedule.location = Locationn(
            address: locationText,
            location: locationText,
          );
        }

        events.add(schedule);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load ICS from $url: $e');
      }
    }
    return events;
  }

  DateTime? _extractDateTime(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is IcsDateTime) return raw.toDateTime();
    if (raw is Map && raw['dt'] != null) {
      return _extractDateTime(raw['dt']);
    }
    if (raw is String) {
      try {
        return DateTime.parse(raw);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  bool _isUpcomingDate(DateTime dateTime) {
    final DateTime today = DateTime.now();
    final DateTime normalizedToday =
        DateTime(today.year, today.month, today.day);
    final DateTime normalizedEvent =
        DateTime(dateTime.year, dateTime.month, dateTime.day);
    return !normalizedEvent.isBefore(normalizedToday);
  }

  String _buildExternalEventKey(ScheduleData data) {
    final calendarId = data.webCalId?.toString() ?? '';
    final date = data.eventDate ?? data.startDate ?? '';
    final start = data.startTime ?? '';
    final summary = data.activityName ?? '';
    if (calendarId.isEmpty && date.isEmpty && summary.isEmpty) {
      return '';
    }
    return '$calendarId|$date|$start|$summary';
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
