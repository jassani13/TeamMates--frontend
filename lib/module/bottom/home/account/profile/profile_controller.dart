import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:path/path.dart';

class ProfileController extends GetxController {
  Rx<UserModel> userModel = Rx<UserModel>(UserModel());
  Rx<File> profileImage = File("").obs;
  RxString selectedProfileImage = "".obs;

  RxInt isValid = (-1).obs;
  String countryCode = "";

  Rx<File> documentImage = File("").obs;
  RxString selectedDocumentImage = "".obs;
  final picker = ImagePicker();

  //common
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController eNumController = TextEditingController();

  //coach
  TextEditingController positionController = TextEditingController();
  TextEditingController jerseyNumberController = TextEditingController();

  RxBool isEdit = false.obs;
  List selectedMethod2List = [
    "Male",
    "Female",
  ];
  AutoScrollController controller2 = AutoScrollController();
  RxInt selectedSearchMethod2 = 0.obs;

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
                      initialDateTime: initial ?? DateTime.now(),
                      minimumDate: DateTime(1950),
                      maximumDate: DateTime.now(),
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

  Future getImage({required ImageSource source,bool isFromDocUpload = false}) async {
    final pickedFile = await picker.pickImage(source: source);

    if(isFromDocUpload){
      if (pickedFile != null) {
        selectedDocumentImage.value = '';
        documentImage.value = File(pickedFile.path);
      }
    }else{
      if (pickedFile != null) {
        selectedProfileImage.value = '';
        profileImage.value = File(pickedFile.path);
      }
    }

  }

  Future<void> updateProfile() async {
    try {
      var data = FormData.fromMap({
        //common
        'user_id': AppPref().userId,
        'role': AppPref().role?.toLowerCase(),
        'zipcode': zipCodeController.text.trim(),
        'state': stateController.text.trim(),
        'city': cityController.text.trim(),
        'address': addressController.text.trim(),
        'phone_number': phoneNumberController.text.trim(),
        'gender': selectedSearchMethod2.value == 0 ? "Male" : "Female",
        'dob': dobController.text.trim(),
        'first_name': fNameController.text.trim(),
        'last_name': lNameController.text.trim(),

        'jersey_number': jerseyNumberController.text.trim(),
        'position': positionController.text.trim(),
        if(AppPref().role=="coach")
        'emergency_contact': eNumController.text.trim(),

        if (profileImage.value.path.isNotEmpty)
          'profile': [
            await MultipartFile.fromFile(profileImage.value.path,
                filename: basename(profileImage.value.path))
          ],
        if (documentImage.value.path.isNotEmpty)
          'document': [
            await MultipartFile.fromFile(documentImage.value.path,
                filename: basename(documentImage.value.path))
          ],
      });
      var res = await callApi(
        dio.post(
          ApiEndPoint.updateProfile,
          data: data,
        ),
        true,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        userModel.value = UserModel.fromJson(jsonData['data']);
        AppPref().userModel = userModel.value;

        Get.back(result: userModel.value);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  RxBool isLoad = false.obs;

  Future<void> getProfileDetail() async {
    try {
      isLoad.value = true;
      var data = {
        "user_id": AppPref().userId,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.profileDetails,
          data: data,
        ),
        true,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        userModel.value = UserModel.fromJson(jsonData['data']);
        fillValue();
        isLoad.value = false;
      }
      isLoad.value = false;
    } catch (e) {
      if (kDebugMode) {
        print(e);
        isLoad.value = false;
      }
    }
  }

  fillValue() {
    fNameController.text = userModel.value.firstName ?? "";
    lNameController.text = userModel.value.lastName ?? "";
    emailController.text = userModel.value.email ?? "";
    dobController.text = userModel.value.dob ?? "";
    zipCodeController.text = userModel.value.zipcode ?? "";
    stateController.text = userModel.value.state ?? "";
    cityController.text = userModel.value.city ?? "";
    addressController.text = userModel.value.address ?? "";
    phoneNumberController.text =(userModel.value.phoneNumber??"");
    jerseyNumberController.text = userModel.value.jerseyNumber ?? "";
    positionController.text = userModel.value.position ?? "";
    genderController.text = userModel.value.gender ?? "";
    selectedProfileImage.value = userModel.value.profile ?? "";
    eNumController.text = userModel.value.eContact ?? "";
    selectedDocumentImage.value = userModel.value.doc ?? "";
    if ((userModel.value.gender ?? "") == "female") {
      selectedSearchMethod2.value = 1;
    } else {
      selectedSearchMethod2.value = 0;
    }
  }

  Future showOptions(context,{bool isFromDocUpload = false}) async {
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
              getImage(source: ImageSource.gallery,isFromDocUpload: isFromDocUpload);
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
              'Camera',
              style: TextStyle().normal14w500.textColor(AppColor.black12Color),
            ),
            onPressed: () {
              Get.back();
              getImage(source: ImageSource.camera,isFromDocUpload: isFromDocUpload);
            },
          ),
        ],
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((val) async {
      await getProfileDetail();
    });
  }
}
