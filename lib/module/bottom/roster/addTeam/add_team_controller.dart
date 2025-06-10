import 'package:base_code/module/bottom/roster/roster_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:path/path.dart';

class AddTeamController extends GetxController {
  TextEditingController teamNameController = TextEditingController();
  // TextEditingController zipCodeController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController gameController = TextEditingController();
  final FocusNode teamNameFocus = FocusNode();
  final FocusNode teamCodeFocus = FocusNode();
  final picker = ImagePicker();
  Rx<File> image = File("").obs;
  RxString selectedImage = "".obs;
  RxInt selectedImageNum = (-1).obs;
  List teamIcon = [
    AppImage.ti1,
    AppImage.ti2,
    AppImage.ti3,
    AppImage.ti4,
    AppImage.ti5,
    AppImage.ti6,
    AppImage.ti7,
    AppImage.ti8,
  ];

  void selectTeamIcon(String iconPath, int index) {
    selectedImage.value = iconPath;
    selectedImageNum.value = index + 1;
  }

  Future<void> createTeamApi() async {
    try {
      var data = FormData.fromMap({
        if (selectedImageNum.value == 0)
          'image': [
            await MultipartFile.fromFile(image.value.path,
                filename: basename(image.value.path))
          ],
        // 'user_id': '1',
        "user_id": AppPref().userId,
        if (selectedImageNum.value != 0) "icon": selectedImageNum.value,
        "name": teamNameController.text.toString(),
        // "zipcode": zipCodeController.text.toString(),
        "country": countryController.text.toString(),
        "sports": gameController.text.toString(),
      });
      var res = await callApi(
        dio.post(
          ApiEndPoint.createTeam,
          data: data,
        ),
        true,
      );

      if (res?.statusCode == 200) {
        Get.back();
        Get.find<RoasterController>().getRosterApiCall();
        Get.toNamed(AppRouter.addPlayer,
            arguments: [res?.data["data"]["team_id"], false]);
        AppToast.showAppToast("Team created successfully",
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
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      image.value = File(pickedFile.path);
      selectedImage.value = pickedFile.path;
      selectedImageNum.value = 0;
    }
  }

  List countryList = [
    "Canada",
    "United states",
    "Iceland",
    "Guyana",
    "Haiti",
    "Honduras",
    "Malta",
    "Mauritania",
    "Mexico",
    "Morocco",
  ];

  List gameList = [
    "Football",
    "Basketball",
    "Rugby",
    "Hockey",
    "Tennis",
    "Volleyball",
    "Baseball",
    "Handball",
    "Golf",
  ];

  List gameIconList = [
    AppImage.football,
    AppImage.basketball,
    AppImage.rugby,
    AppImage.hockey,
    AppImage.tennis,
    AppImage.volleyball,
    AppImage.baseball,
    AppImage.handball,
    AppImage.golf,
  ];
  List countryIconList = [
    AppImage.canada,
    AppImage.us,
    AppImage.iceland,
    AppImage.guyana,
    AppImage.haiti,
    AppImage.honduras,
    AppImage.malta,
    AppImage.mauritania,
    AppImage.mexico,
    AppImage.morocco,
  ];

  void showCountrySheet(
    BuildContext context, {
    required List list,
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
                    storeValue == gameController
                        ? "Select your sport"
                        : "Select your country",
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
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        storeValue.text = list[index];
                        Get.back();
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: index == 0
                              ? null
                              : Border(
                                  top: BorderSide(
                                    color: AppColor.greyEAColor,
                                  ),
                                ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              list[index],
                              style: TextStyle()
                                  .normal16w500
                                  .textColor(AppColor.black12Color),
                            ),
                            Spacer(),
                            SvgPicture.asset(
                              (storeValue == gameController)
                                  ? gameIconList[index]
                                  : countryIconList[index],
                              height: 24,
                              width: 24,
                            )
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
}

class IconData {
  String icon;
  int id;

  IconData({
    required this.icon,
    required this.id,
  });
}
