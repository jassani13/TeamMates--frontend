import 'package:base_code/in_app_purchase_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  debugPrint("BG Message: ${message.messageId}");
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(
    myBackgroundMessageHandler,
  );

  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await AppPref().isPreferenceReady;
  await dioSetUp();

  await PushNotificationService().initialize();

  Get.put(GlobalController());
  Get.put(InAppPurchaseController());

  final defaultLocale = Platform.localeName.split('_')[0];
  AppPref().languageCode = defaultLocale.toLowerCase() == 'ar' ? 'ar' : 'en';

  runApp(const SampleApp());
}
