import 'package:flutter/material.dart';

class GroupTile extends StatelessWidget {
  final Map<String, String> group;

  const GroupTile({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.shade100,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade700,
          child: Text(
            group['name']!.split(' ')[1],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          group['name']!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '${group['members']} members',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        onTap: () {
          Navigator.pushNamed(context, '/chatdetail');
        },
      ),
    );
  }
}
