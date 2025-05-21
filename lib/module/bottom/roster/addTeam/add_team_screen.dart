import 'package:base_code/module/bottom/roster/addTeam/add_team_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class AddTeamScreen extends StatelessWidget {
  AddTeamScreen({super.key});

  final addTeamController = Get.put<AddTeamController>(AddTeamController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard();
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create team",
                    style: TextStyle().normal28w500s.textColor(
                          AppColor.black12Color,
                        ),
                  ),
                  Text(
                    "Set up your team and invite players to join the fun!",
                    style: TextStyle().normal16w500.textColor(
                          AppColor.grey4EColor,
                        ),
                  ),
                  Gap(24),
                  Center(
                    child: GestureDetector(
                      onTap: () => addTeamController.showOptions(context),
                      child: Obx(
                        () => Container(
                          width: 116,
                          height: 116,
                          decoration: BoxDecoration(
                              color: AppColor.greyF6Color,
                              borderRadius: BorderRadius.circular(60),
                              border: addTeamController.selectedImageNum.value != -2 ? null : Border.all(color: AppColor.redColor)),
                          child: CircleAvatar(
                            backgroundColor: AppColor.greyF6Color,
                            child: Obx(
                              () => ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: addTeamController.selectedImage.value.isEmpty
                                    ? Center(
                                        child: SvgPicture.asset(
                                          AppImage.upload,
                                        ),
                                      )
                                    : addTeamController.selectedImage.value.startsWith("asset")
                                        ? SvgPicture.asset(
                                            addTeamController.selectedImage.value,
                                            fit: BoxFit.cover,
                                            width: 90,
                                            height: 90,
                                          )
                                        : Image.file(
                                            File(addTeamController.selectedImage.value),
                                            fit: BoxFit.cover,
                                            width: 90,
                                            height: 90,
                                          ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Gap(18),
                  Center(
                    child: Text(
                      "Upload team icon",
                      style: TextStyle().normal16w500.textColor(AppColor.black12Color),
                    ),
                  ),
                  Gap(24),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 10),
                      child: Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: addTeamController.teamIcon.asMap().entries.map((entry) {
                          int index = entry.key;
                          String icon = entry.value;

                          return GestureDetector(
                            onTap: () {
                              addTeamController.selectTeamIcon(icon, index);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SvgPicture.asset(
                                icon,
                                fit: BoxFit.cover,
                                height: 48,
                                width: 48,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Gap(24),
                  CommonTextField(
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(addTeamController.teamCodeFocus),

                    focusNode: addTeamController.teamNameFocus,
                    hintText: "Team Name",
                    controller: addTeamController.teamNameController,
                    inputFormatters: [
                      CapitalizedTextFormatter(),
                    ],
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please enter team name";
                      } else {
                        return null;
                      }
                    },
                  ),
                  // Gap(16),
                  // CommonTextField(
                  //   focusNode: addTeamController.teamCodeFocus,
                  //   hintText: "Team code",
                  //   controller: addTeamController.zipCodeController,
                  //   keyboardType: TextInputType.number,
                  //   validator: (val) {
                  //     if ((val ?? "").isEmpty) {
                  //       return "Please enter team code";
                  //     } else {
                  //       return null;
                  //     }
                  //   },
                  // ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Country",
                    controller: addTeamController.countryController,
                    readOnly: true,
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: AppColor.black12Color,
                    ),
                    onTap: () {
                      addTeamController.teamCodeFocus.unfocus();
                      addTeamController.teamNameFocus.unfocus();
                      addTeamController.showCountrySheet(context,
                          list: addTeamController.countryList, storeValue: addTeamController.countryController);
                    },
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please select country";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Sports your playing",
                    controller: addTeamController.gameController,
                    readOnly: true,
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: AppColor.black12Color,
                    ),
                    onTap: () {
                      addTeamController.teamCodeFocus.unfocus();
                      addTeamController.teamNameFocus.unfocus();
                      addTeamController.showCountrySheet(context, list: addTeamController.gameList, storeValue: addTeamController.gameController);
                    },
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please select sports";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Gap(32),
                  CommonAppButton(
                    text: "Add players",
                    onTap: () async {
                      if (addTeamController.selectedImageNum.value == (-1)) {
                        addTeamController.selectedImageNum.value = -2;
                      }
                      if (formKey.currentState!.validate()) {
                        if (addTeamController.selectedImageNum.value != (-2)) {
                          await addTeamController.createTeamApi();
                        }
                      }
                    },
                  ),
                  Gap(24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
