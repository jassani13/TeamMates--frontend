import 'package:base_code/model/home_model.dart';
import 'package:base_code/model/schedule_model.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';

class HomeController extends GetxController {
  Rxn<HomeModel> homeModel = Rxn<HomeModel>();
  RxBool isShimmer = false.obs;
  RxString contact = "".obs;
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> getHomeDetailsApiCall() async {
    try {
      isShimmer.value = true;
      String? fcmToken = AppPref().fcmToken;
      var data = {
        "user_id": AppPref().userId,
        "fcm_token": fcmToken,
      };
      debugPrint("getHomeDetailsApiCall:$data");
      var res = await callApi(
        dio.post(
          ApiEndPoint.homeDetails,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        homeModel.value = HomeModel.fromJson(jsonData);
        await _injectExternalUpcomingActivities();
        isShimmer.value = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      isShimmer.value = false;
    }
  }

  Future<void> getCoachApiCall() async {
    try {
      var data = {
        "user_id": AppPref().userId,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.getMyCoachDetails,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        contact.value =
            jsonData["data"]["emergency_contact"] ?? "Not Added yet";
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _injectExternalUpcomingActivities() async {
    final data = homeModel.value?.data;
    if (data == null) return;

    final List<ScheduleData> internal =
        List<ScheduleData>.from(data.upcomingActivities ?? []);
    final List<ScheduleData> external = await _fetchUpcomingExternalEvents();

    if (external.isEmpty && internal.isEmpty) {
      data.upcomingActivities = [];
      homeModel.refresh();
      return;
    }

    final combined = [...internal, ...external];
    combined.sort((a, b) {
      final aDate = _parseScheduleDateTime(a);
      final bDate = _parseScheduleDateTime(b);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });

    final Set<String> seenKeys = {};
    final List<ScheduleData> deduped = [];
    for (final item in combined) {
      final key = _buildUpcomingKey(item);
      if (key.isNotEmpty && seenKeys.contains(key)) {
        continue;
      }
      if (key.isNotEmpty) {
        seenKeys.add(key);
      }
      deduped.add(item);
      if (deduped.length == 3) break;
    }

    data.upcomingActivities = deduped;
    homeModel.refresh();
  }

  Future<List<ScheduleData>> _fetchUpcomingExternalEvents() async {
    final List<ScheduleData> events = [];
    if (AppPref().userId == null) return events;

    try {
      final response = await callApi(
        dio.post(
          ApiEndPoint.getWebCalList,
          data: {
            'user_id': AppPref().userId,
          },
        ),
        false,
      );

      if (response?.statusCode != 200) {
        return events;
      }

      final List<dynamic> links = response?.data['data'] ?? [];
      if (links.isEmpty) {
        return events;
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
      for (final list in results) {
        events.addAll(list);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch external upcoming events: $e');
      }
    }

    return events;
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
        if (!_isUpcomingOrToday(startLocal)) {
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
        print('Failed to load ICS for home upcoming: $e');
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

  bool _isUpcomingOrToday(DateTime dateTime) {
    final DateTime today = DateTime.now();
    final DateTime normalizedToday =
        DateTime(today.year, today.month, today.day);
    final DateTime normalizedEvent =
        DateTime(dateTime.year, dateTime.month, dateTime.day);
    return !normalizedEvent.isBefore(normalizedToday);
  }

  DateTime? _parseScheduleDateTime(ScheduleData data) {
    final date = data.eventDate ?? data.startDate;
    if (date == null || date.isEmpty) return null;
    final time = (data.startTime != null && data.startTime!.isNotEmpty)
        ? data.startTime!
        : '00:00:00';
    try {
      return DateTime.parse('$date$time');
    } catch (_) {
      try {
        return DateTime.parse('$date $time');
      } catch (_) {
        return null;
      }
    }
  }

  String _buildUpcomingKey(ScheduleData data) {
    if (data.activityId != null) {
      return 'internal_${data.activityId}';
    }
    final calendarId = data.webCalId?.toString() ?? 'external';
    final date = data.eventDate ?? data.startDate ?? '';
    final start = data.startTime ?? '';
    final summary = data.activityName ?? '';
    if (date.isEmpty && summary.isEmpty) {
      return '';
    }
    return '$calendarId|$date|$start|$summary';
  }

  @override
  void onInit() {
    super.onInit();
    getHomeDetailsApiCall();
    if (AppPref().role == "team") {
      getCoachApiCall();
    }
  }
}
