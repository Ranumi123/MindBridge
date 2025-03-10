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
            colors: [Colors.white, Colors.lightBlue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // AppBar with Gradient
                AppBar(
                  title: Text(
                    'Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  iconTheme: IconThemeData(color: Colors.blueAccent),
                ),

                const SizedBox(height: 20),

                // Profile Picture with Hero Animation
                Hero(
                  tag: 'profile-picture',
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://via.placeholder.com/150', // Replace with user's profile picture URL
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
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
                    color: Colors.blueAccent,
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

                // Edit Profile Button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to edit profile page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: Colors.blueAccent.withOpacity(0.3),
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
              ],
            ),
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
          color: Colors.blueAccent,
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
        activeColor: Colors.blueAccent,
        inactiveTrackColor: Colors.grey.shade300,
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.5);
  }
}
