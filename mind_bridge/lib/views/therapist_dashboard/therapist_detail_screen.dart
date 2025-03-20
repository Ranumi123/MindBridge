// import 'package:flutter/material.dart';
// import '../therapist_dashboard/booking_screen.dart';
// import '../models/therapist_model.dart';

// class TherapistDetailScreen extends StatelessWidget {
//   final Therapist therapist;

//   TherapistDetailScreen({required this.therapist});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(therapist.name)),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Image.network(therapist.imageUrl, height: 150, width: 150),
//             SizedBox(height: 10),
//             Text(therapist.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             Text(therapist.specialty, style: TextStyle(fontSize: 18, color: Colors.grey)),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(therapist: therapist)));
//               },
//               child: Text('Book Appointment'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
