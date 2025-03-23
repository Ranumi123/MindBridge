// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mind_bridge/views/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String baseUrl = 'http://localhost:5001/api/auth'; // Replace with your actual API URL
  
  Future<User> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return User.fromJson(userData);
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
  }
  
  Future<void> storeUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }
  
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}