import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../therapist_dashboard/therapist_service.dart';
import '../therapist_dashboard/booking_screen.dart';
import '../therapist_dashboard/appointment_provider.dart';

class DoctorProfileScreen extends StatefulWidget {
  final String therapistId;

  const DoctorProfileScreen({
    Key? key,
    required this.therapistId,
  }) : super(key: key);

  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool _isLoading = true;
  late Therapist _therapist;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTherapistDetails();
  }

  Future<void> _fetchTherapistDetails() async {
    try {
      final therapist =
          await TherapistService.getTherapistById(widget.therapistId);
      setState(() {
        _therapist = therapist;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load therapist details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            // Enhanced App Bar with back button
            SafeArea(
              child: Padding(
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
            ),

            const SizedBox(height: 20),

            // Main Content with Enhanced UI
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: _fetchTherapistDetails,
                                    child: const Text('Retry'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          primaryColor, // Changed from primary to backgroundColor
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                const SizedBox(height: 30),
                                // Therapist Image with Enhanced Styling
                                Container(
                                  height: 180,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.2),
                                        blurRadius: 25,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: _therapist.imageUrl.isNotEmpty
                                        ? Image.network(
                                            _therapist.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 80,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.person,
                                              size: 80,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Therapist Name and Specialty with Enhanced Typography
                                Text(
                                  _therapist.name,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primaryColor, accentColor],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _therapist.specialty,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Enhanced Ratings Section
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: List.generate(
                                          5,
                                          (index) => Icon(
                                            Icons.star,
                                            color: index <
                                                    _therapist.rating.floor()
                                                ? const Color(0xFFFFB237)
                                                : Colors.grey[300],
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        _therapist.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        ' (${_therapist.totalReviews} reviews)',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Enhanced About Section
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'About',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color:
                                                  primaryColor.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.verified,
                                                  size: 16,
                                                  color: primaryColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Verified',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _therapist.description,
                                        style: const TextStyle(
                                          color: Color(0xFF757F8C),
                                          height: 1.6,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 30),

                                      // Enhanced Experience Section
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.03),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            _buildExperienceItem(
                                                '${_therapist.experience}+',
                                                'Years\nExperience',
                                                primaryColor),
                                            _buildDivider(),
                                            _buildExperienceItem(
                                                '${_therapist.clientsHelped}+',
                                                'Happy\nClients',
                                                accentColor),
                                            _buildDivider(),
                                            _buildExperienceItem(
                                                _therapist.rating
                                                    .toStringAsFixed(1),
                                                'Rating\nScore',
                                                tertiaryColor),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 30),

                                      // Direct Appointment Button - UPDATED WITH PROVIDER
                                      GestureDetector(
                                        onTap: () {
                                          // Currently hardcoded user info - in a real app, you'd get this from auth
                                          final userId = "user123";
                                          final userEmail = "user@example.com";
                                          final userName = "John Doe";

                                          // Access the AppointmentProvider and navigate to BookingScreen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChangeNotifierProvider.value(
                                                // Use the existing provider instance
                                                value: Provider.of<
                                                        AppointmentProvider>(
                                                    context,
                                                    listen: false),
                                                child: BookingScreen(
                                                  therapistId: _therapist.id,
                                                  therapistName:
                                                      _therapist.name,
                                                  userId: userId,
                                                  userEmail: userEmail,
                                                  userName: userName,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: 60,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                primaryColor,
                                                accentColor,
                                                tertiaryColor
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryColor
                                                    .withOpacity(0.3),
                                                blurRadius: 15,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Make an appointment',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
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
      ),
    );
  }

  Widget _buildExperienceItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }
}
