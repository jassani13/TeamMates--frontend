import 'package:base_code/module/bottom/roster/allPlayer/all_player_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:path/path.dart';

class EditPlayerController extends GetxController {
  Rx<TextEditingController> fNameController = TextEditingController().obs;
  Rx<TextEditingController> lNameController = TextEditingController().obs;
  Rx<TextEditingController> birthdayController = TextEditingController().obs;
  Rx<TextEditingController> jNumberController = TextEditingController().obs;
  Rx<TextEditingController> positionController = TextEditingController().obs;
  Rx<TextEditingController> cfNameController = TextEditingController().obs;
  Rx<TextEditingController> clNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> numberController = TextEditingController().obs;
  Rx<TextEditingController> addressController = TextEditingController().obs;
  Rx<TextEditingController> allergyController = TextEditingController().obs;
  Rx<TextEditingController> cityController = TextEditingController().obs;
  Rx<TextEditingController> stateController = TextEditingController().obs;
  Rx<TextEditingController> zipController = TextEditingController().obs;
  List selectedMethod2List = [
    "Male",
    "Female",
  ];
  AutoScrollController controller2 = AutoScrollController();
  RxInt selectedSearchMethod2 = 0.obs;

  RxBool isAccess = false.obs;
  RxBool isNonPlayer = true.obs;
  final picker = ImagePicker();
  Rx<File> image = File("").obs;
  final allPlayerController = Get.find<AllPlayerController>();

  Future<void> playerUpdateApi({
    required int id,
    required int index,
  }) async {
    try {
      var data = FormData.fromMap({
        if (image.value.path.isNotEmpty)
          'profile':
          [
            await MultipartFile.fromFile(image.value.path,
                filename: basename(image.value.path))
          ],
        "user_id": id,
        "role": "",
        "first_name": fNameController.value.text.toString(),
        "last_name": lNameController.value.text.toString(),
        "dob": birthdayController.value.text.toString(),
        "gender": selectedSearchMethod2.value == 0 ? "Male" : "Female",
        "jersey_number": jNumberController.value.text.toString(),
        "position": positionController.value.text.toString(),
        "phone_number": numberController.value.text.toString(),
        "address": addressController.value.text.toString(),
        "city": cityController.value.text.toString(),
        "state": stateController.value.text.toString(),
        "zipcode": zipController.value.text.toString(),
        "allergy": allergyController.value.text.toString(),
      });
      var res = await callApi(
        dio.post(
          ApiEndPoint.updateProfile,
          data: data,
        ),
        true,
      );

      if (res?.statusCode == 200) {
        Get.back();
        allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index]
            .allergy = allergyController.value.text.toString();
        allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index]
            .firstName = fNameController.value.text.toString();
        allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index]
            .lastName = lNameController.value.text.toString();
        allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index]
            .dob = birthdayController.value.text.toString();
        allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index]
            .address = addressController.value.text.toString();
        allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index]
            .jerseyNumber = jNumberController.value.text.toString();
        allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index]
            .profile = res?.data["data"]["profile"];
        allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index]
            .position = positionController.value.text.toString();
        allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index]
            .email = emailController.value.text.toString();
        allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index]
            .phoneNumber = numberController.value.text.toString();
        allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].city = cityController.value.text.toString();
        allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].zipcode = zipController.value.text.toString();
        allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index].gender = selectedSearchMethod2.value == 0 ? "Male" : "Female";
        allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index]
            .state = stateController.value.text.toString();
        allPlayerController.rosterDetailModel.refresh();

        AppToast.showAppToast("Update player info successfully",
            bgColor: AppColor.greenColor);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future showOptions(context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text(
              'Photo Gallery',
              style: TextStyle().normal14w500.textColor(AppColor.black12Color),
            ),
            onPressed: () {
              Get.back();
              getImage(source: ImageSource.gallery);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              'Camera',
              style: TextStyle().normal14w500.textColor(AppColor.black12Color),
            ),
            onPressed: () {
              Get.back();
              getImage(source: ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }

  Future getImage({required ImageSource source}) async {
    final pickedFile = await picker.pickImage(source: source,imageQuality: 70);

    if (pickedFile != null) {
      image.value = File(pickedFile.path);
    }
  }

  void showYearPicker(
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
                      "Select Date",
                      style: const TextStyle()
                          .normal14w500
                          .textColor(AppColor.black12Color),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        if (storeValue.text.isEmpty) {
                          storeValue.text =
                              "${DateTime.now().year.toString()}-${DateTime.now().month.toString()}-${DateTime.now().day.toString()}";
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
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: DateTime.now(),
                      minimumDate: DateTime(1900),
                      maximumDate: DateTime.now(),
                      onDateTimeChanged: (DateTime newDate) {
                        storeValue.text =
                            "${newDate.year.toString()}-${newDate.month.toString()}-${newDate.day.toString()}";
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
}
