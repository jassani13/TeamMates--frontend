import 'package:base_code/components/common_icon_button.dart';
import 'package:base_code/components/shimmer.dart';
import 'package:base_code/model/chat_list_model.dart';
import 'package:base_code/module/bottom/roster/allPlayer/all_player_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

import '../../../../utils/common_function.dart';

class AllPlayerScreen extends StatelessWidget {
  AllPlayerScreen({super.key});

  final allPlayerController = Get.put<AllPlayerController>(AllPlayerController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Obx(
            () => CommonTitleText(text: allPlayerController.rosterDetailModel.value.data?[0].name ?? ""),
          ),
          centerTitle: false,
          actions: [
            if (AppPref().role == 'coach')
              CommonIconButton(
                  image: AppImage.plus,
                  onTap: () {
                    hideKeyboard();

                    Get.toNamed(AppRouter.addPlayer, arguments: [allPlayerController.rosterDetailModel.value.data?[0].teamId ?? 0, true]);
                  }),
            Gap(20),
          ],
        ),
        bottomNavigationBar: (AppPref().role == "coach")
            ? Obx(() {
                return allPlayerController.isShimmer.value
                    ? SizedBox()
                    : Container(
                        decoration: const BoxDecoration(
                          color: AppColor.white,
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, -2),
                              color: AppColor.lightPrimaryColor,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: Platform.isAndroid ? 20 : 24),
                        child: CommonAppButton(
                          color: AppColor.redColor,
                          text: "Delete team",
                          onTap: () {
                            allPlayerController.deleteTeam(
                              context,
                              tID: allPlayerController.rosterDetailModel.value.data?[0].teamId ?? 0,
                            );
                          },
                        ),
                      );
              })
            : SizedBox(),
        body: Column(
          children: [
            Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CommonTextField(
                onChange: (value) {
                  allPlayerController.searchQuery.value = (value ?? "").toLowerCase();
                },
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColor.grey4EColor,
                ),
                controller: allPlayerController.searchController,
                hintText: "Search player...",
              ),
            ),
            Gap(16),
            Expanded(
              child: Obx(
                () => allPlayerController.isShimmer.value
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ShimmerListClass(
                          length: 10,
                          height: 60,
                        ),
                      )
                    : (allPlayerController.rosterDetailModel.value.data?[0].playerTeams ?? []).isEmpty
                        ? Center(
                            child: buildNoData(
                            text: "No Player Found",
                          ))
                        : RefreshIndicator(
                            onRefresh: () async {
                              await allPlayerController.getRosterApiCall(teamId: Get.arguments[0]);
                            },
                            child: ListView.builder(
                                itemCount: allPlayerController.rosterDetailModel.value.data?[0].playerTeams
                                        ?.where((player) =>
                                            (player.firstName ?? "").toLowerCase().contains(allPlayerController.searchQuery.value) ||
                                            (player.lastName ?? "").toLowerCase().contains(allPlayerController.searchQuery.value))
                                        .length ??
                                    0,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                shrinkWrap: true,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  var filteredPlayers = allPlayerController.rosterDetailModel.value.data?[0].playerTeams
                                      ?.where((player) =>
                                          (player.firstName ?? "").toLowerCase().contains(allPlayerController.searchQuery.value) ||
                                          (player.lastName ?? "").toLowerCase().contains(allPlayerController.searchQuery.value))
                                      .toList();

                                  PlayerTeams? player = filteredPlayers?[index];
                                  int originalIndex = allPlayerController.rosterDetailModel.value.data?[0].playerTeams
                                          ?.indexWhere((p) => p.userId == player?.userId) ??
                                      0;
                                  return GestureDetector(
                                    onTap: () {
                                      hideKeyboard();

                                      Get.toNamed(AppRouter.playOverview, arguments: [originalIndex]);
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
                                            borderRadius: BorderRadius.circular(20),
                                            child: getImageView(
                                              finalUrl: player?.profile ?? "",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Gap(16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${player?.firstName ?? ""} ${player?.lastName ?? ""}",
                                                  style: TextStyle().normal20w500.textColor(
                                                        AppColor.black12Color,
                                                      ),
                                                ),
                                                if ((player?.jerseyNumber ?? "").isNotEmpty || (player?.position ?? "").isNotEmpty)
                                                  RichText(
                                                    text: TextSpan(children: [
                                                      if ((player?.jerseyNumber ?? "").isNotEmpty)
                                                        TextSpan(
                                                          text: "#${player?.jerseyNumber ?? ""}",
                                                          style: TextStyle().normal14w500.textColor(
                                                                AppColor.grey4EColor,
                                                              ),
                                                        ),
                                                      if ((player?.position ?? "").isNotEmpty)
                                                        TextSpan(
                                                          text: " - ${player?.position ?? ""}",
                                                          style: TextStyle().normal14w500.textColor(
                                                                AppColor.grey4EColor,
                                                              ),
                                                        ),
                                                    ]),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Gap(16),
                                          if (AppPref().role == 'coach')
                                            GestureDetector(
                                              onTap: () {
                                                hideKeyboard();

                                                Get.toNamed(
                                                  AppRouter.personalChat,
                                                  arguments: {
                                                    'chatData': ChatListData(
                                                      firstName: player?.firstName,
                                                      lastName: player?.lastName,
                                                      otherId: player?.userId.toString(),
                                                    ),
                                                  },
                                                );
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
            ),
          ],
        ),
      ),
    );
  }
}
