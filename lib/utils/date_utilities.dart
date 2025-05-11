import 'package:base_code/package/config_packages.dart';
import 'package:timeago/timeago.dart' as timeago;

class DateUtilities {
  static const HH_mm_ss = 'HH:mm:ss';
  static const hh_mm_a = 'hh:mm a';
  static const am = 'AM';
  static const pm = 'PM';
  static const dd_MM_yyyy = 'dd MMMM yyyy';


  static String formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day}/${dt.month}/${dt.year}';
  }

  static String formatDuration(int minutes) {
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;

    if (hours > 0 && remainingMinutes > 0) {
      return "${hours}h ${remainingMinutes}m";
    } else if (hours > 0) {
      return "${hours}h";
    } else {
      return "${remainingMinutes}m";
    }
  }
  static DateTime? parseIcsDateTime(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return DateFormat("yyyyMMdd'T'HHmmss'Z'").parseUtc(dateStr).toLocal();
    } catch (e) {
      return null;
    }
  }
  static String getTimeAgo(String createdAt) {
    try {
      DateTime dateTime = DateTime.parse(createdAt).toUtc();
      return timeago.format(
        dateTime,
      );
    } catch (e) {
      return "";
    }
  }

  static String formatDate(String dateString, {String? dateFormat}) {
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat(dateFormat ?? dd_MM_yyyy).format(parsedDate);
    } catch (e) {
      return "";
    }
  }

  static String formatTime(String startTime, String? endTime) {
    try {
      DateTime startDateTime = DateFormat(HH_mm_ss).parse(startTime);
      String formattedStartTime = DateFormat(hh_mm_a).format(startDateTime);

      if (endTime == null || endTime.isEmpty) {
        return formattedStartTime;
      }

      DateTime endDateTime = DateFormat(HH_mm_ss).parse(endTime);
      String formattedEndTime = DateFormat(hh_mm_a).format(endDateTime);

      return "$formattedStartTime - $formattedEndTime";
    } catch (e) {
      return "";
    }
  }

  static String getTimeLeft(String futureDateTime) {
    DateTime now = DateTime.now().toUtc();
    DateTime futureTime =
        DateTime.parse(futureDateTime.replaceAll(" ", "T")).toUtc();

    if (futureTime.isBefore(now)) {
      return "-";
    }

    Duration difference = futureTime.difference(now);
    print(difference);
    int seconds = difference.inSeconds;
    int minutes = difference.inMinutes;
    int hours = difference.inHours;
    int days = difference.inDays;
    int weeks = (days / 7).floor();
    int months = (days / 30).floor();
    int years = (days / 365).floor();

    if (seconds < 60) {
      return "$seconds second${seconds > 1 ? 's' : ''} left";
    } else if (minutes < 60) {
      if (minutes == 0) return "1 minute left";
      return "$minutes minute${minutes > 1 ? 's' : ''} left";
    } else if (hours < 24) {
      if (hours == 0) return "1 hour left";
      return "$hours hour${hours > 1 ? 's' : ''} left";
    } else if (days < 7) {
      if (days == 0) return "1 day left";
      return "$days day${days > 1 ? 's' : ''} left";
    } else if (weeks < 4) {
      if (weeks == 0) return "1 week left";
      return "$weeks week${weeks > 1 ? 's' : ''} left";
    } else if (days < 365) {
      if (months == 0) return "1 month left";
      return "$months month${months > 1 ? 's' : ''} left";
    } else {
      if (years == 0) return "1 yesr left";
      return "$years year${years > 1 ? 's' : ''} left";
    }
  }
}
