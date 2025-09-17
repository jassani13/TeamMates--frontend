
import 'package:base_code/package/config_packages.dart';

import '../app_route.dart';

@pragma('vm:entry-point')
void handleMessage(RemoteMessage message) {
  debugPrint("Handling push message: ${message.data}");
  PushNotificationService._showLocalNotification(message);
}

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static String? _deviceToken;

  Future<void> initialize() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint("Notification_Permission: ${settings.authorizationStatus}");

      _deviceToken = await getAndSaveDeviceToken();
      debugPrint("_deviceToken: $_deviceToken");

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();

      final initSettings =
          InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null) {
            final data = json.decode(response.payload!);
            _handleNotificationTap(data);
          }
        },
      );

      // Terminated state (app closed, opened from push)
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationData(initialMessage.data);
      }

      // Background (opened from push)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationData(message.data);
      });

      // Foreground (show local notification)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("Foreground push: ${message.notification?.title}");
        handleMessage(message);
      });
    } catch (e) {
      debugPrint("Notification initialize: $e");
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    Map<String, dynamic> data = message.data;

    if (notification != null) {
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'Used for important messages',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails();

      const notificationDetails =
          NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _localNotifications.show(
        notification.hashCode,
        notification.title ?? data['title'] ?? 'New Message',
        notification.body ?? data['body'] ?? '',
        notificationDetails,
        payload: json.encode(data),
      );
    }
  }

  static void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint("Tapped notification: $data");
    _handleNotificationData(data);
  }

  static void _handleNotificationData(Map<String, dynamic> data) {
    if (data.containsKey('conversation_type')) {
      switch (data['conversation_type']) {
        case 'personal':
          _navigateToChat(data);
          break;
        case 'group':
          _navigateToTeamChat(data);
          break;
        default:
          debugPrint("Unknown conversation type: ${data['conversation_type']}");
      }
    }
  }

  static void _navigateToChat(Map<String, dynamic> data) {
    if (Get.currentRoute != AppRouter.personalChat) {
      Get.toNamed(AppRouter.personalChat, arguments: {
        'chatData': ChatListData(
          firstName: data["first_name"] ?? '',
          lastName: data["last_name"] ?? '',
          otherId: data['sender_id'] ?? '',
        ),
      });
    }
  }

  static void _navigateToTeamChat(Map<String, dynamic> data) {
    if (Get.currentRoute != AppRouter.grpChat) {
      Get.toNamed(AppRouter.grpChat, arguments: {
        'chatData': ChatListData(
          teamName: data['team_name'],
          teamId: data['team_id'],
        ),
      });
    }
  }

  static Future<String?> getAndSaveDeviceToken() async {
    String? token;

    if (Platform.isIOS) {
      String? apnsToken = await _fcm.getAPNSToken();
      if (apnsToken != null) {
        token = await _fcm.getToken();
        debugPrint("getToken:$token");
      } else {
        Future.delayed(const Duration(seconds: 3), () async {
          String? apnsToken = await _fcm.getAPNSToken();
          debugPrint("inside_delayed_apnsToken:$apnsToken");
          if (apnsToken != null) {
            token = await _fcm.getToken();
          } else {
            try {
              token = await _fcm.getToken();
            } catch (e) {
              debugPrint("APNs token error: $e");
            }
          }
        });
      }

      print("Token_178:$token");
    } else {
      token = await _fcm.getToken();
      debugPrint("getToken->android:$token");
    }

    if (token != null) {
      AppPref().fcmToken = token;
    }

    return token;
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    debugPrint("Subscribed to $topic");
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    debugPrint("Unsubscribed from $topic");
  }

// showTestNotification() {
//   const androidDetails = AndroidNotificationDetails(
//     'high_importance_channel',
//     'High Importance Notifications',
//     channelDescription: 'Used for important messages',
//     importance: Importance.max,
//     priority: Priority.high,
//     playSound: true,
//     enableVibration: true,
//   );
//
//   const iosDetails = DarwinNotificationDetails();
//
//   const notificationDetails =
//       NotificationDetails(android: androidDetails, iOS: iosDetails);
//   _localNotifications.show(
//     999, // Arbitrary ID for the test
//     'Test Notification',
//     'This is a local test notification body',
//     notificationDetails,
//     payload: json.encode({'screen': 'test'}),
//   );
// }
}
