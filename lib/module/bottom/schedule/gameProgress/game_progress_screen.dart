import 'package:base_code/module/bottom/schedule/schedule_screen.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:url_launcher/url_launcher_string.dart';

class GameProgressScreen extends StatelessWidget {
  GameProgressScreen({super.key});

  final controller = Get.put<GameProgressController>(GameProgressController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        actions: [
          if (AppPref().role == "coach")
            CommonIconButton(
              image: AppImage.delete,
              onTap: () {
                showAlertDialog(
                  btn2Text: "Yes",
                  title: "Are you sure you want to\ndelete your activity?",
                  context: context,
                  btn2Tap: () async {
                    Get.back();
                    await controller.deleteActivity();
                  },
                );
              },
            ),
          Gap(10),
          if (AppPref().role == "coach")
            CommonIconButton(
              image: AppImage.edit,
              onTap: () {
                Get.toNamed(
                  AppRouter.addGame,
                  arguments: {
                    "activity":
                        controller.activityDetails.value.data?.activityType ??
                            "",
                    "activityDetail": controller.activityDetails.value.data,
                  },
                )?.then((result) {
                  if (result != null) {
                    controller.activityDetails.value.data = result;
                    controller.activityDetails.refresh();
                  }
                });
              },
            ),
          Gap(16),
        ],
        title: Obx(
          () => CommonTitleText(
            text: ((controller.activityDetails.value.data?.activityType ??
                        "") ==
                    "game")
                ? "${controller.activityDetails.value.data?.team?.name ?? ""} vs ${controller.activityDetails.value.data?.opponent?.opponentName ?? ""}"
                : controller.activityDetails.value.data?.activityName ?? "",
          ),
        ),
      ),
      body: Obx(() {
        return controller.isLoading.value
            ? SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Gap(8),
                          if (AppPref().role == "coach")
                            Row(
                              children: [
                                Text(
                                  "Go Live with this ${controller.activityDetails.value.data?.activityType}",
                                  style: TextStyle().normal16w500.textColor(
                                        AppColor.black12Color,
                                      ),
                                ),
                                Spacer(),
                                Obx(
                                  () => Switch(
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      value: controller.isLive.value,
                                      activeColor: AppColor.redColor,
                                      onChanged: (val) async {
                                        controller.isLive.value =
                                            !controller.isLive.value;
                                        controller.gameLiveStatus();
                                      }),
                                )
                              ],
                            ),
                        ],
                      ),

