import 'package:flutter/foundation.dart';
import '../therapist_dashboard/api_service.dart';

class TimeSlot {
  final String startTime;
  final String endTime;

  TimeSlot({required this.startTime, required this.endTime});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

class Appointment {
  final String id;
  final String userId;
  final Map<String, dynamic> therapist;
  final DateTime appointmentTime;
  final int duration;
  final String status;
  final String notes;
  final String calComBookingId;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.therapist,
    required this.appointmentTime,
    required this.duration,
    required this.status,
    required this.notes,
    required this.calComBookingId,
    required this.createdAt,
  });

  // Getters for therapist data to match the UI requirements
  String get therapistId => therapist['_id'] ?? '';
  String get therapistName => therapist['name'] ?? 'Unknown Therapist';
  String get therapistSpecialty => therapist['specialty'] ?? 'Specialist';
  String get therapistImageUrl => therapist['imageUrl'] ?? '';

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] ?? '',
      userId: json['user'] ?? json['userId'] ?? '',
      therapist: json['therapist'] ?? {},
      appointmentTime: json['appointmentTime'] != null
          ? DateTime.parse(json['appointmentTime'])
          : DateTime.now(),
      duration: json['duration'] ?? 60,
      status: json['status'] ?? 'scheduled',
      notes: json['notes'] ?? '',
      calComBookingId: json['calComBookingId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class AppointmentService {
  static const String _baseEndpoint = 'appointments';

  // Get available time slots for a therapist
  static Future<List<TimeSlot>> getAvailableSlots(
      String therapistId, String date) async {
    try {
      debugPrint(
          'Fetching available slots for therapist $therapistId on $date');

      final response =
          await ApiService.get('$_baseEndpoint/available-slots', queryParams: {
        'therapistId': therapistId,
        'date': date,
      });

      debugPrint('Available slots response: $response');

      final List<dynamic> slotsJson = response;
      return slotsJson.map((json) => TimeSlot.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching available slots: $e');
      rethrow;
    }
  }

  // Create new appointment
  static Future<Appointment> createAppointment({
    required String therapistId,
    required String userId,
    required String startTime,
    required String endTime,
    required String name,
    required String email,
    String? notes,
    String? timeZone,
  }) async {
    try {
      debugPrint(
          'Creating appointment for therapist $therapistId, user $userId');
      debugPrint('Time: $startTime to $endTime');

      final response = await ApiService.post(_baseEndpoint, {
        'therapistId': therapistId,
        'userId': userId,
        'startTime': startTime,
        'endTime': endTime,
        'name': name,
        'email': email,
        'notes': notes ?? '',
        'timeZone': timeZone ?? 'UTC',
      });

      debugPrint('Create appointment response: $response');

      return Appointment.fromJson(response);
    } catch (e) {
      debugPrint('Error creating appointment: $e');
      rethrow;
    }
  }

  // Get appointment by ID
  static Future<Appointment> getAppointmentById(String id) async {
    try {
      debugPrint('Fetching appointment details for ID: $id');

      final response = await ApiService.get('$_baseEndpoint/$id');

      debugPrint('Appointment details response: $response');

      return Appointment.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching appointment details: $e');
      rethrow;
    }
  }

  // Get user's appointments
  static Future<List<Appointment>> getUserAppointments(String userId) async {
    try {
      debugPrint('Fetching appointments for user $userId');

      final response = await ApiService.get('$_baseEndpoint/user/$userId');

      debugPrint(
          'User appointments response: ${response.length} appointments found');

      final List<dynamic> appointmentsJson = response;
      return appointmentsJson
          .map((json) => Appointment.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user appointments: $e');
      rethrow;
    }
  }

  // Cancel appointment
  static Future<Map<String, dynamic>> cancelAppointment(String id) async {
    try {
      debugPrint('Cancelling appointment $id');

      final response = await ApiService.put('$_baseEndpoint/cancel/$id', {});

      debugPrint('Cancel appointment response: $response');

      return response;
    } catch (e) {
      debugPrint('Error cancelling appointment: $e');
      rethrow;
    }
  }

  // Reschedule appointment
  static Future<Appointment> rescheduleAppointment(
      String id, String newStartTime, String newEndTime) async {
    try {
      debugPrint('Rescheduling appointment $id to $newStartTime - $newEndTime');

      final response = await ApiService.put('$_baseEndpoint/reschedule/$id', {
        'newStartTime': newStartTime,
        'newEndTime': newEndTime,
      });

      debugPrint('Reschedule appointment response: $response');

      return Appointment.fromJson(response);
    } catch (e) {
      debugPrint('Error rescheduling appointment: $e');
      rethrow;
    }
  }
}

// Make sure to import this at the top of the file
