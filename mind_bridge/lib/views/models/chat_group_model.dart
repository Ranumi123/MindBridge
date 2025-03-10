class ChatGroup {
  final String id;
  final String name;
  final String members;

  ChatGroup({required this.id, required this.name, required this.members});

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['id'],
      name: json['name'],
      members: json['members'],
    );
  }
}
