import 'package:base_code/package/screen_packages.dart';
import 'package:base_code/package/config_packages.dart';

class PushNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String deviceToken = '';

  Future initialize() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final String? fcmToken = await getAndSaveDeviceToken();
    if (fcmToken != null) {
      deviceToken = fcmToken;
      AppPref().fcmToken = fcmToken;
    }

    RemoteMessage? initialMessage = await _fcm.getInitialMessage();

    void handleMessage(RemoteMessage message) {
      if (message.data['type'] == 'home') {}
    }

    if (initialMessage != null) {
      handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await showNotification(message);
    });

    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    void onSelectNotification(NotificationResponse notificationResponse) async {
      var payloadData = jsonDecode(notificationResponse.payload!);

      if (payloadData["type"] == "home") {}
    }

    _flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onSelectNotification);
  }

  Future showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'fcm_default_channel',
      'High Importance Notifications',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    if (message.notification != null) {
      RemoteNotification? notification = message.notification;

      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channel.id,
        channel.name,
        importance: Importance.max,
        playSound: true,
        channelDescription: channel.description,
        priority: Priority.high,
        ongoing: true,
        styleInformation: const BigTextStyleInformation(''),
      );

      var iOSChannelSpecifics = const DarwinNotificationDetails();

      var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    }
  }

  static Future<String?> getAndSaveDeviceToken() async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    String? deviceToken;

    if (Platform.isIOS) {
      deviceToken = await firebaseMessaging.getAPNSToken();
      if (deviceToken == null) {
        if (kDebugMode) {
          print('=================> APNs token not available yet.');
        }
        return null;
      }
    } else {
      deviceToken = await firebaseMessaging.getToken();
      if (deviceToken == null) {
        if (kDebugMode) {
          print('=================> FCM token not available yet.');
        }
        return null;
      }
    }
    if (kDebugMode) {
      print('=================> Device Token: $deviceToken');
    }

    return deviceToken;
  }
}
