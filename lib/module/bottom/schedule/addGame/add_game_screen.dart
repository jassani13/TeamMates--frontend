import 'package:base_code/module/bottom/schedule/addGame/widget/frequncy_day_selector.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class AddGameScreen extends StatelessWidget {
  AddGameScreen({super.key});

  final addGameController = Get.put<AddGameController>(AddGameController());
  final formKey1 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(),
      child: Scaffold(
        appBar: AppBar(
          title: CommonTitleText(text: addGameController.isGame.value == true ? "New game" : "New event"),
          centerTitle: false,
          actions: [
            CommonIconButton(
              image: AppImage.check,
              onTap: () {
                if (formKey1.currentState!.validate()) {
                  if (addGameController.activityDetail.value == null) {
                    addGameController.addActivityApi(
                      activityType: addGameController.activityType.value,
                      isGame: addGameController.isGame.value,
                    );
                  } else {
                    addGameController.editActivityApi(
                      activityType: addGameController.activityType.value,
                      isGame: addGameController.isGame.value,
                      activityId: addGameController.activityDetail.value?.activityId ?? 0,
                    );
                  }
                }
              },
            ),
            Gap(20),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Form(
              key: formKey1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(16),
                  GestureDetector(
                    onTap: () {
                      addGameController.notify.value = !addGameController.notify.value;
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
                              value: addGameController.notify.value,
                              onChanged: (val) {
                                addGameController.notify.value = val ?? false;
                              },
                              checkColor: AppColor.black12Color,
                              activeColor: AppColor.white,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              side: BorderSide(color: AppColor.white, width: 2), // Border color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(24),
                  CommonTitleText(
                    text: addGameController.isGame.value == true ? "Game info" : "Event info",
                  ),
                  Gap(16),
                  Visibility(
                    visible: addGameController.isGame.value == true,
                    child: Column(
                      children: [
                        CommonTextField(
                          hintText: "Team",
                          readOnly: true,
                          suffixIcon: Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: AppColor.black12Color,
                          ),
                          controller: addGameController.teamController.value,
                          onTap: () async {
                            addGameController.allTeamList(
                              context,
                              list: addGameController.allRosterModelList,
                              storeValue: addGameController.teamController.value,
                            );
                          },
                          validator: (val) {
                            if ((val ?? "").isEmpty) {
                              return "Please select your team";
                            } else {
                              return null;
                            }
                          },
                        ),
                        Gap(16),
                      ],
                    ),
                  ),
                  CommonTextField(
                    hintText: addGameController.isGame.value == true ? "Game Name" : "Event Name",
                    controller: addGameController.activityNameController.value,
                    validator: (val) {
                      // if ((val ?? "").isEmpty) {
                      //   return "Please select name";
                      // } else {
                      //   return null;
                      // }
                    },
                  ),
                  Gap(16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Only for practice",
                          style: TextStyle().normal16w500.textColor(
                                AppColor.black12Color,
                              ),
                        ),
                      ),
                      Spacer(),
                      Obx(
                        () => Switch(
                            value: addGameController.isTimeTBD.value,
                            onChanged: (val) {
                              addGameController.isTimeTBD.value = !addGameController.isTimeTBD.value;
                            }),
                      ),
                    ],
                  ),
                  Gap(16),
                  Column(
                    children: [
                      CommonTextField(
                        hintText: "Date",
                        readOnly: true,
                        suffixIcon: Icon(
                          Icons.keyboard_arrow_down_sharp,
                          color: AppColor.black12Color,
                        ),
                        controller: addGameController.dateController.value,
                        onTap: () {
                          addGameController.showDatePicker(context, 0, addGameController.dateController.value,
                              initial: addGameController.dateController.value.text.isNotEmpty
                                  ? DateTime.parse(addGameController.dateController.value.text)
                                  : null);
                        },
                        validator: (val) {
                          if ((val ?? "").isEmpty) {
                            return "Please select date";
                          } else {
                            return null;
                          }
                        },
                      ),
                      Gap(16),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          validator: (val) {
                            if ((val ?? "").isEmpty) {
                              return "Please select start time";
                            }

                            final startText = val!;
                            final endText = addGameController.endTimeController.value.text;
                            final dateText = addGameController.dateController.value.text;

                            if (endText.isNotEmpty) {
                              try {
                                final start = DateTime.parse("$dateText $startText");
                                final end = DateTime.parse("$dateText $endText");

                                if (start.isAfter(end)) {
                                  return "Start time cannot be after end time";
                                }
                              } catch (e) {
                                return "Invalid time format";
                              }
                            }

                            return null;
                          },
                          hintText: "Start Time",
                          readOnly: true,
                          suffixIcon: Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: AppColor.black12Color,
                          ),
                          controller: addGameController.startTimeController.value,
                          onTap: () {
                            final dateText = addGameController.dateController.value.text;
                            final timeText = addGameController.startTimeController.value.text;

                            DateTime initialTime;

                            if (dateText.isNotEmpty && timeText.isNotEmpty) {
                              try {
                                final format = DateFormat("yyyy-MM-dd HH:mm:ss");
                                initialTime = format.parse("$dateText $timeText");
                              } catch (e) {
                                initialTime = DateTime.now();
                              }
                            } else {
                              initialTime = DateTime.now();
                            }

                            addGameController.showTimePicker(
                              context,
                              0,
                              addGameController.startTimeController.value,
                              initial: initialTime,
                            );
                          },
                        ),
                      ),
                      Gap(10),
                      Expanded(
                        child: CommonTextField(
                          hintText: "End Time",
                          readOnly: true,
                          suffixIcon: Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: AppColor.black12Color,
                          ),
                          controller: addGameController.endTimeController.value,
                          onTap: () {
                            final dateText = addGameController.dateController.value.text;
                            final timeText = addGameController.endTimeController.value.text;

                            DateTime initialTime;

                            if (dateText.isNotEmpty && timeText.isNotEmpty) {
                              try {
                                final format = DateFormat("yyyy-MM-dd HH:mm:ss");
                                initialTime = format.parse("$dateText $timeText");
                              } catch (e) {
                                initialTime = DateTime.now();
                              }
                            } else {
                              initialTime = DateTime.now();
                            }

                            addGameController.showTimePicker(
                              context,
                              0,
                              addGameController.endTimeController.value,
                              initial: initialTime,
                            );
                          },
                          validator: (val) {
                            if ((val ?? "").isEmpty) {
                              return "Please select end time";
                            }

                            final endText = val!;
                            final startText = addGameController.startTimeController.value.text;
                            final dateText = addGameController.dateController.value.text;

                            if (startText.isNotEmpty) {
                              try {
                                final start = DateTime.parse("$dateText $startText");
                                final end = DateTime.parse("$dateText $endText");

                                if (end.isBefore(start)) {
                                  return "End time cannot be before start time";
                                }
                              } catch (e) {
                                return "Invalid time format";
                              }
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Gap(16),
                      FrequencyDaySelector(
                        selectedDays: addGameController.selectedDays,
                        onSelectionChanged: (days) {
                          addGameController.selectedDays.value = days;
                        },
                      ),
                    ],
                  ),
                  Gap(16),
                  Visibility(
                    visible: addGameController.isGame.value == true,
                    child: Column(
                      children: [
                        CommonTextField(
                          hintText: "Opponent",
                          readOnly: true,
                          suffixIcon: Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: AppColor.black12Color,
                          ),
                          controller: addGameController.opponentController.value,
                          onTap: () async {
                            addGameController.showOpponentSheet(
                              context,
                              list: addGameController.opponentList,
                              storeValue: addGameController.opponentController.value,
                            );
                          },
                          validator: (val) {
                            if ((val ?? "").isEmpty) {
                              return "Please select your opponent";
                            } else {
                              return null;
                            }
                          },
                        ),
                        Gap(16),
                      ],
                    ),
                  ),
                  CommonTextField(
                    hintText: "Location",
                    readOnly: true,
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_sharp,
                      color: AppColor.black12Color,
                    ),
                    controller: addGameController.locationController.value,
                    onTap: () {
                      addGameController.showLocationSheet(
                        context,
                        list: addGameController.locationList,
                        storeValue: addGameController.locationController.value,
                      );
                    },
                    validator: (val) {
                      if ((val ?? "").isEmpty) {
                        return "Please select your location";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Location details",
                    controller: addGameController.locationDetailsController.value,
                  ),
                  Gap(24),
                  CommonTitleText(
                    text: "Volunteer assignment",
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Assignment or task",
                    readOnly: true,
                    suffixIcon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColor.black12Color,
                      size: 16,
                    ),
                    controller: addGameController.assignmentController.value,
                    onTap: () async {
                      var result = await Get.toNamed(AppRouter.volunteerAssignments, arguments: addGameController.assignmentController.value.text);
                      if (result != null) {
                        addGameController.assignmentController.value.text = result.join(", ");
                      }
                    },
                  ),
                  Gap(24),
                  Row(
                    children: [
                      CommonTitleText(
                        text: "Game details",
                      ),
                      Text(
                        " (Optional) ",
                        style: TextStyle().normal18w500.textColor(
                              AppColor.grey6EColor,
                            ),
                      )
                    ],
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Duration (min)",
                    readOnly: false,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: addGameController.durationController.value,
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Arrive early",
                    readOnly: true,
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_sharp,
                      color: AppColor.black12Color,
                    ),
                    controller: addGameController.arriveController.value,
                    onTap: () {
                      addGameController.showArriveEarlySheet(
                        context,
                        list: addGameController.arriveEarly,
                        storeValue: addGameController.arriveController.value,
                      );
                    },
                  ),
                  Gap(16),
                  Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: CommonTextField(
                            hintText: "Extra label",
                            controller: addGameController.extraLabelController.value,
                          )),
                      Gap(40),
                      Expanded(
                        flex: 1,
                        child: Obx(
                          () => GestureDetector(
                            onTap: () {
                              addGameController.isAway.value = true;
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                  color: addGameController.isAway.value == false ? AppColor.white : AppColor.black12Color,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColor.grey6EColor)),
                              child: Center(
                                  child: Text(
                                "Away",
                                style: TextStyle()
                                    .normal14w500
                                    .textColor(addGameController.isAway.value == true ? AppColor.white : AppColor.black12Color),
                              )),
                            ),
                          ),
                        ),
                      ),
                      Gap(12),
                      Expanded(
                        flex: 1,
                        child: Obx(
                          () => GestureDetector(
                            onTap: () {
                              addGameController.isAway.value = false;
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                  color: addGameController.isAway.value == true ? AppColor.white : AppColor.black12Color,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColor.grey6EColor)),
                              child: Center(
                                  child: Text(
                                "Home",
                                style: TextStyle()
                                    .normal14w500
                                    .textColor(addGameController.isAway.value == false ? AppColor.white : AppColor.black12Color),
                              )),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Uniform",
                    controller: addGameController.uniformController.value,
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Flag color",
                    readOnly: true,
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_sharp,
                      color: AppColor.black12Color,
                    ),
                    controller: addGameController.flagController.value,
                    onTap: () {
                      addGameController.showFlagSheet(context, storeValue: addGameController.flagController.value);
                    },
                  ),
                  Gap(16),
                  CommonTextField(
                    hintText: "Notes",
                    controller: addGameController.noteController.value,
                  ),
                  Visibility(
                    visible: addGameController.isGame.value == true,
                    child: Row(
                      children: [
                        Text(
                          "Not for standings",
                          style: TextStyle().normal16w500.textColor(
                                AppColor.black12Color,
                              ),
                        ),
                        Spacer(),
                        Obx(
                          () => Switch(
                              value: addGameController.isStanding.value,
                              onChanged: (val) {
                                addGameController.isStanding.value = !addGameController.isStanding.value;
                              }),
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Canceled",
                        style: TextStyle().normal16w500.textColor(
                              AppColor.black12Color,
                            ),
                      ),
                      Spacer(),
                      Obx(
                        () => Switch(
                            value: addGameController.isCanceled.value,
                            onChanged: (val) {
                              addGameController.isCanceled.value = !addGameController.isCanceled.value;
                              if (addGameController.isCanceled.value == false) {
                                addGameController.reasonController.value.clear();
                              }
                            }),
                      )
                    ],
                  ),
                  Obx(() {
                    return Visibility(
                      visible: addGameController.isCanceled.value,
                      child: Column(
                        children: [
                          Gap(10),
                          CommonTextField(
                            hintText: "Cancel Reason",
                            controller: addGameController.reasonController.value,
                            validator: (val) {
                              if ((val ?? "").isEmpty) {
                                return "Please enter reason for cancellation";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    );
                  }),
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
