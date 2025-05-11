import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

void showCommonBottomSheet({
  required BuildContext context,
  required List<String> options,
  required String title,
  required List<Function()> onTapActions,
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
                  title,
                  style: TextStyle().normal28w500s.textColor(
                    AppColor.black12Color,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => Get.back(),
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
            ListView.separated(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: onTapActions[index],
                  behavior: HitTestBehavior.translucent,
                  child: Row(
                    children: [
                      Text(
                        options[index],
                        style: TextStyle().normal16w500.textColor(AppColor.black12Color),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  color: AppColor.greyEAColor,
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
