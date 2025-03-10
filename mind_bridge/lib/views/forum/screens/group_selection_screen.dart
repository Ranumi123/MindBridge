import 'package:flutter/material.dart';
import 'group_details_screen.dart';

class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  _GroupSelectionScreenState createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  // List of predefined groups with details
  final List<Map<String, dynamic>> groups = [
    {'name': 'Tech Talk', 'members': [], 'limit': 10, 'description': 'Discuss the latest tech trends!'},
    {'name': 'Fitness Club', 'members': [], 'limit': 10, 'description': 'Stay fit and healthy with others!'},
    {'name': 'Book Lovers', 'members': [], 'limit': 10, 'description': 'Share and discuss your favorite books!'},
    {'name': 'Gaming Zone', 'members': [], 'limit': 10, 'description': 'Talk about games and play together!'},
    {'name': 'Music Vibes', 'members': [], 'limit': 10, 'description': 'Share your favorite music and artists!'},
  ];

  void joinGroup(int index) {
    setState(() {
      if (groups[index]['members'].length < groups[index]['limit']) {
        groups[index]['members'].add('You'); // Simulating user joining

        // Navigate to Group Details Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupDetailsScreen(group: groups[index]),
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
