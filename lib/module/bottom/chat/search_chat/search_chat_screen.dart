import 'package:base_code/main.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class SearchChatScreen extends StatelessWidget {
  SearchChatScreen({super.key});

  final controller = Get.put<SearchChatController>(SearchChatController());

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: hideKeyboard,
        child: Scaffold(
          backgroundColor: AppColor.white,
          appBar: AppBar(
            backgroundColor: AppColor.white,
            title: const CommonTitleText(text: 'Search'),
            centerTitle: false,
            actions: [
              Visibility(
                visible: AppPref().role == 'coach',
                child: CommonIconButton(
                  image: AppImage.plus,
                  onTap: () {
                    //Get.toNamed(AppRouter.searchChatScreen);
                  },
                ),
              ),
              Gap(16)
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildMethodSelector(),
                const Gap(6),
                Expanded(child: Obx(() => _buildSearchContent(context))),
              ],
            ),
          ),
        ),
      );

  Widget _buildMethodSelector() => Container(
        height: 63,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.greyF6Color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: HorizontalSelectionList(
          items: controller.chatList,
          selectedIndex: controller.selectedChatMethod,
          controller: controller.controller,
          onItemSelected: (index) => controller.selectedChatMethod.value = index,
        ),
      );

  Widget _buildSearchContent(BuildContext context) {
    final isTeam = controller.selectedChatMethod.value == 0;
    return Column(
      children: [
        const Gap(8),
        _buildSearchField(isTeam),
        const Gap(16),
        Expanded(child: isTeam ? _buildTeamList(context) : _buildPlayerList(context)),
      ],
    );
  }

  Widget _buildSearchField(bool isTeam) => CommonTextField(
        onChange: (value) {
          final query = (value ?? '').trim().toLowerCase();
          if (isTeam)
            controller.searchTeamQuery.value = query;
          else
            controller.searchPlayerQuery.value = query;
        },
        prefixIcon: const Icon(Icons.search, color: AppColor.grey4EColor),
        controller: isTeam ? controller.searchTeamController : controller.searchPlayerController,
        hintText: isTeam ? 'Search team...' : 'Search player...',
      );

  Widget _showEmptyState({String? message}) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: Get.height / 3.3),
            child: message != null ? buildNoData(text: message) : buildNoData(),
          ),
        ),
      );

  Widget _buildShimmer() => const ShimmerListClass(length: 10, height: 60);

  Widget _buildTeamList(BuildContext context) {
    return Obx(() {
      if (controller.isShimmer.value) return _buildShimmer();

      final teams = controller.allRosterModelList.where((r) => (r.name ?? '').toLowerCase().contains(controller.searchTeamQuery.value)).toList();

      if (teams.isEmpty) return _showEmptyState();

      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: teams.length,
        separatorBuilder: (_, __) => Divider(color: AppColor.greyF6Color),
        itemBuilder: (_, index) {
          final roster = teams[index];
          return _buildTeamRow(roster, context);
        },
      );
    });
  }

  Widget _buildTeamRow(Roster roster, context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: getImageView(
              finalUrl: '${(roster.iconImage ?? '').isNotEmpty ? roster.iconImage : roster.teamImage}',
              fit: BoxFit.cover,
              height: 48,
              width: 48,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(roster.name ?? '', style: TextStyle().normal20w500.textColor(AppColor.black12Color)),
                Text('${roster.playerTeamsCount ?? ''} Participants', style: TextStyle().normal14w500.textColor(AppColor.grey4EColor)),
              ],
            ),
          ),
          const Gap(16),
          if (AppPref().role == 'coach')
            _buildChatButton(
              onTap: () => _onTeamChatTap(roster.teamId.toString(), roster.name, context),
            ),
        ],
      ),
    );
  }

  void _onTeamChatTap(String teamId, String? teamName, context) {
    // if (AppPref().role == 'coach') {
    //   if (AppPref().proUser == true) {
    //     Get.toNamed(
    //       AppRouter.grpChat,
    //       arguments: {
    //         'chatData': ChatListData(teamName: teamName, teamId: teamId),
    //       },
    //     );
    //   } else {
    //     _showSubscriptionDialog(middleText: "Buy a subscription to\naccess Team Chat.");
    //   }
    // } else {
      Get.toNamed(
        AppRouter.grpChat,
        arguments: {
          'chatData': ChatListData(teamName: teamName, teamId: teamId),
        },
      );
    // }
  }

  Widget _buildPlayerList(BuildContext context) {
    return Obx(() {
      if (controller.isShimmer.value) return _buildShimmer();

      final players = controller.allPlayerModelList
          .where((p) => ('${p.firstName} ${p.lastName}').toLowerCase().contains(controller.searchPlayerQuery.value))
          .toList();

      if (players.isEmpty) return _showEmptyState(message: 'No Player Found');

      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: players.length,
        separatorBuilder: (_, __) => Divider(color: AppColor.greyF6Color),
        itemBuilder: (_, index) {
          final roster = players[index];
          return _buildPlayerRow(roster);
        },
      );
    });
  }

  Widget _buildPlayerRow(PlayerTeams roster) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: getImageView(
            finalUrl: '${roster.profile ?? ''}',
            fit: BoxFit.cover,
            height: 48,
            width: 48,
          ),
        ),
        const Gap(16),
        Expanded(
          child: Text(
            '${roster.firstName} ${roster.lastName}',
            style: TextStyle().normal20w500.textColor(AppColor.black12Color),
          ),
        ),
        const Gap(16),
        if (AppPref().role == 'coach')
          _buildChatButton(
            onTap: () => _onPlayerChatTap(roster.userId.toString(), roster.firstName ?? "", roster.lastName ?? ""),
          ),
      ]),
    );
  }

  void _onPlayerChatTap(String userId, String firstName, String lastName) {
    Get.toNamed(AppRouter.personalChat, arguments: {
      'chatData': ChatListData(firstName: firstName, lastName: lastName, otherId: userId),
    });
  }
}

Widget _buildChatButton({required VoidCallback onTap}) => GestureDetector(
      onTap: onTap,
      child: Image.asset(AppImage.messenger, height: 20),
    );

void _showSubscriptionDialog({required String middleText}) => Get.defaultDialog(
      title: 'Subscription Required',
      titleStyle: TextStyle().normal20w500.textColor(AppColor.black12Color),
      middleText: middleText,
      middleTextStyle: TextStyle().normal16w400.textColor(AppColor.grey4EColor),
      textConfirm: 'Buy Now',
      textCancel: 'Cancel',
      confirmTextColor: AppColor.white,
      buttonColor: AppColor.black12Color,
      cancelTextColor: AppColor.black12Color,
      onConfirm: () {
        Get.back();
        Get.toNamed(AppRouter.subscription);
      },
    );
