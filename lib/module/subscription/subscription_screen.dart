import 'package:base_code/in_app_purchase_controller.dart';
import 'package:base_code/module/subscription/subscription_info_screen.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionScreen extends StatelessWidget {
  SubscriptionScreen({super.key});

  final subscriptionController = Get.put<SubscriptionController>(SubscriptionController());
  final purchaseController = Get.find<InAppPurchaseController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          CommonAppButton(
            text: 'Restore',
            width: 70,
            height: 30,
            style: TextStyle().normal14w600,
            onTap: () async {
              Get.find<InAppPurchaseController>().restore();
            },
          ),
          Gap(20),
        ],
        title: Text(
          "Choose Your Plan",
          style: TextStyle().normal20w500,
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: Obx(() {
        return subscriptionController.selectedPlan.value == 0
            ? SizedBox()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
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
                      horizontal: 24,
                      vertical: Platform.isAndroid ? 20 : 10,
                    ),
                    child: CommonAppButton(
                      text: "Subscribe",
                      onTap: () {
                        if (subscriptionController.selectedPlan.value == 1) {
                          ///monthly
                          Get.find<InAppPurchaseController>().purchase(
                            productId: Platform.isIOS ? "pro_plan_monthly" : 'pro_plan_monthly:pro-plan-monthly',
                            context: context,
                            isFromPurchase: true,
                          );
                        } else {
                          ///annual
                          Get.find<InAppPurchaseController>().purchase(
                            productId: Platform.isIOS ? "12345" : 'pro_plan_annual:pro-plan-annual',
                            context: context,
                            isFromPurchase: true,
                          );
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final Uri url = Uri.parse("https://www.apple.com/legal/internet-services/itunes/dev/stdeula/");

                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                          } else {
                            throw "Could not launch $url";
                          }
                        },
                        child: Text(
                          "Terms and Conditions",
                          style: TextStyle().normal16w700.textColor(AppColor.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          height: 20,
                          width: 2,
                          color: AppColor.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRouter.terms, arguments: [1]);
                        },
                        child: Text(
                          "Privacy policy",
                          style: TextStyle().normal16w700.textColor(AppColor.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              );
      }),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              height: 63,
              width: double.infinity,
              padding: EdgeInsets.all(
                16,
              ),
              decoration: BoxDecoration(
                color: AppColor.greyF6Color,
                borderRadius: BorderRadius.circular(
                  8,
                ),
              ),
              child: HorizontalSelectionList(
                items: subscriptionController.planList,
                selectedIndex: subscriptionController.selectedPlan,
                controller: subscriptionController.autoScrollController,
                onItemSelected: (index) {
                  subscriptionController.selectedPlan.value = index;
                  subscriptionController.controller.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.linear);
                },
              ),
            ),
            Gap(16),
            ExpandablePageView.builder(
                controller: subscriptionController.controller,
                itemCount: 3,
                onPageChanged: (val) {
                  subscriptionController.selectedPlan.value = val;
                },
                itemBuilder: (context, index) {
                  final isFree = index == 0;
                  final isMonthly = index == 1;
                  final featureList = isFree
                      ? subscriptionController.freeFeatureEList
                      : isMonthly
                          ? subscriptionController.proFeatureMonthlyList
                          : subscriptionController.proFeatureAnnualList;

                  final price = isFree
                      ? ""
                      : isMonthly
                          ? "\$9.99/month"
                          : "\$99.99/year";
                  final backgroundColor = isFree
                      ? AppColor.black12Color
                      : isMonthly
                          ? AppColor.premiumColor
                          : AppColor.purpleColor;
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColor.greyF6Color),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          subscriptionController.planList[index],
                                          style: TextStyle().normal16w500.textColor(AppColor.white),
                                        ),
                                        if (subscriptionController.selectedPlan.value == 2) ...[
                                          SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColor.successColor,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "Save 20%",
                                              style: TextStyle().normal12w600.textColor(AppColor.white),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (AppPref().proUser == true && purchaseController.purchasedPlan.value == subscriptionController.planList[index])
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColor.limeColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Subscribed",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Find the plan that fits your team’s needs.",
                                style: TextStyle().normal16w500.textColor(AppColor.white),
                              ),
                              if (index != 0)
                                Column(
                                  children: [
                                    SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          () => SubscriptionInfoScreen(
                                            isMonthly: isMonthly,
                                          ),
                                        );
                                      },
                                      behavior: HitTestBehavior.translucent,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info,
                                            color: AppColor.white,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "AUTO RENEW",
                                            style: TextStyle().normal16w600.textColor(AppColor.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Gap(16),
                              Visibility(
                                visible: price.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    price,
                                    style: TextStyle().normal20w500.textColor(
                                          AppColor.black12Color,
                                        ),
                                  ),
                                ),
                              ),
                              Gap(8),
                              Container(
                                decoration: BoxDecoration(color: AppColor.greyF6Color, borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.all(16),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: featureList.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        border: index == 0 ? null : Border(top: BorderSide(color: AppColor.greyF6Color)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 2),
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.white),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                AppImage.check,
                                                height: 14,
                                                colorFilter: ColorFilter.mode(AppColor.black12Color, BlendMode.srcIn),
                                              ),
                                            ),
                                          ),
                                          Gap(7),
                                          Expanded(
                                            child: Text(
                                              featureList[index],
                                              style: TextStyle().normal16w500.textColor(AppColor.black12Color),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Gap(16),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }),
            Gap(24),
          ],
        ),
      ),
    );
  }
}
