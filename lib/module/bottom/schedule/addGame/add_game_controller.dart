import 'package:base_code/module/bottom/home/home_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class AddGameController extends GetxController {
  Rx<TextEditingController> teamController = TextEditingController().obs;
  Rx<TextEditingController> dateController = TextEditingController().obs;
  Rx<TextEditingController> activityNameController = TextEditingController().obs;
  Rx<TextEditingController> endTimeController = TextEditingController().obs;
  Rx<TextEditingController> startTimeController = TextEditingController().obs;

  // Rx<TextEditingController> timeZoneController = TextEditingController().obs;
  Rx<TextEditingController> opponentController = TextEditingController().obs;
  Rx<TextEditingController> locationController = TextEditingController().obs;
  Rx<TextEditingController> locationDetailsController = TextEditingController().obs;
  Rx<TextEditingController> assignmentController = TextEditingController().obs;
  Rx<TextEditingController> durationController = TextEditingController().obs;
  Rx<TextEditingController> arriveController = TextEditingController().obs;
  Rx<TextEditingController> extraLabelController = TextEditingController().obs;
  Rx<TextEditingController> uniformController = TextEditingController().obs;
  Rx<TextEditingController> noteController = TextEditingController().obs;
  Rx<TextEditingController> flagController = TextEditingController().obs;
  Rx<TextEditingController> reasonController = TextEditingController().obs;
  RxList<OpponentModel> opponentList = <OpponentModel>[].obs;
  RxList<LocationData> locationList = <LocationData>[].obs;
  RxList<Roster> allRosterModelList = <Roster>[].obs;
  var selectedOpponent = Rxn<OpponentModel>();
  var selectedLocation = Rxn<LocationData>();
  var selectedTeam = Rxn<Roster>();
  RxBool isAway = false.obs;
  RxBool notify = false.obs;
  RxBool isCanceled = false.obs;
  RxBool isStanding = false.obs;
  RxBool isTimeTBD = false.obs;
  RxBool isGame = true.obs;
  RxBool isLive = true.obs;
  RxString activityType = ''.obs;

  // List<String> countryList = [
  //   "(GMT-5:00) Eastern Time (US & Canada)",
  //   "(GMT-5:00) Eastern Time (US & Canada)",
  //   "(GMT-5:00) Eastern Time (US & Canada)",
  //   "(GMT-5:00) Eastern Time (US & Canada)",
  //   "(GMT-5:00) Eastern Time (US & Canada)",
  //   "(GMT-5:00) Eastern Time (US & Canada)",
  // ];
  List<String> arriveEarly = [
    "30 minutes early",
    "45 minutes early",
    "1 hour early",
    "1 hour 30 minutes early",
    "2 hours early",
    "2 hours 30 minutes early",
  ];

  List<Flag> flagList = <Flag>[
    Flag(flagColor: AppColor.defaultColor, colorName: "Default"),
    Flag(flagColor: AppColor.lemonColor, colorName: "Lemon"),
    Flag(flagColor: AppColor.cherryColor, colorName: "Cherry"),
    Flag(flagColor: AppColor.limeColor, colorName: "Lime"),
    Flag(flagColor: AppColor.grapeColor, colorName: "Grape"),
    Flag(flagColor: AppColor.black12Color, colorName: "Blackberry"),
  ];

  Future<void> addActivityApi({String? activityType, bool? isGame}) async {
    try {
      FormData formData = FormData.fromMap({
        "user_id": AppPref().userId,
        "notify_team": notify.value == true ? 1 : 0,
        "activity_type": activityType,
        "activity_name": activityNameController.value.text.trim(),
        if (isGame == true) "team_id": selectedTeam.value?.teamId ?? 0,
        if (isGame == true) "opponent_id": selectedOpponent.value?.opponentId ?? 0,
        "is_time_tbd": isTimeTBD.value == true ? 1 : 0,
        "event_date": dateController.value.text.trim(),
        "start_time": startTimeController.value.text.trim(),
        "end_time": endTimeController.value.text.trim(),
        // "time_zone": timeZoneController.value.text.trim(),
        "time_zone": "",
        "location_id": selectedLocation.value?.locationId ?? 0,
        "location_details": locationDetailsController.value.text.trim(),
        "assignments": assignmentController.value.text.trim(),
        "duration": durationController.value.text.trim(),
        "arrive_early": arriveController.value.text.trim(),
        "extra_label": extraLabelController.value.text.trim(),
        "area_type": isAway.value == true ? 'Away' : 'Home',
        "uniform": uniformController.value.text.trim(),
        "flag_color": flagController.value.text.trim(),
        "notes": noteController.value.text.trim(),
        "standings": isStanding.value == true ? 1 : 0,
        // "is_live": isLive.value == true ? 1 : 0,
        "status": isCanceled.value == true ? "canceled" : "active",
        "reason": reasonController.value.text.toString(),
      });
      var response = await callApi(dio.post(
        ApiEndPoint.createActivity,
        data: formData,
      ));
      if (response?.statusCode == 200) {
        AppToast.showAppToast(response?.data['ResponseMsg']);

        ScheduleData scheduleData = ScheduleData.fromJson(response?.data['data']);
        Get.find<HomeController>().refreshKey.currentState?.show();
        Get.back(result: scheduleData);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> editActivityApi({String? activityType, bool? isGame, required int activityId}) async {
    try {
      FormData formData = FormData.fromMap({
        "user_id": AppPref().userId,
        "activity_id": activityId,
        "notify_team": notify.value == true ? 1 : 0,
        "activity_type": activityType,
        "activity_name": activityNameController.value.text.trim(),
        if (isGame == true) "team_id": selectedTeam.value?.teamId ?? 0,
        if (isGame == true) "opponent_id": selectedOpponent.value?.opponentId ?? 0,
        "is_time_tbd": isTimeTBD.value == true ? 1 : 0,
        "event_date": dateController.value.text.trim(),
        "start_time": startTimeController.value.text.trim(),
        "end_time": endTimeController.value.text.trim(),
        // "time_zone": timeZoneController.value.text.trim(),
        "time_zone": "",

        "location_id": selectedLocation.value?.locationId ?? 0,
        "location_details": locationDetailsController.value.text.trim(),
        "assignments": assignmentController.value.text.trim(),
        "duration": durationController.value.text.trim(),
        "arrive_early": arriveController.value.text.trim(),
        "extra_label": extraLabelController.value.text.trim(),
        "area_type": isAway.value == true ? 'Away' : 'Home',
        "uniform": uniformController.value.text.trim(),
        "flag_color": flagController.value.text.trim(),
        "notes": noteController.value.text.trim(),
        "standings": isStanding.value == true ? 1 : 0,
        // "is_live": isLive.value == true ? 1 : 0,
        "status": isCanceled.value == true ? "canceled" : "active",
        "reason": reasonController.value.text.toString(),
      });
      var response = await callApi(dio.post(
        ApiEndPoint.updateActivity,
        data: formData,
      ));
      if (response?.statusCode == 200) {
        ScheduleData scheduleData = ScheduleData.fromJson(response?.data['data']);

        Get.find<GlobalController>().updateScheduleData(scheduleData);
        AppToast.showAppToast(response?.data['ResponseMsg']);
        Get.find<HomeController>().refreshKey.currentState?.show();
        Get.back(result: scheduleData);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void showTimeZoneSheet(BuildContext context, {required List<String> list, required TextEditingController storeValue}) {
    showCustomBottomSheet<String>(
      context: context,
      title: "Select Timezone",
      list: list,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
      storeValue: storeValue,
      onItemSelected: (value) {},
      itemText: (value) => value,
    );
  }

  void showArriveEarlySheet(BuildContext context, {required List<String> list, required TextEditingController storeValue}) {
    showCustomBottomSheet<String>(
      context: context,
      title: "Arrive Early",
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.50),
      list: list,
      storeValue: storeValue,
      onItemSelected: (value) {},
      itemText: (value) => value,
    );
  }

  void allTeamList(BuildContext context, {required List<Roster> list, required TextEditingController storeValue}) {
    showCustomBottomSheet<Roster>(
      context: context,
      title: "Please select your\nTeam",
      list: list,
      storeValue: storeValue,
      onItemSelected: (team) => selectedTeam.value = team,
      itemText: (team) => team.name ?? "",
      icon: Icons.sports_soccer,
    );
  }

  void showOpponentSheet(BuildContext context, {required List<OpponentModel> list, required TextEditingController storeValue}) {
    showCustomBottomSheet<OpponentModel>(
      context: context,
      title: "Opponent",
      list: list,
      storeValue: storeValue,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.50),
      onItemSelected: (opponent) => selectedOpponent.value = opponent,
      itemText: (opponent) => opponent.opponentName ?? "",
      // icon: Icons.sports_soccer,
      onNewItem: () async {
        Get.back();
        final val = await Get.toNamed(AppRouter.newOpponent);
        if (val != null && val is OpponentModel) {
          selectedOpponent.value = val;
          storeValue.text = selectedOpponent.value?.opponentName ?? "";
          opponentList.add(val);
          opponentList.refresh();
        }
      },
    );
  }

  void showLocationSheet(BuildContext context, {required List<LocationData> list, required TextEditingController storeValue}) {
    showCustomBottomSheet<LocationData>(
      context: context,
      title: "Location",
      list: list,
      storeValue: storeValue,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.50),
      onItemSelected: (location) => selectedLocation.value = location,
      itemText: (location) => location.address ?? "",
      // icon: Icons.location_on_rounded,
      onNewItem: () async {
        Get.back();
        final val = await Get.toNamed(AppRouter.newLocation);
        if (val != null && val is LocationData) {
          selectedLocation.value = val;
          storeValue.text = selectedLocation.value?.address ?? "";
          locationList.add(val);
          locationList.refresh();
        }
      },
    );
  }

  void showFlagSheet(
    BuildContext context, {
    required TextEditingController storeValue,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Please select your flag color",
                    style: TextStyle().normal28w500s.textColor(
                          AppColor.black12Color,
                        ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 1),
                            blurRadius: 8.2,
                            spreadRadius: -4,
                            color: AppColor.black.withValues(alpha: 0.25),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.close,
                          color: AppColor.black12Color,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Gap(16),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: flagList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        storeValue.text = flagList[index].colorName ?? "Default";
                        Get.back();
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColor.greyEAColor,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                color: flagList[index].flagColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Gap(16),
                            Text(
                              flagList[index].colorName ?? "Default",
                              style: TextStyle().normal14w500.textColor(AppColor.black12Color),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ],
          ),
        );
      },
    );
  }

  void showDatePicker(
    BuildContext context,
    int index,
    TextEditingController storeValue, {
    DateTime? initial,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 280,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Select Date",
                      style: const TextStyle().normal14w500.textColor(AppColor.black12Color),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        if (storeValue.text.isEmpty) {
                          storeValue.text = "${DateTime.now().year.toString()}-${DateTime.now().month.toString()}-${DateTime.now().day.toString()}";
                        }
                        Get.back();
                      },
                      child: Text(
                        "Done",
                        style: const TextStyle().normal14w500.textColor(AppColor.black12Color),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 210,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: const TextStyle().normal14w500.textColor(AppColor.black12Color),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: initial ?? DateTime.now(),
                      minimumDate: DateTime.now().subtract(Duration(seconds: 2)),
                      maximumDate: DateTime.now().add(Duration(days: 366)),
                      onDateTimeChanged: (DateTime newDate) {
                        storeValue.text =
                            "${newDate.year.toString()}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}";
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showTimePicker(
    BuildContext context,
    int index,
    TextEditingController storeValue, {
    DateTime? initial,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 280,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Select Time",
                      style: const TextStyle().normal14w500.textColor(AppColor.black12Color),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        if (storeValue.text.isEmpty) {
                          DateTime newTime = DateTime.now();
                          storeValue.text = "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}:00";
                        }
                        Get.back();
                      },
                      child: Text(
                        "Done",
                        style: const TextStyle().normal14w500.textColor(AppColor.black12Color),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 210,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: const TextStyle().normal14w500.textColor(AppColor.black12Color),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: initial ?? DateTime.now(),
                      use24hFormat: true,
                      onDateTimeChanged: (DateTime newTime) {
                        storeValue.text = "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}:00";
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> getOpponentListApiCall() async {
    try {
      var data = {
        "user_id": AppPref().userId,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.getOpponentList,
          data: data,
        ),
        false,
      );
      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        var list = (jsonData['data'] as List).map((e) => OpponentModel.fromJson(e)).toList();
        opponentList.assignAll(list);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> getRosterApiCall() async {
    try {
      var data = {
        "user_id": AppPref().userId,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.getRosterList,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        var list = (jsonData['data'] as List).map((e) => Roster.fromJson(e)).toList();
        allRosterModelList.assignAll(list);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> getLocationListApiCall() async {
    try {
      var data = {
        "user_id": AppPref().userId,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.getLocationList,
          data: data,
        ),
        false,
      );
      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        var list = (jsonData['data'] as List).map((e) => LocationData.fromMap(e)).toList();
        locationList.assignAll(list);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  var activityDetail = Rxn<ScheduleData>();

  @override
  void onInit() {
    isGame.value = Get.arguments['activity'] == 'game';
    activityDetail.value = Get.arguments['activityDetail'];
    activityType.value = Get.arguments['activity'];
    if (activityDetail.value != null) {
      teamController.value.text = activityDetail.value?.team?.name ?? "";
      activityNameController.value.text = activityDetail.value?.activityName ?? "";
      dateController.value.text = activityDetail.value?.eventDate ?? "";
      startTimeController.value.text = activityDetail.value?.startTime ?? "";
      endTimeController.value.text = activityDetail.value?.endTime ?? "";
      // timeZoneController.value.text = activityDetail.value?.timeZone ?? "";
      opponentController.value.text = activityDetail.value?.opponent?.opponentName ?? "";
      locationController.value.text = activityDetail.value?.location?.address ?? "";
      locationDetailsController.value.text = activityDetail.value?.locationDetails ?? "";
      assignmentController.value.text = activityDetail.value?.assignments ?? "";
      durationController.value.text = activityDetail.value?.duration ?? "";
      arriveController.value.text = activityDetail.value?.arriveEarly ?? "";
      extraLabelController.value.text = activityDetail.value?.extraLabel ?? "";
      extraLabelController.value.text = activityDetail.value?.extraLabel ?? "";
      noteController.value.text = activityDetail.value?.notes ?? "";
      flagController.value.text = activityDetail.value?.flagColor ?? "";
      uniformController.value.text = activityDetail.value?.uniform ?? "";
      reasonController.value.text = activityDetail.value?.reason ?? "";
      isAway.value = (activityDetail.value?.areaType ?? "").toLowerCase() == "away";
      notify.value = activityDetail.value?.notifyTeam == 1;
      isTimeTBD.value = activityDetail.value?.isTimeTbd == 1;
      isStanding.value = activityDetail.value?.standings == 1;
      isCanceled.value = activityDetail.value?.status == "canceled";
      selectedTeam.value ??= Roster();
      selectedOpponent.value ??= OpponentModel();
      selectedLocation.value ??= LocationData();
      selectedTeam.value?.teamId = activityDetail.value?.teamId ?? 0;
      selectedOpponent.value?.opponentId = activityDetail.value?.opponentId ?? 0;
      selectedLocation.value?.locationId = activityDetail.value?.locationId ?? 0;
      selectedTeam.refresh();
      selectedLocation.refresh();
      selectedOpponent.refresh();
    }
    if (activityType.value == 'game') {
      getRosterApiCall();
      getOpponentListApiCall();
    }
    getLocationListApiCall();
    super.onInit();
  }
}
