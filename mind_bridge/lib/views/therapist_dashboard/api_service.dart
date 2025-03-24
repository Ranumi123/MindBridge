import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Base URL for your API
  static const String baseUrl =
      'http://localhost:5001/api'; // Updated to port 5001

  // Headers for API requests
  static Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Set auth token
  static void setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  // Add custom headers
  static void setCustomHeaders(Map<String, String> headers) {
    _headers.addAll(headers);
  }

  // Clear headers (optional, useful for logging out)
  static void clearHeaders() {
    _headers.clear();
    _headers['Content-Type'] = 'application/json'; // Retain content type
  }

  // GET request helper
  static Future<dynamic> get(String endpoint,
      {Map<String, String>? queryParams}) async {
    try {
      // Build the URI with optional query parameters
      final uri =
          Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams);

      debugPrint('GET Request: $uri'); // Log the request
      final response = await http.get(uri, headers: _headers);

      debugPrint(
          'GET Response: ${response.statusCode} - ${response.body}'); // Log the response
      return _processResponse(response);
    } catch (e) {
      debugPrint('Error during GET request: $e');
      throw Exception('Failed to perform GET request: $e');
    }
  }

  // POST request helper
  static Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final body = json.encode(data);

      debugPrint('POST Request: $uri'); // Log the request
      debugPrint('POST Body: $body'); // Log the request body
      final response = await http.post(uri, headers: _headers, body: body);

      debugPrint(
          'POST Response: ${response.statusCode} - ${response.body}'); // Log the response
      return _processResponse(response);
    } catch (e) {
      debugPrint('Error during POST request: $e');
      throw Exception('Failed to perform POST request: $e');
    }
  }

  // PUT request helper
  static Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final body = json.encode(data);

      debugPrint('PUT Request: $uri'); // Log the request
      debugPrint('PUT Body: $body'); // Log the request body
      final response = await http.put(uri, headers: _headers, body: body);

      debugPrint(
          'PUT Response: ${response.statusCode} - ${response.body}'); // Log the response
      return _processResponse(response);
    } catch (e) {
      debugPrint('Error during PUT request: $e');
      throw Exception('Failed to perform PUT request: $e');
    }
  }

  // DELETE request helper
  static Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');

      debugPrint('DELETE Request: $uri'); // Log the request
      final response = await http.delete(uri, headers: _headers);

      debugPrint(
          'DELETE Response: ${response.statusCode} - ${response.body}'); // Log the response
      return _processResponse(response);
    } catch (e) {
      debugPrint('Error during DELETE request: $e');
      throw Exception('Failed to perform DELETE request: $e');
    }
  }

  // Process HTTP response
  static dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = json.decode(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else {
      // Extract error message from response body
      final error = responseBody['message'] ?? 'Unknown error occurred';
      debugPrint('API Error: $error'); // Log the error
      throw Exception('API Error: $error (Status Code: $statusCode)');
    }
  }
}
