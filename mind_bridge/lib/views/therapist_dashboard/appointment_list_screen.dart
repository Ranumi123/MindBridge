import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appoinment_provider.dart';
import '../widgets/appointment_card.dart';

class AppointmentListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appointments =
        Provider.of<AppointmentProvider>(context).appointments;

    return Scaffold(
      appBar: AppBar(title: Text('Your Appointments')),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (ctx, i) => AppointmentCard(appointment: appointments[i]),
      ),
    );
  }
}
