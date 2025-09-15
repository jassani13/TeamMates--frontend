import 'package:base_code/module/bottom/schedule/calendar/calendar_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:collection/collection.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();

  static Widget buildExternalEventCard(Map<String, dynamic> event) {
    final String summary = event['summary']?.toString() ?? 'No Title';
    final String location = event['location']?.toString() ?? 'Unknown Location';
    final String description =
    cleanDescription(event['description']?.toString() ?? '');
    final String? mapUrl =
    extractMapUrl(event['description']?.toString() ?? '');

    final dynamic rawDt = event['dtstart']?.dt;
    final dynamic rawDtEnd = event['dtend']?.dt;

    if (rawDt == null || rawDtEnd == null) {
      return const SizedBox.shrink();
    }

    late DateTime start, end;
    try {
      start = DateTime.parse(rawDt.toString()).toLocal();
      end = DateTime.parse(rawDtEnd.toString()).toLocal();
    } catch (e) {
      return const SizedBox.shrink();
    }

    final String formattedDate = DateFormat('EEEE, MMMM d, y').format(start);
    final String formattedTime =
        '${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColor.black12Color.withOpacity(0.09),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Event Header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.2),
                child: Icon(Icons.event, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary,
                      style: TextStyle()
                          .normal16w700
                          .textColor(AppColor.black12Color),
                    ),
                    Text(
                      'External Calendar',
                      style: TextStyle().normal12w500.textColor(Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Date & Time
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                '$formattedDate | $formattedTime',
                style: TextStyle()
                    .normal14w500
                    .textColor(AppColor.black12Color.withOpacity(0.7)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Location
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle()
                      .normal14w500
                      .textColor(AppColor.black12Color.withOpacity(0.7)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// Description / Map Link
          if (mapUrl != null)
            InkWell(
              onTap: () async {
                final uri = Uri.parse(mapUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.map_outlined, size: 16, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    'View on Map',
                    style: TextStyle()
                        .normal14w600
                        .textColor(AppColor.primaryColorLight),
                  ),
                ],
              ),
            )
          else
            Text(
              description,
              style: TextStyle().normal14w500.textColor(AppColor.black12Color),
            ),
        ],
      ),
    );
  }
}

