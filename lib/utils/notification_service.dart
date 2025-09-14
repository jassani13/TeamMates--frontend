import 'dart:convert';
import 'dart:io';

import 'package:base_code/package/config_packages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../app_route.dart';

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static String? _deviceToken;

  // =========================
  // Initialization
  // =========================
  Future<void> initialize() async {
    await Firebase.initializeApp();

    // Request permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint("Notification permission: ${settings.authorizationStatus}");

    // Save token
    _deviceToken = await getAndSaveDeviceToken();
    debugPrint("FCM_Token: $_deviceToken");

    // Setup local notifications
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

    // =========================
    // Handle lifecycle events
    // =========================

    // Terminated state (app closed, opened from push)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Background (opened from push)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // Foreground (show local notification)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground push: ${message.notification?.title}");
      _showLocalNotification(message);
    });
  }

  // =========================
  // Local Notification
  // =========================
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

  // =========================
  // Message Handlers
  // =========================
  static void _handleMessage(RemoteMessage message) {
    debugPrint("Handling push message: ${message.data}");
    _handleNotificationData(message.data);
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

  // =========================
  // Token
  // =========================
  static Future<String?> getAndSaveDeviceToken() async {
    String? token;

    if (Platform.isIOS) {
      token = await _fcm.getAPNSToken();
    } else {
      token = await _fcm.getToken();
    }

    if (token != null) {
      AppPref().fcmToken = token;
    }

    return token;
  }

  // =========================
  // Topic Management
  // =========================
  static Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    debugPrint("Subscribed to $topic");
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    debugPrint("Unsubscribed from $topic");
  }
}
