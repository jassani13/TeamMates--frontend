import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

void showCustomBottomSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> list,
  required TextEditingController storeValue,
  required Function(T) onItemSelected,
  required String Function(T) itemText,
  IconData? icon,
  VoidCallback? onNewItem,
  BoxConstraints? constraints,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return ConstrainedBox(
        constraints: constraints ?? BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle().normal28w500s.textColor(AppColor.black12Color),
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
                            color: AppColor.black.withOpacity(0.25),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(Icons.close, color: AppColor.black12Color),
                      ),
                    ),
                  )
                ],
              ),
              Gap(16),
              Expanded(
                child: SingleChildScrollView(
                  child: ListView.builder(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          onItemSelected(list[index]);
                          storeValue.text = itemText(list[index]);
                          Get.back();
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border:index==0?null: Border(top: BorderSide(color: AppColor.greyEAColor)),
                          ),
                          child: Row(
                            children: [
                              if (icon != null) ...[
                                Icon(icon, color: AppColor.black12Color),
                                Gap(16),
                              ],
                              Text(
                                itemText(list[index]),
                                style: TextStyle().normal16w500.textColor(AppColor.black12Color),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (onNewItem != null) ...[
                Gap(16),
                GestureDetector(
                  onTap: onNewItem,
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      Gap(16),
                      Text(
                        'New $title',
                        style: TextStyle().normal16w500.textColor(AppColor.black12Color),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
