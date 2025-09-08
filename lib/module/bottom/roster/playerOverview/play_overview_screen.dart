import 'package:base_code/module/bottom/roster/allPlayer/all_player_controller.dart';
import 'package:base_code/module/bottom/roster/playerOverview/play_overview_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'dart:io';

class PlayOverviewScreen extends StatefulWidget {
  PlayOverviewScreen({super.key});

  @override
  State<PlayOverviewScreen> createState() => _PlayOverviewScreenState();
}

class _PlayOverviewScreenState extends State<PlayOverviewScreen> {
  final playerOverviewController = Get.put<PlayerOverviewController>(PlayerOverviewController());
  final allPlayerController = Get.find<AllPlayerController>();
  int index = 0;

  @override
  void initState() {
    if (Get.arguments != null && Get.arguments.isNotEmpty) {
      index = Get.arguments[0];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: (AppPref().role == "coach")
          ? Container(
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
          text: "Remove from the team",
          onTap: () async {
            await playerOverviewController.removePlayerFromTeam(context,
                tID: allPlayerController.rosterDetailModel.value.data?[0].teamId ?? 0,
                mID: (allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].userId ?? 0));
          },
        ),
      )
          : const SizedBox(),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            width: double.infinity,
            child: Stack(
              children: [
                Obx(
                      () => (allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].profile ?? "").contains("icons")
                      ? Image.asset(
                    AppImage.defaultPlayer,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height / 3,
                    width: double.infinity,
                  )
                      : Stack(
                    children: [
                      getImageView(
                        finalUrl: '${allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].profile}' ?? "",
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height / 3,
                        width: double.infinity,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 3,
                        width: double.infinity,
                        color: Colors.black38,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap(Platform.isAndroid ? ScreenUtil().statusBarHeight + 20 : ScreenUtil().statusBarHeight + 10),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Container(
                              height: 36,
                              width: 36,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColor.white,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: AppColor.black12Color,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (AppPref().role == 'coach')
                            CommonIconButton(
                                image: AppImage.edit,
                                onTap: () {
                                  Get.toNamed(AppRouter.editPlayer, arguments: [index]);
                                }),
                        ],
                      ),
                      const Spacer(),
                      Obx(
                            () => Text(
                          "${allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].firstName} ${allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].lastName}",
                          style: TextStyle().normal32w500s.textColor(
                            AppColor.white,
                          ),
                        ),
                      ),
                      const Gap(16),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Obx(
                          () => buildContainer(
                          heading: "Name",
                          image: AppImage.fname,
                          value:
                          "${allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].firstName ?? "-"} ${allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].lastName ?? ""}"),
                    ),
                    Obx(
                          () => buildContainer(
                          image: AppImage.clock,
                          heading: "Birthday",
                          value: allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].dob ?? "-"),
                    ),
                    Obx(
                          () => buildContainer(
                          image: AppImage.location,
                          heading: "Location",
                          value: (allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].address ?? "").isNotEmpty
                              ? "${allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].address ?? ""}, ${allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].city ?? ""}, ${allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].state ?? "-"}"
                              : "-"),
                    ),
                    Obx(
                          () => buildContainer(
                        image: AppImage.person,
                        heading: "Jersey Number",
                        value: allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].jerseyNumber ?? "-",
                      ),
                    ),
                    Obx(
                          () => buildContainer(
                        image: AppImage.assignment,
                        heading: "Allergy",
                        value: allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].allergy ?? "-",
                      ),
                    ),
                    Obx(
                          () => buildContainer(
                        image: AppImage.position,
                        heading: "Position",
                        value: allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].position ?? "-",
                      ),
                    ),
                    Obx(
                          () => buildContainer(
                        image: AppImage.email,
                        heading: "Email",
                        value: (allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].userId ?? 0) != AppPref().userId
                            ? playerOverviewController.isCoach.value
                            ? (allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].email ?? "-")
                            : "-"
                            : (allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].email ?? "-"),
                      ),
                    ),
                    Obx(
                          () => buildContainer(
                        isFirst: false,
                        image: AppImage.call,
                        heading: "Phone number",
                        value: (allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].userId ?? 0) != AppPref().userId
                            ? playerOverviewController.isCoach.value
                            ? (allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].phoneNumber ?? "-")
                            : "-"
                            : (allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].phoneNumber ?? "-"),
                      ),
                    ),
                    // NEW: Display ALL user emails
                    _buildAllEmailsSection(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAllEmailsSection() {
    return Obx(() {
      final playerTeam = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index];
      final userEmails = playerTeam?.userEmails ?? [];
      final userRelationships = playerTeam?.userRelationships ?? [];

      if (userEmails.isEmpty || !playerOverviewController.isCoach.value) {
        return const SizedBox();
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(16),
          Row(
            children: [
              SvgPicture.asset(
                AppImage.info,
                colorFilter: const ColorFilter.mode(AppColor.black12Color, BlendMode.srcIn),
              ),
              const Gap(16),
              Text(
                "Contact Information",
                style: TextStyle().normal16w500.textColor(
                  AppColor.black12Color,
                ),
              ),
            ],
          ),
          const Gap(8),
          ...List.generate(userEmails.length - 2, (emailIndex) {
            final actualIndex = emailIndex + 2; // shift by 2
            final email = userEmails[actualIndex].toString();
            final relationship = actualIndex < userRelationships.length
                ? userRelationships[actualIndex].toString()
                : "Email";
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    relationship,
                    style: TextStyle().normal14w600.textColor(
                      AppColor.grey6EColor,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle().normal14w500.textColor(
                      AppColor.grey6EColor,
                    ),
                  ),
                ],
              ),
            );
          }),

        ],
      );
    });
  }

  Widget buildContainer({
    String? image,
    String? heading,
    String? value,
    bool? isFirst = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isFirst == true
            ? Border(
          bottom: BorderSide(
            color: AppColor.greyEAColor,
          ),
        )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: SvgPicture.asset(
              image ?? AppImage.name,
              colorFilter: ColorFilter.mode(AppColor.black12Color, BlendMode.srcIn),
            ),
          ),
          Gap(16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                heading ?? "",
                style: TextStyle().normal16w500.textColor(
                  AppColor.black12Color,
                ),
              ),
              Gap(4),
              Text(
                value ?? "",
                style: TextStyle().normal14w500.textColor(
                  AppColor.grey6EColor,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}