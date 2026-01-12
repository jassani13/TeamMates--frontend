import 'package:base_code/model/schedule_model.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

void showExternalEventDetailsDialog(BuildContext context, ScheduleData data) {
  showDialog(
    context: context,
    builder: (context) {
      final String dateLabel = _formatExternalDate(data);
      final String timeLabel = _formatExternalTime(data);
      return AlertDialog(
        title: Text(
          capitalizeFirst(data.activityName ?? 'External Event'),
          style: TextStyle().normal18w600.textColor(AppColor.black12Color),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dateLabel.isNotEmpty)
              Text(
                dateLabel,
                style:
                    TextStyle().normal16w500.textColor(AppColor.black12Color),
              ),
            if (timeLabel.isNotEmpty) ...[
              Gap(6),
              Text(
                timeLabel,
                style: TextStyle()
                    .normal15w500
                    .textColor(AppColor.black12Color.withOpacity(0.7)),
              ),
            ],
            if ((data.location?.address ?? data.locationDetails ?? '')
                .isNotEmpty) ...[
              Gap(12),
              Text(
                data.location?.address ?? data.locationDetails ?? '',
                style:
                    TextStyle().normal15w500.textColor(AppColor.black12Color),
              ),
            ],
            if ((data.notes ?? data.externalDescription ?? '').isNotEmpty) ...[
              Gap(12),
              Text(
                data.notes ?? data.externalDescription ?? '',
                style:
                    TextStyle().normal14w400.textColor(AppColor.black12Color),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          if ((data.externalCalendarLink ?? '').isNotEmpty)
            TextButton(
              onPressed: () {
                launchURL(data.externalCalendarLink!);
              },
              child: Text('Open Link'),
            ),
        ],
      );
    },
  );
}

String _formatExternalDate(ScheduleData data) {
  final dateString = data.eventDate ?? data.startDate;
  if (dateString == null || dateString.isEmpty) return '';
  try {
    final parsed = DateTime.parse(dateString);
    return DateFormat('EEEE, MMM d, y').format(parsed);
  } catch (e) {
    return dateString;
  }
}

String _formatExternalTime(ScheduleData data) {
  if ((data.startTime ?? '').isEmpty) {
    return '';
  }
  return DateUtilities.formatTime(
      data.startTime ?? '', data.endTime ?? data.startTime ?? '');
}
