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
}

class Appointment {
  final String id;
  final String userId;
  final String therapistId;
  final String therapistName;
  final String therapistSpecialty;
  final String therapistImageUrl;
  final DateTime appointmentTime;
  final int duration;
  final String status;
  final String notes;
  final String calComBookingId;

  Appointment({
    required this.id,
    required this.userId,
    required this.therapistId,
    required this.therapistName,
    required this.therapistSpecialty,
    required this.therapistImageUrl,
    required this.appointmentTime,
    required this.duration,
    required this.status,
    required this.notes,
    required this.calComBookingId,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'],
      userId: json['user'],
      therapistId: json['therapist']['_id'],
      therapistName: json['therapist']['name'],
      therapistSpecialty: json['therapist']['specialty'],
      therapistImageUrl: json['therapist']['imageUrl'],
      appointmentTime: DateTime.parse(json['appointmentTime']),
      duration: json['duration'],
      status: json['status'],
      notes: json['notes'],
      calComBookingId: json['calComBookingId'],
    );
  }
}

class AppointmentService {
  // Get available time slots for a therapist
  static Future<List<TimeSlot>> getAvailableSlots(
      String therapistId, String date) async {
    final response = await ApiService.get(
        'appointments/available-slots?therapistId=$therapistId&date=$date');

    final List<dynamic> slotsJson = response;
    return slotsJson.map((json) => TimeSlot.fromJson(json)).toList();
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
    final response = await ApiService.post('appointments', {
      'therapistId': therapistId,
      'userId': userId,
      'startTime': startTime,
      'endTime': endTime,
      'name': name,
      'email': email,
      'notes': notes,
      'timeZone': timeZone ?? 'UTC',
    });

    return Appointment.fromJson(response);
  }

  // Get appointment by ID
  static Future<Appointment> getAppointmentById(String id) async {
    final response = await ApiService.get('appointments/$id');
    return Appointment.fromJson(response);
  }

  // Get user's appointments
  static Future<List<Appointment>> getUserAppointments(String userId) async {
    final response = await ApiService.get('appointments/user/$userId');

    final List<dynamic> appointmentsJson = response;
    return appointmentsJson.map((json) => Appointment.fromJson(json)).toList();
  }

  // Cancel appointment
  static Future<void> cancelAppointment(String id) async {
    await ApiService.put('appointments/cancel/$id', {});
  }

  // Reschedule appointment
  static Future<Appointment> rescheduleAppointment(
      String id, String newStartTime, String newEndTime) async {
    final response = await ApiService.put('appointments/reschedule/$id', {
      'newStartTime': newStartTime,
      'newEndTime': newEndTime,
    });

    return Appointment.fromJson(response);
  }
}
