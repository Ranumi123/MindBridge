import 'dart:convert';
import '../therapist_dashboard/api_service.dart';

class Therapist {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int totalReviews;
  final String description;
  final int experience;
  final int clientsHelped;
  final String imageUrl;
  final bool isPopular;
  final bool isAvailable;
  final String calComUserId;
  final String calComEventTypeId;

  Therapist({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.totalReviews,
    required this.description,
    required this.experience,
    required this.clientsHelped,
    required this.imageUrl,
    required this.isPopular,
    required this.isAvailable,
    required this.calComUserId,
    required this.calComEventTypeId,
  });

  factory Therapist.fromJson(Map<String, dynamic> json) {
    return Therapist(
      id: json['_id'],
      name: json['name'],
      specialty: json['specialty'],
      rating: json['rating'].toDouble(),
      totalReviews: json['totalReviews'],
      description: json['description'],
      experience: json['experience'],
      clientsHelped: json['clientsHelped'],
      imageUrl: json['imageUrl'],
      isPopular: json['isPopular'],
      isAvailable: json['isAvailable'],
      calComUserId: json['calComUserId'],
      calComEventTypeId: json['calComEventTypeId'],
    );
  }
}

class TherapistService {
  // Get all therapists
  static Future<List<Therapist>> getAllTherapists() async {
    final response = await ApiService.get('therapists');
    return _parseTherapistList(response);
  }

  // Get popular therapists
  static Future<List<Therapist>> getPopularTherapists() async {
    final response = await ApiService.get('therapists/popular');
    return _parseTherapistList(response);
  }

  // Get available therapists
  static Future<List<Therapist>> getAvailableTherapists() async {
    final response = await ApiService.get('therapists/available');
    return _parseTherapistList(response);
  }

  // Get therapist by ID
  static Future<Therapist> getTherapistById(String id) async {
    final response = await ApiService.get('therapists/$id');
    return Therapist.fromJson(response);
  }

  // Search therapists
  static Future<List<Therapist>> searchTherapists(String keyword) async {
    final response = await ApiService.get('therapists/search?keyword=$keyword');
    return _parseTherapistList(response);
  }

  // Helper method to parse therapist list from response
  static List<Therapist> _parseTherapistList(dynamic response) {
    final List<dynamic> therapistsJson = response;
    return therapistsJson.map((json) => Therapist.fromJson(json)).toList();
  }
}