                      // NEW: RSVP Nudge Section (Coach Only)
                      if (AppPref().role == "coach") ...[
                        Gap(16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColor.greyF6Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.notifications_outlined,
                                    color: AppColor.black12Color,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "RSVP Management",
                                    style: TextStyle()
                                        .normal16w500
                                        .textColor(AppColor.black12Color),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Send a reminder to team members who haven't responded yet.",
                                style: TextStyle()
                                    .normal14w400
                                    .textColor(AppColor.grey6EColor),
                              ),
                              SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: (controller.activityDetails.value
                                              .data?.canSendNudge ??
                                          true)
                                      ? () => _showNudgeConfirmation(context)
                                      : null,
                                  icon: Icon(
                                    Icons.send_outlined,
                                    size: 18,
                                    color: (controller.activityDetails.value
                                                .data?.canSendNudge ??
                                            true)
                                        ? AppColor.white
                                        : AppColor.grey6EColor,
                                  ),
                                  label: Text(
                                    (controller.activityDetails.value.data
                                                ?.canSendNudge ??
                                            true)
                                        ? "Send Nudge to Unanswered"
                                        : "Nudge Sent Recently",
                                    style: TextStyle().normal14w500.textColor(
                                          (controller.activityDetails.value.data
                                                      ?.canSendNudge ??
                                                  true)
                                              ? AppColor.white
                                              : AppColor.grey6EColor,
                                        ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (controller.activityDetails
                                                .value.data?.canSendNudge ??
                                            true)
                                        ? AppColor.black12Color
                                        : AppColor.greyEAColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              if (controller.activityDetails.value.data
                                      ?.lastNudgeSent !=
                                  null) ...[
                                SizedBox(height: 8),
                                Text(
                                  "Last nudge sent: ${_formatLastNudgeTime(controller.activityDetails.value.data!.lastNudgeSent!)}",
                                  style: TextStyle()
                                      .normal12w400
                                      .textColor(AppColor.grey6EColor),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      // EXISTING CODE CONTINUES - All your existing widgets stay the same
                      Gap(16),
                      Row(
                        children: [
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonTitleText(
                                text: (controller.activityDetails.value.data
                                            ?.eventDate?.isNotEmpty ??
                                        false)
                                    ? DateFormat('EEEE, MMMM d, y').format(
                                        DateTime.parse(controller
                                                .activityDetails
                                                .value
                                                .data
                                                ?.eventDate ??
                                            ''))
                                    : '',
                              ),
                              if (controller.activityDetails.value.data
                                          ?.startTime !=
                                      null ||
                                  controller.activityDetails.value.data
                                          ?.endTime !=
                                      null)
                                Text(
                                  DateUtilities.formatTime(
                                      controller.activityDetails.value.data
                                              ?.startTime ??
                                          "",
                                      controller.activityDetails.value.data
                                              ?.endTime ??
                                          ""),
                                  style: TextStyle().normal16w500.textColor(
                                        AppColor.grey4EColor,
                                      ),
                                ),
                            ],
                          )),
                          Visibility(
                            visible:
                                controller.activityDetails.value.data?.isLive ==
                                    1,
                            child: GestureDetector(
                              onTap: () {
                                launchURL(
                                    'https://watch.livebarn.com/en/signin');
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 9),
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColor.greyEAColor,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 12,
                                      width: 12,
                                      decoration: BoxDecoration(
                                        color: AppColor.redColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Gap(10),
                                    Text(
                                      "WATCH",
                                      style: TextStyle().normal16w500.textColor(
                                            AppColor.redColor,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ALL YOUR EXISTING WIDGETS CONTINUE HERE...
                      // (Game in progress section, location, activity details, etc.)
                      // I'm keeping them as they were in your original code

                      Visibility(
                        visible:
                            (controller.activityDetails.value.data?.isLive ==
                                    1 &&
                                ((controller.activityDetails.value.data
                                            ?.activityType ??
                                        "") ==
                                    "game")),
                        child: Column(
                          children: [
                            Gap(16),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  AppRouter.liveScore,
                                  arguments: {
                                    'activity_data':
                                        controller.activityDetails.value.data,
                                  },
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ),
                                  color: AppColor.black12Color,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Game in progress",
                                      style: TextStyle().normal16w500.textColor(
                                            AppColor.white,
                                          ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: AppColor.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Obx(() {
                        return (controller.activityDetails.value.data?.reason ??
                                    "")
                                .isEmpty
                            ? Gap(24)
                            : Column(
                                children: [
                                  Gap(24),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: AppColor.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColor.greyEAColor,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 12,
                                          width: 12,
                                          decoration: BoxDecoration(
                                            color: AppColor.redColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Gap(10),
                                        Expanded(
                                          child: Text(
                                            "Canceled - Due to ${controller.activityDetails.value.data?.reason ?? "-"}",
                                            style: TextStyle()
                                                .normal16w500
                                                .textColor(
                                                  AppColor.redColor,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Gap(12),
                                ],
                              );
                      }),

                      // ALL YOUR EXISTING buildContainer WIDGETS...
                      buildContainer(
                          image: AppImage.location,
                          isIcon: true,
                          heading: controller.activityDetails.value.data
                                  ?.location?.address ??
                              "-",
                          subHeading: "Open in google map",
                          value: "Location",
                          onSubHeadingTap: () {
                            openGoogleMaps(
                              address: controller.activityDetails.value.data
                                  ?.location?.address,
                              googleMapLink: controller
                                  .activityDetails.value.data?.location?.link,
                              lat: double.parse(controller.activityDetails.value
                                      .data?.location?.latitude ??
                                  "0.0"),
                              lng: double.parse(controller.activityDetails.value
                                      .data?.location?.longitude ??
                                  "0.0"),
                            );
                          }),
                      buildContainer(
                        image: AppImage.activityName,
                        heading: controller
                                .activityDetails.value.data?.activityName ??
                            "-",
                        value: "Activity Name",
                        isIcon: false,
                      ),
                      buildContainer(
                        image: AppImage.locationDetail,
                        isIcon: false,
                        heading: controller
                                .activityDetails.value.data?.locationDetails ??
                            "-",
                        value: "Location Detail",
                      ),
                      GestureDetector(
                        onTap: () {
                          if ((controller.activityDetails.value.data?.team
                                      ?.playerTeams ??
                                  [])
                              .isNotEmpty) {
                            if (AppPref().role == "coach") {
                              Get.toNamed(AppRouter.participatedPlayer,
                                  arguments: controller.activityDetails.value
                                          .data?.team?.playerTeams ??
                                      []);
                            }
                          } else {
                            print("No player participated yet");
                            AppToast.showAppToast("No player participated yet");
                          }
                        },
                        child: buildContainer(
                          image: AppImage.player,
                          isIcon: true,
                          heading: ((controller.activityDetails.value.data?.team
                                          ?.playerTeams ??
                                      [])
                                  .isEmpty)
                              ? "-"
                              : (controller.activityDetails.value.data?.team
                                          ?.playerTeams ??
                                      [])
                                  .map((player) =>
                                      "${player.firstName} ${player.lastName}")
                                  .join(", "),
                          value: "Player List",
                        ),
                      ),

                      buildContainer(
                        image: AppImage.assignment,
                        isIcon: false,
                        heading: controller
                                .activityDetails.value.data?.assignments ??
                            "-",
                        value: "Assignment",
                      ),
                      buildContainer(
                        image: AppImage.duration,
                        isIcon: false,
                        heading: (controller
                                        .activityDetails.value.data?.duration ??
                                    "0")
                                .isEmpty
                            ? "-"
                            : DateUtilities.formatDuration(int.parse(controller
                                    .activityDetails.value.data?.duration ??
                                "0")),
                        value: "Duration",
                      ),
                      buildContainer(
                        image: AppImage.arriveEarly,
                        isIcon: false,
                        heading: controller
                                .activityDetails.value.data?.arriveEarly ??
                            "-",
                        value: "Arrive Early",
                      ),
                      buildContainer(
                        image: AppImage.uniform,
                        isIcon: false,
                        heading:
                            controller.activityDetails.value.data?.uniform ??
                                "-",
                        value: "Uniform",
                      ),
                      buildContainer(
                        image: AppImage.flag,
                        isIcon: false,
                        heading:
                            controller.activityDetails.value.data?.flagColor ??
                                "-",
                        value: "Flag Color",
                      ),
                      buildContainer(
                        image: AppImage.notes,
                        heading:
                            controller.activityDetails.value.data?.notes ?? "-",
                        isIcon: false,
                        value: "Notes",
                      ),
                      if ((controller
                                  .activityDetails.value.data?.activityType ??
                              "") ==
                          "game")
                        buildContainer(
                          isIcon: false,
                          isLast: true,
                          image: AppImage.opponents,
                          heading: controller.activityDetails.value.data
                                  ?.opponent?.opponentName ??
                              "-",
                          value: "Opponent",
                        ),

                      Gap(24),
                    ],
                  ),
                ),
              );
      }),
    );
  }

  // NEW: Show nudge confirmation dialog
  void _showNudgeConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Send RSVP Reminder",
            style: TextStyle().normal18w600.textColor(AppColor.black12Color),
          ),
          content: Text(
            "This will send a notification to all team members who haven't responded to this event yet. Are you sure?",
            style: TextStyle().normal14w400.textColor(AppColor.grey6EColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle().normal14w500.textColor(AppColor.grey6EColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendNudge();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.black12Color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Send Nudge",
                style: TextStyle().normal14w500.textColor(AppColor.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // NEW: Send nudge to unresponded players
  void _sendNudge() async {
    await Get.find<ScheduleController>().sendRsvpNudgeApiCall(
      activityId: controller.activityDetails.value.data?.activityId ?? 0,
    );

    // Refresh activity details to update nudge status
    // You might need to call your existing method to refresh the data
    // controller.getActivityDetails(); // Add this if you have such method
  }

  // NEW: Format last nudge time for display
  String _formatLastNudgeTime(String lastNudgeSent) {
    try {
      final DateTime nudgeTime = DateTime.parse(lastNudgeSent);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(nudgeTime);

      if (difference.inMinutes < 60) {
        return "${difference.inMinutes} minutes ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} hours ago";
      } else {
        return "${difference.inDays} days ago";
      }
    } catch (e) {
      return "Recently";
    }
  }

  // EXISTING buildContainer method - keep exactly as it was
  Widget buildContainer(
      {String? image,
      String? heading,
      String? subHeading,
      String? value,
      bool? isIcon = true,
      bool? isLast = false,
      final Function()? onSubHeadingTap}) {
    return GestureDetector(
      onTap: onSubHeadingTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: isLast == false
              ? Border(
                  bottom: BorderSide(
                    color: AppColor.greyEAColor,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: SvgPicture.asset(
                        image ?? AppImage.name,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                            AppColor.black12Color, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          heading ?? "1 Volunteer Needed",
                          style: TextStyle().normal16w500.textColor(
                                AppColor.black12Color,
                              ),
                        ),
                        Visibility(
                          visible: (subHeading ?? "").isNotEmpty,
                          child: GestureDetector(
                            onTap: onSubHeadingTap,
                            child: Text(
                              subHeading ?? "",
                              style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.black)
                                  .normal14w500
                                  .textColor(
                                    AppColor.black,
                                  ),
                            ),
                          ),
                        ),
                        Text(
                          value ??
                              "My assignments\nAttendance, clock, fieldprep, Photogragher",
                          style: TextStyle().normal14w500.textColor(
                                AppColor.grey6EColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Gap(16),
                ],
              ),
            ),
            if (isIcon == true) ...[
              Center(
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20,
                  color: AppColor.black12Color,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
