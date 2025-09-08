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

  // Additional contact information controllers - use RxList instead of regular List
  RxList<Rx<TextEditingController>> additionalEmailControllers = <Rx<TextEditingController>>[].obs;
  RxList<Rx<TextEditingController>> additionalRelationshipControllers = <Rx<TextEditingController>>[].obs;

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

  @override
  void onInit() {
    super.onInit();
    // Initialize with empty controllers for additional contacts
    addAdditionalContact();
  }

  @override
  void onClose() {
    // Dispose all controllers
    fNameController.value.dispose();
    lNameController.value.dispose();
    birthdayController.value.dispose();
    jNumberController.value.dispose();
    positionController.value.dispose();
    cfNameController.value.dispose();
    clNameController.value.dispose();
    emailController.value.dispose();
    numberController.value.dispose();
    addressController.value.dispose();
    allergyController.value.dispose();
    cityController.value.dispose();
    stateController.value.dispose();
    zipController.value.dispose();

    // Dispose additional contact controllers
    for (var controller in additionalEmailControllers) {
      controller.value.dispose();
    }
    for (var controller in additionalRelationshipControllers) {
      controller.value.dispose();
    }

    super.onClose();
  }

  void addAdditionalContact() {
    additionalEmailControllers.add(TextEditingController().obs);
    additionalRelationshipControllers.add(TextEditingController().obs);
  }

  Future<void> playerUpdateApi({
    required int id,
    required int index,
  }) async {
    try {
      // Prepare additional contact data
      List<String> additionalEmails = [];
      List<String> additionalRelationships = [];

      for (int i = 0; i < additionalEmailControllers.length; i++) {
        final email = additionalEmailControllers[i].value.text.trim();
        final relationship = additionalRelationshipControllers[i].value.text.trim();

        if (email.isNotEmpty) {
          additionalEmails.add(email);
          additionalRelationships.add(relationship.isNotEmpty ? relationship : "Other");
        }
      }

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
        "contact_first_name": cfNameController.value.text.toString(),
        "contact_last_name": clNameController.value.text.toString(),
        "email": emailController.value.text.toString(),
        // Add additional contact information
        "additional_emails": additionalEmails,
        "additional_relationships": additionalRelationships,
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

        // Update main player info
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

        // Update additional contact information
        final playerTeam = allPlayerController.rosterDetailModel.value.data?[0].playerTeams?[index];
        if (playerTeam != null) {
          // Keep the first two emails (primary and contact)
          final existingEmails = playerTeam.userEmails?.take(2).toList() ?? [];
          final existingRelationships = playerTeam.userRelationships?.take(2).toList() ?? [];

          // Add the new additional emails and relationships
          for (int i = 0; i < additionalEmailControllers.length; i++) {
            final email = additionalEmailControllers[i].value.text.trim();
            final relationship = additionalRelationshipControllers[i].value.text.trim();

            if (email.isNotEmpty) {
              existingEmails.add(email);
              existingRelationships.add(relationship.isNotEmpty ? relationship : "Other");
            }
          }

          playerTeam.userEmails = existingEmails;
          playerTeam.userRelationships = existingRelationships;
        }

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