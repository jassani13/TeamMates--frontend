import 'package:base_code/components/common_progress_bar.dart';
import 'package:base_code/components/common_stat_card.dart';
import 'package:base_code/model/challenge_model.dart';
import 'package:base_code/module/bottom/home/home_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter/gestures.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final homeController = Get.put<HomeController>(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset(
            AppImage.bottomBg,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          RefreshIndicator(
            key: homeController.refreshKey,
            onRefresh: () async {
              await homeController.getHomeDetailsApiCall();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(Platform.isAndroid ? ScreenUtil().statusBarHeight + 20 : ScreenUtil().statusBarHeight + 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonTitleText(text: "Welcome back,"),
                            Text(
                              "${AppPref().userModel?.firstName ?? ""} ${AppPref().userModel?.lastName ?? ""}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle().normal16w600.textColor(AppColor.black12Color),
                            ),
                          ],
                        ),
                      ),
                      Gap(20),
                      CommonIconButton(
                        image: AppImage.noti,
                        onTap: () {
                          Get.toNamed(
                            AppRouter.notification,
                          );
                        },
                      ),
                      Gap(24),
                      CommonIconButton(
                        image: AppImage.profile,
                        onTap: () {
                          Get.toNamed(
                            AppRouter.account,
                          );
                        },
                      ),
                    ],
                  ),
                  Gap(24),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            return homeController.isShimmer.value
                                ? SizedBox()
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (AppPref().role != "coach") ...[
                                        _cancelledActivity(),
                                      ],
                                      Obx(() {
                                        return (homeController.homeModel.value?.data?.upcomingActivities ?? []).isEmpty
                                            ? SizedBox()
                                            : Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CommonTitleText(text: "Upcoming"),
                                                  ListView.builder(
                                                    padding: EdgeInsets.only(top: 10),
                                                    physics: ScrollPhysics(),
                                                    itemCount: homeController.homeModel.value?.data?.upcomingActivities?.length,
                                                    shrinkWrap: true,
                                                    itemBuilder: (context, index) {
                                                      ScheduleData? scheduleData = homeController.homeModel.value?.data?.upcomingActivities?[index];
                                                      return Padding(
                                                        padding: EdgeInsets.only(top: index == 0 ? 0 : 16.0),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Get.toNamed(AppRouter.gameProgress, arguments: {
                                                              'user_id': scheduleData?.userBy,
                                                              'activity_id': scheduleData?.activityId,
                                                            });
                                                          },
                                                          child: CommonScheduleCard(
                                                            scheduleData: scheduleData,
                                                            isBtn: AppPref().role == 'team',
                                                            isHome: true,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  Gap(24),
                                                ],
                                              );
                                      }),
                                      Obx(() {
                                        return (homeController.homeModel.value?.data?.challenges ?? []).isEmpty
                                            ? SizedBox()
                                            : Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CommonTitleText(text: "Coach's Goal Challenge"),
                                                  Gap(24),
                                                  ListView.builder(
                                                      itemCount: homeController.homeModel.value?.data?.challenges?.length,
                                                      shrinkWrap: true,
                                                      padding: EdgeInsets.zero,
                                                      physics: ScrollPhysics(),
                                                      itemBuilder: (context, index) {
                                                        Challenge? challenge = homeController.homeModel.value?.data?.challenges?[index];
                                                        return GestureDetector(
                                                          onTap: () {
                                                            if (AppPref().role == "coach") {
                                                              Get.toNamed(AppRouter.challengeMembers, arguments: {
                                                                "challenge_id": challenge.challengeId ?? "",
                                                                "isHome": true,
                                                              });
                                                            } else {
                                                              if ((DateUtilities.getTimeLeft(challenge.endAt ?? "-")) == "-") {
                                                                AppToast.showAppToast("This challenge is no longer available.",
                                                                    bgColor: AppColor.redColor);
                                                              } else {
                                                                Get.toNamed(AppRouter.challengeMembers, arguments: {
                                                                  "challenge_id": challenge.challengeId ?? "",
                                                                  "isHome": true,
                                                                });
                                                              }
                                                            }
                                                          },
                                                          child: CommonStatCard(
                                                            index: index,
                                                            challenge: challenge!,
                                                            isCoach: AppPref().role == "coach",
                                                            pWidth: MediaQuery.of(context).size.width - 96 - 8,
                                                          ),
                                                        );
                                                      }),
                                                  Gap(24),
                                                ],
                                              );
                                      }),
                                    ],
                                  );
                          }),
                          buildNews(),
                          Gap(24),
                          if (AppPref().role != "coach")
                            GestureDetector(
                              onTap: () async {
                                if (homeController.contact.value != "Not Added yet") {
                                  final Uri callUri = Uri.parse("tel:${homeController.contact.value}");
                                  if (await canLaunchUrl(callUri)) {
                                    await launchUrl(callUri);
                                  } else {
                                    print("Could not launch the call.");
                                  }
                                }
                              },
                              child: Row(
                                children: [
                                  Gap(16),
                                  Expanded(
                                      child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.redColor,
                                      borderRadius: BorderRadius.circular(
                                        8,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset(AppImage.info),
                                            Gap(8),
                                            Text(
                                              "Emergency Contact",
                                              style: TextStyle().normal14w500.textColor(
                                                    AppColor.white,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Obx(() {
                                          return Text(
                                            homeController.contact.value,
                                            style: TextStyle().normal16w600.textColor(
                                                  AppColor.white,
                                                ),
                                          );
                                        }),
                                      ],
                                    ),
                                  )),
                                  Gap(16),
                                ],
                              ),
                            ),
                          if (AppPref().role != "coach") Gap(24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Obx _cancelledActivity() {
    return Obx(() {
      return homeController.isShimmer.value
          ? ShimmerClass()
          : homeController.homeModel.value?.data?.canceledActivity != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRouter.gameProgress, arguments: {
                          'user_id': homeController.homeModel.value?.data?.canceledActivity?.userBy,
                          'activity_id': homeController.homeModel.value?.data?.canceledActivity?.activityId,
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(
                          16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.greyF6Color,
                          ),
                          borderRadius: BorderRadius.circular(
                            16,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 20,
                              width: 12,
                              decoration: BoxDecoration(
                                color: AppColor.redColor,
                                borderRadius: BorderRadius.circular(
                                  4,
                                ),
                              ),
                            ),
                            Gap(12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Practice cancelled for ${homeController.homeModel.value?.data?.canceledActivity?.activityName ?? ""}",
                                  style: TextStyle().normal16w500.textColor(
                                        AppColor.redColor,
                                      ),
                                ),
                                Text(
                                  "${DateUtilities.formatDate(homeController.homeModel.value?.data?.canceledActivity?.eventDate ?? "")}  ${DateUtilities.formatTime(homeController.homeModel.value?.data?.canceledActivity?.startTime ?? "", homeController.homeModel.value?.data?.canceledActivity?.endTime ?? "")}",
                                  style: TextStyle().normal15w500.textColor(
                                        AppColor.black12Color,
                                      ),
                                ),
                                Gap(4),
                                Text(
                                  "Reason",
                                  style: TextStyle().normal14w500.textColor(
                                        AppColor.black45Color,
                                      ),
                                ),
                                Text(
                                  homeController.homeModel.value?.data?.canceledActivity?.reason ?? "-",
                                  style: TextStyle().normal16w500.textColor(
                                        AppColor.black12Color,
                                      ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Gap(16),
                  ],
                )
              : SizedBox();
    });
  }

  Widget buildNews() {
    return Obx(() {
      return homeController.isShimmer.value
          ? ShimmerListClass(
              length: 7,
              height: 200,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonTitleText(text: "News"),
                Gap(24),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.greyF6Color,
                    borderRadius: BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      physics: ScrollPhysics(),
                      itemCount: homeController.homeModel.value?.data?.news?.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            final Uri url = Uri.parse(homeController.homeModel.value?.data?.news?[index].url ?? "");
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                            } else {
                              throw "Could not launch $url";
                            }
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            margin: EdgeInsets.only(top: index == 0 ? 0 : 16),
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(
                                16,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((homeController.homeModel.value?.data?.news?[index].image ?? "").isNotEmpty)
                                  ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(16),
                                        topLeft: Radius.circular(16),
                                      ),
                                      child: getImageView(
                                        finalUrl: homeController.homeModel.value?.data?.news?[index].image ?? "",
                                        height: 137,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        homeController.homeModel.value?.data?.news?[index].title ?? "",
                                        style: TextStyle().normal16w500.textColor(
                                              AppColor.black12Color,
                                            ),
                                        maxLines: 2,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Gap(7),
                                      ExpandableText(
                                        homeController.homeModel.value?.data?.news?[index].description ?? "",
                                        index: index,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            );
    });
  }

  Widget buildPersonalGoal(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.greyF6Color,
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildStandingsData(context, value: "60", title: "Push up", score: "8/12"),
                buildStandingsData(context, value: "60", title: "Running", score: "8/12"),
              ],
            ),
          ),
          Container(
            height: 38,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColor.greyEAColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                "Points / Game",
                style: TextStyle().normal16w600.textColor(
                      AppColor.black12Color,
                    ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildStandings(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: AppColor.greyF6Color,
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: Column(
        children: [
          buildStandingsData(context),
          buildStandingsData(context, value: "60", title: "The Tigers", score: "9/12"),
          buildStandingsData(context, value: "30", title: "The Bears", score: "5/12"),
          buildStandingsData(context, value: "90", title: "Dance", score: "11/12"),
        ],
      ),
    );
  }

  Widget buildStandingsData(
    context, {
    String? title,
    String? score,
    String? value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              title ?? "The Falcons",
              style: TextStyle().normal16w500.textColor(
                    AppColor.black12Color,
                  ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 2,
              ),
              decoration: BoxDecoration(color: AppColor.white, borderRadius: BorderRadius.circular(8)),
              child: Text(
                score ?? "8 /12",
                style: TextStyle().normal18w500.textColor(
                      AppColor.black12Color,
                    ),
              ),
            )
          ],
        ),
        Gap(4),
        CommonProgressBar(value: value ?? "50"),
        Gap(12),
      ],
    );
  }

  String checkGameDate(String dateString) {
    DateTime givenDate = DateTime.parse(dateString);

    DateTime today = DateTime.now();
    DateTime tomorrow = today.add(Duration(days: 1));

    String formattedToday = DateFormat('yyyy-MM-dd').format(today);
    String formattedTomorrow = DateFormat('yyyy-MM-dd').format(tomorrow);
    String formattedGivenDate = DateFormat('yyyy-MM-dd').format(givenDate);

    if (formattedGivenDate == formattedToday) {
      return "Today";
    } else if (formattedGivenDate == formattedTomorrow) {
      return "Tomorrow";
    } else if (formattedGivenDate == dateString) {
      return formattedGivenDate;
    } else {
      return "No game today or tomorrow.";
    }
  }
}

