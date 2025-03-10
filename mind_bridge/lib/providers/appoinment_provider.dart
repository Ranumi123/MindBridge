import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../views/models/appoinment_model.dart';

class AppointmentProvider with ChangeNotifier {
  final List<Appointment> _appointments = [];

  List<Appointment> get appointments => _appointments;

  void addAppointment(String therapist, DateTime date) {
    final newAppointment = Appointment(
      id: Uuid().v4(),
      therapist: therapist,
      date: date,
    );

    _appointments.add(newAppointment);
    notifyListeners();
  }
}