class _CalendarScreenState extends State<CalendarScreen> {
  final controller = Get.put(CalendarViewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CommonTitleText(text: "Calendar"),
        centerTitle: false,
        actions: [
          CommonAppButton(
            text: 'Subscribe',
            width: 90,
            height: 30,
            style: TextStyle().normal14w600,
            onTap: () {
              _showSubscribeDialog(context);
            },
          ),
          Gap(10),
          CommonAppButton(
            text: 'Unsubscribe',
            width: 90,
            height: 30,
            style: TextStyle().normal14w600,
            onTap: () {
              _showUnSubscribedDialog(context, controller);
            },
          ),
          Gap(20),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshCalendarData();
        },
        child: Column(
          children: [
            Obx(
              () => TableCalendar(
                key: ValueKey(controller.events.length),
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: controller.focusedDay.value,
                selectedDayPredicate: (day) {
                  final selected = controller.selectedDate.value;
                  if (selected == null) return false;
                  return isSameDay(day, selected);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  controller.selectedDate.value = selectedDay;
                  controller.focusedDay.value = focusedDay;
                  controller.updateSelectedDayEvents(selectedDay);
                },
                eventLoader: (day) {
                  final key = DateTime(day.year, day.month, day.day);
                  return controller.events[key] ?? [];
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox();

                    // Group events by type with null safety
                    final internalEvents = events
                        .where((e) =>
                            e != null &&
                            e is Map<String, dynamic> &&
                            e['type'] == 'internal_schedule')
                        .toList();
                    final externalEvents = events
                        .where((e) =>
                            e != null &&
                            e is Map<String, dynamic> &&
                            e['type'] == 'external_calendar')
                        .toList();

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Internal events marker (blue)
                        if (internalEvents.isNotEmpty)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0.5, vertical: 1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.primaryColorLight,
                            ),
                          ),
                        // External events marker (green)
                        if (externalEvents.isNotEmpty)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0.5, vertical: 1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColor.black12Color,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle:
                      TextStyle().normal14w500.textColor(AppColor.black12Color),
                  defaultTextStyle:
                      TextStyle().normal14w500.textColor(AppColor.black12Color),
                  outsideTextStyle:
                      TextStyle().normal14w500.textColor(AppColor.grey300),
                  markersMaxCount: 3,
                  markersAlignment: Alignment.bottomCenter,
                  markerDecoration: const BoxDecoration(),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekendStyle:
                      TextStyle().normal14w500.textColor(AppColor.black12Color),
                  weekdayStyle:
                      TextStyle().normal14w500.textColor(AppColor.black12Color),
                ),
                headerStyle: const HeaderStyle(
                  titleTextStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  formatButtonVisible: false,
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: Colors.black),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Legend for event types
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.primaryColorLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Team Events',
                        style: TextStyle()
                            .normal12w500
                            .textColor(AppColor.black12Color),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'External Calendars',
                        style: TextStyle()
                            .normal12w500
                            .textColor(AppColor.black12Color),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Obx(() {
                final events = controller.selectedDayEvents;

                if (events.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_busy,
                              size: 80,
                              color:
                                  AppColor.primaryColorLight.withOpacity(0.7)),
                          const SizedBox(height: 16),
                          Text(
                            "No events for selected date",
                            textAlign: TextAlign.center,
                            style: TextStyle()
                                .normal16w600
                                .textColor(AppColor.grey4EColor),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final bool isInternalEvent =
                        event['type'] == 'internal_schedule';

                    return _buildEventCard(event, isInternalEvent);
                  },
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, bool isInternalEvent) {
    if (isInternalEvent) {
      return _buildInternalEventCard(event);
    } else {
      return CalendarScreen.buildExternalEventCard(event);
    }
  }

  Widget _buildInternalEventCard(Map<String, dynamic> event) {
    final String summary = event['summary']?.toString() ?? 'Team Event';
    final String description = event['description']?.toString() ?? '';
    final String location = event['location']?.toString() ?? '';
    final String activityType = event['activity_type']?.toString() ?? 'event';
    final String uniform = event['uniform']?.toString() ?? '';
    final String arriveEarly = event['arrive_early']?.toString() ?? '';
    final String duration = event['duration']?.toString() ?? '';

    // Parse date/time with null safety
    final dynamic startDtRaw = event['dtstart']?['dt'];
    final dynamic endDtRaw = event['dtend']?['dt'];

    if (startDtRaw == null || endDtRaw == null) {
      return const SizedBox.shrink();
    }

    final String startDt = startDtRaw.toString();
    final String endDt = endDtRaw.toString();

    late DateTime start, end;
    try {
      start = DateTime.parse(startDt);
      end = DateTime.parse(endDt);
    } catch (e) {
      return const SizedBox.shrink();
    }

    final String formattedDate = DateFormat('EEEE, MMMM d, y').format(start);
    final String formattedTime =
        '${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}';

    return GestureDetector(
      onTap: () {
        // Navigate to game progress or event details
        final userBy = event['user_by'];
        final activityId = event['activity_id'];
        if (userBy != null && activityId != null) {
          Get.toNamed(AppRouter.gameProgress, arguments: {
            'user_by': userBy,
            'activity_id': activityId,
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.primaryColorLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColor.black12Color.withOpacity(0.09),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Event Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColor.primaryColorLight.withOpacity(0.2),
                  child: Icon(
                    activityType == 'game' ? Icons.sports_soccer : Icons.event,
                    color: AppColor.primaryColorLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary,
                        style: TextStyle()
                            .normal16w700
                            .textColor(AppColor.black12Color),
                      ),
                      Text(
                        activityType == 'game' ? 'Game' : 'Team Event',
                        style: TextStyle()
                            .normal12w500
                            .textColor(AppColor.primaryColorLight),
                      ),
                    ],
                  ),
                ),
                if (event['is_live'] == 1)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'LIVE',
                      style: TextStyle().normal10w600.textColor(Colors.white),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            /// Date & Time
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '$formattedDate | $formattedTime',
                  style: TextStyle()
                      .normal14w500
                      .textColor(AppColor.black12Color.withOpacity(0.7)),
                ),
              ],
            ),

            if (location.isNotEmpty) ...[
              const SizedBox(height: 8),

              /// Location
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle()
                          .normal14w500
                          .textColor(AppColor.black12Color.withOpacity(0.7)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            if (uniform.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.checkroom, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Uniform: $uniform',
                    style: TextStyle()
                        .normal14w500
                        .textColor(AppColor.black12Color.withOpacity(0.7)),
                  ),
                ],
              ),
            ],

            if (arriveEarly.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Arrive Early: $arriveEarly minutes',
                    style: TextStyle()
                        .normal14w500
                        .textColor(AppColor.black12Color.withOpacity(0.7)),
                  ),
                ],
              ),
            ],

