import 'package:flutter/material.dart';


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
      appBar: AppBar(
        title: const Text('Community Forum'),
        backgroundColor: Colors.blue.shade800,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chat Groups',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return _buildGroupCard(context, group);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, Map<String, String> group) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.blueAccent.withOpacity(0.4),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(
            group['name']!.split(' ')[1], // Extract group number
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          group['name']!,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        subtitle: Text(
          '${group['members']} members',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
        onTap: () {
          Navigator.pushNamed(context, '/chatdetail');
        },
      ),
    );
  }
}
