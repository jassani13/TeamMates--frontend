import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class StatsScreen extends StatelessWidget {
  StatsScreen({super.key});

  final StatsController statsController = Get.put(StatsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          RefreshIndicator(
            key: statsController.refreshKey,
            onRefresh: statsController.getChallengeApiCall,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(Platform.isAndroid ? ScreenUtil().statusBarHeight + 20 : ScreenUtil().statusBarHeight + 10),
                  _buildHeader(context),
                  Gap(24),
                  _buildTabSelection(),
                  Gap(16),
                  Expanded(child:  _buildContent(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return SvgPicture.asset(
      AppImage.bottomBg,
      height: double.infinity,
      width: double.infinity,
      fit: BoxFit.fill,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CommonTitleText(text: "Challenges & Rewards"),
        const Spacer(),
        if (AppPref().role == "coach")
          CommonIconButton(
            image: AppImage.plus,
            onTap: () {
              Get.toNamed(AppRouter.createChallenge)?.then((result) {
                if (result != null) {
                  statsController.allChallengeDetail.value.list?.insert(0, result);
                  statsController.allChallengeDetail.refresh();
                }
              });
            },
          ),
      ],
    );
  }

  Widget _buildTabSelection() {
    return Container(
      height: 63,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.greyF6Color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: HorizontalSelectionList(
        items: statsController.statList,
        selectedIndex: statsController.selectedMethod,
        controller: statsController.scrollController,
        onItemSelected: (index) {
          statsController.selectedMethod.value = index;
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (AppPref().role == "coach") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonTitleText(text: "Team challenges"),
          Gap(16),
          Expanded(child: _buildChallengeList(context, isCoach: true)),
        ],
      );
    } else {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => CommonTitleText(text: statsController.selectedMethod.value == 0 ? "Stats" : "Challenges")),
            Gap(16),
            Obx(() {
              if (statsController.selectedMethod.value == 0) {
                return buildStat(context);
              } else {
                return _buildChallengeList(context, isCoach: false);
              }
            }),
          ],
        ),
      );
    }
  }

  Widget _buildChallengeList(BuildContext context, {required bool isCoach}) {
    if (statsController.isShimmer.value) {
      return ShimmerListClass(length: 5, height: isCoach ? 250 : 100);
    }

    final challenges = statsController.allChallengeDetail.value.list ?? [];
    if (challenges.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.3),
            child: buildNoData(text: "No challenges found"),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: challenges.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return GestureDetector(
          onTap: () {
            if (!isCoach && DateUtilities.getTimeLeft(challenge.endAt ?? "-") == "-") {
              AppToast.showAppToast(
                "This challenge is no longer available.",
                bgColor: AppColor.redColor,
              );
              return;
            }
            Get.toNamed(AppRouter.challengeMembers, arguments: {
              "challenge_id": challenge.challengeId ?? "",
              "isHome": false,
            });
          },
          child: CommonStatCard(
            index: index,
            challenge: challenge,
            isCoach: isCoach,
          ),
        );
      },
    );
  }

  Widget buildStat(BuildContext context) {
    final score = statsController.allChallengeDetail.value.score;
    final scoreNumber = score?.scoreNumber ?? 0;
    final totalChallenges = score?.totalParticipate ?? 0;
    final percentage = double.tryParse("${score?.percentage ?? 0}") ?? 0;
    final grade = score?.grade ?? "";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [AppColor.black12Color, AppColor.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total strength gained", style: TextStyle().normal20w500.textColor(AppColor.white)),
          Gap(16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [AppColor.white, AppColor.white.withOpacity(0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: AppColor.white),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "$scoreNumber",
                      style: TextStyle().normal48w500.textColor(AppColor.black),
                    ),
                    Gap(10),
                    Text(
                      "$totalChallenges Challenges",
                      style: TextStyle().normal16w500.textColor(AppColor.white),
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
                        barRadius: const Radius.circular(12),
                        lineHeight: 19.0,
                        backgroundColor: Colors.white,
                        animationDuration: 2500,
                        percent: (percentage / 100).clamp(0.0, 1.0),
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        progressColor: AppColor.black12Color,
                      ),
                      Gap(8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          grade,
                          style: TextStyle().normal20w500.textColor(AppColor.grey6EColor),
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
    );
  }
}
