import 'package:flutter/material.dart';
import '../repositories/chat_repository.dart';
import 'chat_screen.dart';

class GroupSelectionScreen extends StatefulWidget {
  @override
  State<GroupSelectionScreen> createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  List<String> groups = [];

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    final fetchedGroups = await _chatRepository.getGroups();
    setState(() => groups = fetchedGroups);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mind Bridge Groups')),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(groups[index]),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(groupName: groups[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
