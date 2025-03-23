import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'user_prefs.dart'; // Import the user preferences service

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

  // Login with user data storage
  static Future<Map<String, dynamic>> login(String email, String password) async {
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

      if (response.statusCode == 200) {
        // Parse response body
        final responseData = jsonDecode(response.body);

        // Extract token and userId
        final token = responseData['token'];
        final userId = responseData['user']['userId']; // Use the consistent userId from backend

        print('Login successful. userId: $userId');

        // Save user data to preferences
        await UserPrefs.saveUserLogin(token, userId, responseData['user']);

        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['msg'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('Exception during login: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Enhanced signup method that handles phone and emergency contact
  static Future<Map<String, dynamic>> signup(
      String name, String email, String password,
      [String? phone, String? emergencyContact]) async {
    print('Attempting signup for: $name, $email');
    print('Using base URL: $baseUrl');

    if (phone != null && phone.isNotEmpty) {
      print('Including phone: $phone');
    }

    if (emergencyContact != null && emergencyContact.isNotEmpty) {
      print('Including emergency contact: $emergencyContact');
    }

    // Prepare request body with all fields
    final Map<String, dynamic> requestBody = {
      'name': name,
      'email': email,
      'password': password,
    };

    // Add optional fields if provided
    if (phone != null && phone.isNotEmpty) {
      requestBody['phone'] = phone;
    }

    if (emergencyContact != null && emergencyContact.isNotEmpty) {
      requestBody['emergencyContact'] = emergencyContact;
    }

    try {
      print('Connecting to: $baseUrl/signup');
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      print('Signup response status code: ${response.statusCode}');
      print('Signup response body: ${response.body}');

      if (response.statusCode == 201) {
        // Parse response data
        final responseData = jsonDecode(response.body);

        // If the response includes a token, save the user data
        if (responseData['user'] != null && responseData['user']['userId'] != null) {
          final userId = responseData['user']['userId'];
          print('Signup successful. userId: $userId');

          // Save user data if there's a token (some APIs might not return a token on signup)
          if (responseData['token'] != null) {
            await UserPrefs.saveUserLogin(
                responseData['token'],
                userId,
                responseData['user']
            );
          }
        }

        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['msg'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      print('Exception during signup: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Logout
  static Future<bool> logout() async {
    return await UserPrefs.clearUserData();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return await UserPrefs.isLoggedIn();
  }

  // Get current user ID - IMPORTANT for persistence
  static Future<String?> getCurrentUserId() async {
    return await UserPrefs.getUserId();
  }

  // Get auth token
  static Future<String?> getToken() async {
    return await UserPrefs.getToken();
  }

  // Fetch Profile
  static Future<http.Response> fetchProfile() async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

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
  static Future<http.Response> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

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
  static Future<http.Response> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

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
  static Future<http.Response> updatePrivacySettings(Map<String, dynamic> privacySettings) async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

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

  // Update user profile with phone and emergency contact
  static Future<Map<String, dynamic>> updateContactInfo(String userId, String phone, String emergencyContact) async {
    try {
      final token = await getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.put(
        Uri.parse('$profileBaseUrl/contact-info'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'phone': phone,
          'emergencyContact': emergencyContact,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['msg'] ?? 'Failed to update contact information',
        };
      }
    } catch (e) {
      print('Exception during contact info update: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
}