class ExpandableText extends StatefulWidget {
  const ExpandableText(
    this.text, {
    super.key,
    required this.index,
    this.trimLines = 5,
  });

  final String text;
  final int trimLines;
  final int index;

  @override
  ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
  bool _readMore = true;

  void _onTapLink() {
    setState(() => _readMore = !_readMore);
  }

  @override
  Widget build(BuildContext context) {
    TextSpan link = TextSpan(
        text: _readMore ? "  See more" : "  See less",
        style: TextStyle().normal16w600.textColor(AppColor.black12Color),
        recognizer: TapGestureRecognizer()..onTap = _onTapLink);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth - 10;
        final text = TextSpan(
          text: widget.text,
          style: TextStyle().normal14w500.textColor(
                AppColor.grey4EColor,
              ),
        );
        TextPainter textPainter = TextPainter(
          text: link,
          textDirection: TextDirection.rtl,
          maxLines: widget.trimLines,
          ellipsis: '...',
        );
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;
        int? endIndex;
        final pos = textPainter.getPositionForOffset(Offset(
          textSize.width - linkSize.width,
          textSize.height,
        ));
        endIndex = textPainter.getOffsetBefore(pos.offset);
        TextSpan textSpan;
        if (textPainter.didExceedMaxLines) {
          textSpan = TextSpan(
            text: _readMore ? widget.text.substring(0, endIndex) : widget.text,
            style: TextStyle().normal14w500.textColor(
                  AppColor.grey4EColor,
                ),
            children: <TextSpan>[link],
          );
        } else {
          textSpan = TextSpan(
            text: widget.text,
            style: TextStyle().normal14w500.textColor(
                  AppColor.grey4EColor,
                ),
          );
        }
        return RichText(
          softWrap: true,
          overflow: TextOverflow.clip,
          text: textSpan,
        );
      },
    );

    // return result;
  }
}