            if (description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                description,
                style:
                    TextStyle().normal14w500.textColor(AppColor.black12Color),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String cleanDescription(String raw) {
    return raw.split('\r\n').firstWhere(
          (line) => !line.toLowerCase().startsWith('map'),
          orElse: () => '',
        );
  }

  static String? extractMapUrl(String raw) {
    final mapRegex = RegExp(r'(http[s]?:\/\/maps\.google\.com\?q=[^\s]+)');
    final match = mapRegex.firstMatch(raw);
    return match?.group(0);
  }

  void _showSubscribeDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.all(20),
          children: [
            Text(
              'Enter Calendar URL',
              style: TextStyle().normal20w600.textColor(AppColor.black12Color),
            ),
            Gap(20),
            CommonTextField(
              hintText: 'webcal://example.com/calendar.ics',
              controller: urlController,
              maxLine: 2,
            ),
            Gap(20),
            // FIXED: Stack buttons vertically to prevent overflow
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CommonAppButton(
                        text: 'Cancel',
                        height: 40,
                        style: TextStyle().normal14w600,
                        onTap: () => Get.back(),
                      ),
                    ),
                    Gap(20),
                    Expanded(
                      child: CommonAppButton(
                        text: 'Subscribe',
                        height: 40,
                        style: TextStyle().normal14w600,
                        onTap: () async {
                          if (urlController.text.trim().isNotEmpty) {
                            String inputUrl = urlController.text.trim();
                            if (inputUrl.startsWith('webcal://')) {
                              inputUrl = inputUrl.replaceFirst(
                                  'webcal://', 'https://');
                            }
                            if (!mounted) return;
                            Navigator.of(context).pop();
                            await controller.addWebCallUrl(link: inputUrl);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Gap(12),
                SizedBox(
                  width: double.infinity,
                  child: CommonAppButton(
                    text: 'Import from CSV',
                    height: 40,
                    style: TextStyle().normal14w600,
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['csv'],
                              withData: true);

                      if (result != null && result.files.single.bytes != null) {
                        String csvString =
                            utf8.decode(result.files.single.bytes!);
                        List<List<dynamic>> rows =
                            const CsvToListConverter().convert(csvString);

                        // Correct header
                        List<String> expectedHeader = [
                          'date',
                          'start_time',
                          'end_time',
                          'event_type',
                          'title',
                          'team_name',
                          'location',
                          'opponent'
                        ];

                        if (rows.isEmpty ||
                            !ListEquality().equals(rows[0], expectedHeader)) {
                          showAppErrorDialog(context, "CSV Import Error", [
                            'Invalid CSV header. Expected: ${expectedHeader.join(", ")}.'
                          ]);
                          return;
                        }

                        List<String> errors = [];
                        List<Map<String, dynamic>> validEvents = [];

                        for (int i = 1; i < rows.length; i++) {
                          var row = rows[i];
                          if (row.length != expectedHeader.length) {
                            errors.add(
                                'Row ${i + 1}: Incorrect number of columns.');
                            continue;
                          }

                          // Map row to event
                          final event = <String, dynamic>{};
                          for (int j = 0; j < expectedHeader.length; j++) {
                            event[expectedHeader[j]] =
                                row[j]?.toString().trim() ?? '';
                          }

                          final eventType = (event['event_type'] ?? '')
                              .toString()
                              .toLowerCase();

                          // Validation for required fields
                          if (eventType == 'game') {
                            // For game, all fields are required
                            bool missing = false;
                            for (final field in expectedHeader) {
                              if ((event[field] ?? '').toString().isEmpty) {
                                errors.add(
                                    'Row ${i + 1}: Field "$field" is required for event_type "game".');
                                missing = true;
                              }
                            }
                            if (missing) continue;
                          } else {
                            // For non-game, team_name and opponent can be blank, others required
                            for (final field in expectedHeader) {
                              if ((field == 'team_name' || field == 'opponent')) {
                                continue;
                              }
                              if ((event[field] ?? '').toString().isEmpty) {
                                errors.add(
                                    'Row ${i + 1}: Field "$field" is required for event_type "$eventType".');
                              }
                            }
                            // If any required field is missing, skip this row
                            if (errors.isNotEmpty &&
                                errors.last.startsWith('Row ${i + 1}:')) {
                              continue;
                            }
                          }

                          validEvents.add(event);
                        }

                        if (errors.isNotEmpty) {
                          showAppErrorDialog(
                              context, "CSV Import Errors", errors);
                        } else {
                          List<String> errorsReturned =
                              await controller.addEventsFromCsv(validEvents);
                          if (errorsReturned.isNotEmpty) {
                            showAppErrorDialog(
                                context, "CSV Import Errors", errorsReturned);
                          } else if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showUnSubscribedDialog(
      BuildContext context, CalendarViewController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.all(20),
          children: [
            Text(
              'Calendar URLs',
              style: TextStyle().normal20w600.textColor(AppColor.black12Color),
            ),
            Gap(20),
            Obx(() {
              final links = controller.calendarLinks;
              return SizedBox(
                width: double.maxFinite,
                child: links.isEmpty
                    ? Text(
                        "No calendar links found.",
                        style: TextStyle()
                            .normal16w500
                            .textColor(AppColor.grey4EColor),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: links.length,
                        itemBuilder: (context, index) {
                          final link = links[index]['link'];
                          final linkId = links[index]['web_cal_id'];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              link,
                              style: TextStyle()
                                  .normal16w500
                                  .textColor(AppColor.black12Color),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                Get.back();
                                await controller.unsubscribeLink(linkId);
                              },
                            ),
                          );
                        },
                      ),
              );
            }),
          ],
        );
      },
    );
  }

  void showAppErrorDialog(
      BuildContext context, String title, List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle().normal18w700.textColor(AppColor.redColor),
              ),
              const SizedBox(height: 12),
              ...errors.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error, color: AppColor.redColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e,
                            style: TextStyle()
                                .normal14w500
                                .textColor(AppColor.black12Color),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close',
                      style: TextStyle()
                          .normal16w600
                          .textColor(AppColor.redColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
