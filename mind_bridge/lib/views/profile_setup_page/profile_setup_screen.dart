import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  bool enableNotifications = true;
  bool anonymousMode = false;
  bool allowDataSharing = true;
  bool enableEncryption = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, const Color(0xFFF5F9FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Custom SliverAppBar with subtle gradient
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF39B0E5), const Color(0xFF1ED4B5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                'Profile',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.settings_outlined, color: Colors.white, size: 18),
                  ),
                  onPressed: () {
                    // Show settings
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Profile content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // Profile picture and info
                    Row(
                      children: [
                        // Profile picture
                        Hero(
                          tag: 'profile-picture',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: 'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                  width: 76,
                                  height: 76,
                                  placeholder: (context, url) => const CircularProgressIndicator(
                                    color: Color(0xFF39B0E5),
                                    strokeWidth: 2,
                                  ),
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Color(0xFF39B0E5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Name and bio
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'John Doe',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              Text(
                                'Mental Health Advocate',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton(
                                onPressed: () {
                                  // Edit profile
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: const Color(0xFF39B0E5)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: Text(
                                  'Edit Profile',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF39B0E5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Professional info card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Professional Information',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildInfoItem(Icons.business, 'Organization', 'Mindfulness Institute'),
                            const Divider(height: 20),
                            _buildInfoItem(Icons.location_on_outlined, 'Location', 'San Francisco, CA'),
                            const Divider(height: 20),
                            _buildInfoItem(Icons.email_outlined, 'Email', 'john.doe@example.com'),
                            const Divider(height: 20),
                            _buildInfoItem(Icons.phone_outlined, 'Phone', '+1 (555) 123-4567'),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms),

                    const SizedBox(height: 30),

                    // Tabs for Settings
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: const Color(0xFF39B0E5),
                                  width: 3,
                                ),
                              ),
                            ),
                            labelColor: const Color(0xFF39B0E5),
                            unselectedLabelColor: Colors.grey.shade600,
                            labelStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            tabs: const [
                              Tab(text: 'Account'),
                              Tab(text: 'Privacy'),
                              Tab(text: 'Notifications'),
                            ],
                          ),

                          SizedBox(
                            height: 380, // Fixed height for the tab content
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Account Tab
                                _buildSettingsTab([
                                  _buildPreferenceItem(
                                    'Account Information',
                                    'View and edit your personal details',
                                    Icons.person_outline,
                                    onTap: () {},
                                  ),
                                  _buildPreferenceItem(
                                    'Password & Security',
                                    'Manage your password and security options',
                                    Icons.lock_outline,
                                    onTap: () {},
                                  ),
                                  _buildPreferenceItem(
                                    'Linked Accounts',
                                    'Connect to other services',
                                    Icons.link,
                                    onTap: () {},
                                  ),
                                  _buildPreferenceItem(
                                    'Language',
                                    'English (US)',
                                    Icons.language,
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Color(0xFF39B0E5),
                                    ),
                                    onTap: () {},
                                  ),
                                ]),

                                // Privacy Tab
                                _buildSettingsTab([
                                  _buildPreferenceSwitch(
                                    'Anonymous Mode',
                                    'Hide your profile from others',
                                    Icons.visibility_off_outlined,
                                    anonymousMode,
                                        (newValue) {
                                      setState(() {
                                        anonymousMode = newValue;
                                      });
                                    },
                                  ),
                                  _buildPreferenceSwitch(
                                    'Allow Data Sharing',
                                    'Share usage data to improve the app',
                                    Icons.share_outlined,
                                    allowDataSharing,
                                        (newValue) {
                                      setState(() {
                                        allowDataSharing = newValue;
                                      });
                                    },
                                  ),
                                  _buildPreferenceSwitch(
                                    'Enable Encryption',
                                    'End-to-end encryption for your data',
                                    Icons.enhanced_encryption_outlined,
                                    enableEncryption,
                                        (newValue) {
                                      setState(() {
                                        enableEncryption = newValue;
                                      });
                                    },
                                  ),
                                  _buildPreferenceItem(
                                    'Advanced Privacy Settings',
                                    'Manage your data and privacy controls',
                                    Icons.security,
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Color(0xFF39B0E5),
                                    ),
                                    onTap: () {
                                      Navigator.pushNamed(context, '/privacy_settings');
                                    },
                                  ),
                                ]),

                                // Notifications Tab
                                _buildSettingsTab([
                                  _buildPreferenceSwitch(
                                    'Enable Notifications',
                                    'Receive alerts about new features',
                                    Icons.notifications_outlined,
                                    enableNotifications,
                                        (newValue) {
                                      setState(() {
                                        enableNotifications = newValue;
                                      });
                                    },
                                  ),
                                  _buildPreferenceItem(
                                    'Email Notifications',
                                    'Manage email notification preferences',
                                    Icons.email_outlined,
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Color(0xFF39B0E5),
                                    ),
                                    onTap: () {},
                                  ),
                                  _buildPreferenceItem(
                                    'Push Notifications',
                                    'Manage mobile push notification preferences',
                                    Icons.mobile_friendly_outlined,
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Color(0xFF39B0E5),
                                    ),
                                    onTap: () {},
                                  ),
                                  _buildPreferenceItem(
                                    'Do Not Disturb',
                                    'Set quiet hours for notifications',
                                    Icons.do_not_disturb_on_outlined,
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Color(0xFF39B0E5),
                                    ),
                                    onTap: () {},
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Log out button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Log out
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.grey.shade700,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          'Log Out',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF39B0E5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF39B0E5),
            size: 20,
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsTab(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      ),
    );
  }

  Widget _buildPreferenceItem(
      String title,
      String subtitle,
      IconData icon, {
        Widget? trailing,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF39B0E5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF39B0E5),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildPreferenceSwitch(
      String title,
      String subtitle,
      IconData icon,
      bool value,
      Function(bool) onChanged,
      ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF39B0E5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF39B0E5),
            size: 20,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF39B0E5),
        activeTrackColor: const Color(0xFF39B0E5).withOpacity(0.2),
        inactiveTrackColor: Colors.grey.shade300,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}