import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class OnBoardingScreen extends StatelessWidget {
  OnBoardingScreen({super.key});

  final onBoardingController =
      Get.put<OnBoardingController>(OnBoardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        padding: EdgeInsets.symmetric(
            vertical: Platform.isAndroid ? 20 : 24, horizontal: 20),
        child: Obx(
          () => CommonAppButton(
            text: (onBoardingController.selectedIndex.value <
                    onBoardingController.obList.length - 1)
                ? "Next"
                : "Continue",
            onTap: () {
              if (onBoardingController.selectedIndex.value <
                  onBoardingController.obList.length - 1) {
                onBoardingController.controller.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                AppPref().isFirstTime = true;
                Get.toNamed(AppRouter.login);
              }
            },
          ),
        ),
      ),
      body: Obx(
        () => PageView.builder(
            controller: onBoardingController.controller,
            itemCount: onBoardingController.obList.length,
            onPageChanged: (val) {
              onBoardingController.selectedIndex.value = val;
            },
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height / 1.8,
                      width: double.infinity,
                      child: Image.asset(
                        onBoardingController.obList[index].image,
                        fit: BoxFit.fill,
                      )),
                  Spacer(),
                  _buildInfo(index),
                ],
              );
            }),
      ),
    );
  }

  Padding _buildInfo(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            onBoardingController.obList[index].title,
            style: TextStyle(height: 1).normal32w600s.textColor(
                  AppColor.black12Color,
                ),
          ),
          Gap(8),
          Text(
            onBoardingController.obList[index].description,
            style: TextStyle().normal20w500.textColor(
                  AppColor.grey4EColor,
                ),
          ),
          Text(
            onBoardingController.obList[index].description2,
            style: TextStyle().normal16w400.textColor(
                  AppColor.grey4EColor,
                ),
          ),
        ],
      ),
    );
  }
}
