import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../login_page/login_page.dart';
import '../signup_page/signup_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

<<<<<<< Updated upstream
class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, const Color(0xFFF0F8FF)], // Subtle gradient background
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false, // Don't pad the bottom for more space
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0),
            child: Column(
              children: <Widget>[
                // Top section with text - slightly more compact
                Column(
                  children: [
                    // Logo with gradient text
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [
                            Color(0xFF4B9FE1), // Blue shade
                            Color(0xFF1EBBD7), // Teal shade
                            Color(0xFF20E4B5), // Mint green shade
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ).createShader(bounds);
                      },
                      child: const Text(
                        'mind bridge',
                        style: TextStyle(
                          fontSize: 38, // Slightly smaller for mobile
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12), // Smaller spacing for mobile

                    // Tagline with mobile-friendly styling
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Your Mental Health Companion',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF4A6572),
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                // Middle section with image - adjusted for better mobile balance
                Expanded(
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        vertical: screenSize.height * 0.03, // Proportional spacing
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Subtle glow backdrop
                          Opacity(
                            opacity: 0.2,
                            child: Container(
                              width: screenSize.width * 0.9,
                              height: screenSize.width * 0.9,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF4B9FE1).withOpacity(0.5),
                                    const Color(0xFF20E4B5).withOpacity(0.0),
                                  ],
                                  stops: const [0.1, 1.0],
                                ),
                              ),
                            ),
                          ),

                          // Main image with glass effect
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Let's get started on your journey!"),
                                  backgroundColor: const Color(0xFF1EBBD7),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  duration: const Duration(seconds: 2),
                                  margin: EdgeInsets.only(
                                    bottom: 70,
                                    left: 16,
                                    right: 16,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: screenSize.width * 0.85,
                              height: screenSize.width * 0.85,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(36),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(36),
                                child: Stack(
                                  children: [
                                    // Blur effect
                                    BackdropFilter(
                                      filter: ui.ImageFilter.blur(
                                        sigmaX: 5,
                                        sigmaY: 5,
                                      ),
                                      child: Container(
                                        color: Colors.white.withOpacity(0.05),
                                      ),
                                    ),

                                    // Gradient overlay
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.25),
                                            Colors.white.withOpacity(0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(36),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                    ),

                                    // Image
                                    Center(
                                      child: Container(
                                        width: screenSize.width * 0.75,
                                        height: screenSize.width * 0.75,
                                        padding: const EdgeInsets.all(8),
                                        child: Image.asset(
                                          'assets/images/2.png',
                                          fit: BoxFit.contain,
                                        ),
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
                  ),
                ),

                // Bottom section with buttons - adjusted for mobile
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 24 + MediaQuery.of(context).padding.bottom, // Account for navigation bar
                  ),
                  child: Column(
                    children: [
                      // Get Started Button - optimized for mobile touch
                      Container(
                        width: double.infinity,
                        height: 54, // Slightly smaller height for mobile
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF4B9FE1), // Blue
                              Color(0xFF1EBBD7), // Teal
                              Color(0xFF20E4B5), // Mint green
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(27),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1EBBD7).withOpacity(0.25),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(27),
                            splashColor: Colors.white.withOpacity(0.3),
                            highlightColor: Colors.white.withOpacity(0.2),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) {
                                    return SignupPage();
                                  },
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    var curve = Curves.easeOutQuint;
                                    var curveTween = CurveTween(curve: curve);
                                    var begin = const Offset(0.0, 1.0);
                                    var end = Offset.zero;
                                    var tween = Tween(begin: begin, end: end).chain(curveTween);
                                    var offsetAnimation = animation.drive(tween);
                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 500), // Faster for mobile
                                ),
                              );
                            },
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Get Started',
                                    style: TextStyle(
                                      fontSize: 16, // Slightly smaller for mobile
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
=======
class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Create a scale animation that goes from 0.95 to 1.05 and back
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.95, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.05, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_animationController);

    // Start the animation and make it repeat
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo in circle with shadow
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'mind\nbridge',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF1EBBD7),
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Main title
              Text(
                'mind bridge',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1EBBD7),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 20),

              // Tagline
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Text(
                  'Your Mental Health Companion',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A6572),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Main image container with animation
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: size.width * 0.7,
                          height: size.width * 0.7,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // The image from assets
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.asset(
                                  'assets/images/2.png',
                                  width: size.width * 0.7,
                                  height: size.width * 0.7,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              // Curved light blue line top
                              Positioned(
                                top: size.width * 0.13,
                                left: 0,
                                right: 0,
                                child: CustomPaint(
                                  size: Size(size.width * 0.7, 2),
                                  painter: CurvedLinePainter(
                                    color: const Color(0xFFE0F7FA),
                                    thickness: 2,
                                  ),
                                ),
                              ),

                              // Curved light blue line bottom
                              Positioned(
                                bottom: size.width * 0.13,
                                left: 0,
                                right: 0,
                                child: CustomPaint(
                                  size: Size(size.width * 0.7, 2),
                                  painter: CurvedLinePainter(
                                    color: const Color(0xFFE0F7FA),
                                    thickness: 2,
                                  ),
                                ),
                              ),

                              // Small teal dot (top right)
                              Positioned(
                                top: size.width * 0.13,
                                right: size.width * 0.15,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF1EBBD7),
                                  ),
                                ),
                              ),

                              // Small green dot (bottom left)
                              Positioned(
                                bottom: size.width * 0.13,
                                left: size.width * 0.25,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF20E4B5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Get Started Button
              Container(
                width: double.infinity,
                height: 56,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF4B9FE1), // Blue
                      Color(0xFF20E4B5), // Mint green
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1EBBD7).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => SignupPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Sign In link
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A6572),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 300),
>>>>>>> Stashed changes
                          ),
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1EBBD7),
                        ),
                      ),
<<<<<<< Updated upstream

                      const SizedBox(height: 16), // Mobile-optimized spacing

                      // Sign In Link - simpler for mobile
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) {
                                return LoginPage();
                              },
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 400),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1EBBD7),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4A6572),
                                ),
                              ),
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1EBBD7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
=======
                    ),
                  ],
                ),
              ),
            ],
>>>>>>> Stashed changes
          ),
        ),
      ),
    );
  }
<<<<<<< Updated upstream
=======
}

// Custom painter for the curved lines
class CurvedLinePainter extends CustomPainter {
  final Color color;
  final double thickness;

  CurvedLinePainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
        size.width / 2,
        size.height / 2 - 20,
        size.width,
        size.height / 2
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom heart painter
class HeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF20E4B5)
      ..style = PaintingStyle.fill;

    // Create heart path
    Path path = Path();
    double width = size.width;
    double height = size.height;

    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(
        0.2 * width, height * 0.1,
        -0.25 * width, height * 0.6,
        0.5 * width, height
    );
    path.cubicTo(
        1.25 * width, height * 0.6,
        0.8 * width, height * 0.1,
        0.5 * width, height * 0.35
    );

    canvas.drawPath(path, paint);

    // Add shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    Path shadowPath = Path();
    shadowPath.addPath(path, const Offset(2, 8));
    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
>>>>>>> Stashed changes
}