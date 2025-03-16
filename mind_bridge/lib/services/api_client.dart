import 'dart:convert';
import 'package:http/http.dart' as http;

// Directly defining the models within the file temporarily to fix import issues
// Later you can move these to their proper files once the structure is fixed

class ChatGroup {
  final String id;
  final String name;
  final String members;
  final String description;
  final List<String> membersList;

  ChatGroup({
    required this.id, 
    required this.name, 
    required this.members,
    this.description = '',
    this.membersList = const [],
  });

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    List<String> membersListData = [];
    if (json.containsKey('membersList') && json['membersList'] != null) {
      membersListData = List<String>.from(json['membersList']);
    }
    
    return ChatGroup(
      id: json['id'],
      name: json['name'],
      members: json['members'],
      description: json['description'] ?? '',
      membersList: membersListData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'description': description,
      'membersList': membersList,
    };
  }
}

class MessageModel {
  final String id;
  final String message;
  final String sender;
  final DateTime timestamp;
  final bool isMe;

  MessageModel({
    required this.id,
    required this.message,
    required this.sender,
    required this.timestamp,
    this.isMe = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      message: json['message'],
      sender: json['sender'],
      timestamp: DateTime.parse(json['timestamp']),
      isMe: json['sender'] == 'You', // Assuming 'You' is the current user
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'isMe': isMe,
    };
  }

  // Format the timestamp for display
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

// Now define the ApiClient
class ApiClient {
  static const String baseUrl = 'http://localhost:3000';
  
  // Mock data for groups and messages when server isn't available
  final List<ChatGroup> _mockGroups = [
    ChatGroup(
      id: '1',
      name: 'Tech Talk',
      members: '0/10',
      description: 'Discuss the latest tech trends!',
    ),
    ChatGroup(
      id: '2',
      name: 'Fitness Club',
      members: '0/10',
      description: 'Stay fit and healthy with others!',
    ),
    ChatGroup(
      id: '3',
      name: 'Book Lovers',
      members: '0/10',
      description: 'Share and discuss your favorite books!',
    ),
    ChatGroup(
      id: '4',
      name: 'Gaming Zone',
      members: '0/10',
      description: 'Talk about games and play together!',
    ),
    ChatGroup(
      id: '5',
      name: 'Music Vibes',
      members: '0/10',
      description: 'Share your favorite music and artists!',
    ),
  ];

  final Map<String, List<MessageModel>> _mockMessages = {};

  Future<List<Map<String, dynamic>>> fetchGroups() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/groups'));
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } catch (e) {
      // Return mock data when server is not available
      return _mockGroups.map((group) => {
        'id': group.id,
        'name': group.name,
        'members': group.members,
        'description': group.description,
      }).toList();
    }
  }

  Future<List<Map<String, dynamic>>> fetchMessages(String groupId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/groups/$groupId/messages'));
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } catch (e) {
      // Return mock data when server is not available
      if (!_mockMessages.containsKey(groupId)) {
        _mockMessages[groupId] = [
          MessageModel(
            id: '1',
            message: 'Welcome to the group!',
            sender: 'Admin',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];
      }
      return _mockMessages[groupId]!.map((message) => {
        'id': message.id,
        'message': message.message,
        'sender': message.sender,
        'timestamp': message.timestamp.toIso8601String(),
      }).toList();
    }
  }

  Future<void> sendMessage(String groupId, String message) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/groups/$groupId/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );
    } catch (e) {
      // Store message locally when server is not available
      if (!_mockMessages.containsKey(groupId)) {
        _mockMessages[groupId] = [];
      }
      
      _mockMessages[groupId]!.add(
        MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: message,
          sender: 'You',
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<bool> joinGroup(String groupId, String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/groups/$groupId/join'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );
      return response.statusCode == 200;
    } catch (e) {
      // Update mock group data when server is not available
      final groupIndex = _mockGroups.indexWhere((group) => group.id == groupId);
      if (groupIndex != -1) {
        final parts = _mockGroups[groupIndex].members.split('/');
        final currentMembers = int.parse(parts[0]);
        final maxMembers = int.parse(parts[1]);
        
        if (currentMembers < maxMembers) {
          _mockGroups[groupIndex] = ChatGroup(
            id: _mockGroups[groupIndex].id,
            name: _mockGroups[groupIndex].name,
            members: '${currentMembers + 1}/$maxMembers',
            description: _mockGroups[groupIndex].description,
          );
          return true;
        }
      }
      return false;
    }
  }
}