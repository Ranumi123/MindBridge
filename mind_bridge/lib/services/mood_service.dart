// lib/services/mood_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'user_prefs.dart'; // Import user preferences
import 'auth_service.dart'; // Import auth service for token

class MoodService {
  final String baseUrl;
  String? _userId;
  String? _token;

  // In-memory cache for mood data
  Map<String, int> _cachedWeeklyMoods = {
    "Mon": 0, "Tue": 0, "Wed": 0, "Thu": 0, "Fri": 0, "Sat": 0, "Sun": 0
  };

  MoodService({required this.baseUrl});

  // Initialize service - IMPORTANT: Call this before using any methods
  Future<void> initialize() async {
    // Load userId from persistent storage
    _userId = await AuthService.getCurrentUserId();
    _token = await AuthService.getToken();

    if (_userId != null) {
      debugPrint('MoodService initialized with userId: $_userId');
    } else {
      debugPrint('MoodService initialized but no userId found. User may not be logged in.');
    }
  }

  // Get API endpoint based on platform
  String get _apiUrl {
    if (kIsWeb) {
      return "$baseUrl/api/moods";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:5001/api/moods";
    } else {
      return "$baseUrl/api/moods";
    }
  }

  // Get weekly moods from API
  Future<Map<String, int>> getWeeklyMoods({bool forceRefresh = false}) async {
    // If we have no userId, try to get it again (might have logged in since initialize)
    if (_userId == null) {
      _userId = await AuthService.getCurrentUserId();

      // If still null, return empty data
      if (_userId == null) {
        debugPrint('Cannot fetch moods: No user ID available');
        return _cachedWeeklyMoods;
      }
    }

    // If not forcing refresh and we have cached data, return it
    if (!forceRefresh && _cachedWeeklyMoods.values.any((value) => value > 0)) {
      return _cachedWeeklyMoods;
    }

    try {
      // Add authentication token if available
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (_token != null) {
        headers['Authorization'] = 'Bearer $_token';
      }

      // Make the API request
      debugPrint('Fetching weekly moods from: $_apiUrl/weekly?userId=$_userId');
      final response = await http.get(
        Uri.parse('$_apiUrl/weekly?userId=$_userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Received mood data: $data');

        // Update cached data with the response
        final Map<String, int> weeklyMoods = {
          "Mon": data['Mon'] ?? 0,
          "Tue": data['Tue'] ?? 0,
          "Wed": data['Wed'] ?? 0,
          "Thu": data['Thu'] ?? 0,
          "Fri": data['Fri'] ?? 0,
          "Sat": data['Sat'] ?? 0,
          "Sun": data['Sun'] ?? 0,
        };

        _cachedWeeklyMoods = weeklyMoods;
        return weeklyMoods;
      } else {
        debugPrint('Failed to load moods. Status: ${response.statusCode}, Body: ${response.body}');
        return _cachedWeeklyMoods;
      }
    } catch (e) {
      debugPrint('Error fetching weekly moods: $e');
      return _cachedWeeklyMoods;
    }
  }

  // Check if user has a mood for today
  Future<bool> hasTodayMood() async {
    // If we have no userId, try to get it again
    if (_userId == null) {
      _userId = await AuthService.getCurrentUserId();

      // If still null, return false
      if (_userId == null) {
        debugPrint('Cannot check today mood: No user ID available');
        return false;
      }
    }

    try {
      // Add authentication token if available
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (_token != null) {
        headers['Authorization'] = 'Bearer $_token';
      }

      // Make the API request
      final response = await http.get(
        Uri.parse('$_apiUrl/today?userId=$_userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['hasMood'] ?? false;
      } else {
        debugPrint('Failed to check today mood. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error checking today mood: $e');
      return false;
    }
  }

  // Save mood
  Future<bool> saveMood(String mood, {String notes = ""}) async {
    // If we have no userId, try to get it again
    if (_userId == null) {
      _userId = await AuthService.getCurrentUserId();

      // If still null, cannot save
      if (_userId == null) {
        debugPrint('Cannot save mood: No user ID available');
        return false;
      }
    }

    try {
      debugPrint('Saving mood: $mood for user: $_userId');

      // Add authentication token if available
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (_token != null) {
        headers['Authorization'] = 'Bearer $_token';
      }

      // Make the API request
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: jsonEncode({
          'userId': _userId,
          'mood': mood,
          'notes': notes,
        }),
      );

      // Log response for debugging
      debugPrint('Save mood response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // If the server says the mood already exists, that's still a success
        if (data['exists'] == true) {
          debugPrint('Mood already exists for today');
        }

        // Update the local weekly moods cache with the new mood
        await getWeeklyMoods(forceRefresh: true);

        return true;
      } else {
        debugPrint('Failed to save mood. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error saving mood: $e');
      return false;
    }
  }

  // Update today's mood
  Future<bool> updateTodayMood(String mood, {String notes = ""}) async {
    // If we have no userId, try to get it again
    if (_userId == null) {
      _userId = await AuthService.getCurrentUserId();

      // If still null, cannot update
      if (_userId == null) {
        debugPrint('Cannot update mood: No user ID available');
        return false;
      }
    }

    try {
      // Add authentication token if available
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (_token != null) {
        headers['Authorization'] = 'Bearer $_token';
      }

      // Make the API request
      final response = await http.put(
        Uri.parse('$_apiUrl/today'),
        headers: headers,
        body: jsonEncode({
          'userId': _userId,
          'mood': mood,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        // Update the local weekly moods cache with the updated mood
        await getWeeklyMoods(forceRefresh: true);
        return true;
      } else {
        debugPrint('Failed to update mood. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating mood: $e');
      return false;
    }
  }

  // Get mood history
  Future<List<dynamic>> getMoodHistory({int page = 1, int limit = 10}) async {
    // If we have no userId, try to get it again
    if (_userId == null) {
      _userId = await AuthService.getCurrentUserId();

      // If still null, return empty list
      if (_userId == null) {
        debugPrint('Cannot fetch mood history: No user ID available');
        return [];
      }
    }

    try {
      // Add authentication token if available
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (_token != null) {
        headers['Authorization'] = 'Bearer $_token';
      }

      // Make the API request
      final response = await http.get(
        Uri.parse('$_apiUrl/history?userId=$_userId&page=$page&limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        debugPrint('Failed to load mood history. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching mood history: $e');
      return [];
    }
  }
}