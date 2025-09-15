import 'package:base_code/module/bottom/roster/allPlayer/all_player_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';


class AllPlayerScreen extends StatelessWidget {
  AllPlayerScreen({super.key});

  final allPlayerController = Get.put<AllPlayerController>(AllPlayerController());

  void _showAddOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Quick-Add Options",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionItem(
                context,
                title: "Add Player",
                onTap: () {
                  Get.back();
                  hideKeyboard();
                  Get.toNamed(AppRouter.addPlayer, arguments: [
                    allPlayerController.rosterDetailModel.value.data?[0].teamId ?? 0,
                    true
                  ]);
                },
              ),
              _buildOptionItem(
                context,
                title: "Add Staff",
                onTap: () {
                  Get.back();
                  hideKeyboard();
                  Get.toNamed(AppRouter.addNonPlayer, arguments: [
                    allPlayerController.rosterDetailModel.value.data?[0].teamId ?? 0,
                    true
                  ]);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(BuildContext context, {required String title, required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                    _showAddOptionsBottomSheet(context);
                  }),
            Gap(20),
          ],
        ),
        bottomNavigationBar: (AppPref().role == "coach")
            ? Obx(() {
          return allPlayerController.isShimmer.value
              ? const SizedBox()
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
            : const SizedBox(),
        body: Column(
          children: [
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CommonTextField(
                onChange: (value) {
                  allPlayerController.searchQuery.value = (value ?? "").toLowerCase();
                },
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColor.grey4EColor,
                ),
                controller: allPlayerController.searchController,
                hintText: "Search player...",
              ),
            ),
            const Gap(16),
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
                    child: buildNoData(text: "No Team Members Found"))
                    : RefreshIndicator(
                  onRefresh: () async {
                    int? teamId;
                    if (Get.arguments is Map && Get.arguments.containsKey('teamId')) {
                      teamId = Get.arguments['teamId'] as int;
                    } else if (Get.arguments is List && Get.arguments.isNotEmpty) {
                      teamId = Get.arguments[0] as int;
                    }
                    if (teamId != null) {
                      await allPlayerController.getRosterApiCall(teamId: teamId);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlayersSection(),
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
      var allMembers = allPlayerController.rosterDetailModel.value.data?[0].playerTeams ?? [];

      // ✅ Filter by user_identity instead of role
      var players = allMembers.where((member) =>
      (member.userIdentity?.toLowerCase() == 'player' ||
          member.userIdentity == null) // Handle null case if needed
      ).toList();

      var filteredPlayers = players
          .where((player) =>
      (player.firstName ?? "").toLowerCase().contains(allPlayerController.searchQuery.value) ||
          (player.lastName ?? "").toLowerCase().contains(allPlayerController.searchQuery.value))
          .toList();

      if (filteredPlayers.isEmpty && allPlayerController.searchQuery.value.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Players",
              style: TextStyle().normal18w600.textColor(AppColor.black12Color),
            ),
          ),
          if (filteredPlayers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
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
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                PlayerTeams player = filteredPlayers[index];
                int originalIndex = allPlayerController.rosterDetailModel.value.data?[0].playerTeams
                    ?.indexWhere((p) => p.userId == player.userId) ??
                    0;

                return _buildMemberTile(player, originalIndex, index);
              },
            ),
          const Gap(20),
        ],
      );
    });
  }

  Widget _buildStaffSection() {
    return Obx(() {
      var allMembers = allPlayerController.rosterDetailModel.value.data?[0].playerTeams ?? [];

      // ✅ Filter by user_identity instead of role
      var staff = allMembers.where((member) =>
      member.userIdentity?.toLowerCase() == 'non_player'
      ).toList();

      var filteredStaff = staff
          .where((staffMember) =>
      (staffMember.firstName ?? "").toLowerCase().contains(allPlayerController.searchQuery.value) ||
          (staffMember.lastName ?? "").toLowerCase().contains(allPlayerController.searchQuery.value))
          .toList();

      if (filteredStaff.isEmpty && allPlayerController.searchQuery.value.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Team Staff",
              style: TextStyle().normal18w600.textColor(AppColor.black12Color),
            ),
          ),
          if (filteredStaff.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
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
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                PlayerTeams staffMember = filteredStaff[index];
                int originalIndex = allPlayerController.rosterDetailModel.value.data?[0].playerTeams
                    ?.indexWhere((p) => p.userId == staffMember.userId) ??
                    0;

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
        padding: const EdgeInsets.only(
          bottom: 14,
          top: 14,
        ),
        decoration: BoxDecoration(
          border: index == 0
              ? null
              : const Border(
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
                // Use a local asset for "assets/icons/team1.png" and network for others.
                finalUrl: member.profile != null && member.profile!.startsWith('http') ? member.profile! : 'assets/icons/team1.png',
                fit: BoxFit.cover,
              ),
            ),
            const Gap(16),
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
                  if (isStaff)
                    Text(
                      member.staff_role ?? "Staff",
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
            const Gap(16),
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