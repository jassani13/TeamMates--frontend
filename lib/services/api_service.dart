import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:base_code/package/config_packages.dart';

class ApiService {
  // Use your existing baseUrl configuration
  static String get baseUrl => baseUrl;
  static String get apiUrl => '$baseUrl/api';

  static Future<Map<String, dynamic>> sendMessage(
      int conversationId,
      int userId,
      String message
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/send-message'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer TEST123',
          'key': 'TEST123',
        },
        body: json.encode({
          'conversation_id': conversationId,
          'user_id': userId,
          'body': message,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> storeFcmToken(int userId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/store-fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer TEST123',
          'key': 'TEST123',
        },
        body: json.encode({
          'user_id': userId,
          'fcm_token': token,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Additional method to send message with authentication token
  static Future<Map<String, dynamic>> sendMessageWithAuth(
      int conversationId,
      int userId,
      String message,
      String authToken
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/send-message'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
          'key': 'TEST123',
        },
        body: json.encode({
          'conversation_id': conversationId,
          'user_id': userId,
          'body': message,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Method to get user conversations
  static Future<Map<String, dynamic>> getConversations(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/conversations/$userId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer TEST123',
          'key': 'TEST123',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Method to mark message as read
  static Future<Map<String, dynamic>> markAsRead(int messageId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/mark-as-read'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer TEST123',
          'key': 'TEST123',
        },
        body: json.encode({
          'message_id': messageId,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}