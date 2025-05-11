import 'package:base_code/model/noti_model.dart';
import 'package:base_code/module/bottom/home/notification/notification_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final notificationController = Get.put<NotificationController>(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CommonTitleText(
          text: "Notification",
        ),
      ),
      body: Obx(() {
        return notificationController.isShimmer.value
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ShimmerListClass(
                  length: 7,
                  height: 100,
                ),
              )
            : ((notificationController.notificationList).isEmpty)
                ? Center(child: buildNoData(text: "No notification found"))
                : ListView.builder(
                    itemCount: notificationController.notificationList.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemBuilder: (context, index) {
                      NotificationModel val = notificationController.notificationList[index];
                      return GestureDetector(
                        onTap: () {
                          if (val.modelType == "Team") {
                            Get.toNamed(AppRouter.allPlayer, arguments: [val.details?.teamId ?? ""]);
                          } else if (val.modelType == "Challenge") {
                            Get.toNamed(
                              AppRouter.challengeMembers,
                              arguments: {
                                "challenge_id": val.details?.challengeId ?? "",
                                "isHome": false,
                              },
                            );
                          } else if (val.modelType == "Activity") {
                            Get.toNamed(AppRouter.gameProgress, arguments: {
                              'user_id': val.userId,
                              'activity_id': val.details?.activityId,
                            });
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: index == 0 ? 0 : 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColor.greyEAColor),
                              borderRadius: BorderRadius.circular(
                                8,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: AppColor.black12Color,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      )),
                                  child: Text(
                                    notificationController.notificationList[index].modelType ?? "",
                                    style: TextStyle().normal16w500.textColor(
                                          AppColor.white,
                                        ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(16),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: AppColor.greyF6Color, borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: SvgPicture.asset(
                                          AppImage.ti1,
                                          height: 24,
                                          width: 24,
                                        ),
                                      ),
                                      Gap(16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CommonTitleText(
                                              text: notificationController.notificationList[index].notifyType ?? "",
                                            ),
                                            Text(
                                              notificationController.notificationList[index].message ?? "",
                                              style: TextStyle().normal14w500.textColor(
                                                    AppColor.black12Color,
                                                  ),
                                            ),
                                            Text(
                                              DateUtilities.getTimeAgo(
                                                notificationController.notificationList[index].createdAt ?? "",
                                              ),
                                              style: TextStyle().normal14w500.textColor(
                                                    AppColor.grey4EColor,
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
                        ),
                      );
                    });
      }),
    );
  }
}
