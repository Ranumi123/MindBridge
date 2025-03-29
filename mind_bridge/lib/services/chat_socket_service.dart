// lib/services/chat_socket_service.dart
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../views/models/chat_message.dart';
import '../views/utils/constants.dart';

class ChatSocketService {
  late IO.Socket socket;
  final String currentUsername;

  // Modified callback types
  final Function(dynamic) onNewMessage; // Changed to accept dynamic
  final Function(String, String, String) onMemberJoined;
  final Function(String, String, String) onMemberLeft;
  final Function(Map<String, dynamic>) onMessageError;
  final Function(Map<String, dynamic>) onUserTyping;

  ChatSocketService({
    required this.currentUsername,
    required this.onNewMessage,
    required this.onMemberJoined,
    required this.onMemberLeft,
    required this.onMessageError,
    required this.onUserTyping,
  }) {
    _connectSocket();
  }

  void _connectSocket() {
    try {
      socket = IO.io(
        ApiConstants.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNew()
            .build(),
      );

      socket.connect();

      socket.onConnect((_) {
        debugPrint('Socket connected');
      });

      // Setup event listeners
      socket.on('receiveMessage', (data) {
        // Pass data directly to the callback
        onNewMessage(data);
      });

      socket.on('memberJoined', (data) {
        onMemberJoined(
          data['groupId'] ?? '',
          data['username'] ?? '',
          data['memberCount'] ?? '',
        );
      });

      socket.on('memberLeft', (data) {
        onMemberLeft(
          data['groupId'] ?? '',
          data['username'] ?? '',
          data['memberCount'] ?? '',
        );
      });

      socket.on('messageError', (data) {
        if (data is Map<String, dynamic>) {
          onMessageError(data);
        } else {
          onMessageError({'error': 'Unknown message error'});
        }
      });

      socket.on('userTyping', (data) {
        if (data is Map<String, dynamic>) {
          onUserTyping(data);
        } else {
          debugPrint('Invalid typing data format: $data');
        }
      });

      socket.onDisconnect((_) => debugPrint('Socket disconnected'));
      socket.onError((error) => debugPrint('Socket error: $error'));
    } catch (e) {
      debugPrint('Error connecting socket: $e');
    }
  }

  void joinGroup(String groupId) {
    socket.emit('joinGroup', groupId);
  }

  void leaveGroup(String groupId) {
    socket.emit('leaveGroup', groupId);
  }

  void sendMessage(String groupId, String message, bool isAnonymous) {
    socket.emit('newMessage', {
      'groupId': groupId,
      'message': message,
      'sender': currentUsername,
      'isAnonymous': isAnonymous,
    });
  }

  void sendTypingStatus(String groupId, bool isTyping) {
    socket.emit('typing', {
      'userId': currentUsername,
      'groupId': groupId,
      'isTyping': isTyping,
    });
  }

  void disconnect() {
    try {
      socket.disconnect();
      debugPrint('Socket disconnected successfully');
    } catch (e) {
      debugPrint('Error disconnecting socket: $e');
    }
  }
}