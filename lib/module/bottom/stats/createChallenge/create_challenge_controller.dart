import 'package:base_code/model/challenge_model.dart';
import 'package:base_code/module/bottom/home/home_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class CreateChallengeController extends GetxController {
  TextEditingController cNameController = TextEditingController();
  TextEditingController cDescriptionController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  Rx<TextEditingController> startTimeController = TextEditingController().obs;
  Rx<TextEditingController> endTimeController = TextEditingController().obs;
  FocusNode nameFocus = FocusNode();
  FocusNode descFocus = FocusNode();
  FocusNode notesFocus = FocusNode();
  RxBool isNotify = false.obs;

  DateTime? parseDateTime(String dateTimeString) {
    try {
      if (dateTimeString.isEmpty) return null;
      dateTimeString = dateTimeString.replaceAll(RegExp(r'\s+'), ' ').trim();
      return DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateTimeString);
    } catch (e) {
      print("Error parsing date-time: $e");
      return null;
    }
  }

  void showTimePicker(
      BuildContext context, int index, TextEditingController storeValue) {
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
                      style: const TextStyle()
                          .normal14w500
                          .textColor(AppColor.black12Color),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        if (storeValue.text.isEmpty) {
                          DateTime newTime = DateTime.now();
                          storeValue.text =
                              "${newTime.year.toString()}-${newTime.month.toString().padLeft(2, '0')}-${newTime.day.toString().padLeft(2, '0')}  ${"${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}:00"}";
                        }
                        Get.back();
                      },
                      child: Text(
                        "Done",
                        style: const TextStyle()
                            .normal14w500
                            .textColor(AppColor.black12Color),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 210,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: const TextStyle()
                            .normal14w500
                            .textColor(AppColor.black12Color),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.dateAndTime,
                      initialDateTime: DateTime.now(),
                      use24hFormat: false,
                      minimumDate:
                          DateTime.now().subtract(Duration(seconds: 2)),
                      maximumDate: DateTime.now().add(Duration(days: 366)),
                      onDateTimeChanged: (DateTime newTime) {
                        storeValue.text =
                            "${newTime.year.toString()}-${newTime.month.toString().padLeft(2, '0')}-${newTime.day.toString().padLeft(2, '0')}  ${"${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}:00"}";
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

  // Rx<AllChallengeModel> activityDetails = AllChallengeModel().obs;

  Future<void> addChallengeApi() async {
    try {
      FormData formData = FormData.fromMap({
        "user_id": AppPref().userId,
        "name": cNameController.value.text.trim(),
        "description": cDescriptionController.value.text.trim(),
        "start_at": startTimeController.value.text.trim(),
        "end_at": endTimeController.value.text.trim(),
        "notes": notesController.value.text.trim(),
        "notify_team": isNotify.value == true ? 1 : 0,
      });
      var response = await callApi(dio.post(
        ApiEndPoint.createChallenge,
        data: formData,
      ));
      if (response?.statusCode == 200) {
        AppToast.showAppToast(response?.data['ResponseMsg']);
        Challenge challenge = Challenge.fromJson(response?.data['data']);
        Get.find<HomeController>().refreshKey.currentState?.show();
        Get.back(result: challenge);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
