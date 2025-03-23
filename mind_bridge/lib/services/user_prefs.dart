// lib/services/user_prefs.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_ID_KEY = 'user_id';
  static const String USER_DATA_KEY = 'user_data';

  // Save user login data
  static Future<bool> saveUserLogin(String token, String userId, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(TOKEN_KEY, token);
      await prefs.setString(USER_ID_KEY, userId);
      await prefs.setString(USER_DATA_KEY, jsonEncode(userData));
      print('Saved user data to preferences. userId: $userId');
      return true;
    } catch (e) {
      print('Error saving user preferences: $e');
      return false;
    }
  }

  // Get user token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_ID_KEY);
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(USER_DATA_KEY);
    if (userDataString != null && userDataString.isNotEmpty) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  // Clear user data on logout
  static Future<bool> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(USER_ID_KEY);
    await prefs.remove(USER_DATA_KEY);
    return true;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final userId = await getUserId();
    return token != null && userId != null;
  }
}