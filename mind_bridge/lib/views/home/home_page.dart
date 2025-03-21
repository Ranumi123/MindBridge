// Modified HomePage class

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/feature_card.dart';
import '../feed-page/meditation_list_screen.dart';
import '../therapist_dashboard/appointment_screen.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  // For typing animation
  String _displayText = "";
  final String _fullText = "MindBridge";
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    // Set status bar to transparent for a more immersive UI
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Start animations after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      _startTypingAnimation();
    });
  }

  void _startTypingAnimation() {
    // Reset state for animation restart
    setState(() {
      _displayText = "";
      _currentIndex = 0;
    });

    // Create a timer that adds one character at a time
    _timer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayText = _fullText.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        timer.cancel();

        // Optional: Add a blinking cursor effect or restart animation after pause
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            _startTypingAnimation();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation based on bottom navbar selection
    if (index == 0) {
      // Home - we're already here, no navigation needed
    } else if (index == 1) {
      // Therapist icon navigation with page transition
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AppointmentScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      );
    } else if (index == 2) {
      // Feed icon navigation with fade transition
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MeditationListScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else if (index == 3) {
      // Settings icon navigation
      Navigator.pushNamed(context, '/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true, // This allows the body to extend behind the bottom navigation bar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/logo.png'),
                radius: 22,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF39B0E5),
              Color(0xFF1ED4B5),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Top image with curved bottom
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                child: ClipPath(
                  clipper: BottomCurveClipper(),
                  child: Image.asset(
                    'assets/images/homeimg2.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Content
            SafeArea(
              bottom: false, // Important: Don't add bottom padding for the safe area
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 80), // Add extra bottom padding for content
                  child: Column(
                    children: [
                      // Space for the top image
                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),

                      // Hero Card
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Container(
                          width: screenSize.width,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: Offset(0, 8),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _displayText,
                                    style: TextStyle(
                                      color: Color(0xFF39B0E5),
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  AnimatedOpacity(
                                    opacity: (_currentIndex < _fullText.length && _currentIndex % 2 == 0) ? 1.0 : 0.0,
                                    duration: Duration(milliseconds: 500),
                                    child: Text(
                                      "|",
                                      style: TextStyle(
                                        color: Color(0xFF39B0E5),
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Welcome to your mental health journey!",
                                style: TextStyle(
                                  color: Color(0xFF1E2D3D),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 35),

                      // Service text heading with professional styling
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            children: [
                              Text(
                                "Services",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.5),
                                        Colors.white.withOpacity(0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Feature Cards - 2-1 layout (2 on top, 1 in middle below)
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Column(
                            children: [
                              // First row - 2 cards
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.translate(
                                    offset: Offset(0, 50 * (1 - _animationController.value)),
                                    child: Opacity(
                                      opacity: _animationController.value,
                                      child: _buildFeatureCard(
                                        "AI Chatbot",
                                        "Talk to our AI about your feelings",
                                        "/chatbot",
                                        Color(0xFF4B9FE1),
                                        Icons.smart_toy_outlined,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Transform.translate(
                                    offset: Offset(0, 50 * (1 - _animationController.value)),
                                    child: Opacity(
                                      opacity: _animationController.value * 0.85,
                                      child: _buildFeatureCard(
                                        "Community",
                                        "Connect with others on similar journeys",
                                        "/chatforum",
                                        Color(0xFF1EBBD7),
                                        Icons.forum_outlined,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20),

                              // Second row - 1 card centered
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform.translate(
                                    offset: Offset(0, 50 * (1 - _animationController.value)),
                                    child: Opacity(
                                      opacity: _animationController.value * 0.7,
                                      child: _buildFeatureCard(
                                        "Mood Tracker",
                                        "Track and analyze your mood patterns",
                                        "/moodtracker",
                                        Color(0xFF20E4B5),
                                        Icons.insights_outlined,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Use a Theme to adjust the visual properties of the BottomNavigationBar
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // This makes the navigation bar transparent
          canvasColor: Colors.transparent,
          // This removes the shadow from the navigation bar
          shadowColor: Colors.transparent,
        ),
        child: BottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, String route, Color accentColor, IconData icon) {
    // Fixed width for consistent card size in the 2-1 layout
    final double cardWidth = 150.0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        width: cardWidth,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 28,
                  color: accentColor,
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF718096),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Curved bottom clipper for the top image
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);

    // Create a curved bottom
    path.quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width,
        size.height - 50
    );

    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}