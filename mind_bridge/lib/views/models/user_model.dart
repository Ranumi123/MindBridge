// lib/models/user_model.dart
class User {
  final String id;
  final String name;
  final String bio;
  final String organization;
  final String location;
  final String email;
  final String phone;
  final String profileImageUrl;
  
  User({
    required this.id,
    required this.name,
    required this.bio,
    required this.organization,
    required this.location,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      organization: json['organization'] ?? '',
      location: json['location'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }
}