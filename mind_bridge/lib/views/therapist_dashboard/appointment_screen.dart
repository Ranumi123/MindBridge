import 'package:flutter/material.dart';
import '../therapist_dashboard/doctor_profile_screen.dart';
import '../therapist_dashboard/therapist_service.dart'; // Add this import

class AppointmentScreen extends StatefulWidget {
  // Changed to StatefulWidget
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  bool _isLoading = true;
  List<Therapist> _therapists = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTherapists();
  }

  Future<void> _fetchTherapists() async {
    try {
      final therapists = await TherapistService.getAllTherapists();
      setState(() {
        _therapists = therapists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load therapists: $e';
        _isLoading = false;
      });
      print('Error fetching therapists: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the gradient colors
    final primaryColor = const Color(0xFF4B9FE1);
    final accentColor = const Color(0xFF1EBBD7);
    final tertiaryColor = const Color(0xFF20E4B5);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, accentColor, tertiaryColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced App Bar with only back button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Enhanced Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Icon(Icons.search,
                            color: Color(0xFF4B9FE1), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search therapists...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 10.0),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.filter_list,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Main Content Area (Enhanced Background)
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage.isNotEmpty
                            ? Center(child: Text(_errorMessage))
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Popular Therapist Section
                                    const Text(
                                      'Popular Therapists',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: _getPopularTherapists()
                                            .map((therapist) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: _buildPopularDoctorCard(
                                              therapist.name,
                                              therapist.specialty,
                                              therapist.rating.toString(),
                                              therapist.imageUrl.isNotEmpty
                                                  ? therapist.imageUrl
                                                  : 'assets/images/doctor1.png',
                                              primaryColor,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // Available Therapists Section
                                    const Text(
                                      'Available Therapists',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Column(
                                      children: _getAvailableTherapists()
                                          .map((therapist) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 16.0),
                                          child: _buildTopDoctorCard(
                                            context,
                                            therapist.name,
                                            therapist.specialty,
                                            therapist.rating.toString(),
                                            therapist.imageUrl.isNotEmpty
                                                ? therapist.imageUrl
                                                : 'assets/images/doctor3.png',
                                            primaryColor,
                                            accentColor,
                                            therapist.id,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods to filter therapists
  List<Therapist> _getPopularTherapists() {
    final popularTherapists = _therapists.where((t) => t.isPopular).toList();

    // If no popular therapists in DB, return default ones
    if (popularTherapists.isEmpty) {
      return [
        Therapist(
          id: 'default_1',
          name: 'DR. ALEXA',
          specialty: 'Clinical Psychologist',
          rating: 4.9,
          totalReviews: 120,
          description: 'Experienced therapist',
          experience: 8,
          clientsHelped: 350,
          imageUrl: '',
          isPopular: true,
          isAvailable: true,
          calComUserId: 'default',
          calComEventTypeId: 'default',
        ),
        Therapist(
          id: 'default_2',
          name: 'DR. JAMES',
          specialty: 'Psychiatrist',
          rating: 4.8,
          totalReviews: 110,
          description: 'Experienced psychiatrist',
          experience: 7,
          clientsHelped: 320,
          imageUrl: '',
          isPopular: true,
          isAvailable: true,
          calComUserId: 'default',
          calComEventTypeId: 'default',
        ),
      ];
    }

    return popularTherapists;
  }

  List<Therapist> _getAvailableTherapists() {
    final availableTherapists =
        _therapists.where((t) => t.isAvailable).toList();

    // If no available therapists in DB, return default ones
    if (availableTherapists.isEmpty) {
      return [
        Therapist(
          id: 'therapist_id_1', // Use the ID you mentioned
          name: 'Dr. Emily Smith',
          specialty: 'Psychotherapist',
          rating: 4.9,
          totalReviews: 124,
          description:
              'Dr. Smith is a licensed therapist with over 10 years of experience.',
          experience: 10,
          clientsHelped: 500,
          imageUrl: '',
          isPopular: false,
          isAvailable: true,
          calComUserId: 'default',
          calComEventTypeId: 'default',
        ),
        Therapist(
          id: 'therapist_id_2',
          name: 'Dr. Jenny Wilson',
          specialty: 'Clinical Psychologist',
          rating: 4.8,
          totalReviews: 118,
          description: 'Experienced clinical psychologist.',
          experience: 9,
          clientsHelped: 450,
          imageUrl: '',
          isPopular: false,
          isAvailable: true,
          calComUserId: 'default',
          calComEventTypeId: 'default',
        ),
      ];
    }

    return availableTherapists;
  }

  Widget _buildPopularDoctorCard(
    String name,
    String specialty,
    String rating,
    String imagePath,
    Color primaryColor,
  ) {
    return Container(
      width: 160,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.grey[200],
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(42),
                    child: imagePath.startsWith('assets/')
                        ? Image.asset(imagePath)
                        : imagePath.isNotEmpty
                            ? Image.network(
                                imagePath,
                                errorBuilder: (ctx, error, _) => Icon(
                                    Icons.person,
                                    size: 42,
                                    color: Colors.grey),
                              )
                            : Icon(Icons.person, size: 42, color: Colors.grey),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            specialty,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopDoctorCard(
    BuildContext context,
    String name,
    String specialty,
    String rating,
    String imagePath,
    Color primaryColor,
    Color accentColor,
    String therapistId,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorProfileScreen(
              therapistId: therapistId,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[200],
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: imagePath.startsWith('assets/')
                      ? Image.asset(imagePath)
                      : imagePath.isNotEmpty
                          ? Image.network(
                              imagePath,
                              errorBuilder: (ctx, error, _) => Icon(
                                  Icons.person,
                                  size: 35,
                                  color: Colors.grey),
                            )
                          : Icon(Icons.person, size: 35, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star,
                          color: const Color(0xFFFFB237), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(124)',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
