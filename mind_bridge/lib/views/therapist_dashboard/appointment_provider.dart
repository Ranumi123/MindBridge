import 'package:flutter/material.dart';
import '../therapist_dashboard/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter appointments by status
  List<Appointment> getAppointmentsByStatus(String status) {
    return _appointments
        .where((appointment) => appointment.status == status)
        .toList();
  }

  // Load user's appointments
  Future<void> loadUserAppointments(String userId) async {
    _setLoading(true);

    try {
      final appointments = await AppointmentService.getUserAppointments(userId);
      _appointments = appointments;
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading appointments: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Book a new appointment
  Future<Appointment?> bookAppointment({
    required String therapistId,
    required String userId,
    required String startTime,
    required String endTime,
    required String name,
    required String email,
    String? notes,
  }) async {
    _setLoading(true);

    try {
      final appointment = await AppointmentService.createAppointment(
        therapistId: therapistId,
        userId: userId,
        startTime: startTime,
        endTime: endTime,
        name: name,
        email: email,
        notes: notes,
      );

      // Add the new appointment to the list
      _appointments.add(appointment);
      _error = null;

      return appointment;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error booking appointment: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel an appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    _setLoading(true);

    try {
      await AppointmentService.cancelAppointment(appointmentId);

      // Update the appointment status in the local list
      final index = _appointments
          .indexWhere((appointment) => appointment.id == appointmentId);
      if (index != -1) {
        // Create a new list to trigger state updates properly
        final updatedAppointments = List<Appointment>.from(_appointments);

        // This is a simplification since we can't modify the appointment directly
        // In a real app, you'd fetch the updated appointment or create a new one
        _appointments = updatedAppointments
            .where((appointment) => appointment.id != appointmentId)
            .toList();
        notifyListeners();
      }

      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error cancelling appointment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reschedule an appointment
  Future<Appointment?> rescheduleAppointment(
      String appointmentId, String newStartTime, String newEndTime) async {
    _setLoading(true);

    try {
      final updatedAppointment = await AppointmentService.rescheduleAppointment(
          appointmentId, newStartTime, newEndTime);

      // Update the appointment in the local list
      final index = _appointments
          .indexWhere((appointment) => appointment.id == appointmentId);
      if (index != -1) {
        // Create a new list to trigger state updates properly
        final updatedAppointments = List<Appointment>.from(_appointments);
        updatedAppointments[index] = updatedAppointment;
        _appointments = updatedAppointments;
      }

      _error = null;
      return updatedAppointment;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error rescheduling appointment: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
