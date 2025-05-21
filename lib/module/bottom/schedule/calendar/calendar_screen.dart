import 'package:base_code/module/bottom/schedule/calendar/calendar_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter/gestures.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
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
      body: Column(
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
                controller.updateSelectedDayEvents(selectedDay); // <--- Add this
              },
              eventLoader: (day) {
                final key = DateTime(day.year, day.month, day.day);
                return controller.events[key] ?? [];
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return const SizedBox();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.take(3).map((event) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      );
                    }).toList(),
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
                weekendTextStyle: TextStyle().normal14w500.textColor(AppColor.black12Color),
                defaultTextStyle: TextStyle().normal14w500.textColor(AppColor.black12Color),
                outsideTextStyle: TextStyle().normal14w500.textColor(AppColor.grey300),
                markersMaxCount: 3,
                markersAlignment: Alignment.bottomCenter,
                markerDecoration: const BoxDecoration(),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekendStyle: TextStyle().normal14w500.textColor(AppColor.black12Color),
                weekdayStyle: TextStyle().normal14w500.textColor(AppColor.black12Color),
              ),
              headerStyle: const HeaderStyle(
                titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                formatButtonVisible: false,
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                        Icon(Icons.event_busy, size: 80, color: AppColor.primaryColorLight.withOpacity(0.7)),
                        const SizedBox(height: 16),
                        Text(
                          "No events for selected date",
                          textAlign: TextAlign.center,
                          style: TextStyle().normal16w600.textColor(AppColor.grey4EColor),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  print(event);
                  final String summary = event['summary'] ?? 'No Title';
                  final String location = event['location'] ?? 'Unknown Location';
                  final String description = cleanDescription(event['description'] ?? '');
                  final String? mapUrl = extractMapUrl(event['description'] ?? '');

                  final rawDt = event['dtstart'].dt;
                  final start = DateTime.parse(rawDt);

                  final rawDtEnd = event['dtend'].dt;
                  final end = DateTime.parse(rawDtEnd);
                  final String formattedDate = DateFormat('EEEE, MMMM d, y').format(start);
                  final String formattedTime = '${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(16),
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
                              child: Icon(Icons.event, color: AppColor.primaryColorLight),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                summary,
                                style: TextStyle().normal16w700.textColor(AppColor.black12Color),
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
                              style: TextStyle().normal14w500.textColor(AppColor.black12Color.withOpacity(0.7)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// Location
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle().normal14w500.textColor(AppColor.black12Color.withOpacity(0.7)),
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
                                  style: TextStyle().normal14w600.textColor(AppColor.primaryColorLight),
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
                },
              );
            }),
          )
        ],
      ),
    );
  }

  String cleanDescription(String raw) {
    return raw.split('\r\n').firstWhere(
          (line) => !line.toLowerCase().startsWith('map'),
          orElse: () => '',
        );
  }

  String? extractMapUrl(String raw) {
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
            Row(
              children: [
                Expanded(
                  child: CommonAppButton(
                    text: 'Cancel',
                    width: 80,
                    height: 40,
                    style: TextStyle().normal14w600,
                    onTap: () => Get.back(),
                  ),
                ),
                Gap(20),
                Expanded(
                  child: CommonAppButton(
                    text: 'Subscribe',
                    width: 80,
                    height: 40,
                    style: TextStyle().normal14w600,
                    onTap: () async {
                      if (urlController.text.trim().isNotEmpty) {
                        String inputUrl = urlController.text.trim();
                        if (inputUrl.startsWith('webcal://')) {
                          inputUrl = inputUrl.replaceFirst('webcal://', 'https://');
                        }
                        Navigator.of(context).pop();
                        await controller.addWebCallUrl(link: inputUrl);
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void _showUnSubscribedDialog(BuildContext context, CalendarViewController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        style: TextStyle().normal16w500.textColor(AppColor.grey4EColor),
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
                              style: TextStyle().normal16w500.textColor(AppColor.black12Color),
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
}
