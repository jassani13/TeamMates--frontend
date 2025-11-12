import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

import 'privacy_settings_controller.dart';

class PrivacySettingsScreen extends StatelessWidget {
  PrivacySettingsScreen({super.key});

  final controller =
      Get.put<PrivacySettingsController>(PrivacySettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy', style: TextStyle().normal20w500),
        centerTitle: false,
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (controller.loading.value) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColor.greyF6Color,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.visibility, color: AppColor.black12Color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Read receipts',
                          style: TextStyle()
                              .normal16w500
                              .textColor(AppColor.black12Color),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Allow others to see when you\'ve read their messages. When off, you won\'t see others\' read receipts either.',
                          style: TextStyle()
                              .normal12w400
                              .textColor(AppColor.grey4EColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CupertinoSwitch(
                    activeTrackColor: AppColor.greenColor,
                    thumbColor: AppColor.black12Color,
                    value: controller.readReceiptsEnabled.value,
                    onChanged: controller.saving.value
                        ? null
                        : (v) => controller.setReadReceipts(v),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
