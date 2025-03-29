// lib/services/chat_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mind_bridge/views/models/chat_group.dart';
import 'package:mind_bridge/views/models/chat_message.dart';
import 'package:mind_bridge/views/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatApiService {
  static const String baseUrl = ApiConstants.baseUrl;
  String currentUsername;

  // Add a static instance for singleton pattern
  static ChatApiService? _instance;
  static ChatApiService get instance => _instance ??= ChatApiService(currentUsername: 'DefaultUser');

  ChatApiService({required this.currentUsername});

  // Get all chat groups
  Future<List<ChatGroup>> getChatGroups() async {
    try {
      // Clear any cached data first to ensure fresh state
      await _clearCachedData();

      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/groups'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final groups = data.map((item) => ChatGroup.fromJson(item)).toList();

        // Mark groups that the user has joined - specific to current user
        for (var group in groups) {
          group.isJoined = group.membersList.contains(currentUsername);
        }

        return groups;
      } else {
        throw Exception('Failed to load chat groups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting chat groups: $e');
    }
  }

  // Get a specific chat group
  Future<ChatGroup> getChatGroup(String groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/groups/$groupId'),
      );

      if (response.statusCode == 200) {
        final group = ChatGroup.fromJson(json.decode(response.body));
        group.isJoined = group.membersList.contains(currentUsername);
        return group;
      } else {
        throw Exception('Failed to load chat group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting chat group: $e');
    }
  }

  // Join a chat group
  Future<bool> joinChatGroup(String groupId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/groups/$groupId/join'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': currentUsername}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to join chat group');
      }
    } catch (e) {
      throw Exception('Error joining chat group: $e');
    }
  }

  // Leave a chat group
  Future<bool> leaveChatGroup(String groupId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/groups/$groupId/leave'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': currentUsername}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to leave chat group');
      }
    } catch (e) {
      throw Exception('Error leaving chat group: $e');
    }
  }

  // Get messages for a group
  Future<List<ChatMessage>> getGroupMessages(String groupId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/messages/group/$groupId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ChatMessage.fromJson(item, currentUsername)).toList();
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting messages: $e');
    }
  }

  // Send a message to a group
  Future<ChatMessage> sendMessage(String groupId, String message, bool isAnonymous) async {
    try {
      // Check for toxic content first
      final toxicCheckResponse = await http.post(
        Uri.parse('$baseUrl/api/chat/messages/check-toxic'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );

      final toxicData = json.decode(toxicCheckResponse.body);
      if (toxicData['toxic'] == true) {
        throw Exception('Your message contains inappropriate language: ${toxicData['toxicWord']}');
      }

      // Send the message
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/messages/group/$groupId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': message,
          'sender': currentUsername,
          'isAnonymous': isAnonymous,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ChatMessage.fromJson(data, currentUsername);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  // Method to update current user
  void updateCurrentUser(String username) {
    currentUsername = username;
    _clearCachedData();
  }

  // Clear cached data to ensure a fresh state for each user
  Future<void> _clearCachedData() async {
    try {
      // Clear any cached group membership info
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_chat_groups_${currentUsername}');

      // You can add more cache clearing logic here if needed
    } catch (e) {
      print('Error clearing cached data: $e');
    }
  }
}