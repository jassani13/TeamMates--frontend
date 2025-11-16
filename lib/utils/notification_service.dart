import 'dart:convert';
import 'dart:io';

import 'package:base_code/package/config_packages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../app_route.dart';
import '../model/conversation_item.dart';

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

    // Ensure FCM auto-init is enabled (generates token automatically)
    await _fcm.setAutoInitEnabled(true);

    // Request permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint("Notification permission: ${settings.authorizationStatus}");

    // iOS/macOS: allow foreground notification presentation
    if (Platform.isIOS || Platform.isMacOS) {
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Save token
    _deviceToken = await getAndSaveDeviceToken();
    debugPrint("FCM_Token: $_deviceToken");

    // Persist refreshed tokens
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint("FCM token refreshed: $newToken");
      if (newToken.isNotEmpty) {
        AppPref().fcmToken = newToken;
        _deviceToken = newToken;
      }
    });

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
    // Prefer unified navigation when a conversation_id is present
    final convId = (data['conversation_id'] ?? '').toString();
    final convTypeRaw = (data['conversation_type'] ?? '').toString();
    if (convId.isNotEmpty) {
      final convType = convTypeRaw.isEmpty
          ? null
          : (convTypeRaw == 'group'
              ? 'team'
              : convTypeRaw); // normalize legacy 'group' -> 'team'

      final title = (data['title'] ?? data['team_name'] ?? '').toString();
      final image = (data['image'] ?? '').toString();

      final conversation = ConversationItem(
        conversationId: convId,
        type: convType,
        title: title,
        image: image,
        lastMessage: '',
        lastMessageFileUrl: '',
        lastReadMessageId: '',
        msgType: 'text',
        createdAt: null,
        unreadCount: 0,
      );

      if (Get.currentRoute != AppRouter.conversationDetailScreen) {
        Get.toNamed(AppRouter.conversationDetailScreen, arguments: {
          'conversation': conversation,
        });
      }
      return;
    }
  }

  // =========================
  // Token
  // =========================

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
