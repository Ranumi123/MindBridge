import 'package:flutter/material.dart';

// Professional mood data
final Map<String, Map<String, dynamic>> moodData = {
  "Happy": {
    "icon": Icons.sentiment_very_satisfied_rounded,
    "color": const Color(0xFFFFC640),
    "gradient": const LinearGradient(
      colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    "description": "Joyful and content",
    "message": "Embrace the positive energy!"
  },
  "Calm": {
    "icon": Icons.spa_rounded,
    "color": const Color(0xFF4A9BFF),
    "gradient": const LinearGradient(
      colors: [Color(0xFF4A9BFF), Color(0xFF006EE6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    "description": "Peaceful and relaxed",
    "message": "Stay centered and mindful"
  },
  "Relaxed": {
    "icon": Icons.self_improvement_rounded,
    "color": const Color(0xFF4CD964),
    "gradient": const LinearGradient(
      colors: [Color(0xFF4CD964), Color(0xFF2EA043)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    "description": "At ease and tranquil",
    "message": "Enjoy this serene moment"
  },
  "Sad": {
    "icon": Icons.sentiment_dissatisfied_rounded,
    "color": const Color(0xFF8E8E93),
    "gradient": const LinearGradient(
      colors: [Color(0xFF8E8E93), Color(0xFF636366)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    "description": "Feeling down",
    "message": "It's okay not to be okay"
  },
  "Angry": {
    "icon": Icons.sentiment_very_dissatisfied_rounded,
    "color": const Color(0xFFFF3B30),
    "gradient": const LinearGradient(
      colors: [Color(0xFFFF3B30), Color(0xFFDC2626)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    "description": "Frustrated or irritated",
    "message": "Take deep breaths"
  },
};