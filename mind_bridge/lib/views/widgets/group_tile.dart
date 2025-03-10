import 'package:flutter/material.dart';

class GroupTile extends StatelessWidget {
  final Map<String, String> group;

  const GroupTile({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(group['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Members: ${group['members']}'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => Navigator.pushNamed(context, '/chatlist'),
    );
  }
}
