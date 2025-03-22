// services/auth_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  // API base URL - update this with your actual backend URL
  static const String baseUrl = 'http://localhost:5001/api/auth';
  // For Android emulator, use: 'http://10.0.2.2:5001/api/auth'
  // For iOS simulator, use: 'http://localhost:5001/api/auth'
  // For real device testing, use your actual server IP/domain

  // Signup method with additional parameters
  static Future<http.Response> signup(
      String name,
      String email,
      String password,
      [String? phone, String? emergencyContact]
      ) async {
    // Print what we're sending to the API for debugging
    print('Sending signup data: Name: $name, Email: $email, Phone: $phone, EmergencyContact: ${emergencyContact ?? "Not provided"}');

    // Create the request body
    final Map<String, dynamic> requestBody = {
      'name': name,
      'email': email,
      'password': password,
    };

    // Add phone if provided
    if (phone != null && phone.isNotEmpty) {
      requestBody['phone'] = phone;
    }

    // Add emergency contact if provided
    if (emergencyContact != null && emergencyContact.isNotEmpty) {
      requestBody['emergencyContact'] = emergencyContact;
    }

    print('Final request body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('Signup response status: ${response.statusCode}');
    print('Signup response body: ${response.body}');

    return response;
  }

  // Login method
  static Future<http.Response> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('Login response status: ${response.statusCode}');

    return response;
  }

// Add other auth methods as needed
}