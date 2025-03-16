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

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    List<String> membersListData = [];
    if (json.containsKey('membersList') && json['membersList'] != null) {
      membersListData = List<String>.from(json['membersList']);
    }
    
    return ChatGroup(
      id: json['id'],
      name: json['name'],
      members: json['members'],
      description: json['description'] ?? '',
      membersList: membersListData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'description': description,
      'membersList': membersList,
    };
  }
}