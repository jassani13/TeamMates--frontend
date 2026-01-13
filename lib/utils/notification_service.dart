import 'dart:convert';
import 'dart:io';
import 'package:base_code/package/config_packages.dart';

import '../app_route.dart';
import '../model/conversation_item.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint("Background tap: ${notificationResponse.payload}");
  if (notificationResponse.payload != null) {
    final data = json.decode(notificationResponse.payload!);
    PushNotificationService._handleNotificationTap(data);
  }
}

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // =========================
  // Initialization
  // =========================
  Future<void> initialize() async {
    // Firebase is already initialized in main.dart
    await _fcm.setAutoInitEnabled(true);

    // Request permissions
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint("Notification permission: ${settings.authorizationStatus}");

    // iOS foreground handling (DO NOT auto show, we show locally)
    if (Platform.isIOS || Platform.isMacOS) {
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // 🔹 Token handling (simple & safe)
    final token = await _fcm.getToken();
    if (token != null) {
      AppPref().fcmToken = token;
      debugPrint("FCM Token: $token");
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      AppPref().fcmToken = newToken;
      debugPrint("FCM Token refreshed: $newToken");
    });

    // =========================
    // Local Notifications
    // =========================
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(initSettings,
        onDidReceiveNotificationResponse: (response) {
      if (response.payload != null) {
        final data = json.decode(response.payload!);
        _handleNotificationTap(data);
      }
    }, onDidReceiveBackgroundNotificationResponse: notificationTapBackground);

    // =========================
    // Message Handling
    // =========================

    // Terminated
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(seconds: 1), () {
        _handleMessage(initialMessage);
      });
    }

    // Background → opened
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Foreground → show local notification
    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  // =========================
  // Local Notification
  // =========================
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null && data.isEmpty) return;

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Used for important notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification?.title ?? data['title'],
      notification?.body ?? data['body'],
      details,
      payload: json.encode(data),
    );
  }

  // =========================
  // Message Routing
  // =========================
  static void _handleMessage(RemoteMessage message) {
    debugPrint("Handling message: ${message.data}");
    _handleNotificationData(message.data);
  }

  static void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint("Tapped notification: $data");
    _handleNotificationData(data);
  }

  static void _handleNotificationData(Map<String, dynamic> data) {
    debugPrint("Notification data: $data");
    final convId = (data['conversation_id'] ?? '').toString();
    if (convId.isEmpty) return;

    final convTypeRaw = (data['conversation_type'] ?? '').toString();
    final convType = convTypeRaw == 'group' ? 'team' : convTypeRaw;

    final conversation = ConversationItem(
      conversationId: convId,
      type: convType,
      title: (data['title'] ?? data['team_name'] ?? '').toString(),
      image: (data['image'] ?? '').toString(),
      lastMessage: '',
      lastMessageFileUrl: '',
      lastReadMessageId: '',
      msgType: 'text',
      createdAt: null,
      unreadCount: 0,
    );

    debugPrint(
        "mtag: ${Get.currentRoute} :: ${AppRouter.conversationDetailScreen}");
    if (Get.currentRoute != AppRouter.conversationDetailScreen) {
      debugPrint("mtag->inside if block");
      Get.toNamed(
        AppRouter.conversationDetailScreen,
        arguments: {'conversation': conversation},
      );
    }
  }

  Future<void> testLocalNotification() async {
    final FlutterLocalNotificationsPlugin localNotifications =
        FlutterLocalNotificationsPlugin();

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Local notification test channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await localNotifications.show(
      0,
      'Test Notification ✅',
      'If you see this, local notifications are working.',
      notificationDetails,
    );
  }
}
