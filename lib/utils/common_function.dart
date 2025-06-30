import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/package/config_packages.dart';


String cleanDescription(String raw) {
  return raw.replaceAll(r'\r\n', '\n');
}

String? extractMapUrl(String text) {
  final regex = RegExp(r'(https?:\/\/[^\s]+)');
  final match = regex.firstMatch(text);
  return match?.group(0);
}

String capitalizeFirst(String? text) {
  if (text == null || text.isEmpty) return "";
  return text[0].toUpperCase() + text.substring(1);
}

void openPdf(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print("Could not open the PDF file.");
  }
}

hideKeyboard() {
  Get.context?.let((it) {
    final currentFocus = FocusScope.of(it);
    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  });
}

bool isNullEmptyOrFalse(dynamic o) {
  if (o is Map<String, dynamic> || o is List<dynamic>) {
    return o == null || o.length == 0;
  }
  return o == null || false == o || "" == o;
}

class Throttler {
  Throttler({required this.throttleGapInMillis});

  final int throttleGapInMillis;
  int? lastActionTime;

  void run(VoidCallback action) {
    if (lastActionTime == null) {
      action();
      lastActionTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      if (DateTime.now().millisecondsSinceEpoch - lastActionTime! > (throttleGapInMillis)) {
        action();
        lastActionTime = DateTime.now().millisecondsSinceEpoch;
      }
    }
  }
}

Future<void> launchURL(String url) async {
  try {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      throw 'Could not launch $url';
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
}

void openGoogleMaps({double? lat, double? lng, String? googleMapLink, address}) async {
  String googleMapsUrl;

  if (lat != null && lng != null) {
    googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
  } else if (googleMapLink != null && googleMapLink.isNotEmpty) {
    googleMapsUrl = googleMapLink;
  } else if (address != null && address.isNotEmpty) {
    googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}";
  } else {
    if (kDebugMode) {
      print("No location data available");
    }
    return;
  }
  launchURL(googleMapsUrl);
}
