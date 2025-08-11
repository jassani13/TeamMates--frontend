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
                            text: "No Team Members Found",
                          ))
                        : RefreshIndicator(
                            onRefresh: () async {
                              await allPlayerController.getRosterApiCall(teamId: Get.arguments[0]);
                            },
                            child: SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Players Section
                                  _buildPlayersSection(),
                                  
                                  // Staff Section
                                  _buildStaffSection(),
                                ],
                              ),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersSection() {
    return Obx(() {
      // Filter players (role = 'team')
      var allMembers = allPlayerController.rosterDetailModel.value.data?[0].playerTeams ?? [];
      var players = allMembers.where((member) => member.role == 'team').toList();
      
      // Apply search filter
      var filteredPlayers = players.where((player) =>
          (player.firstName ?? "").toLowerCase().contains(allPlayerController.searchQuery.value) ||
          (player.lastName ?? "").toLowerCase().contains(allPlayerController.searchQuery.value))
      .toList();

      if (filteredPlayers.isEmpty && allPlayerController.searchQuery.value.isEmpty) {
        return SizedBox(); // Don't show section if no players
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Players",
              style: TextStyle().normal18w600.textColor(AppColor.black12Color),
            ),
          ),
          
          // Players List
          if (filteredPlayers.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "No players found",
                  style: TextStyle().normal14w500.textColor(AppColor.grey4EColor),
                ),
              ),
            )
          else
            ListView.builder(
              itemCount: filteredPlayers.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                PlayerTeams player = filteredPlayers[index];
                int originalIndex = allPlayerController.rosterDetailModel.value.data?[0].playerTeams
                        ?.indexWhere((p) => p.userId == player.userId) ?? 0;
                        
                return _buildMemberTile(player, originalIndex, index);
              },
            ),
          Gap(20),
        ],
      );
    });
  }

  Widget _buildStaffSection() {
    return Obx(() {
      // Filter staff (role = 'coach')
      var allMembers = allPlayerController.rosterDetailModel.value.data?[0].playerTeams ?? [];
      var staff = allMembers.where((member) => member.role == 'coach').toList();
      
      // Apply search filter
      var filteredStaff = staff.where((staffMember) =>
          (staffMember.firstName ?? "").toLowerCase().contains(allPlayerController.searchQuery.value) ||
          (staffMember.lastName ?? "").toLowerCase().contains(allPlayerController.searchQuery.value))
      .toList();

      if (filteredStaff.isEmpty && allPlayerController.searchQuery.value.isEmpty) {
        return SizedBox(); // Don't show section if no staff
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Staff",
              style: TextStyle().normal18w600.textColor(AppColor.black12Color),
            ),
          ),
          
          // Staff List
          if (filteredStaff.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "No staff found",
                  style: TextStyle().normal14w500.textColor(AppColor.grey4EColor),
                ),
              ),
            )
          else
            ListView.builder(
              itemCount: filteredStaff.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                PlayerTeams staffMember = filteredStaff[index];
                int originalIndex = allPlayerController.rosterDetailModel.value.data?[0].playerTeams
                        ?.indexWhere((p) => p.userId == staffMember.userId) ?? 0;
                        
                return _buildMemberTile(staffMember, originalIndex, index, isStaff: true);
              },
            ),
        ],
      );
    });
  }

  Widget _buildMemberTile(PlayerTeams member, int originalIndex, int index, {bool isStaff = false}) {
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
                finalUrl: '${member.profile}',
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
                    "${member.firstName ?? ""} ${member.lastName ?? ""}",
                    style: TextStyle().normal20w500.textColor(
                          AppColor.black12Color,
                        ),
                  ),
                  // Show different info for players vs staff
                  if (isStaff)
                    Text(
                      "Staff",
                      style: TextStyle().normal14w500.textColor(
                            AppColor.grey4EColor,
                          ),
                    )
                  else if ((member.jerseyNumber ?? "").isNotEmpty || (member.position ?? "").isNotEmpty)
                    RichText(
                      text: TextSpan(children: [
                        if ((member.jerseyNumber ?? "").isNotEmpty)
                          TextSpan(
                            text: "#${member.jerseyNumber ?? ""}",
                            style: TextStyle().normal14w500.textColor(
                                  AppColor.grey4EColor,
                                ),
                          ),
                        if ((member.position ?? "").isNotEmpty)
                          TextSpan(
                            text: " - ${member.position ?? ""}",
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
            GestureDetector(
              onTap: () {
                hideKeyboard();
                Get.toNamed(
                  AppRouter.personalChat,
                  arguments: {
                    'chatData': ChatListData(
                      firstName: member.firstName,
                      lastName: member.lastName,
                      otherId: member.userId.toString(),
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
  }
}