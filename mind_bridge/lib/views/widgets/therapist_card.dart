// Therapist Card Widget
import 'package:flutter/material.dart';
import '../models/therapist_model.dart';
import '../therapist_dashboard/therapist_detail_screen.dart';

class TherapistCard extends StatelessWidget {
  final Therapist therapist;

  TherapistCard({required this.therapist});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(therapist.imageUrl, width: 50, height: 50),
        title: Text(therapist.name),
        subtitle: Text(therapist.specialty),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TherapistDetailScreen(therapist: therapist)),
          );
        },
      ),
    );
  }
}
