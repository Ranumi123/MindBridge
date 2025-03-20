import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/feature_card.dart';
import '../feed-page/meditation_list_screen.dart';
import '../therapist_dashboard/doctor_list_screen.dart'; // Add this import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation based on bottom navbar selection
    if (index == 0) {
      // Home - we're already here, no navigation needed
    } else if (index == 1) {
      // Therapist icon navigation - go to doctor list
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DoctorListScreen()),
      );
    } else if (index == 2) {
      // Feed icon navigation - go to meditation list
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MeditationListScreen()),
      );
    } else if (index == 3) {
      // Settings icon navigation
      Navigator.pushNamed(context, '/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4B9FE1), // Blue primary color
                Color(0xFF1EBBD7), // Teal accent color
                Color(0xFF20E4B5), // Tertiary color
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        elevation: 2,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.png'),
              radius: 22,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome to MindBridge!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Your mental wellness journey starts here!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 25),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/welcome_image.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 35),

              // Feature Section with custom PNG cards
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  FeatureCard(
                      cardImagePath: "assets/images/chatbot_card.png",
                      route: "/chatbot"),
                  FeatureCard(
                      cardImagePath: "assets/images/chatforum_card.png",
                      route: "/chatforum"),
                  FeatureCard(
                      cardImagePath: "assets/images/moodtracker_card.png",
                      route: "/moodtracker"),
                ],
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