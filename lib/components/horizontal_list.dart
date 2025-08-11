import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/package/config_packages.dart';

class HorizontalSelectionList extends StatelessWidget {
  final List items;
  final RxInt selectedIndex;
  final AutoScrollController controller;
  final Function(int) onItemSelected;
  final bool? shrinkWrap;
  final double? margin;

  const HorizontalSelectionList({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.controller,
    required this.onItemSelected,
    this.shrinkWrap = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemCount: items.length,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return AutoScrollTag(
          controller: controller,
          index: index,
          key: ValueKey(index),
          child: GestureDetector(
            onTap: () {
              selectedIndex.value = index;
              controller.scrollToIndex(index,
                  preferPosition: AutoScrollPosition.middle);
              onItemSelected(index);
            },
            behavior: HitTestBehavior.translucent,
            child: Obx(
              () => Container(
                margin: EdgeInsets.only(left: index == 0 ? 0 : (margin ?? 16)),
                padding: EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: index == selectedIndex.value
                      ? AppColor.black12Color
                      : AppColor.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: index == selectedIndex.value
                        ? AppColor.black12Color
                        : AppColor.greyEAColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    items[index],
                    style: TextStyle()
                        .textColor(
                          selectedIndex.value == index
                              ? AppColor.white
                              : AppColor.black12Color,
                        )
                        .normal14w500,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
