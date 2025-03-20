import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/feature_card.dart';
import '../feed-page/meditation_list_screen.dart';
import '../therapist_dashboard/appointment_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

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
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        decoration: BoxDecoration(
          // Subtle gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF39B0E5).withOpacity(0.9), // Slightly muted blue
              Color(0xFF1ED4B5).withOpacity(0.85), // Slightly muted turquoise
            ],
          ),
        ),
        child: Stack(
          children: [
            // Top curved shape
            Positioned(
              top: -100,
              right: -150,
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom curved shape
            Positioned(
              bottom: -80,
              left: -100,
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15),

                      // Hero Banner with professional design
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Center(
                          child: Container(
                            width: screenSize.width * 0.95,
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                  spreadRadius: 2,
                                ),
                              ],
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF4B9FE1),
                                  Color(0xFF20E4B5),
                                ],
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  // Abstract curved shape in top right
                                  Positioned(
                                    top: -20,
                                    right: -20,
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                  ),

                                  // Abstract curved shape in bottom left
                                  Positioned(
                                    bottom: -40,
                                    left: -40,
                                    child: Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                  ),

                                  // Meditation figure
                                  Positioned(
                                    right: -20,
                                    bottom: 0,
                                    child: Container(
                                      width: 170,
                                      height: 200,
                                      child: Image.asset(
                                        'assets/images/homepageimg.png',
                                        fit: BoxFit.contain,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ),

                                  // Text content
                                  Positioned(
                                    top: 35,
                                    left: 25,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "MindBridge",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          width: screenSize.width * 0.5,
                                          child: Text(
                                            "Welcome to your\nmental health journey!",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 35),

                      // Service text heading with professional styling
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
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

                      // Feature Cards with professional design and animation
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            alignment: WrapAlignment.center,
                            children: [
                              Transform.translate(
                                offset: Offset(0, 50 * (1 - _animationController.value)),
                                child: Opacity(
                                  opacity: _animationController.value,
                                  child: _buildProfessionalFeatureCard(
                                    "AI Chatbot",
                                    "Talk to our AI about your feelings",
                                    "/chatbot",
                                    Color(0xFF4B9FE1),
                                    Icons.smart_toy_outlined,
                                  ),
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0, 50 * (1 - _animationController.value)),
                                child: Opacity(
                                  opacity: _animationController.value * 0.85,
                                  child: _buildProfessionalFeatureCard(
                                    "Community",
                                    "Connect with others on similar journeys",
                                    "/chatforum",
                                    Color(0xFF1EBBD7),
                                    Icons.forum_outlined,
                                  ),
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0, 50 * (1 - _animationController.value)),
                                child: Opacity(
                                  opacity: _animationController.value * 0.7,
                                  child: _buildProfessionalFeatureCard(
                                    "Mood Tracker",
                                    "Track and analyze your mood patterns",
                                    "/moodtracker",
                                    Color(0xFF20E4B5),
                                    Icons.insights_outlined,
                                  ),
                                ),
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
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildProfessionalFeatureCard(String title, String subtitle, String route, Color accentColor, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        width: 150,
        height: 170,
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
            BoxShadow(
              color: accentColor.withOpacity(0.1),
              blurRadius: 16,
              offset: Offset(0, 3),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Curved accent on the top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                  SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}