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
                    "activity": controller.activityDetails.value.data?.activityType ?? "",
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
            text: ((controller.activityDetails.value.data?.activityType ?? "") == "game")
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
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      value: controller.isLive.value,
                                      activeColor: AppColor.redColor,
                                      onChanged: (val) async {
                                        controller.isLive.value = !controller.isLive.value;
                                        controller.gameLiveStatus();
                                      }),
                                )
                              ],
                            ),
                        ],
                      ),
                      Gap(16),
                      Row(
                        children: [
                          // Container(
                          //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(8),
                          //     color: AppColor.black12Color,
                          //   ),
                          //   child: Text(
                          //     "11",
                          //     style: TextStyle().normal20w500.textColor(
                          //           AppColor.white,
                          //         ),
                          //   ),
                          // ),
                          // Gap(16),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonTitleText(
                                text: DateUtilities.formatDate(controller.activityDetails.value.data?.eventDate ?? ""),
                              ),
                              if (controller.activityDetails.value.data?.startTime != null || controller.activityDetails.value.data?.endTime != null)
                                Text(
                                  DateUtilities.formatTime(
                                      controller.activityDetails.value.data?.startTime ?? "", controller.activityDetails.value.data?.endTime ?? ""),
                                  style: TextStyle().normal16w500.textColor(
                                        AppColor.grey4EColor,
                                      ),
                                ),
                            ],
                          )),

                          Visibility(
                            visible: controller.activityDetails.value.data?.isLive == 1,
                            child: GestureDetector(
                              onTap: () {
                                launchURL('https://watch.livebarn.com/en/signin');
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
                      Visibility(
                        visible: (controller.activityDetails.value.data?.isLive == 1 &&
                            ((controller.activityDetails.value.data?.activityType ?? "") == "game")),
                        child: Column(
                          children: [
                            Gap(16),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  AppRouter.liveScore,
                                  arguments: {
                                    'activity_data': controller.activityDetails.value.data,
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
                        return (controller.activityDetails.value.data?.reason ?? "").isEmpty
                            ? Gap(24)
                            : Column(
                                children: [
                                  Gap(24),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
                                            style: TextStyle().normal16w500.textColor(
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
                      buildContainer(
                          image: AppImage.location,
                          isIcon: true,
                          heading: controller.activityDetails.value.data?.location?.address ?? "-",
                          subHeading: "Open in google map",
                          value: "Location",
                          onSubHeadingTap: () {
                            openGoogleMaps(
                              address: controller.activityDetails.value.data?.location?.address,
                              googleMapLink: controller.activityDetails.value.data?.location?.link,
                              lat: double.parse(controller.activityDetails.value.data?.location?.latitude ?? "0.0"),
                              lng: double.parse(controller.activityDetails.value.data?.location?.longitude ?? "0.0"),
                            );
                          }),
                      buildContainer(
                        image: AppImage.activityName,
                        heading: controller.activityDetails.value.data?.activityName ?? "-",
                        value: "Activity Name",
                        isIcon: false,
                      ),
                      buildContainer(
                        image: AppImage.locationDetail,
                        isIcon: false,
                        heading: controller.activityDetails.value.data?.locationDetails ?? "-",
                        value: "Location Detail",
                      ),
                      GestureDetector(
                        onTap: () {
                          if ((controller.activityDetails.value.data?.team?.playerTeams ?? []).isNotEmpty) {
                            if (AppPref().role == "coach") {
                              Get.toNamed(AppRouter.participatedPlayer, arguments: controller.activityDetails.value.data?.team?.playerTeams ?? []);
                            }
                          } else {
                            AppToast.showAppToast("No player participated yet");
                          }
                        },
                        child: buildContainer(
                          image: AppImage.player,
                          isIcon: true,
                          heading: ((controller.activityDetails.value.data?.team?.playerTeams ?? []).isEmpty)
                              ? "-"
                              : (controller.activityDetails.value.data?.team?.playerTeams ?? [])
                                  .map((player) => "${player.firstName} ${player.lastName}")
                                  .join(", "),
                          value: "Player List",
                        ),
                      ),
                      buildContainer(
                        image: AppImage.assignment,
                        isIcon: false,
                        heading: controller.activityDetails.value.data?.assignments ?? "-",
                        value: "Assignment",
                      ),
                      buildContainer(
                        image: AppImage.duration,
                        isIcon: false,
                        heading: (controller.activityDetails.value.data?.duration ?? "0").isEmpty
                            ? "-"
                            : DateUtilities.formatDuration(int.parse(controller.activityDetails.value.data?.duration ?? "0")),
                        value: "Duration",
                      ),
                      buildContainer(
                        image: AppImage.arriveEarly,
                        isIcon: false,
                        heading: controller.activityDetails.value.data?.arriveEarly ?? "-",
                        value: "Arrive Early",
                      ),
                      buildContainer(
                        image: AppImage.uniform,
                        isIcon: false,
                        heading: controller.activityDetails.value.data?.uniform ?? "-",
                        value: "Uniform",
                      ),
                      buildContainer(
                        image: AppImage.flag,
                        isIcon: false,
                        heading: controller.activityDetails.value.data?.flagColor ?? "-",
                        value: "Flag Color",
                      ),
                      buildContainer(
                        image: AppImage.notes,
                        heading: controller.activityDetails.value.data?.notes ?? "-",
                        isIcon: false,
                        value: "Notes",
                      ),
                      if ((controller.activityDetails.value.data?.activityType ?? "") == "game")
                        buildContainer(
                          isIcon: false,
                          isLast: true,
                          image: AppImage.opponents,
                          heading: controller.activityDetails.value.data?.opponent?.opponentName ?? "-",
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
                        colorFilter: ColorFilter.mode(AppColor.black12Color, BlendMode.srcIn),
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
                              style: TextStyle(decoration: TextDecoration.underline, decorationColor: Colors.black).normal14w500.textColor(
                                    AppColor.black,
                                  ),
                            ),
                          ),
                        ),
                        Text(
                          value ?? "My assignments\nAttendance, clock, fieldprep, Photogragher",
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
