import 'package:base_code/in_app_purchase_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

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
