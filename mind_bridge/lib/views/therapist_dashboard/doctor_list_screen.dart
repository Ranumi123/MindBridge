import 'package:flutter/material.dart';
import '../models/therapist_model.dart';
import '../widgets/doctor_card.dart';

class DoctorListScreen extends StatelessWidget {
  final List<Therapist> doctors = [
    Therapist(
      name: 'Dr. Diwanga',
      specialty: 'Psychiatrist',
      imageUrl: 'assets/images/doctor1.png',
    ),
    Therapist(
      name: 'Dr. Ranumi',
      specialty: 'Therapist',
      imageUrl: 'assets/images/doctor2.png',
    ),
    Therapist(
      name: 'Dr. Kavindu',
      specialty: 'Psychologist',
      imageUrl: 'assets/images/doctor3.png',
    ),
    Therapist(
      name: 'Dr. Samanthi',
      specialty: 'Mental Health Specialist',
      imageUrl: 'assets/images/doctor4.png',
    ),
    Therapist(
      name: 'Dr. Fernando',
      specialty: 'Clinical Therapist',
      imageUrl: 'assets/images/doctor5.png',
    ),
    Therapist(
      name: 'Dr. Perera',
      specialty: 'Neurologist',
      imageUrl: 'assets/images/doctor6.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen width to determine layout
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Find a Specialist Doctor'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Rated Doctors',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Responsive Grid/List Layout
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // If screen width > 600px (Tablet), use a Grid
                  bool isTablet = screenWidth > 600;

                  return isTablet
                      ? GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Two doctors per row on tablets
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8, // Adjust for better height
                          ),
                          itemCount: doctors.length,
                          itemBuilder: (context, index) {
                            return DoctorCard(therapist: doctors[index]);
                          },
                        )
                      : ListView.builder(
                          itemCount: doctors.length,
                          itemBuilder: (context, index) {
                            return DoctorCard(therapist: doctors[index]);
                          },
                        );
                },
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
