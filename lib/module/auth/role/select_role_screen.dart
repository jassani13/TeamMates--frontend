import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class SelectRoleScreen extends StatelessWidget {
  SelectRoleScreen({super.key});

  final selectRoleController =
      Get.put<SelectRoleController>(SelectRoleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Padding(
            padding:
                EdgeInsets.only(bottom: (Platform.isAndroid ? 20 : 24.0) + 50),
            child: SvgPicture.asset(
              AppImage.roleBg,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(16),
                        Text(
                          "Select your role",
                          style: TextStyle().normal32w500s.textColor(
                                AppColor.black12Color,
                              ),
                        ),
                        Text(
                          "Select your role to customize your experience in the app",
                          style: TextStyle().normal16w500.textColor(
                                AppColor.grey4EColor,
                              ),
                        ),
                        Gap(32),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: selectRoleController.roleList.length,
                          itemBuilder: (context, index) {
                            return Obx(
                              () => GestureDetector(
                                onTap: () {
                                  selectRoleController.selectedRole.value =
                                      selectRoleController.roleList[index];
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      width: 2,
                                      color: selectRoleController
                                                  .selectedRole.value ==
                                              selectRoleController
                                                  .roleList[index]
                                          ? AppColor.black
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        child: SvgPicture.asset(
                                          selectRoleController
                                                  .roleList[index].image ??
                                              "",
                                          height: 61,
                                          width: 61,
                                        ),
                                      ),
                                      Gap(8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              selectRoleController
                                                      .roleList[index].title ??
                                                  "",
                                              style: TextStyle()
                                                  .normal20w500
                                                  .textColor(
                                                    AppColor.black12Color,
                                                  ),
                                            ),
                                            Text(
                                              selectRoleController
                                                      .roleList[index]
                                                      .description ??
                                                  "",
                                              style: TextStyle()
                                                  .normal14w500
                                                  .textColor(
                                                    AppColor.grey4EColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: 10,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                CommonAppButton(
                  text: "Continue",
                  onTap: () async {
                    hideKeyboard();
                    await selectRoleController.updateRole();
                  },
                ),
                Gap(Platform.isAndroid ? 20 : 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
