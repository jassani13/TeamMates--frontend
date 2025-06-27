import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class BottomController extends GetxController {
  RxInt selectedIndex = 0.obs;

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  Future<void> askPermission() async {
    var status = await (Permission.location.status);
    if (!status.isGranted) {
      var status = await Permission.location.request();
      if (!status.isGranted) {
        // await showLocationAllowDialogue();
      }
    }

  }

  Future<void> showLocationAllowDialogue() async {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        return Theme(
          data: ThemeData(
          ),
          child: Dialog(
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 32, left: 16, right: 8, top: 41),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Column(
                        children: [
                          Text(
                            "StethUp needs access to location for finding jobs near you.Please allow location permission",
                            style: const TextStyle()
                                .normal14w600
                                .textColor(AppColor.black12Color),
                            textAlign: TextAlign.center,
                          ),
                          const Gap(32),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                            child: CommonAppButton(
                                buttonType: ButtonType.enable,
                                textColor: AppColor.white,
                                color: AppColor.primaryColor,
                                onTap: () async {
                                  await openAppSettings();
                                },
                                text: "Allow".toUpperCase()),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )),
        );
      },
    );
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      // Get the InAppPurchaseController instance
      final purchaseController = Get.find<InAppPurchaseController>();
      
      // Always refresh subscription status when entering the bottom screen
      await purchaseController.refreshSubscriptionStatus();
      
      if (kDebugMode) {
        print("Subscription status check completed - proUser: ${AppPref().proUser}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error checking subscription status: $e");
      }
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       await askPermission();
       await checkSubscriptionStatus();
    });
  }
}
