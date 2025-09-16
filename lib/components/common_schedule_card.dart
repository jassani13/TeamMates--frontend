import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/model/event_tag_model.dart';

class CommonScheduleCard extends StatelessWidget {
  final ScheduleData? scheduleData;
  final bool? isBtn;
  final bool? isHome;

  CommonScheduleCard({
    super.key,
    this.scheduleData,
    this.isBtn,
    this.isHome,
  });

  AutoScrollController controller1 = AutoScrollController();
  RxInt selectedSearchMethod1 = (-1).obs;
  List selectedMethod1List = [
    "Going",
    "Maybe",
    "No",
  ];

  @override
  Widget build(BuildContext context) {
    selectedSearchMethod1.value = selectedMethod1List
        .indexWhere((e) => e == (scheduleData?.activityUserStatus ?? ""));
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 16, top: 16, right: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppColor.greyF6Color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (scheduleData?.isTimeTbd == 1)
                Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Practice".toUpperCase(),
                            style: TextStyle().normal14w600.textColor(
                                  AppColor.greenColor,
                                ),
                          )
                        ],
                      ),
                    ),
                    Gap(4),
                  ],
                ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: capitalizeFirst(scheduleData?.activityName),
                      style: TextStyle().normal16w500.textColor(
                            AppColor.black12Color,
                          ),
                    ),
                  ],
                ),
              ),
              if (scheduleData?.startTime != null ||
                  scheduleData?.endTime != null)
                Text(
                  DateUtilities.formatTime(scheduleData?.startTime ?? "",
                      scheduleData?.endTime ?? ""),
                  style: TextStyle().normal16w500.textColor(
                        AppColor.black12Color,
                      ),
                ),
              Visibility(
                visible: scheduleData?.activityType == 'game',
                child: Text(
                  "${scheduleData?.team?.name ?? ""} vs ${scheduleData?.opponent?.opponentName ?? ""}",
                  style: TextStyle().normal14w500.textColor(
                        AppColor.black12Color,
                      ),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: scheduleData?.location?.address ?? "",
                      style: TextStyle().normal15w500.textColor(
                            AppColor.black12Color,
                          ),
                    ),
                    if (AppPref().role != "family" &&
                        scheduleData?.totalParticipate != 0)
                      TextSpan(
                        text:
                            " (${scheduleData?.totalParticipate ?? ""} total participants)",
                        style: TextStyle().normal14w500.textColor(
                              AppColor.black12Color,
                            ),
                      )
                  ],
                ),
              ),
              if (isBtn == true) ...[
                SizedBox(height: 12),
                Center(
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: HorizontalSelectionList(
                        margin: MediaQuery.of(context).size.width / 9,
                        items: selectedMethod1List,
                        selectedIndex: selectedSearchMethod1,
                        controller: controller1,
                        onItemSelected: (index) async {
                          selectedSearchMethod1.value = index;
                          scheduleData?.activityUserStatus =
                              selectedMethod1List[index];
                          Get.find<ScheduleController>().statusChangeApiCall(
                              status: selectedMethod1List[index],
                              aId: scheduleData?.activityId ?? 0,
                              isHome: isHome ?? false);
                        },
                      ),
                    ),
                  ),
                ),
              ],
              Visibility(
                visible: scheduleData?.activityType == 'game' &&
                    scheduleData?.isLive == 1,
                child: GestureDetector(
                  onTap: () {
                    launchURL('https://watch.livebarn.com/en/signin');
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: AppColor.redColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Gap(6),
                        Text(
                          "WATCH",
                          style: TextStyle().normal12w500.textColor(
                                AppColor.redColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // NEW: Tags display in bottom right corner
              if (scheduleData?.hasTags == true) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Spacer(), // Push tags to the right
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (scheduleData?.tags ?? []).map((tag) {
                        return Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: tag.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag.displayName,
                            style: TextStyle().normal16w500,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // TOP RIGHT CORNER - Keep existing "Game"/"Event" label
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Text(
            (scheduleData?.isLive == 1)
                ? 'Live - ${capitalizeFirst(scheduleData?.activityType)}'
                : capitalizeFirst(scheduleData?.activityType),
            style: TextStyle().normal16w500.textColor(
                  (scheduleData?.isLive == 1 ||
                          scheduleData?.activityType?.toLowerCase() == 'game')
                      ? AppColor.redColor
                      : AppColor.black12Color,
                ),
          ),
        ),
      ],
    );
  }
}
