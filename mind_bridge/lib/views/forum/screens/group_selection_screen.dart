import 'package:flutter/material.dart';
import 'group_chat_screen.dart';

class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  _GroupSelectionScreenState createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  // List of predefined groups with their current members
  final List<Map<String, dynamic>> groups = [
    {'name': 'Tech Talk', 'members': [], 'limit': 10},
    {'name': 'Fitness Club', 'members': [], 'limit': 10},
    {'name': 'Book Lovers', 'members': [], 'limit': 10},
    {'name': 'Gaming Zone', 'members': [], 'limit': 10},
    {'name': 'Music Vibes', 'members': [], 'limit': 10},
  ];

  void joinGroup(int index) {
    setState(() {
      if (groups[index]['members'].length < groups[index]['limit']) {
        groups[index]['members'].add('You'); // Simulating user joining
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupChatScreen(groupName: groups[index]['name']),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This group is full! Max 10 members.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join a Group')),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(groups[index]['name']),
              subtitle: Text('${groups[index]['members'].length} / ${groups[index]['limit']} members'),
              trailing: ElevatedButton(
                onPressed: () => joinGroup(index),
                child: const Text('Join'),
              ),
            ),
          );
        },
      ),
    );
  }
}
