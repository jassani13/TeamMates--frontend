import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Support",
          style: TextStyle().normal20w500,
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  8,
                ),
                border: Border.all(color: AppColor.greyEAColor),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppColor.black12Color,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        )),
                    child: Text(
                      "Support",
                      style: TextStyle().normal16w500.textColor(
                            AppColor.white,
                          ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppColor.greyF6Color,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final Uri callUri =
                                    Uri.parse("tel:${"+1 905-914-8143"}");
                                if (await canLaunchUrl(callUri)) {
                                  await launchUrl(callUri);
                                } else {
                                  print("Could not launch the call.");
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Mobile number",
                                    style: TextStyle().normal14w500.textColor(
                                          AppColor.grey4EColor,
                                        ),
                                  ),
                                  Text(
                                    "+1 905-914-8143",
                                    style: TextStyle().normal16w500.textColor(
                                          AppColor.black12Color,
                                        ),
                                  ),
                                  Gap(16),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final Uri emailLaunchUri =
                                    Uri.parse("mailto:Info@teammatesapp.org");

                                if (await launchUrl(emailLaunchUri)) {
                                  debugPrint("Email app opened successfully");
                                } else {
                                  debugPrint("Could not launch email app");
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Gmail",
                                    style: TextStyle().normal14w500.textColor(
                                          AppColor.grey4EColor,
                                        ),
                                  ),
                                  Text(
                                    "Info@teammatesapp.org",
                                    style: TextStyle().normal16w500.textColor(
                                          AppColor.black12Color,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
