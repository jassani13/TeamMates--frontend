import 'package:base_code/components/common_icon_button.dart';
import 'package:base_code/components/common_progress_bar.dart';
import 'package:base_code/components/common_title_text.dart';
import 'package:base_code/components/horizontal_list.dart';
import 'package:base_code/model/challenge_model.dart';
import 'package:base_code/module/bottom/stats/stats_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

import '../../../components/common_stat_card.dart';

class StatsScreen extends StatelessWidget {
  StatsScreen({super.key});

  final statsController = Get.put<StatsController>(StatsController());

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
            key: statsController.refreshKey,
            onRefresh: () async {
              await statsController.getChallengeApiCall();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(Platform.isAndroid
                      ? ScreenUtil().statusBarHeight + 20
                      : ScreenUtil().statusBarHeight + 10),
                  Row(
                    children: [
                      CommonTitleText(text: "Challenges & Rewards"),
                      Spacer(),
                      if (AppPref().role == "coach")
                        CommonIconButton(
                            image: AppImage.plus,
                            onTap: () {
                              Get.toNamed(AppRouter.createChallenge)
                                  ?.then((result) {
                                if (result != null) {
                                  statsController.allChallengeDetail.value.list
                                      ?.insert(0, result);
                                  statsController.allChallengeDetail.refresh();
                                }
                              });
                            }),
                    ],
                  ),
                  Gap(24),
                  Container(
                    height: 63,
                    width: double.infinity,
                    padding: EdgeInsets.all(
                      16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.greyF6Color,
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                    ),
                    child: HorizontalSelectionList(
                      items: statsController.statList,
                      selectedIndex: statsController.selectedMethod,
                      controller: statsController.controller,
                      onItemSelected: (index) {
                        statsController.selectedMethod.value = index;
                      },
                    ),
                  ),
                  Gap(16),
                  if (AppPref().role == "coach") ...[
                    CommonTitleText(text: "Team challenges"),
                    Gap(16),
                    Expanded(
                      child: Obx(() {
                        return statsController.isShimmer.value
                            ? ShimmerListClass(
                                length: 5,
                                height: 250,
                              )
                            : (statsController.allChallengeDetail.value.list ??
                                        [])
                                    .isEmpty
                                ? SingleChildScrollView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  3.3),
                                          child: Center(
                                              child: buildNoData(
                                            text: "No challenges found",
                                          )),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: statsController
                                        .allChallengeDetail.value.list?.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      Challenge? challenge = statsController
                                          .allChallengeDetail
                                          .value
                                          .list?[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Get.toNamed(
                                              AppRouter.challengeMembers,
                                              arguments: {
                                                "challenge_id":
                                                    challenge.challengeId ?? "",
                                                "isHome": false,
                                              });
                                        },
                                        child: CommonStatCard(
                                          index: index,
                                          challenge: challenge!,
                                          isCoach: true,
                                        ),
                                      );
                                    });
                      }),
                    ),
                  ] else ...[
                    Expanded(
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() {
                              return CommonTitleText(
                                  text:
                                      statsController.selectedMethod.value == 0
                                          ? "Stats"
                                          : "Challenges");
                            }),
                            Gap(16),
                            Obx(() {
                              return statsController.selectedMethod.value == 0
                                  ? buildStat(context)
                                  : statsController.isShimmer.value
                                      ? ShimmerListClass(
                                          length: 5,
                                          height: 100,
                                        )
                                      : (statsController.allChallengeDetail
                                                      .value.list ??
                                                  [])
                                              .isEmpty
                                          ? Center(
                                              child: Padding(
                                              padding: EdgeInsets.only(
                                                  top: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      4),
                                              child: buildNoData(
                                                  text: "No challenges found"),
                                            ))
                                          : ListView.builder(
                                              itemCount: statsController
                                                  .allChallengeDetail
                                                  .value
                                                  .list
                                                  ?.length,
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics: ScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                Challenge? challenge =
                                                    statsController
                                                        .allChallengeDetail
                                                        .value
                                                        .list?[index];
                                                return GestureDetector(
                                                  onTap: () {
                                                    if ((DateUtilities
                                                            .getTimeLeft(
                                                                challenge
                                                                        .endAt ??
                                                                    "-")) ==
                                                        "-") {
                                                      AppToast.showAppToast(
                                                          "This challenge is no longer available.",
                                                          bgColor: AppColor
                                                              .redColor);
                                                    } else {
                                                      Get.toNamed(
                                                          AppRouter
                                                              .challengeMembers,
                                                          arguments: {
                                                            "challenge_id":
                                                                challenge
                                                                        .challengeId ??
                                                                    "",
                                                            "isHome": false,
                                                          });
                                                    }
                                                  },
                                                  child: CommonStatCard(
                                                      isCoach: false,
                                                      index: index,
                                                      challenge: challenge!),
                                                );
                                              });
                            }),
                          ],
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildStat(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(colors: [
                AppColor.black12Color,
                AppColor.white,
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total strength gained",
                style: TextStyle().normal20w500.textColor(
                      AppColor.white,
                    ),
              ),
              Gap(16),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(colors: [
                      AppColor.white,
                      AppColor.white.withValues(alpha: .0),
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    border: Border.all(color: AppColor.white)),
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Row(
                      // crossAxisAlignment: s,
                      children: [
                        Text(
                          "${statsController.allChallengeDetail.value.score?.scoreNumber ?? 0}",
                          style: TextStyle().normal48w500.textColor(
                                AppColor.black,
                              ),
                        ),
                        Gap(10),
                        Text(
                          "${statsController.allChallengeDetail.value.score?.totalParticipate ?? 0} Challenges",
                          style: TextStyle().normal16w500.textColor(
                                AppColor.white,
                              ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: Column(
                        children: [
                          LinearPercentIndicator(
                            padding: EdgeInsets.zero,
                            width: MediaQuery.of(context).size.width - 130,
                            animation: true,
                            barRadius: Radius.circular(12),
                            lineHeight: 19.0,
                            backgroundColor: Colors.white,
                            animationDuration: 2500,
                            percent: double.parse(
                                    "${statsController.allChallengeDetail.value.score?.percentage ?? 0}") /
                                100,
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor: AppColor.black12Color,
                          ),
                          Gap(8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              statsController
                                      .allChallengeDetail.value.score?.grade ??
                                  "",
                              style: TextStyle().normal20w500.textColor(
                                    AppColor.grey6EColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Gap(16),
        // CommonTitleText(text: "Coach's Goal Challenge"),
        // Gap(16),
        // Obx(() {
        //   return statsController.isShimmer.value
        //       ? ShimmerListClass(
        //           length: 5,
        //           height: 100,
        //         )
        //       : (statsController.allChallengeDetail.value.list ?? []).isEmpty
        //           ? Center(child: buildNoData(text: "No challenges found"))
        //           : ListView.builder(
        //               itemCount:
        //                   statsController.allChallengeDetail.value.list?.length,
        //               shrinkWrap: true,
        //               padding: EdgeInsets.zero,
        //               physics: ScrollPhysics(),
        //               itemBuilder: (context, index) {
        //                 return GestureDetector(
        //                   onTap: () {},
        //                   child: Container(
        //                     // margin: EdgeInsets.only(
        //                     //     top: index == 0
        //                     //         ? 0
        //                     //         : 16),
        //                     decoration: BoxDecoration(
        //                         border: index == 0
        //                             ? null
        //                             : Border(
        //                                 top: BorderSide(
        //                                     color: AppColor.greyF6Color))),
        //                     padding: EdgeInsets.all(
        //                       16,
        //                     ),
        //                     child: Row(
        //                       crossAxisAlignment: CrossAxisAlignment.start,
        //                       children: [
        //                         Expanded(
        //                           child: Column(
        //                             crossAxisAlignment:
        //                                 CrossAxisAlignment.start,
        //                             children: [
        //                               Text(
        //                                 "Team Spirit Challenge",
        //                                 style:
        //                                     TextStyle().normal16w500.textColor(
        //                                           AppColor.black12Color,
        //                                         ),
        //                               ),
        //                               Text(
        //                                 "20 push ups",
        //                                 style:
        //                                     TextStyle().normal14w500.textColor(
        //                                           AppColor.grey4EColor,
        //                                         ),
        //                               ),
        //                               Text(
        //                                 "Completed",
        //                                 style:
        //                                     TextStyle().normal14w500.textColor(
        //                                           AppColor.successColor,
        //                                         ),
        //                               ),
        //                               Gap(8),
        //                               CommonProgressBar(
        //                                 value: "50",
        //                                 width:
        //                                     MediaQuery.of(context).size.width -
        //                                         80,
        //                               ),
        //                             ],
        //                           ),
        //                         ),
        //                         Gap(16),
        //                       ],
        //                     ),
        //                   ),
        //                 );
        //               });
        // }),
      ],
    );
  }
}
