class ChatGroup {
  final String id;
  final String name;
  final String description;
  final String members; // Format: "0/10"
  final List<String> membersList;
  final DateTime createdAt;
  bool isJoined = false; // Track if current user has joined

  ChatGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.membersList,
    required this.createdAt,
    this.isJoined = false,
  });

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      members: json['members'] ?? '0/10',
      membersList: List<String>.from(json['membersList'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  bool get isFull {
    final parts = members.split('/');
    if (parts.length == 2) {
      final current = int.tryParse(parts[0]) ?? 0;
      final max = int.tryParse(parts[1]) ?? 10;
      return current >= max;
    }
    return false;
  }

  int get memberCount {
    final parts = members.split('/');
    return int.tryParse(parts[0]) ?? 0;
  }

  int get maxMembers {
    final parts = members.split('/');
    if (parts.length == 2) {
      return int.tryParse(parts[1]) ?? 10;
    }
    return 10;
  }
}