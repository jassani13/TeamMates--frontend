import 'package:base_code/in_app_purchase_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';


Future myBackgroundMessageHandler(RemoteMessage message) async {
  debugPrint("myBackgroundMessageHandler: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();
  const fatalError = true;
  // Non-async exceptions
  FlutterError.onError = (errorDetails) {
    if (fatalError) {
      // If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      // ignore: dead_code
    } else {
      // If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    }
  };
  // Async exceptions
  PlatformDispatcher.instance.onError = (error, stack) {
    if (fatalError) {
      // If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      // ignore: dead_code
    } else {
      // If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordError(error, stack);
    }
    return true;
  };
  await AppPref().isPreferenceReady;
  await dioSetUp();

  await PushNotificationService().initialize();
  Get.put<GlobalController>(GlobalController());
  Get.put<InAppPurchaseController>(InAppPurchaseController());

  final String defaultLocale = Platform.localeName.split('_')[0];
  AppPref().languageCode = (defaultLocale.toLowerCase() == 'ar') ? defaultLocale : 'en';
  if (AppPref().languageCode.isEmpty) {
    AppPref().languageCode = 'en';
  }

  runApp(const SampleApp());
}
