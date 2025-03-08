class ChatGroup {
  final String id;
  final String name;

  ChatGroup({required this.id, required this.name});

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['id'],
      name: json['name'],
    );
  }
}
