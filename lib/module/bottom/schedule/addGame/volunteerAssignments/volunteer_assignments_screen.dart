import 'package:base_code/components/common_icon_button.dart';
import 'package:base_code/module/bottom/schedule/addGame/volunteerAssignments/volunteer_assignments_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class VolunteerAssignmentsScreen extends StatelessWidget {
  VolunteerAssignmentsScreen({super.key});

  final volunteerAssignmentsController = Get.put<VolunteerAssignmentsController>(VolunteerAssignmentsController());

  List<String> getSelectedAssignments() {
    return volunteerAssignmentsController.dataList.where((data) => data.isCheck).map((data) => data.title).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          CommonIconButton(
            image: AppImage.check,
            onTap: () {
              Get.back(result: getSelectedAssignments());
            },
          ),
          Gap(20),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(16),
            Text(
              "Volunteer assignments",
              style: TextStyle().normal28w500s.textColor(
                    AppColor.black12Color,
                  ),
            ),
            Text(
              "Manage and track volunteer roles for upcoming\nevents and activities",
              style: TextStyle().normal16w500.textColor(
                    AppColor.grey4EColor,
                  ),
            ),
            Gap(24),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: volunteerAssignmentsController.dataList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.only(
                        bottom: 8,
                        top: 8,
                      ),
                      decoration: BoxDecoration(
                        border:index==0?null: Border(
                          top: BorderSide(
                            color: AppColor.greyEAColor,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          volunteerAssignmentsController.dataList[index].isCheck = !(volunteerAssignmentsController.dataList[index].isCheck);
                          volunteerAssignmentsController.dataList.refresh();
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Row(
                          children: [
                            Obx(
                              () => Checkbox(
                                value: volunteerAssignmentsController.dataList[index].isCheck,
                                onChanged: (val) {
                                  volunteerAssignmentsController.dataList[index].isCheck = val ?? true;
                                  volunteerAssignmentsController.dataList.refresh();
                                },
                                checkColor: AppColor.white,
                                activeColor: AppColor.black12Color,
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                side: BorderSide(color: AppColor.black12Color, width: 2),
                              ),
                            ),
                            Gap(16),
                            Text(
                              volunteerAssignmentsController.dataList[index].title ?? "",
                              style: TextStyle().normal16w500.textColor(
                                    AppColor.black12Color,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
