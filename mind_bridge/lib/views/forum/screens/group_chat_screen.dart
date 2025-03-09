import 'package:flutter/material.dart';
import '../../widgets/group_tile.dart'; // Ensure `group_tile.dart` exists

class GroupSelectionScreen extends StatelessWidget {
  const GroupSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = [
      {'name': 'Group 1 - Floyd', 'members': '5/10'},
      {'name': 'Group 2 - Devon', 'members': '8/10'},
      {'name': 'Group 3 - Jerome', 'members': '7/10'},
      {'name': 'Group 4 - Eleanor', 'members': '9/10'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Community Forum')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Chat Groups',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...groups.map((group) => GroupTile(group: group)).toList(),
        ],
      ),
    );
  }
}
