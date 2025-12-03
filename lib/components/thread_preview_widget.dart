import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class ThreadPreviewWidget extends StatelessWidget {
  final int repliesCount;
  final String? latestReplyText;
  final String? latestReplySender;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? margin;

  const ThreadPreviewWidget({
    Key? key,
    required this.repliesCount,
    this.latestReplyText,
    this.latestReplySender,
    required this.onTap,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (repliesCount == 0) return SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.only(top: 8, left: 12, right: 12),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColor.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.forum_outlined,
              size: 16,
              color: AppColor.primaryColor,
            ),
            Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$repliesCount ${repliesCount == 1 ? 'reply' : 'replies'}',
                    style: TextStyle()
                        .normal12w600
                        .textColor(AppColor.primaryColor),
                  ),
                  if (latestReplyText != null &&
                      latestReplyText!.isNotEmpty) ...[
                    Gap(2),
                    Row(
                      children: [
                        if (latestReplySender != null &&
                            latestReplySender!.isNotEmpty) ...[
                          Text(
                            '$latestReplySender: ',
                            style: TextStyle().textColor(AppColor.grey4EColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        Expanded(
                          child: Text(
                            latestReplyText!,
                            style: TextStyle().textColor(AppColor.grey4EColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColor.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
