import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MoodTrackerController extends ChangeNotifier {
  // Current selected mood
  String _selectedMood = "Happy"; // Default mood

  // Weekly moods data
  Map<String, int> _weeklyMoods = {
    "Mon": 0,
    "Tue": 0,
    "Wed": 0,
    "Thu": 0,
    "Fri": 0,
    "Sat": 0,
    "Sun": 0
  };

  // User ID (you'll need to set this when user logs in)
  String? userId;

  // Mood tracking state
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get selectedMood => _selectedMood;
  Map<String, int> get weeklyMoods => _weeklyMoods;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Mood data mapping with additional information
  Map<String, Map<String, dynamic>> get moodData => {
        "Happy": {
          "value": 3,
          "icon": Icons.sentiment_very_satisfied_rounded,
          "color": const Color(0xFFFFC640),
        },
        "Sad": {
          "value": 1,
          "icon": Icons.sentiment_dissatisfied_rounded,
          "color": const Color(0xFF8E8E93),
        },
        "Calm": {
          "value": 2,
          "icon": Icons.spa_rounded,
          "color": const Color(0xFF4A9BFF),
        },
        "Angry": {
          "value": 4,
          "icon": Icons.sentiment_very_dissatisfied_rounded,
          "color": const Color(0xFFFF3B30),
        },
        "Relaxed": {
          "value": 5,
          "icon": Icons.self_improvement_rounded,
          "color": const Color(0xFF4CD964),
        },
      };

  // Constructor - initialize and load data
  MoodTrackerController() {
    // Optional: You might want to perform initial setup
  }

  // Set user ID (call this after login)
  void setUserId(String id) {
    userId = id;
    // Automatically load chart data after setting user ID
    loadChartData();
  }

  // Load chart data from server
  Future<void> loadChartData() async {
    if (userId == null) {
      _setError("User ID is not set");
      return;
    }

    _setLoading(true);

    try {
      final response = await http.get(
        Uri.parse(
            'https://your-server-url.com/api/mood-tracker/weekly-moods?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Convert and validate data
        _weeklyMoods = {
          "Mon": data["Mon"] ?? 0,
          "Tue": data["Tue"] ?? 0,
          "Wed": data["Wed"] ?? 0,
          "Thu": data["Thu"] ?? 0,
          "Fri": data["Fri"] ?? 0,
          "Sat": data["Sat"] ?? 0,
          "Sun": data["Sun"] ?? 0,
        };

        _setError(null);
      } else {
        _setError('Failed to load weekly moods: ${response.body}');
      }
    } catch (e) {
      _setError("Error loading chart data: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Update the selected mood
  Future<void> updateMood(String mood, [String? notes]) async {
    // Validate mood
    if (!moodData.containsKey(mood)) {
      _setError('Invalid mood: $mood');
      return;
    }

    if (userId == null) {
      _setError('User ID is not set');
      return;
    }

    _setLoading(true);

    try {
      final response = await http.post(
        Uri.parse('https://your-server-url.com/api/mood-tracker/add-mood'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'mood': mood,
          'notes': notes,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        _selectedMood = mood;

        // Reload chart data after adding mood
        await loadChartData();

        _setError(null);
      } else {
        _setError('Failed to save mood: ${response.body}');
      }
    } catch (e) {
      _setError("Error saving mood to server: $e");
    } finally {
      _setLoading(false);
    }

    notifyListeners();
  }

  // Clear all mood entries
  Future<void> clearMoodEntries() async {
    if (userId == null) {
      _setError('User ID is not set');
      return;
    }

    _setLoading(true);

    try {
      final response = await http.delete(
        Uri.parse(
            'https://your-server-url.com/api/mood-tracker/clear-moods?userId=$userId'),
      );

      if (response.statusCode == 200) {
        // Reset weekly moods after clearing
        _weeklyMoods = {
          "Mon": 0,
          "Tue": 0,
          "Wed": 0,
          "Thu": 0,
          "Fri": 0,
          "Sat": 0,
          "Sun": 0
        };
        _selectedMood = "Happy"; // Reset to default

        _setError(null);
      } else {
        _setError('Failed to clear mood entries: ${response.body}');
      }
    } catch (e) {
      _setError("Error clearing mood entries: $e");
    } finally {
      _setLoading(false);
    }

    notifyListeners();
  }

  // Internal method to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Internal method to set error message
  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Refresh chart data
  Future<void> refreshChartData() async {
    await loadChartData();
  }
}

// Provider setup wrapper for the app
class MoodTrackerProviderSetup extends StatelessWidget {
  final Widget child;

  const MoodTrackerProviderSetup({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodTrackerController()),
      ],
      child: child,
    );
  }
}
