import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/services/api_service.dart';

import '../app_route.dart'; // Import your ApiService

class FcmService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    return;
    await Firebase.initializeApp();

    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    try {
      String? apnsToken = await _firebaseMessaging.getAPNSToken();
      print("APNs Token: $apnsToken");

      if (apnsToken == null) {
        print("APNs token not yet available. Waiting...");
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print("FCM Token refreshed: $newToken");
        _storeFcmToken(newToken);
      });

      // Get token and store it
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");

      // Automatically store the token when initialized
      if (token != null) {
        _storeFcmToken(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print("FCM Token refreshed: $newToken");
        _storeFcmToken(newToken);
      });

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidSettings,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          // Handle notification tap when app is in foreground
          if (details.payload != null) {
            final data = json.decode(details.payload!);
            _handleNotificationTap(data);
          }
        },
      );

      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message: ${message.notification?.body}');
        _showNotification(message);
      });

      // Handle when app is in background but opened by tapping notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App opened from background: ${message.data}');
        _handleMessage(message);
      });

      // Handle when app is terminated and opened by tapping notification
      RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }
    } catch (e) {
      print("Error requesting permission: $e");
    }
  }

  // Store FCM token to backend
  static Future<void> _storeFcmToken(String token) async {
    try {
      // Get user ID from your app preferences
      // int userId = AppPref().userId ?? 1; // Make sure this is available
      //
      // debugPrint("_storeFcmToken: Storing token for user $userId");
      // var result = await ApiService.storeFcmToken(userId, token);
      // if (result['success'] == true) {
      //   print('FCM token stored successfully on server');
      // } else {
      //   print('Failed to store FCM token on server: ${result['message']}');
      // }
    } catch (e) {
      print('Error storing FCM token: $e');
    }
  }

  static void _showNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    Map<String, dynamic> data = message.data;

    if (notification != null) {
      _notificationsPlugin.show(
        notification.hashCode,
        notification.title ?? data['title'] ?? 'New Message',
        notification.body ?? data['body'] ?? 'You have a new message',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications',
            importance: Importance.max,
            priority: Priority.high,
            colorized: true,
            enableVibration: true,
            playSound: true,
          ),
        ),
        payload: json.encode(data),
      );
    }
  }

  static void _handleMessage(RemoteMessage message) {
    // Navigate to appropriate screen based on message data
    _handleNotificationData(message.data);
  }

  static void _handleNotificationTap(Map<String, dynamic> data) {
    // Handle notification tap
    _handleNotificationData(data);
  }

  static void _handleNotificationData(Map<String, dynamic> data) {
    debugPrint("_handleNotificationData->Handling notification data: $data");
    if (data.containsKey('type') && data.containsKey('conversation_type')) {
      //switch (data['type']) {
      switch (data['conversation_type']) {
        case 'personal':
          print('New message received: ${data['message']}');
          // Navigate to chat screen
          _navigateToChat(data);
          break;
        case 'group':
          print('Team message received: ${data['message']}');
          _navigateToTeamChat(data);
          break;
        default:
          print('Unknown notification type: ${data['type']}');
      }
    }
  }

  static void _navigateToChat(Map<String, dynamic> data) {
    // Navigate to personal chat screen
    // You'll need to implement your navigation logic here
    if (Get.currentRoute != AppRouter.personalChat) {
      debugPrint("Navigating to personal chat with data: $data");
      Get.toNamed(AppRouter.personalChat, arguments: {
        'chatData': ChatListData(
            firstName: data["sender_name"],
            lastName: "",
            otherId: data['sender_id']),
      });
    }
  }

  static void _navigateToTeamChat(Map<String, dynamic> data) {
    // Navigate to team chat screen
    if (Get.currentRoute != AppRouter.grpChat) {
      debugPrint("_navigateToTeamChat:$data");
      Get.toNamed(
        AppRouter.grpChat,
        arguments: {
          'chatData': ChatListData(
              teamName: data['team_name'], teamId: data['team_id']),
        },
      );
    }
    // {
    // type: new_message,
    // conversation_id: 2,
    // sender_id: 21,
    // sender_name: null null,
    // conversation_type: group,
    // team_name: Australia
    // }
  }

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Method to show local notification manually
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications',
      importance: Importance.max,
      priority: Priority.high,
      colorized: true,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      title,
      body,
      notificationDetails,
      payload: json.encode(data),
    );
  }

  // Subscribe to topics for group chats
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  // Unsubscribe from topics
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }
}
