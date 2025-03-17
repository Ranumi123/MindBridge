import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  // Dynamically set the base URL based on the platform
  static String get baseUrl {
    if (kIsWeb) {
      // For web (Chrome) use localhost
      return "http://localhost:5001/api/auth";
    } else if (Platform.isAndroid) {
      // For Android emulator
      return "http://10.0.2.2:5001/api/auth";
    } else {
      // For iOS and other platforms
      return "http://localhost:5001/api/auth";
    }
  }

  static String get profileBaseUrl {
    if (kIsWeb) {
      return "http://localhost:5001/api/profile";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:5001/api/profile";
    } else {
      return "http://localhost:5001/api/profile";
    }
  }

  // Login
  static Future<http.Response> login(String email, String password) async {
    print('Attempting login with email: $email');
    print('Using base URL: $baseUrl');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );
      print('Login response status code: ${response.statusCode}');
      print('Login response body: ${response.body}');
      return response;
    } catch (e) {
      print('Exception during login: $e');
      // Create a fake response to handle the error in the UI
      return http.Response('{"msg": "Connection error: $e"}', 500);
    }
  }

  // Signup
  static Future<http.Response> signup(
      String name, String email, String password) async {
    print('Attempting signup for: $name, $email');
    print('Using base URL: $baseUrl');

    try {
      print('Connecting to: $baseUrl/signup');
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      print('Signup response status code: ${response.statusCode}');
      print('Signup response body: ${response.body}');
      return response;
    } catch (e) {
      print('Exception during signup: $e');
      // Create a fake response to handle the error in the UI
      return http.Response('{"msg": "Connection error: $e"}', 500);
    }
  }

  // Fetch Profile
  static Future<http.Response> fetchProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$profileBaseUrl'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      print('Exception during fetch profile: $e');
      return http.Response('{"msg": "Connection error: $e"}', 500);
    }
  }

  // Update Profile
  static Future<http.Response> updateProfile(
      String token, Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse('$profileBaseUrl'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profileData),
      );
      return response;
    } catch (e) {
      print('Exception during update profile: $e');
      return http.Response('{"msg": "Connection error: $e"}', 500);
    }
  }

  // Update Preferences
  static Future<http.Response> updatePreferences(
      String token, Map<String, dynamic> preferences) async {
    try {
      final response = await http.put(
        Uri.parse('$profileBaseUrl/preferences'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(preferences),
      );
      return response;
    } catch (e) {
      print('Exception during update preferences: $e');
      return http.Response('{"msg": "Connection error: $e"}', 500);
    }
  }

  // Update Privacy Settings
  static Future<http.Response> updatePrivacySettings(
      String token, Map<String, dynamic> privacySettings) async {
    try {
      final response = await http.put(
        Uri.parse('$profileBaseUrl/privacy-settings'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(privacySettings),
      );
      return response;
    } catch (e) {
      print('Exception during update privacy settings: $e');
      return http.Response('{"msg": "Connection error: $e"}', 500);
    }
  }
}