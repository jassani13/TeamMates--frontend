import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/package/config_packages.dart';


class TabContainer extends StatelessWidget {
  final List<String> tab;
  final int selectedIndex;
  final Color? bgColor;
  final Function(int) onTabSelected;

  const TabContainer({
    super.key,
    required this.tab,
    required this.selectedIndex,
    this.bgColor,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: bgColor??AppColor.lightPrimaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            tab.length,
            (index) => Flexible(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  onTabSelected(index);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    decoration: BoxDecoration(
                      color: (selectedIndex == index)
                          ? AppColor.primaryColor
                          : AppColor.primaryColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        tab[index],
                        style: (selectedIndex == index)
                            ? const TextStyle()
                                .normal16w600
                                .textColor(AppColor.black12Color)
                            : TextStyle()
                                .normal16w400
                                .textColor(AppColor.black12Color),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
