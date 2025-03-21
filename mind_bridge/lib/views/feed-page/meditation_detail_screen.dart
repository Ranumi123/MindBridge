import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/bottom_navbar.dart';
import '../therapist_dashboard/appointment_screen.dart';
import '../home/home_page.dart';
import 'meditation_list_screen.dart';
import '../profile_setup_page/profile_setup_screen.dart';

class MeditationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> meditation;

  const MeditationDetailScreen({super.key, required this.meditation});

  @override
  State<MeditationDetailScreen> createState() => _MeditationDetailScreenState();
}

class _MeditationDetailScreenState extends State<MeditationDetailScreen> {
  int _selectedIndex = 2; // Set to 2 for meditation tab

  // Function to handle bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentScreen(),
            ));
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MeditationListScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProfilePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var begin = Offset(0.0, 1.0);
              var end = Offset.zero;
              var curve = Curves.easeInOut;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                  position: animation.drive(tween), child: child);
            },
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meditation['title'] ?? 'Meditation'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4B9FE1),
                Color(0xFF1EBBD7)
              ], // Gradient for AppBar
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meditation Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.meditation['image'] ?? '',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Meditation Title
              Text(
                widget.meditation['title'] ?? 'No Title',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Meditation Author
              Text(
                'By ${widget.meditation['author'] ?? 'Unknown'}',
                style:
                    const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 10),

              // Meditation Category and Duration
              Row(
                children: [
                  Chip(
                    label: Text(widget.meditation['category'] ?? 'Unknown'),
                    backgroundColor: const Color(0xFF1EBBD7)
                        .withOpacity(0.2), // Fixed to use withOpacity
                  ),
                  const SizedBox(width: 10),
                  Chip(
                    label: Text(widget.meditation['duration'] ?? 'Unknown'),
                    backgroundColor: const Color(0xFF20E4B5)
                        .withOpacity(0.2), // Fixed to use withOpacity
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Meditation Description
              Text(
                widget.meditation['description'] ?? 'No description available.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),

              // Play Meditation Button with Gradient
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4B9FE1),
                        Color(0xFF1EBBD7)
                      ], // Gradient for button
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.transparent, // Allows gradient to show
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0, // Removes default shadow for a sleek look
                    ),
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: const Text("Play Meditation",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      final url = widget.meditation['url'];
                      if (url != null && url.isNotEmpty) {
                        final Uri uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Could not open video")),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No video available")),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
