import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://10.0.2.2:5001/api/auth";
  static const String profileBaseUrl = "http://10.0.2.2:5001/api/profile";

  // Login
  static Future<http.Response> login(String email, String password) async {
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
    return response;
  }

  // Signup
  static Future<http.Response> signup(
      String name, String email, String password) async {
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
    return response;
  }

  // Fetch Profile
  static Future<http.Response> fetchProfile(String token) async {
    final response = await http.get(
      Uri.parse('$profileBaseUrl'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  // Update Profile
  static Future<http.Response> updateProfile(
      String token, Map<String, dynamic> profileData) async {
    final response = await http.put(
      Uri.parse('$profileBaseUrl'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profileData),
    );
    return response;
  }

  // Update Preferences
  static Future<http.Response> updatePreferences(
      String token, Map<String, dynamic> preferences) async {
    final response = await http.put(
      Uri.parse('$profileBaseUrl/preferences'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(preferences),
    );
    return response;
  }

  // Update Privacy Settings
  static Future<http.Response> updatePrivacySettings(
      String token, Map<String, dynamic> privacySettings) async {
    final response = await http.put(
      Uri.parse('$profileBaseUrl/privacy-settings'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(privacySettings),
    );
    return response;
  }
}
