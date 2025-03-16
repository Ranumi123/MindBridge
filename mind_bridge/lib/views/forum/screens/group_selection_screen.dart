import 'package:flutter/material.dart';

// Define ChatGroup class inline to avoid import errors
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
}

// Define simple GroupDetailsScreen for navigation
class GroupDetailsScreen extends StatelessWidget {
  final ChatGroup group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text('Group Details: ${group.name}'),
      ),
    );
  }
}

// ChatRepository implementation
class ChatRepository {
  // Mock data for groups
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

  Future<List<ChatGroup>> getGroups() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockGroups;
  }

  Future<bool> joinGroup(String groupId, String username) async {
    // Find the group by ID
    final groupIndex = _mockGroups.indexWhere((group) => group.id == groupId);
    if (groupIndex != -1) {
      // Parse current/max members
      final parts = _mockGroups[groupIndex].members.split('/');
      final currentMembers = int.parse(parts[0]);
      final maxMembers = int.parse(parts[1]);
      
      // Check if group has space
      if (currentMembers < maxMembers) {
        // Update member count
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
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        group.name.isNotEmpty ? group.name[0] : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      group.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      group.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${group.members}'),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _joinGroup(group),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                          child: const Text(
                            'Join',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}