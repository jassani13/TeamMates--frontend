import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class ChallengeMembersScreen extends StatelessWidget {
  ChallengeMembersScreen({super.key});

  final controller = Get.put(ChallengeMembersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CommonTitleText(
          text: AppPref().role == "coach" ? "Challenge Members" : "Challenges & Rewards",
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: Obx(() => _buildBottomBar(context)),
      body: Obx(() => controller.isLoading.value ? SizedBox() : _buildBody(context)),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    if (controller.isLoading.value) return SizedBox();

    final isCoach = AppPref().role == "coach";
    final status = controller.challengeDetails.value.participateStatus ?? "";

    if (isCoach) {
      return _buildButton(
        text: "Delete Challenge",
        color: AppColor.redColor,
        onTap: () => controller.deleteChallenge(context),
      );
    } else if (status != "Completed") {
      return _buildButton(
        text: status.isEmpty ? "Participate" : "Complete",
        color: AppColor.successColor,
        onTap: () => _showParticipationDialog(context, status),
      );
    }
    return SizedBox();
  }

  Widget _buildButton({required String text, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        boxShadow: [BoxShadow(offset: Offset(0, -2), color: AppColor.lightPrimaryColor)],
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: Platform.isAndroid ? 20 : 24),
      child: CommonAppButton(color: color, text: text, onTap: onTap),
    );
  }

  Widget _buildBody(BuildContext context) {
    final challenge = controller.challengeDetails.value;
    final isCoach = AppPref().role == "coach";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(challenge, isCoach),
            Gap(16),
            if (challenge.notes?.isNotEmpty ?? false) _buildNotes(challenge.notes!),
            Gap(16),
            isCoach ? _buildParticipantsList(context, challenge) : _buildNoCoachView(context, challenge)
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Challenge challenge, bool isCoach) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(challenge.name ?? "", style: TextStyle().normal20w500.textColor(AppColor.black12Color)),
              Text(
                "${DateUtilities.formatDate(challenge.startAt ?? "", dateFormat: "MMM dd, yyyy")} - ${DateUtilities.formatDate(challenge.endAt ?? "", dateFormat: "MMM dd, yyyy")}",
                style: TextStyle().normal16w500.textColor(AppColor.grey4EColor),
              ),
              if (isCoach)
                Text("${challenge.attendancePercentage ?? "0"}% attendance", style: TextStyle().normal16w500.textColor(AppColor.grey4EColor)),
            ],
          ),
        ),
        if (!isCoach) Text(DateUtilities.getTimeLeft(challenge.endAt ?? ""), style: TextStyle().normal16w500.textColor(AppColor.redColor)),
      ],
    );
  }

  Widget _buildNotes(String notes) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: SvgPicture.asset(AppImage.note),
        ),
        Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notes, style: TextStyle().normal16w500.textColor(AppColor.black12Color)),
              Text("Notes", style: TextStyle().normal16w500.textColor(AppColor.grey6EColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsList(BuildContext context, Challenge challenge) {
    final participants = challenge.participates ?? [];
    if (participants.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 5),
          child: buildNoData(text: "No participate found"),
        ),
      );
    }

    return ListView.separated(
      itemCount: participants.length,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) => _buildParticipantItem(participants[index]),
      separatorBuilder: (context, index) => Divider(color: AppColor.greyF6Color),
    );
  }

  Widget _buildParticipantItem(Participates participate) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: getImageView(
              finalUrl: '$publicImageUrl${participate.user?.profile}' ?? "",
              fit: BoxFit.cover,
              height: 48,
              width: 48,
            ),
          ),
          Gap(16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${participate.user?.firstName ?? ""} ${participate.user?.lastName ?? ""}",
                  style: TextStyle().normal20w500.textColor(AppColor.black12Color)),
              Text(
                participate.status ?? "",
                style: TextStyle().normal14w500.textColor(_getStatusColor(participate.status)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "completed":
        return AppColor.success500;
      case "participate":
        return AppColor.primaryColor;
      default:
        return AppColor.grey4EColor;
    }
  }

  Widget _buildNoCoachView(BuildContext context, Challenge challenge) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 5),
          child: Center(child: SvgPicture.asset(AppImage.noP)),
        ),
        if ((challenge.participateStatus ?? "") == "Completed") ...[
          Gap(20),
          Center(
            child: Text(
              "This challenge is already\ncompleted by you.",
              textAlign: TextAlign.center,
              style: TextStyle().textColor(AppColor.successColor).normal18w500,
            ),
          )
        ]
      ],
    );
  }

  Future<void> _showParticipationDialog(BuildContext context, String status) {
    final isParticipating = status.toLowerCase() != 'participate';
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => SimpleCommonDialog(
        icon: AppImage.logOut,
        btn1Text: "Cancel",
        btn2Text: "Yes",
        btn2Tap: () async {
          Get.back();
          await controller.statusChangeApiCall(
            status: isParticipating ? "Participate" : "Completed",
          );
        },
        btn1Tap: () => Get.back(),
        subTitle: isParticipating ? "Are you sure you want to\nparticipate in this challenge?" : "Are you sure you completed\nthis challenge?",
      ),
    );
  }
}
