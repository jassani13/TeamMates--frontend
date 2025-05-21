import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class TeamCodeScreen extends StatelessWidget {
  TeamCodeScreen({super.key});

  final teamCodeController = Get.put<TeamCodeController>(TeamCodeController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Ensures taps are detected on empty areas

      onTap: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide'); // Calls native method to hide keyboard
      },
      child: Scaffold(
        bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColor.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, -2),
                  color: AppColor.lightPrimaryColor,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: CommonAppButton(
              text: "Submit",
              buttonType: ButtonType.enable,
              onTap: () {
                teamCodeController.checkPlayerCode();
              },
            )),
        appBar: AppBar(
          actions: [
            GestureDetector(
              onTap: () {
                Get.offNamed(AppRouter.selectRole);
              },
              child: Text(
                "Switch Role",
                style: TextStyle().normal16w500.textColor(
                      AppColor.black12Color,
                    ),
              ),
            ),
            Gap(20),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Join team",
                  style: TextStyle().normal32w500s.textColor(
                        AppColor.black12Color,
                      ),
                ),
                Text(
                  "Enter the team code to join and get started!",
                  style: TextStyle().normal16w500.textColor(
                        AppColor.grey4EColor,
                      ),
                ),
                Gap(32),
                Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 4,
                    child: SvgPicture.asset(
                      AppImage.teamCodeBg,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Gap(24),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColor.greyF6Color,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Obx(
                        () => CommonTextField(
                          controller: teamCodeController.codeController.value,
                          bgColor: Colors.black,
                          cColor: AppColor.white,
                          maxLength: 5,
                          textAlign: TextAlign.center,
                          style: const TextStyle().normal20w500.textColor(AppColor.white),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(32),
                Center(
                  child: TextButton(
                    onPressed: () {
                      hideKeyboard();
                      teamCodeController.showTeamCodeSheet(context);
                    },
                    child: Text(
                      "I don't have Code ",
                      style: TextStyle().normal20w500.textColor(AppColor.black12Color),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
