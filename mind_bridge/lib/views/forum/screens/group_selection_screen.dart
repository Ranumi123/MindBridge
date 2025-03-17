import 'package:flutter/material.dart';
import 'group_details_screen.dart';

// Define ChatGroup class directly in this file to resolve the import error
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

// Define ChatRepository class directly in this file to resolve the import error
class ChatRepository {
  final List<ChatGroup> _mockGroups = [
    ChatGroup(
      id: '1',
      name: 'Tech Talk',
      members: '0/10',
      description: 'Discuss the latest tech trends and innovations. Share news about gadgets, software, and tech events!',
    ),
    ChatGroup(
      id: '2',
      name: 'Fitness Club',
      members: '0/10',
      description: 'Stay fit and healthy with others! Share workout routines, nutrition tips, and fitness motivation.',
    ),
    ChatGroup(
      id: '3',
      name: 'Book Lovers',
      members: '0/10',
      description: 'Share and discuss your favorite books! From classics to contemporary, fiction to non-fiction.',
    ),
    ChatGroup(
      id: '4',
      name: 'Gaming Zone',
      members: '0/10',
      description: 'Talk about games and play together! PC, console, or mobile - all gamers welcome here.',
    ),
    ChatGroup(
      id: '5',
      name: 'Music Vibes',
      members: '0/10',
      description: 'Share your favorite music and artists! Discover new songs, discuss concerts, and connect through music.',
    ),
  ];

  final Map<String, List<dynamic>> _mockMessages = {};

  Future<List<ChatGroup>> getGroups() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockGroups;
  }

  Future<List<dynamic>> getMessages(String groupId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!_mockMessages.containsKey(groupId)) {
      _mockMessages[groupId] = [
        {
          'id': '1',
          'message': 'Welcome to the group!',
          'sender': 'Admin',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'isMe': false,
        },
      ];
    }
    
    return _mockMessages[groupId]!;
  }

  Future<void> sendMessage(String groupId, String message) async {
    if (!_mockMessages.containsKey(groupId)) {
      _mockMessages[groupId] = [];
    }
    
    _mockMessages[groupId]!.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'message': message,
      'sender': 'You',
      'timestamp': DateTime.now().toIso8601String(),
      'isMe': true,
    });
  }

  Future<bool> joinGroup(String groupId, String username) async {
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
          membersList: [...(_mockGroups[groupIndex].membersList), username],
        );
        return true;
      }
    }
    return false;
  }
}

class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  State<GroupSelectionScreen> createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  List<ChatGroup> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await _chatRepository.getGroups();
      if (mounted) {
        setState(() {
          _groups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load groups: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _joinGroup(ChatGroup group) async {
    final membersParts = group.members.split('/');
    final currentMembers = int.parse(membersParts[0]);
    final maxMembers = int.parse(membersParts[1]);

    if (currentMembers >= maxMembers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This group is full! Max 10 members.')),
      );
      return;
    }

    try {
      final success = await _chatRepository.joinGroup(group.id, 'You');
      if (success) {
        // Reload groups to show updated member count
        await _loadGroups();
        
        // Navigate to Group Details Screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupDetailsScreen(group: group),
            ),
          ).then((_) => _loadGroups()); // Refresh when returning
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to join group. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining group: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Group'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index];
                
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.teal,
                      child: Text(
                        group.name.isNotEmpty ? group.name[0] : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          group.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Members: ${group.members}',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _joinGroup(group),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 10
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Join',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}