import 'package:base_code/components/common_icon_button.dart';
import 'package:base_code/module/bottom/stats/challangeMembers/challange_members_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/utils/common_simple_dialog.dart';

class ChallengeMembersScreen extends StatelessWidget {
  ChallengeMembersScreen({super.key});

  final challengeMembersController = Get.put<ChallengeMembersController>(ChallengeMembersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CommonTitleText(text: (AppPref().role == "coach") ? "Challenge Members" : "Challenges & Rewards"),
        centerTitle: false,
      ),
      bottomNavigationBar: (AppPref().role == "coach")
          ? Obx(() {
              return challengeMembersController.isLoading.value
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
                        text: "Delete Challenge",
                        onTap: () {
                          challengeMembersController.deleteChallenge(context);
                        },
                      ),
                    );
            })
          : Obx(() {
              return challengeMembersController.isLoading.value
                  ? SizedBox()
                  : (challengeMembersController.challengeDetails.value.participateStatus ?? "") == "Completed"
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
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                          child: CommonAppButton(
                            color: AppColor.successColor,
                            text: (challengeMembersController.challengeDetails.value.participateStatus ?? "").isEmpty ? "Participate" : "Complete",
                            onTap: () {
                              participateCompleteDialog(
                                context: context,
                                status: challengeMembersController.challengeDetails.value.participateStatus?.toLowerCase() ?? "",
                              );
                            },
                          ),
                        );
            }),
      body: Obx(
        () => challengeMembersController.isLoading.value
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  challengeMembersController.challengeDetails.value.name ?? "",
                                  style: TextStyle().normal20w500.textColor(
                                        AppColor.black12Color,
                                      ),
                                ),
                                Text(
                                  "${DateUtilities.formatDate(challengeMembersController.challengeDetails.value.startAt ?? "", dateFormat: "MMM dd, yyyy")} - ${DateUtilities.formatDate(challengeMembersController.challengeDetails.value.endAt ?? "", dateFormat: "MMM dd, yyyy")}",
                                  style: TextStyle().normal16w500.textColor(
                                        AppColor.grey4EColor,
                                      ),
                                ),
                                Visibility(
                                  visible: (AppPref().role == "coach"),
                                  child: Text(
                                    "${challengeMembersController.challengeDetails.value.attendancePercentage ?? "0"}% attendance",
                                    style: TextStyle().normal16w500.textColor(
                                          AppColor.grey4EColor,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (AppPref().role != "coach")
                            Text(
                              DateUtilities.getTimeLeft(challengeMembersController.challengeDetails.value.endAt ?? "2025-03-15 02:47:00"),
                              style: TextStyle().normal16w500.textColor(
                                    AppColor.redColor,
                                  ),
                            ),
                        ],
                      ),
                      Gap(16),
                      Obx(() {
                        return (challengeMembersController.challengeDetails.value.notes ?? "").isEmpty
                            ? SizedBox()
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: SvgPicture.asset(
                                      AppImage.note,
                                    ),
                                  ),
                                  Gap(16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          challengeMembersController.challengeDetails.value.notes ?? "-",
                                          style: TextStyle().normal16w500.textColor(
                                                AppColor.black12Color,
                                              ),
                                        ),
                                        Text(
                                          "Notes",
                                          style: TextStyle().normal16w500.textColor(
                                                AppColor.grey6EColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Spacer(),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(top: 10.0),
                                  //   child: Icon(
                                  //     Icons.arrow_forward_ios_rounded,
                                  //     color: AppColor.grey6EColor,
                                  //     size: 20,
                                  //   ),
                                  // )
                                ],
                              );
                      }),
                      Gap(16),
                      if (AppPref().role == "coach") ...[
                        Obx(() {
                          return challengeMembersController.isLoading.value
                              ? Text("")
                              : (challengeMembersController.challengeDetails.value.participates ?? []).isEmpty
                                  ? Center(
                                      child: Padding(
                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 5),
                                      child: buildNoData(text: "No participate found"),
                                    ))
                                  : ListView.builder(
                                      itemCount: (challengeMembersController.challengeDetails.value.participates ?? []).length,
                                      padding: EdgeInsets.zero,
                                      physics: ScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return Container(
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
                                                        '$publicImageUrl${(challengeMembersController.challengeDetails.value.participates ?? [])[index].user?.profile}' ??
                                                            "",
                                                    fit: BoxFit.cover,
                                                    height: 48,
                                                    width: 48),
                                              ),
                                              Gap(16),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${(challengeMembersController.challengeDetails.value.participates ?? [])[index].user?.firstName ?? ""} ${(challengeMembersController.challengeDetails.value.participates ?? [])[index].user?.lastName ?? ""}",
                                                    style: TextStyle().normal20w500.textColor(
                                                          AppColor.black12Color,
                                                        ),
                                                  ),
                                                  Text(
                                                    (challengeMembersController.challengeDetails.value.participates ?? [])[index].status ?? "",
                                                    style: TextStyle().normal14w500.textColor(
                                                          (challengeMembersController.challengeDetails.value.participates ?? [])[index]
                                                                      .status
                                                                      ?.toLowerCase() ==
                                                                  "completed"
                                                              ? AppColor.success500
                                                              : (challengeMembersController.challengeDetails.value.participates ?? [])[index]
                                                                          .status
                                                                          ?.toLowerCase() ==
                                                                      "participate"
                                                                  ? AppColor.primaryColor
                                                                  : AppColor.grey4EColor,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                        }),
                      ] else ...[
                        Padding(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 5),
                          child: Center(child: SvgPicture.asset(AppImage.noP)),
                        ),
                        if ((challengeMembersController.challengeDetails.value.participateStatus ?? "") == "Completed") ...[
                          Gap(20),
                          Center(
                            child: Text(
                              "This challenge is already\ncompleted by you.",
                              textAlign: TextAlign.center,
                              style: TextStyle().textColor(AppColor.successColor).normal18w500,
                            ),
                          )
                        ]
                      ]
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> participateCompleteDialog({
    required BuildContext context,
    required String status,
  }) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleCommonDialog(
          icon: AppImage.logOut,
          btn1Text: "Cancel",
          btn2Text: "Yes",
          btn2Tap: () async {
            Get.back();
            await challengeMembersController.statusChangeApiCall(
              status: (challengeMembersController.challengeDetails.value.participateStatus ?? "").isEmpty ? "Participate" : "Completed",
            );
          },
          btn1Tap: () {
            Get.back();
          },
          subTitle: status.toLowerCase() != 'participate'
              ? "Are you sure you want to\nparticipate in this challenge?"
              : "Are you sure you completed\nthis challenge?",
        );
      },
    );
  }
}
