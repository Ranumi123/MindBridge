// import 'package:flutter/material.dart';
// import '../models/therapist_model.dart';
// import '../therapist_dashboard/booking_screen.dart';

// class DoctorCard extends StatelessWidget {
//   final Therapist therapist;

//   DoctorCard({required this.therapist});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 3,
//       child: ListTile(
//         leading: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.asset(
//             therapist.imageUrl, // Now it will use a local image path
//             width: 60,
//             height: 60,
//             fit: BoxFit.cover,
//           ),
//         ),

//         title: Text(
//           therapist.name,
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           therapist.specialty,
//           style: TextStyle(color: Colors.grey[600]),
//         ),
//         trailing: ElevatedButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => BookingScreen(therapist: therapist),
//               ),
//             );
//           },
//           child: Text('Channel Now'),
//         ),
//       ),
//     );
//   }
// }
