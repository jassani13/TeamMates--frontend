import 'package:base_code/components/common_icon_button.dart';
import 'package:base_code/module/bottom/stats/createChallenge/create_challenge_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/utils/common_function.dart';

class CreateChallengeScreen extends StatelessWidget {
  CreateChallengeScreen({super.key});

  final createChallengeController =
      Get.put<CreateChallengeController>(CreateChallengeController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(),
      child: Scaffold(
        appBar: AppBar(
          title: CommonTitleText(text: "Create a Challenge"),
          centerTitle: false,
          actions: [
            CommonIconButton(
                image: AppImage.check,
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    createChallengeController.addChallengeApi();
                  }
                }),
            Gap(20),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(16),
                  GestureDetector(
                    onTap: () {
                      createChallengeController.isNotify.value =
                          !createChallengeController.isNotify.value;
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        color: AppColor.black12Color,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Notify Team",
                            style: TextStyle().normal16w500.textColor(
                                  AppColor.white,
                                ),
                          ),
                          Spacer(),
                          Obx(
                            () => Checkbox(
                              value: createChallengeController.isNotify.value,
                              onChanged: (val) {
                                createChallengeController.isNotify.value =
                                    val ?? false;
                              },
                              checkColor: AppColor.black12Color,
                              activeColor: AppColor.white,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              side: BorderSide(
                                  color: AppColor.white,
                                  width: 2), // Border color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(24),
                  CommonTitleText(text: "Challenge Info"),
                  Gap(16),
                  CommonTextField(
                    focusNode: createChallengeController.nameFocus,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(createChallengeController.descFocus);
                    },


                    controller: createChallengeController.cNameController,
                    hintText: "Challenge Name",
                    inputFormatters: [
                      CapitalizedTextFormatter(),
                    ],
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please enter challenge name";
                      }
                      return null;
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    focusNode: createChallengeController.descFocus,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(createChallengeController.notesFocus);
                    },


                    maxLine: 4,
                    controller:
                        createChallengeController.cDescriptionController,
                    inputFormatters: [
                      CapitalizedTextFormatter(),
                    ],
                    hintText: "Challenge Description",
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please enter challenge description";
                      }
                      return null;
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Start time",
                    readOnly: true,
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_sharp,
                      color: AppColor.black12Color,
                    ),
                    controller:
                        createChallengeController.startTimeController.value,
                    onTap: () {
                      createChallengeController.notesFocus.unfocus();
                      createChallengeController.descFocus.unfocus();
                      createChallengeController.notesFocus.unfocus();
                      createChallengeController.showTimePicker(context, 0,
                          createChallengeController.startTimeController.value);
                    },
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please select start time";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "End Time",
                    readOnly: true,
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_sharp,
                      color: AppColor.black12Color,
                    ),
                    controller:
                        createChallengeController.endTimeController.value,
                    onTap: () {

                      createChallengeController.notesFocus.unfocus();
                      createChallengeController.descFocus.unfocus();
                      createChallengeController.notesFocus.unfocus();

                      createChallengeController.showTimePicker(context, 0,
                          createChallengeController.endTimeController.value);
                    },
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please select end time";
                      }

                      DateTime? startTime = createChallengeController
                          .parseDateTime(createChallengeController
                              .startTimeController.value.text);
                      DateTime? endTime = createChallengeController
                          .parseDateTime(createChallengeController
                              .endTimeController.value.text);

                      if (startTime != null && endTime != null) {

                        if (startTime.year == endTime.year &&
                            startTime.month == endTime.month &&
                            startTime.hour == endTime.hour &&
                            startTime.second == endTime.second &&
                            startTime.minute == endTime.minute &&
                            startTime.day == endTime.day     ) {
                          return "Start date and end date must not be the same";
                        }
                        else if (endTime.isBefore(startTime)) {
                          return "End time must be greater than start time";
                        }
                        else{
                          return null;
                        }
                      }

                      return null;
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    focusNode: createChallengeController.notesFocus,

                    controller: createChallengeController.notesController,
                    hintText: "Notes",
                    inputFormatters: [
                      CapitalizedTextFormatter(),
                    ],
                    textInputAction: TextInputAction.done,
                    maxLine: 4,
                  ),
                  Gap(16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
