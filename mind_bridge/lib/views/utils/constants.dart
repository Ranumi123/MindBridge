// lib/utils/constants.dart

class ApiConstants {
  // For Android emulator
  static const String baseUrl = 'http://localhost:5001';

  // For iOS simulator or web (uncomment if needed)
  // static const String baseUrl = 'http://localhost:5001';

  // For physical devices testing on local network (replace with your computer's IP)
  // static const String baseUrl = 'http://192.168.1.x:5001';

  // For production deployment (uncomment and update when deploying)
  // static const String baseUrl = 'https://your-production-api.com';

  // API endpoints
  static const String chatGroupsEndpoint = '/api/chat/groups';
  static const String chatMessagesEndpoint = '/api/chat/messages';

  // Socket events
  static const String messageEvent = 'receiveMessage';
  static const String memberJoinedEvent = 'memberJoined';
  static const String memberLeftEvent = 'memberLeft';
  static const String typingEvent = 'userTyping';
  static const String errorEvent = 'messageError';
}

class AppColors {
  static const primary = 0xFF39B0E5;
  static const secondary = 0xFF1ED4B5;
  static const accent = 0xFF1EBBD7;
  static const textDark = 0xFF1E2D3D;
  static const textLight = 0xFF718096;
  static const background = 0xFFF5F7FA;
  static const white = 0xFFFFFFFF;
  static const error = 0xFFE53935;
}

class AppConstants {
  static const int maxGroupMembers = 10;
  static const int messageCooldownSeconds = 1; // Prevent message spam
  static const int typingIndicatorDurationSeconds = 2;
}