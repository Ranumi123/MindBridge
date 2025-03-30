import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_bridge/views/welcome_screen/welcome_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User data and loading state
  Map<String, dynamic>? userData;
  bool isLoading = true;
  final String apiBaseUrl =
      'http://localhost:5001/api/auth'; // Replace with your actual API URL

  @override
  void initState() {
    super.initState();
    // Fetch user data when the page initializes
    _fetchUserData();
  }

  // Method to fetch user data
  Future<void> _fetchUserData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Retrieve user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userEmail = prefs.getString('user_email');
      final userName = prefs.getString('user_name');
      final userPhone = prefs.getString('user_phone');

      // Debug: Print stored user details
      print("Stored User Details:");
      print("ID: $userId");
      print("Email: $userEmail");
      print("Name: $userName");
      print("Phone: $userPhone");

      if (userId == null && userEmail == null) {
        throw Exception('User not logged in');
      }

      // Attempt to fetch user data from API
      final response = await http.get(
        Uri.parse('$apiBaseUrl/users/${userId ?? userEmail}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debug: Print API response
        print("API Response: $data");

        setState(() {
          userData = data;
          isLoading = false;
        });
      } else {
        print("API Request Failed - Status Code: ${response.statusCode}");

        // Fallback to locally stored data if API request fails
        setState(() {
          userData = {
            'id': userId,
            'name': userName,
            'email': userEmail,
            'phone':
                userPhone?.isNotEmpty == true ? userPhone : "Not specified",
            'organization':
                prefs.getString('user_organization') ?? "Not specified",
            'location': prefs.getString('user_location') ?? "Not specified",
          };
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }
  }

  // Method to edit account information
  void _editAccountInfo() async {
    // Show dialog to edit user information
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AccountEditDialog(userData: userData),
    );

    if (result != null) {
      try {
        // Update local state first for immediate feedback
        setState(() {
          userData = {...?userData, ...result};
        });

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', result['name'] ?? '');
        await prefs.setString('user_email', result['email'] ?? '');
        await prefs.setString('user_phone', result['phone'] ?? '');
        await prefs.setString(
            'user_organization', result['organization'] ?? '');
        await prefs.setString('user_location', result['location'] ?? '');

        // Optionally update to backend
        final userId = prefs.getString('user_id');
        if (userId != null) {
          final response = await http.put(
            Uri.parse('$apiBaseUrl/users/$userId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(result),
          );

          if (response.statusCode != 200) {
            print("API Update Failed - Status Code: ${response.statusCode}");
            // Show warning that changes are only stored locally
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Changes saved locally only. Will sync when online.')),
            );
          }
        }
      } catch (e) {
        print('Error updating user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user data: $e')),
        );
      }
    }
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
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF39B0E5)))
            : CustomScrollView(
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
                            colors: [
                              const Color(0xFF39B0E5),
                              const Color(0xFF1ED4B5)
                            ],
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
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
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
                          child: const Icon(Icons.settings_outlined,
                              color: Colors.white, size: 18),
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
                                      child: userData != null &&
                                              userData!.containsKey(
                                                  'profileImageUrl') &&
                                              userData!['profileImageUrl'] !=
                                                  null &&
                                              userData!['profileImageUrl']
                                                  .toString()
                                                  .isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl:
                                                  userData!['profileImageUrl'],
                                              fit: BoxFit.cover,
                                              width: 76,
                                              height: 76,
                                              placeholder: (context, url) =>
                                                  const CircularProgressIndicator(
                                                color: Color(0xFF39B0E5),
                                                strokeWidth: 2,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                Icons.person,
                                                size: 40,
                                                color: Color(0xFF39B0E5),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              size: 40,
                                              color: Color(0xFF39B0E5),
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
                                      userData?['name'] ?? 'User',
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    Text(
                                      userData?['bio'] ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    OutlinedButton(
                                      onPressed: () {
                                        _editAccountInfo();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Color(0xFF39B0E5)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
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
                                  _buildInfoItem(Icons.business, 'Organization',
                                      userData?['organization'] ?? ''),
                                  const Divider(height: 20),
                                  _buildInfoItem(Icons.location_on_outlined,
                                      'Location', userData?['location'] ?? ''),
                                  const Divider(height: 20),
                                  _buildInfoItem(Icons.email_outlined, 'Email',
                                      userData?['email'] ?? ''),
                                  const Divider(height: 20),
                                  _buildInfoItem(Icons.phone_outlined, 'Phone',
                                      userData?['phone'] ?? ''),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 600.ms),

                          const SizedBox(height: 30),

                          // Account Settings Section
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Text(
                                    'Account Settings',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: [
                                      _buildPreferenceItem(
                                        'Account Information',
                                        'View and edit your personal details',
                                        Icons.person_outline,
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Color(0xFF39B0E5),
                                        ),
                                        onTap: () {
                                          _editAccountInfo();
                                        },
                                      ),
                                      _buildPreferenceItem(
                                        'Password & Security',
                                        'Manage your password and security options',
                                        Icons.lock_outline,
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Color(0xFF39B0E5),
                                        ),
                                        onTap: () {
                                          _showPasswordSecurityDialog();
                                        },
                                      ),
                                      _buildPreferenceItem(
                                        'Privacy Settings',
                                        'Manage your privacy preferences',
                                        Icons.security_outlined,
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Color(0xFF39B0E5),
                                        ),
                                        onTap: () {
                                          _showPrivacySettingsDialog();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Log out button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _logout();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade100,
                                foregroundColor: Colors.grey.shade700,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
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

  // Method to show password and security dialog
  void _showPasswordSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Password & Security',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogOption(
              'Change Password',
              Icons.lock_reset_outlined,
              () {
                Navigator.pop(context);
                _showChangePasswordDialog();
              },
            ),
            const SizedBox(height: 10),
            _buildDialogOption(
              'Two-Factor Authentication',
              Icons.security_outlined,
              () {
                Navigator.pop(context);
                // Show 2FA setup dialog
              },
            ),
            const SizedBox(height: 10),
            _buildDialogOption(
              'Login History',
              Icons.history_outlined,
              () {
                Navigator.pop(context);
                // Show login history
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                color: const Color(0xFF39B0E5),
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  // Method to show privacy settings dialog
  void _showPrivacySettingsDialog() {
    bool anonymousMode = false;
    bool allowDataSharing = true;
    bool enableEncryption = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Privacy Settings',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text(
                  'Anonymous Mode',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                subtitle: Text(
                  'Hide your profile from other users',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                value: anonymousMode,
                onChanged: (value) {
                  setState(() {
                    anonymousMode = value;
                  });
                },
                activeColor: const Color(0xFF39B0E5),
              ),
              SwitchListTile(
                title: Text(
                  'Data Sharing',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                subtitle: Text(
                  'Allow anonymous data collection for app improvement',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                value: allowDataSharing,
                onChanged: (value) {
                  setState(() {
                    allowDataSharing = value;
                  });
                },
                activeColor: const Color(0xFF39B0E5),
              ),
              SwitchListTile(
                title: Text(
                  'End-to-End Encryption',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                subtitle: Text(
                  'Enable encryption for all your data',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                value: enableEncryption,
                onChanged: (value) {
                  setState(() {
                    enableEncryption = value;
                  });
                },
                activeColor: const Color(0xFF39B0E5),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Save privacy settings
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF39B0E5),
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  // Method to show change password dialog
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Change Password',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Validate and change password
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              // Handle password change logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
              );
            },
            child: Text(
              'Change',
              style: GoogleFonts.poppins(
                color: const Color(0xFF39B0E5),
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildDialogOption(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF39B0E5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to handle logout
  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_email');

      // Navigate to welcome page
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const WelcomePage();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.easeOutQuint;
            var curveTween = CurveTween(curve: curve);
            var fadeAnimation = animation.drive(curveTween);
            return FadeTransition(
              opacity: fadeAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
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
              value.isNotEmpty ? value : 'Not specified',
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
}

// Dialog to edit account information
class AccountEditDialog extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AccountEditDialog({Key? key, this.userData}) : super(key: key);

  @override
  _AccountEditDialogState createState() => _AccountEditDialogState();
}

class _AccountEditDialogState extends State<AccountEditDialog> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController organizationController;
  late TextEditingController locationController;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.userData?['name'] ?? '');
    emailController =
        TextEditingController(text: widget.userData?['email'] ?? '');
    phoneController =
        TextEditingController(text: widget.userData?['phone'] ?? '');
    organizationController =
        TextEditingController(text: widget.userData?['organization'] ?? '');
    locationController =
        TextEditingController(text: widget.userData?['location'] ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    organizationController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Edit Account Information',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: organizationController,
              decoration: InputDecoration(
                labelText: 'Organization',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            final updatedData = {
              'name': nameController.text,
              'email': emailController.text,
              'phone': phoneController.text,
              'organization': organizationController.text,
              'location': locationController.text,
            };
            Navigator.pop(context, updatedData);
          },
          child: Text(
            'Save',
            style: GoogleFonts.poppins(
              color: const Color(0xFF39B0E5),
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}
