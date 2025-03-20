import 'package:flutter/material.dart';
import 'group_chat_screen.dart';
import 'group_selection_screen.dart';  // Import this to use the ChatGroup class

class GroupDetailsScreen extends StatelessWidget {
  final ChatGroup group;

  const GroupDetailsScreen({super.key, required this.group});

  // Add method to leave the group
  void _leaveGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Are you sure you want to leave "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to group selection
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('You left "${group.name}"')),
              );
            },
            child: const Text('LEAVE'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Parse members string to get current and max members
    final membersParts = group.members.split('/');
    final currentMembers = int.parse(membersParts[0]);
    
    // Generate a list of members - handle empty lists safely
    List<String> memberList = ['You'];
    if (currentMembers > 1) {
      for (int i = 1; i < currentMembers; i++) {
        memberList.add('Member ${i}');
      }
    }
    
    // Use provided member list if it exists and is not empty
    if (group.membersList.isNotEmpty) {
      memberList = group.membersList;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          // Add option to leave group
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'leave') {
                _leaveGroup(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Leave group', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Image
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal.shade200,
                child: Text(
                  group.name.isNotEmpty ? group.name[0] : '?',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Group Name
            Text(
              group.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Group Description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                group.description,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Members count and limit
            Row(
              children: [
                const Icon(Icons.people, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Members: ${group.members}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Members list
            const Text(
              'Group Members:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: memberList.length,
                itemBuilder: (context, index) {
                  final isCurrentUser = index == 0;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrentUser ? Colors.teal : Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        color: isCurrentUser ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                    title: Text(
                      memberList[index],
                      style: TextStyle(
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: isCurrentUser ? const Text('You (Admin)') : null,
                  );
                },
              ),
            ),

            // Button container for multiple buttons
            Row(
              children: [
                // Enter Chat Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupChatScreen(group: group),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Enter Chat'),
                  ),
                ),
                const SizedBox(width: 10),
                // Leave Group Button
                ElevatedButton(
                  onPressed: () => _leaveGroup(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.exit_to_app, size: 18),
                      SizedBox(width: 4),
                      Text('Leave'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}