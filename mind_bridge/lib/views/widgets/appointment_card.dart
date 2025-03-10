import 'package:flutter/material.dart';
import '../models/appoinment_model.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(appointment.therapist),
        subtitle: Text(appointment.date.toString()),
      ),
    );
  }
}
