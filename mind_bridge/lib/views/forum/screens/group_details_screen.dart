import 'package:flutter/material.dart';
import 'group_chat_screen.dart';

class GroupDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(group['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(group['description'], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Text('Members (${group['members'].length} / ${group['limit']}):', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...group['members'].map<Widget>((member) => Text('• $member')).toList(),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupChatScreen(groupName: group['name']),
                  ),
                );
              },
              child: const Text('Enter Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
