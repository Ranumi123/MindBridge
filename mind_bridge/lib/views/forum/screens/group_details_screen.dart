import 'package:flutter/material.dart';
import 'group_chat_screen.dart';
import 'group_selection_screen.dart';  // Import this to use the ChatGroup class

class GroupDetailsScreen extends StatefulWidget {
  final ChatGroup group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  bool _isAnonymous = false;

  // Add method to leave the group
  void _leaveGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Are you sure you want to leave "${widget.group.name}"?'),
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
                SnackBar(content: Text('You left "${widget.group.name}"')),
              );
            },
            child: const Text('LEAVE'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  // Define app color scheme
  static const Color primaryColor = Color(0xFF4B9FE1); // Blue
  static const Color accentColor = Color(0xFF1EBBD7); // Teal
  static const Color tertiaryColor = Color(0xFF20E4B5); // Turquoise

  @override
  Widget build(BuildContext context) {
    // Parse members string to get current and max members
    final membersParts = widget.group.members.split('/');
    final currentMembers = int.parse(membersParts[0]);
    
    // Generate a list of members - handle empty lists safely
    List<String> memberList = ['You'];
    if (currentMembers > 1) {
      for (int i = 1; i < currentMembers; i++) {
        memberList.add('Member ${i}');
      }
    }
    
    // Use provided member list if it exists and is not empty
    if (widget.group.membersList.isNotEmpty) {
      memberList = widget.group.membersList;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        centerTitle: true,
        backgroundColor: primaryColor,
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
                backgroundColor: accentColor,
                child: Text(
                  widget.group.name.isNotEmpty ? widget.group.name[0] : '?',
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
              widget.group.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Group Description with Anonymous Mode Button
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.group.description,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Anonymous Mode Toggle
                  Row(
                    children: [
                      Switch(
                        value: _isAnonymous,
                        onChanged: (value) {
                          setState(() {
                            _isAnonymous = value;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isAnonymous 
                                ? 'Anonymous mode enabled. Your identity will be hidden in chat.'
                                : 'Anonymous mode disabled. Your real username will be visible.'),
                              backgroundColor: _isAnonymous ? tertiaryColor : primaryColor,
                            ),
                          );
                        },
                        activeColor: tertiaryColor,
                        activeTrackColor: tertiaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Anonymous Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.privacy_tip_outlined,
                        color: _isAnonymous ? tertiaryColor : Colors.grey,
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Members count and limit
            Row(
              children: [
                Icon(Icons.people, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Members: ${widget.group.members}',
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
                      backgroundColor: isCurrentUser ? primaryColor : Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        color: isCurrentUser ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                    title: Text(
                      isCurrentUser && _isAnonymous ? "Anonymous (You)" : memberList[index],
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
                          builder: (context) => GroupChatScreen(
                            group: widget.group,
                            isAnonymous: _isAnonymous,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      backgroundColor: primaryColor,
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