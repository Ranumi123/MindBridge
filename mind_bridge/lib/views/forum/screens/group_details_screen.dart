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

// Simple version of GroupChatScreen to reference in navigation
class GroupChatScreen extends StatefulWidget {
  final ChatGroup group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name)),
      body: Center(
        child: Text('Welcome to ${widget.group.name} chat!'),
      ),
    );
  }
}

class GroupDetailsScreen extends StatelessWidget {
  final ChatGroup group;

  const GroupDetailsScreen({super.key, required this.group});

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
            Text(
              group.description,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
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

            // Enter Chat Button
            SizedBox(
              width: double.infinity,
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enter Chat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}