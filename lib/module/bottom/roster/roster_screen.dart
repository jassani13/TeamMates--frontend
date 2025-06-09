import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class RosterScreen extends StatelessWidget {
  RosterScreen({super.key});

  final roasterController = Get.put<RoasterController>(RoasterController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard();
      },
      child: Scaffold(
        body: Stack(
          children: [
            SvgPicture.asset(
              AppImage.bottomBg,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RefreshIndicator(
                key: roasterController.refreshKey,
                onRefresh: () async {
                  await roasterController.getRosterApiCall();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(Platform.isAndroid ? ScreenUtil().statusBarHeight + 20 : ScreenUtil().statusBarHeight + 10),
                    Row(
                      children: [
                        CommonTitleText(text: "Roster"),
                        Spacer(),
                        if (AppPref().role == 'coach')
                          CommonIconButton(
                            image: AppImage.plus,
                            onTap: () {
                              hideKeyboard();
                              Get.toNamed(AppRouter.addTeam);
                            },
                          ),
                      ],
                    ),
                    Text(
                      "Teams",
                      style: TextStyle().normal28w500s.textColor(
                            AppColor.black12Color,
                          ),
                    ),
                    Text(
                      (AppPref().role == 'coach') ? "Manage your team and get ready for the game" : "Rise as a team, play as a champion",
                      style: TextStyle().normal16w500.textColor(
                            AppColor.grey4EColor,
                          ),
                    ),
                    Gap(16),
                    CommonTextField(
                      onChange: (value) {
                        roasterController.searchQuery.value = (value ?? "").trim().toLowerCase();
                      },
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColor.grey4EColor,
                      ),
                      controller: roasterController.searchController,
                      hintText: "Search team...",
                    ),
                    Gap(16),
                    Obx(
                      () => Expanded(
                        child: roasterController.isShimmer.value
                            ? ShimmerListClass(
                                length: 10,
                                height: 60,
                              )
                            : (roasterController.allRosterModelList).isEmpty
                                ? SingleChildScrollView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.3),
                                          child: Center(child: buildNoData()),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: roasterController.allRosterModelList
                                        .where((roster) => (roster.name ?? "").toLowerCase().contains(roasterController.searchQuery.value))
                                        .length,
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      var filteredList = roasterController.allRosterModelList
                                          .where((roster) => (roster.name ?? "").toLowerCase().contains(roasterController.searchQuery.value))
                                          .toList();
                                      Roster roster = filteredList[index];
                                      return GestureDetector(
                                        onTap: () {
                                          hideKeyboard();
                                          Get.toNamed(AppRouter.allPlayer, arguments: [roster.teamId ?? ""]);
                                        },
                                        behavior: HitTestBehavior.translucent,
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            bottom: 14,
                                            top: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            border: index == 0
                                                ? null
                                                : Border(
                                                    top: BorderSide(
                                                      color: AppColor.greyF6Color,
                                                    ),
                                                  ),
                                          ),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(24),
                                                child: getImageView(
                                                    finalUrl:
                                                        '$publicImageUrl${(roster.iconImage ?? "").isNotEmpty ? (roster.iconImage ?? "") : roster.teamImage ?? ""}',
                                                    fit: BoxFit.cover,
                                                    height: 48,
                                                    width: 48),
                                              ),
                                              Gap(16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      roster.name ?? "",
                                                      style: TextStyle().normal20w500.textColor(
                                                            AppColor.black12Color,
                                                          ),
                                                    ),
                                                    Text(
                                                      "${roster.playerTeamsCount ?? ""} Participants",
                                                      style: TextStyle().normal14w500.textColor(
                                                            AppColor.grey4EColor,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Gap(16),
                                              if (AppPref().role == 'coach')
                                                GestureDetector(
                                                  onTap: () {
                                                    if (AppPref().proUser == true) {
                                                      Get.toNamed(
                                                        AppRouter.grpChat,
                                                        arguments: {
                                                          'chatData': ChatListData(
                                                            teamName: roster.name,
                                                            teamId: roster.teamId.toString(),
                                                          ),
                                                        },
                                                      );
                                                    } else {
                                                      Get.defaultDialog(
                                                        title: "Subscription Required",
                                                        titleStyle: TextStyle().normal20w500.textColor(AppColor.black12Color),
                                                        middleTextStyle: TextStyle().normal16w400.textColor(AppColor.grey4EColor),
                                                        middleText: "Buy a subscription to\naccess Team Chat.",
                                                        textConfirm: "Buy Now",
                                                        confirmTextColor: AppColor.white,
                                                        buttonColor: AppColor.black12Color,
                                                        cancelTextColor: AppColor.black12Color,
                                                        textCancel: "Cancel",
                                                        onConfirm: () {
                                                          Get.back();
                                                          Get.toNamed(AppRouter.subscription);
                                                        },
                                                      );
                                                    }
                                                  },
                                                  child: Image.asset(
                                                    AppImage.messenger,
                                                    height: 20,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
