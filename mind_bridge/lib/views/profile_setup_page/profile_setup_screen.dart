import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool enableNotifications = true;
  bool anonymousMode = false;
  bool allowDataSharing = true;
  bool enableEncryption = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0F7FA)], // Changed to match the app's teal theme
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Custom AppBar with Gradient and Back Button
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 16, right: 16, bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF39B0E5), Color(0xFF1ED4B5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      'Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 40), // Balance the spacing
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Profile Picture with Hero Animation
              Hero(
                tag: 'profile-picture',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF39B0E5).withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF39B0E5).withOpacity(0.1),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: 'https://via.placeholder.com/150', // Replace with user's profile picture URL
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                        placeholder: (context, url) => CircularProgressIndicator(
                          color: Color(0xFF39B0E5),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xFF39B0E5),
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).scale(),

              const SizedBox(height: 20),

              // Display Name
              Text(
                'John Doe',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF39B0E5),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.5),

              const SizedBox(height: 10),

              // Bio
              Text(
                'Mental Health Advocate | Lover of Mindfulness',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.5),

              const SizedBox(height: 30),

              // Preferences Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildSectionTitle('Preferences'),
                    _buildPreferenceSwitch(
                        'Enable Notifications', enableNotifications, (newValue) {
                      setState(() {
                        enableNotifications = newValue;
                      });
                    }),
                    _buildPreferenceSwitch('Anonymous Mode', anonymousMode,
                            (newValue) {
                          setState(() {
                            anonymousMode = newValue;
                          });
                        }),

                    const SizedBox(height: 30),

                    // Privacy Settings Section
                    _buildSectionTitle('Privacy Settings'),
                    _buildPreferenceSwitch('Allow Data Sharing', allowDataSharing,
                            (newValue) {
                          setState(() {
                            allowDataSharing = newValue;
                          });
                        }),
                    _buildPreferenceSwitch('Enable Encryption', enableEncryption,
                            (newValue) {
                          setState(() {
                            enableEncryption = newValue;
                          });
                        }),

                    const SizedBox(height: 30),

                    // Link to Privacy Settings Page
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(
                          'Advanced Privacy Settings',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF39B0E5)),
                        onTap: () {
                          Navigator.pushNamed(context, '/privacy_settings');
                        },
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.5),

                    const SizedBox(height: 30),

                    // Edit Profile Button
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to edit profile page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF39B0E5), // Match app theme
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: Color(0xFF39B0E5).withOpacity(0.3),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.5),

                    // Add padding at the bottom to ensure everything is visible
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF39B0E5), // Match app theme
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.5);
  }

  Widget _buildPreferenceSwitch(
      String title, bool value, Function(bool) onChanged) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFF39B0E5), // Match app theme
        inactiveTrackColor: Colors.grey.shade300,
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.5);
  }
}