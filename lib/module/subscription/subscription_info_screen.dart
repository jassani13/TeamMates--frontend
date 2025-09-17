import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class SubscriptionInfoScreen extends StatelessWidget {
  final bool isMonthly;

  const SubscriptionInfoScreen({super.key, required this.isMonthly});

  @override
  Widget build(BuildContext context) {
    final title = isMonthly ? "Monthly plan" : "Annual plan";
    final duration = isMonthly ? "1 Month" : "1 Year";

    return Scaffold(
      appBar: AppBar(
        title: CommonTitleText(text: title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle().normal20w500.textColor(AppColor.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Duration: $duration",
                      style: TextStyle().normal20w500.textColor(AppColor.black),
                    ),
                    SizedBox(height: 16),
                    bulletPoint("Payment will be charged to iTunes Account at confirmation of purchase."),
                    bulletPoint(
                        "Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period."),
                    bulletPoint(
                        "Account will be charged for renewal within 24-hours prior to the end of the current period, and identify the cost of the renewal."),
                    bulletPoint(
                        "Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user's Account Settings after purchase."),
                    bulletPoint(
                        "Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable."),
                  ],
                ),
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
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle().normal18w400.textColor(AppColor.black),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle().normal16w400.textColor(AppColor.grey4EColor),
            ),
          ),
        ],
      ),
    );
  }
}
