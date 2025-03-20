// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF5D5FEF),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Top Bar
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Icon(Icons.menu, color: Colors.white),
//                   const Icon(Icons.add, color: Colors.white),
//                   CircleAvatar(
//                     radius: 16,
//                     backgroundColor: Colors.white,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: Image.asset('assets/images/profile.png'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Search Bar
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Container(
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Row(
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.only(left: 16.0),
//                       child: Icon(Icons.search, color: Colors.grey),
//                     ),
//                     const SizedBox(width: 8),
//                     const Expanded(
//                       child: TextField(
//                         decoration: InputDecoration(
//                           hintText: 'Search...',
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 16.0),
//                       child: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Icon(Icons.filter_list, color: Colors.grey),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Main Content Area (White Background)
//             Expanded(
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFF4F6FA),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(30),
//                     topRight: Radius.circular(30),
//                   ),
//                 ),
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Popular Doctor Section
//                       const Text(
//                         'Popular Doctor',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           children: [
//                             _buildPopularDoctorCard(
//                               'DR. ALEXA',
//                               'assets/images/doctor1.png',
//                             ),
//                             const SizedBox(width: 16),
//                             _buildPopularDoctorCard(
//                               'DR. JAMES',
//                               'assets/images/doctor2.png',
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       // Specialist Section
//                       const Text(
//                         'Find a doctor with specialist',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           _buildSpecialistButton(
//                               'General Practitioner', Icons.medical_services),
//                           _buildSpecialistButton(
//                               'Dental Surgeon', Icons.medical_information),
//                         ],
//                       ),

//                       const SizedBox(height: 24),

