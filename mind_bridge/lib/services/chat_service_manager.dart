// lib/services/chat_service_manager.dart
import 'package:mind_bridge/services/chat_api_service.dart';
import 'package:mind_bridge/services/chat_socket_service.dart';

/// A singleton manager for chat services to ensure proper handling of
/// user switching and service cleanup
class ChatServiceManager {
  static final ChatServiceManager _instance = ChatServiceManager._internal();

  factory ChatServiceManager() {
    return _instance;
  }

  ChatServiceManager._internal();

  ChatApiService? _chatApiService;
  ChatSocketService? _chatSocketService;
  String? _currentUsername;

  /// Initialize services for a new user
  void initializeForUser(String username) {
    if (_currentUsername == username) {
      print('ChatServiceManager: Same user, no need to reinitialize');
      return;
    }

    print('ChatServiceManager: Initializing services for $username');
    _currentUsername = username;

    // If socket service exists, disconnect it
    if (_chatSocketService != null) {
      print('ChatServiceManager: Disconnecting existing socket');
      _chatSocketService!.disconnect();
      _chatSocketService = null;
    }

    // Create or update API service for the current user
    if (_chatApiService != null) {
      print('ChatServiceManager: Updating existing API service');
      _chatApiService!.updateCurrentUser(username);
    } else {
      print('ChatServiceManager: Creating new API service');
      _chatApiService = ChatApiService(currentUsername: username);
    }
  }

  /// Get the API service for a specific username, creating it if necessary
  ChatApiService getChatApiService(String username) {
    if (_chatApiService == null || _chatApiService!.currentUsername != username) {
      print('ChatServiceManager: Creating new API service for $username');
      _chatApiService = ChatApiService(currentUsername: username);
      _currentUsername = username;
    }
    return _chatApiService!;
  }

  /// Create a new socket service with the provided callbacks
  /// All callback parameters are defined with correct types
  ChatSocketService createSocketService({
    required String username,
    required Function(dynamic) onNewMessage, // Changed to accept dynamic
    required Function(String, String, String) onMemberJoined,
    required Function(String, String, String) onMemberLeft,
    required Function(Map<String, dynamic>) onMessageError,
    required Function(Map<String, dynamic>) onUserTyping,
  }) {
    // Disconnect existing socket if it exists
    _chatSocketService?.disconnect();

    // Create new socket service
    _chatSocketService = ChatSocketService(
      currentUsername: username,
      onNewMessage: onNewMessage,
      onMemberJoined: onMemberJoined,
      onMemberLeft: onMemberLeft,
      onMessageError: onMessageError,
      onUserTyping: onUserTyping,
    );

    return _chatSocketService!;
  }

  /// Clean up all services (call on logout)
  void cleanUp() {
    print('ChatServiceManager: Cleaning up services');

    if (_chatSocketService != null) {
      _chatSocketService!.disconnect();
      _chatSocketService = null;
    }

    _chatApiService = null;
    _currentUsername = null;
  }
}