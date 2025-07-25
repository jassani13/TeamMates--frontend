import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';

class CalendarViewController extends GetxController {
  Rx<DateTime?> selectedDate = Rx<DateTime?>(DateTime.now());
  Rx<DateTime> focusedDay = DateTime.now().obs;
  RxList<dynamic> selectedDayEvents = <dynamic>[].obs;
  RxList<Map<String, dynamic>> calendarLinks = <Map<String, dynamic>>[].obs;

  // Separate storage for internal and external events
  RxMap externalEvents = {}.obs; // ICS events
  RxMap internalEvents = {}.obs; // Schedule events
  RxMap events = {}.obs; // Combined events for display

  void updateSelectedDayEvents(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    selectedDayEvents.value = events[key] ?? [];
  }

  // Load internal schedule events from the app's schedule API
  Future<void> loadInternalScheduleEvents() async {
    try {
      var data = {
        "user_id": AppPref().userId,
        // Get all events without filter to populate calendar
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
        
        // Clear existing internal events
        internalEvents.clear();
        
        // Process each schedule item
        for (var scheduleItem in list) {
          if (scheduleItem.eventDate != null) {
            // Parse the event date
            DateTime eventDate = DateFormat('yyyy-MM-dd').parse(scheduleItem.eventDate!);
            final eventDateKey = DateTime(eventDate.year, eventDate.month, eventDate.day);
            
            // Build event title from available data
            String eventTitle = scheduleItem.activityName ?? 'Team Event';
            if (scheduleItem.opponent?.opponentName != null) {
              eventTitle += ' vs ${scheduleItem.opponent!.opponentName}';
            }
            
            // Build description from notes and details
            String eventDescription = '';
            if (scheduleItem.notes != null && scheduleItem.notes!.isNotEmpty) {
              eventDescription = scheduleItem.notes!;
            }
            if (scheduleItem.assignments != null && scheduleItem.assignments!.isNotEmpty) {
              if (eventDescription.isNotEmpty) eventDescription += '\n';
              eventDescription += 'Assignments: ${scheduleItem.assignments}';
            }
            
            // Get location details
            String eventLocation = '';
            if (scheduleItem.location?.location != null) {
              eventLocation = scheduleItem.location!.location!;
              if (scheduleItem.location!.address != null) {
                eventLocation += ', ${scheduleItem.location!.address}';
              }
            } else if (scheduleItem.locationDetails != null) {
              eventLocation = scheduleItem.locationDetails!;
            }
            
            // Create start and end time strings
            String startTimeStr = scheduleItem.startTime ?? '00:00:00';
            String endTimeStr = scheduleItem.endTime ?? '23:59:59';
            
            // Handle time format if needed
            if (!startTimeStr.contains(':')) {
              startTimeStr = '00:00:00';
            }
            if (!endTimeStr.contains(':')) {
              endTimeStr = '23:59:59';
            }
            
            // Create internal event object compatible with calendar display
            final internalEvent = {
              'type': 'internal_schedule',
              'summary': eventTitle,
              'description': eventDescription,
              'location': eventLocation,
              'dtstart': {
                'dt': scheduleItem.eventDate! + 'T' + startTimeStr,
              },
              'dtend': {
                'dt': scheduleItem.eventDate! + 'T' + endTimeStr,
              },
              'activity_id': scheduleItem.activityId,
              'activity_name': scheduleItem.activityName,
              'activity_type': scheduleItem.activityType,
              'status': scheduleItem.status,
              'user_by': scheduleItem.userBy,
              'is_live': scheduleItem.isLive,
              'team_id': scheduleItem.teamId,
              'opponent': scheduleItem.opponent,
              'uniform': scheduleItem.uniform,
              'arrive_early': scheduleItem.arriveEarly,
              'duration': scheduleItem.duration,
            };
            
            // Add to internal events
            if (internalEvents[eventDateKey] == null) {
              internalEvents[eventDateKey] = [];
            }
            internalEvents[eventDateKey].add(internalEvent);
          }
        }
        
        // Merge with external events and update display
        _mergeEventsForDisplay();
        
        if (kDebugMode) {
          print("Internal schedule events loaded: ${internalEvents.length} dates");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to load internal schedule events: $e");
      }
    }
  }

  // Merge internal and external events for calendar display
  void _mergeEventsForDisplay() {
    events.clear();
    
    // Add internal events
    internalEvents.forEach((key, value) {
      events[key] = List.from(value);
    });
    
    // Add external events
    externalEvents.forEach((key, value) {
      if (events[key] == null) {
        events[key] = [];
      }
      events[key].addAll(value);
    });
    
    // Update selected day events if a date is selected
    if (selectedDate.value != null) {
      updateSelectedDayEvents(selectedDate.value!);
    }
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

        // Merge with internal events and update display
        _mergeEventsForDisplay();

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
        externalEvents.removeWhere((key, value) {
          return value.any((event) => event['web_cal_id'] == linkId);
        });

        // Update display
        _mergeEventsForDisplay();

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


  Future<List<String>> addEventsFromCsv(List<Map<String, dynamic>> events) async {
  final addGameController = AddGameController();
  List<String> errors = [];
  
  // Fetch existing data first
  await addGameController.getOpponentListApiCall();
  await addGameController.getRosterApiCall();
  await addGameController.getLocationListApiCall();
  
  for (int i = 0; i < events.length; i++) {
    final event = events[i];
    final rowNum = i + 2; // +2 for header and 0-index

    final dateRaw = (event['date'] ?? '').toString().trim();
    final startTimeRaw = (event['start_time'] ?? '').toString().trim();
    final endTimeRaw = (event['end_time'] ?? '').toString().trim();
    final eventType = (event['event_type'] ?? '').toString().trim().toLowerCase();
    final title = (event['title'] ?? '').toString().trim();
    final teamName = (event['team_name'] ?? '').toString().trim();
    final locationName = (event['location'] ?? '').toString().trim();
    final opponentName = (event['opponent'] ?? '').toString().trim();

    // Validate date format
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(dateRaw);
    } catch (_) {
      errors.add('Row $rowNum: Invalid date format "$dateRaw". Expected yyyy-MM-dd.');
      continue;
    }

    // Validate and parse time format
    DateTime? parsedStartTime;
    DateTime? parsedEndTime;
    try {
      parsedStartTime = DateFormat('HH:mm:ss').parseStrict(startTimeRaw);
    } catch (_) {
      errors.add('Row $rowNum: Invalid start_time format "$startTimeRaw". Expected HH:mm:ss.');
      continue;
    }
    try {
      parsedEndTime = DateFormat('HH:mm:ss').parseStrict(endTimeRaw);
    } catch (_) {
      errors.add('Row $rowNum: Invalid end_time format "$endTimeRaw". Expected HH:mm:ss.');
      continue;
    }

    // Convert to required format for API
    final formattedDate = DateFormat('yyyy/MM/dd').format(parsedDate);
    final formattedStartTime = DateFormat('HH:mm:ss').format(parsedStartTime);
    final formattedEndTime = DateFormat('HH:mm:ss').format(parsedEndTime);

    if (eventType == 'game') {
      // For game: require event_type, title, team_name, date, start_time, end_time, location, opponent
      if (event['event_type'] == '' || title == '' || teamName == '' || dateRaw == '' || startTimeRaw == '' || endTimeRaw == '' || opponentName == '' || locationName == '') {
        errors.add('Row $rowNum: For Game, event_type, title, team_name, date, start_time, end_time, location, and opponent are required.');
        continue;
      }
    } else {
      // For non-game: require event_type, title, date, start_time, end_time, location
      if (event['event_type'] == '' || title == '' || dateRaw == '' || startTimeRaw == '' || endTimeRaw == '' || locationName == '') {
        errors.add('Row $rowNum: For non-Game, event_type, title, date, start_time, end_time, and location are required.');
        continue;
      }
    }

    try {
      // Match team name to ID
      Roster? matchedTeam;
      if (eventType == 'game' && teamName.isNotEmpty) {
        matchedTeam = addGameController.allRosterModelList.firstWhere(
          (team) => team.name?.toLowerCase() == teamName.toLowerCase(),
          orElse: () => Roster(),
        );
        if (matchedTeam?.teamId == null) {
          errors.add('Row $rowNum: Team "$teamName" not found in existing teams.');
          continue;
        }
      }

      // Match opponent name to ID
      OpponentModel? matchedOpponent;
      if (eventType == 'game' && opponentName.isNotEmpty) {
        matchedOpponent = addGameController.opponentList.firstWhere(
          (opponent) => opponent.opponentName?.toLowerCase() == opponentName.toLowerCase(),
          orElse: () => OpponentModel(),
        );
        if (matchedOpponent?.opponentId == null) {
          errors.add('Row $rowNum: Opponent "$opponentName" not found in existing opponents.');
          continue;
        }
      }

      // Match location name to ID
      LocationData? matchedLocation;
      if (locationName.isNotEmpty) {
        matchedLocation = addGameController.locationList.firstWhere(
          (location) => location.address?.toLowerCase() == locationName.toLowerCase(),
          orElse: () => LocationData(),
        );
        if (matchedLocation?.locationId == null) {
          errors.add('Row $rowNum: Location "$locationName" not found in existing locations.');
          continue;
        }
      }

      // Set fields for AddGameController with matched IDs
      addGameController.activityType.value = event['event_type'] ?? '';
      addGameController.activityNameController.value.text = title;
      addGameController.dateController.value.text = formattedDate;
      addGameController.startTimeController.value.text = formattedStartTime;
      addGameController.endTimeController.value.text = formattedEndTime;
      
      // Set matched IDs
      if (eventType == 'game') {
        addGameController.selectedTeam.value = matchedTeam;
        addGameController.selectedOpponent.value = matchedOpponent;
        addGameController.teamController.value.text = matchedTeam?.name ?? '';
        addGameController.opponentController.value.text = matchedOpponent?.opponentName ?? '';
      } else {
        addGameController.selectedTeam.value = null;
        addGameController.selectedOpponent.value = null;
        addGameController.teamController.value.text = '';
        addGameController.opponentController.value.text = '';
      }
      
      addGameController.selectedLocation.value = matchedLocation;
      addGameController.locationController.value.text = matchedLocation?.address ?? '';

      // Call API to add activity
      await addGameController.addActivityApi(
        activityType: event['event_type'],
        isGame: eventType == 'game',
      );
    } catch (e) {
      errors.add('Row $rowNum: Failed to add event.  [1m${e.toString()} [0m');
    }
  }

  if (errors.isEmpty) {
    AppToast.showAppToast("All events imported successfully!");
  }
  return errors;
}

  // Refresh all calendar data
  Future<void> refreshCalendarData() async {
    await Future.wait([
      loadInternalScheduleEvents(),
      getWebCallUrl(),
    ]);
  }

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((val) {
      refreshCalendarData();
    });
  }
}