//                       // Top Doctor Section
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: const [
//                           Text(
//                             'Top Doctor',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             'See All',
//                             style: TextStyle(
//                               color: Colors.grey,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       _buildTopDoctorCard(
//                         context,
//                         'Dr. Jonathan',
//                         'Pediatrician',
//                         'assets/images/doctor3.png',
//                       ),
//                       const SizedBox(height: 12),
//                       _buildTopDoctorCard(
//                         context,
//                         'Dr. Jenny',
//                         'Cardiologist',
//                         'assets/images/doctor4.png',
//                       ),
//                       const SizedBox(height: 12),
//                       _buildTopDoctorCard(
//                         context,
//                         'Dr. Jensen',
//                         'Neurologist',
//                         'assets/images/doctor5.png',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPopularDoctorCard(String name, String imagePath) {
//     return Container(
//       width: 150,
//       height: 180,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             radius: 40,
//             backgroundColor: Colors.grey[200],
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(40),
//               child: Image.asset(imagePath),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             name,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSpecialistButton(String title, IconData icon) {
//     return Container(
//       width: 160,
//       height: 60,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             color: const Color(0xFF5D5FEF),
//           ),
//           const SizedBox(width: 8),
//           Flexible(
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTopDoctorCard(
//       BuildContext context, String name, String specialty, String imagePath) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DoctorProfileScreen(
//               name: name,
//               specialty: specialty,
//               imagePath: imagePath
//             ),
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundColor: Colors.grey[200],
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(30),
//                 child: Image.asset(imagePath),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   specialty,
//                   style: const TextStyle(
//                     color: Colors.grey,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//             const Spacer(),
//             Row(
//               children: List.generate(
//                 5,
//                 (index) => const Icon(
//                   Icons.star,
//                   color: Color(0xFFFFB237),
//                   size: 16,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class DoctorProfileScreen extends StatelessWidget {
//   final String name;
//   final String specialty;
//   final String imagePath;

//   const DoctorProfileScreen({
//     Key? key,
//     required this.name,
//     required this.specialty,
//     required this.imagePath,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF5D5FEF),
//       body: Column(
//         children: [
//           // App Bar
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(
//                         Icons.arrow_back_ios_new,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                   const Expanded(
//                     child: Center(
//                       child: Text(
//                         'Doctor',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Main Content
//           Expanded(
//             child: Container(
//               decoration: const BoxDecoration(
//                 color: Color(0xFFF4F6FA),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   topRight: Radius.circular(30),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 24),
//                     // Doctor Image
//                     Container(
//                       height: 180,
//                       width: 180,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 20,
//                             offset: const Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Image.asset(
//                           imagePath,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // Doctor Name and Specialty
//                     Text(
//                       name == 'Dr. Jonathan' ? 'Dr. John Smith' : name,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       specialty,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Ratings
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Row(
//                           children: List.generate(
//                             5,
//                             (index) => const Icon(
//                               Icons.star,
//                               color: Color(0xFFFFB237),
//                               size: 20,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         const Text(
//                           '(124 reviews)',
//                           style: TextStyle(
//                             color: Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         const Text(
//                           'See all reviews',
//                           style: TextStyle(
//                             color: Color(0xFF5D5FEF),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),

//                     // About Section
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'About',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'Dr. Smith is a specialist in general medicine and has over 10 years of experience. They hold an MBBS degree, along with a post-graduate qualification in internal medicine. Their expertise includes diagnosing and treating a wide range of health conditions.',
//                             style: TextStyle(
//                               color: Colors.grey,
//                               height: 1.5,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           const Text(
//                             'See More',
//                             style: TextStyle(
//                               color: Color(0xFF5D5FEF),
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: 40),

//                           // Contact Buttons
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Container(
//                                   margin: const EdgeInsets.only(right: 8),
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(16),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.05),
//                                         blurRadius: 10,
//                                         offset: const Offset(0, 5),
//                                       ),
//                                     ],
//                                   ),
//                                   child: const Center(
//                                     child: Icon(
//                                       Icons.email_outlined,
//                                       color: Color(0xFF5D5FEF),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Container(
//                                   margin: const EdgeInsets.only(left: 8),
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(16),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.05),
//                                         blurRadius: 10,
//                                         offset: const Offset(0, 5),
//                                       ),
//                                     ],
//                                   ),
//                                   child: const Center(
//                                     child: Icon(
//                                       Icons.phone,
//                                       color: Color(0xFF5D5FEF),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 24),

//                           // Appointment Button
//                           Container(
//                             height: 60,
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF5D5FEF),
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: const Color(0xFF5D5FEF).withOpacity(0.3),
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 5),
//                                 ),
//                               ],
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 'Make an appointment',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D5FEF),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, color: Colors.white),
                  const Icon(Icons.add, color: Colors.white),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset('assets/images/profile.jpg'),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Icon(Icons.search, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.filter_list,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Main Content Area (White Background)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Popular Doctor Section
                      const Text(
                        'Popular Doctor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPopularDoctorCard(
                              'DR. ALEXA',
                              'assets/images/doctor1.png',
                            ),
                            const SizedBox(width: 16),
                            _buildPopularDoctorCard(
                              'DR. JAMES',
                              'assets/images/doctor2.png',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Specialist Section
                      const Text(
                        'Find a doctor with specialist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSpecialistButton(
                            'General Practitioner',
                            Icons.medical_services,
                          ),
                          _buildSpecialistButton(
                            'Dental Surgeon',
                            Icons.medical_information,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Top Doctor Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Top Doctor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'See All',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTopDoctorCard(
                        context,
                        'Dr. Jonathan',
                        'Pediatrician',
                        'assets/images/doctor3.png',
                      ),
                      const SizedBox(height: 12),
                      _buildTopDoctorCard(
                        context,
                        'Dr. Jenny',
                        'Cardiologist',
                        'assets/images/doctor4.png',
                      ),
                      const SizedBox(height: 12),
                      _buildTopDoctorCard(
                        context,
                        'Dr. Jensen',
                        'Neurologist',
                        'assets/images/doctor5.png',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularDoctorCard(String name, String imagePath) {
    return Container(
      width: 150,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200],
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(imagePath),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialistButton(String title, IconData icon) {
    return Container(
      width: 160,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF5D5FEF)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDoctorCard(
    BuildContext context,
    String name,
    String specialty,
    String imagePath,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DoctorProfileScreen(
                  name: name,
                  specialty: specialty,
                  imagePath: imagePath,
                ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(imagePath),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specialty,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: List.generate(
                5,
                (index) =>
                    const Icon(Icons.star, color: Color(0xFFFFB237), size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorProfileScreen extends StatelessWidget {
  final String name;
  final String specialty;
  final String imagePath;

  const DoctorProfileScreen({
    Key? key,
    required this.name,
    required this.specialty,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D5FEF),
      body: Column(
        children: [
          // App Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Doctor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Main Content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F6FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Doctor Image
                    Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(imagePath, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Doctor Name and Specialty
                    Text(
                      name == 'Dr. Jonathan' ? 'Dr. John Smith' : name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      specialty,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Ratings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => const Icon(
                              Icons.star,
                              color: Color(0xFFFFB237),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '(124 reviews)',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'See all reviews',
                          style: TextStyle(
                            color: Color(0xFF5D5FEF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // About Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Dr. Smith is a specialist in general medicine and has over 10 years of experience. They hold an MBBS degree, along with a post-graduate qualification in internal medicine. Their expertise includes diagnosing and treating a wide range of health conditions.',
                            style: TextStyle(color: Colors.grey, height: 1.5),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'See More',
                            style: TextStyle(
                              color: Color(0xFF5D5FEF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Contact Buttons
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.email_outlined,
                                      color: Color(0xFF5D5FEF),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.phone,
                                      color: Color(0xFF5D5FEF),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Appointment Button
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5D5FEF),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF5D5FEF,
                                  ).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Make an appointment',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
