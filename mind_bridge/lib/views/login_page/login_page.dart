import 'package:flutter/material.dart';
import 'package:mind_bridge/views/profile_setup_page/profile_setup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import 'dart:convert';
import '../privacy_settings_page/privacy_setting_page.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Animation controller for staggered animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
  final email = _emailController.text;
  final password = _passwordController.text;

  final response = await AuthService.login(email, password);

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    print('Login successful: ${responseData['msg']}');

    // Save user data in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', responseData['user']['id']);
    await prefs.setString('user_email', responseData['user']['email']);
    await prefs.setString('user_name', responseData['user']['name']);
    await prefs.setString('user_phone', responseData['user']['phone'] ?? "");

    // Navigate to Profile Page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  } else {
    final responseData = jsonDecode(response.body);
    print('Login failed: ${responseData['msg']}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(responseData['msg']),
        backgroundColor: Color(0xFF1EBBD7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xFFF0F8FF), // Light blue background from welcome page
                ],
              ),
            ),
          ),

          // Decorative curved elements - background
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: Size(screenSize.width, screenSize.height * 0.4),
              painter: TopCurvePainter(
                color: Color(0xFF4B9FE1).withOpacity(0.04),
                fillColor: true,
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            child: CustomPaint(
              size: Size(screenSize.width, screenSize.height * 0.3),
              painter: BottomCurvePainter(
                color: Color(0xFF20E4B5).withOpacity(0.05),
              ),
            ),
          ),

          // Top curved container for image with ENLARGED size
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenSize.height * 0.4, // Slightly reduced height for better spacing
              child: Stack(
                children: [
                  // Background wave with deeper curve
                  CustomPaint(
                    size: Size(screenSize.width, screenSize.height * 0.4),
                    painter: TopWavePainter(
                      color: Color(0xFF1EBBD7).withOpacity(0.1),
                      depth: 1.5,
                    ),
                  ),

                  // Additional curved accent
                  Positioned(
                    top: 20,
                    right: 0,
                    child: CustomPaint(
                      size: Size(screenSize.width * 0.6, screenSize.height * 0.15),
                      painter: AccentCurvePainter(
                        color: Color(0xFF4B9FE1).withOpacity(0.15),
                        strokeWidth: 3,
                      ),
                    ),
                  ),

                  // Image positioned nicely in the curved area
                  Positioned(
                    bottom: -10,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: screenSize.height * 0.32, // Slightly adjusted for better fit
                      child: Image.asset(
                        'assets/images/loginimage2.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Decorative elements - circles
          Positioned(
            top: screenSize.height * 0.15,
            left: screenSize.width * 0.1,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF20E4B5).withOpacity(0.2),
              ),
            ),
          ),

          Positioned(
            top: screenSize.height * 0.25,
            right: screenSize.width * 0.15,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4B9FE1).withOpacity(0.15),
              ),
            ),
          ),

          Positioned(
            bottom: screenSize.height * 0.12,
            left: screenSize.width * 0.18,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1EBBD7).withOpacity(0.2),
              ),
            ),
          ),

          // Animated floating dot
          Positioned(
            top: screenSize.height * 0.2,
            right: screenSize.width * 0.25,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 2500),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 8 * math.sin(value * 2 * math.pi)),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4B9FE1).withOpacity(0.3),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4B9FE1).withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title and Back button at the very top
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF4A6572)),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A6572),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Space for the larger image in the stack
                    SizedBox(height: screenSize.height * 0.3), // Adjusted spacing

                    // Enhanced welcome message section
                    Container(
                      margin: EdgeInsets.only(bottom: 25),
                      child: Column(
                        children: [
                          // Subtle divider above welcome message
                          Container(
                            margin: EdgeInsets.only(bottom: 20),
                            height: 2,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF1EBBD7).withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          // Welcome message with gradient background card
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Color(0xFFE7F5FB),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF4B9FE1).withOpacity(0.1),
                                  blurRadius: 15,
                                  spreadRadius: 0,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Welcome Back!",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A6572),
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Log in to continue your mental health journey",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF4A6572).withOpacity(0.8),
                                    letterSpacing: 0.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form fields with animation
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          // Email field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Color(0xFF4B9FE1)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Color(0xFF1EBBD7)),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.email, color: Color(0xFF4B9FE1)),
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          // Password field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Color(0xFF4B9FE1)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Color(0xFF1EBBD7)),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.lock, color: Color(0xFF4B9FE1)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Color(0xFF4B9FE1),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),

                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Handle forgot password
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFF4B9FE1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20), // Adjusted spacing

                    // Login button with animation
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF4B9FE1),
                              Color(0xFF1EBBD7),
                              Color(0xFF20E4B5),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF1EBBD7).withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 1,
                              offset: Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Color(0xFF20E4B5).withOpacity(0.2),
                              blurRadius: 25,
                              spreadRadius: 0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            splashColor: Colors.white.withOpacity(0.2),
                            highlightColor: Colors.white.withOpacity(0.1),
                            onTap: _login,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 25), // Increased spacing

                    // Don't have account link
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: child,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              color: Color(0xFF4A6572),
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to the SignupPage
                              Navigator.pushReplacementNamed(context, '/signup');
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF1EBBD7),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Top wave painter with adjustable depth for more pronounced curve
class TopWavePainter extends CustomPainter {
  final Color color;
  final double depth;

  TopWavePainter({
    required this.color,
    this.depth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start at top left
    path.moveTo(0, 0);

    // Line to top right
    path.lineTo(size.width, 0);

    // Line to bottom right
    path.lineTo(size.width, size.height * 0.7);

    // Draw more pronounced curve from bottom right to bottom left
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * (1.0 + (0.2 * depth)), // More pronounced curve
      0,
      size.height * 0.75,
    );

    // Line back to top left to close path
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Top curve painter for decoration
class TopCurvePainter extends CustomPainter {
  final Color color;
  final bool fillColor;

  TopCurvePainter({
    required this.color,
    this.fillColor = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = fillColor ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();

    // Start at top right
    path.moveTo(size.width, 0);

    // Curve down and to the left
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.5,
      0,
      size.height * 0.3,
    );

    // If filling, close the path
    if (fillColor) {
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Bottom curve painter for decoration
class BottomCurvePainter extends CustomPainter {
  final Color color;

  BottomCurvePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start from bottom left
    path.moveTo(0, size.height);

    // Draw line to bottom right
    path.lineTo(size.width, size.height);

    // Draw curve up
    path.lineTo(size.width, size.height * 0.6);

    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.2,
      size.width * 0.3,
      size.height * 0.4,
    );

    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.5,
      0,
      size.height * 0.3,
    );

    // Close the path
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Accent curve painter for decorative elements
class AccentCurvePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  AccentCurvePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(0, size.height * 0.3);

    // First curve
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.1,
      size.width * 0.5,
      size.height * 0.4,
    );

    // Second curve
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.7,
      size.width,
      size.height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}