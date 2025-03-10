import 'package:flutter/material.dart';

class GroupTile extends StatelessWidget {
  final Map<String, String> group;

  const GroupTile({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            group['name']!.split(' ')[1],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(group['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${group['members']} members'),
        onTap: () => Navigator.pushNamed(context, '/chatdetail'),
      ),
    );
  }
}
