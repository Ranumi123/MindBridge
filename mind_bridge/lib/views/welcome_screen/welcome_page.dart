import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../login_page/login_page.dart';
import '../signup_page/signup_page.dart';
import 'dart:math' as math;

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Slightly faster rotation
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
        child: Stack(
          children: [
            // Background subtle pattern
            Opacity(
              opacity: 0.05,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.grey,
                ),
              ),
            ),

            // Interactive background elements that follow pointer
            MouseRegion(
              onHover: (event) {
                // This enables the interactive elements to react on hover
                setState(() {});
              },
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Stack(
                    children: List.generate(10, (index) {
                      final size = 8.0 + (index % 3) * 5.0;
                      final offset = 2 * math.pi * index / 10;
                      final x = screenSize.width * 0.5 + math.cos(
                          _animationController.value * 2 * math.pi + offset
                      ) * screenSize.width * 0.4;
                      final y = screenSize.height * 0.5 + math.sin(
                          _animationController.value * 2 * math.pi + offset
                      ) * screenSize.height * 0.3;

                      return Positioned(
                        left: x - size / 2,
                        top: y - size / 2,
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.lerp(
                              const Color(0xFF4B9FE1),
                              const Color(0xFF20E4B5),
                              index / 10,
                            )!.withOpacity(0.3),
                            boxShadow: [
                              BoxShadow(
                                color: Color.lerp(
                                  const Color(0xFF4B9FE1),
                                  const Color(0xFF20E4B5),
                                  index / 10,
                                )!.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Top section with text (removed logo)
                    Column(
                      children: [
                        // Logo with gradient text and blur effect
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
                          child: Text(
                            'mind bridge',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: Colors.white, // This will be overridden by the shader
                              shadows: [
                                Shadow(
                                  color: Colors.black12,
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Tagline with modern styling and animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
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
                                color: Color(0xFF4A6572),
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Center section with your PNG image in a modern frame with CURVED LINES
                    Expanded(
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Simple subtle glow without animation
                              Opacity(
                                opacity: 0.2,
                                child: Container(
                                  width: screenSize.width * 0.95,
                                  height: screenSize.width * 0.95,
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

                              // Main image with interactive glass morphism effect
                              GestureDetector(
                                onTap: () {
                                  // Add interactive feedback on tap
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Let's get started on your journey!"),
                                      backgroundColor: const Color(0xFF1EBBD7),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: MouseRegion(
                                  onEnter: (_) => setState(() {}),
                                  onExit: (_) => setState(() {}),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: screenSize.width * 0.9,
                                    height: screenSize.width * 0.9,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: Stack(
                                        children: [
                                          // Background blur with increased transparency
                                          BackdropFilter(
                                            filter: ui.ImageFilter.blur(
                                              sigmaX: 5,
                                              sigmaY: 5,
                                            ),
                                            child: Container(
                                              color: Colors.white.withOpacity(0.05),
                                            ),
                                          ),

                                          // Interactive gradient overlay with more subtle styling
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
                                              borderRadius: BorderRadius.circular(40),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                          ),

                                          // Removed all decorative curved lines

                                          // The image
                                          Center(
                                            child: Container(
                                              width: screenSize.width * 0.85,
                                              height: screenSize.width * 0.85,
                                              padding: const EdgeInsets.all(10),
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
                              ),

                              // Clean rotating dots around the picture
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Stack(
                                    children: List.generate(12, (index) {
                                      // Calculating the position on a circle
                                      final angle = 2 * math.pi * index / 12 + (_animationController.value * 2 * math.pi);
                                      final radius = screenSize.width * 0.45; // Size of the circle
                                      final centerX = screenSize.width * 0.45;
                                      final centerY = screenSize.width * 0.45;

                                      // Calculate position
                                      final x = centerX + radius * math.cos(angle);
                                      final y = centerY + radius * math.sin(angle);

                                      // Dot size varies slightly around the circle
                                      final dotSize = 10.0 + (index % 3) * 2.0;

                                      return Positioned(
                                        left: x - dotSize / 2,
                                        top: y - dotSize / 2,
                                        child: Container(
                                          width: dotSize,
                                          height: dotSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.lerp(
                                              const Color(0xFF4B9FE1),
                                              const Color(0xFF20E4B5),
                                              index / 12,
                                            )!.withOpacity(0.9),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color.lerp(
                                                  const Color(0xFF4B9FE1),
                                                  const Color(0xFF20E4B5),
                                                  index / 12,
                                                )!.withOpacity(0.7),
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom section with stylized interactive buttons
                    Column(
                      children: [
                        // Advanced Get Started Button with animation and hover effect
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              width: double.infinity,
                              height: 60,
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
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1EBBD7).withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF20E4B5).withOpacity(0.2),
                                    blurRadius: 25,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  splashColor: Colors.white.withOpacity(0.3),
                                  highlightColor: Colors.white.withOpacity(0.2),
                                  hoverColor: Colors.white.withOpacity(0.1),
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) =>
                                            SignupPage(),
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
                                        transitionDuration: const Duration(milliseconds: 700),
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
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        TweenAnimationBuilder<double>(
                                          tween: Tween<double>(begin: 0, end: 1),
                                          duration: const Duration(milliseconds: 1500),
                                          builder: (context, value, child) {
                                            return Transform.translate(
                                              offset: Offset(5 * math.sin(value * 2 * math.pi), 0),
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Sign In Link with interactive hover effects
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: child,
                            );
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                hoverColor: Colors.black.withOpacity(0.05),
                                splashColor: Colors.white.withOpacity(0.3),
                                highlightColor: Colors.white.withOpacity(0.2),
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                          LoginPage(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        var curve = Curves.easeOutQuint;
                                        var curveTween = CurveTween(curve: curve);
                                        var tween = Tween(begin: 0.0, end: 1.0).chain(curveTween);
                                        var fadeAnimation = animation.drive(tween);
                                        return FadeTransition(
                                          opacity: fadeAnimation,
                                          child: child,
                                        );
                                      },
                                      transitionDuration: const Duration(milliseconds: 500),
                                    ),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Already have an account? ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF4A6572),
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Sign In',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1EBBD7),
                                          decoration: TextDecoration.underline,
                                          decorationColor: const Color(0xFF1EBBD7).withOpacity(0.3),
                                          decorationThickness: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Curved line painter
class CurvedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool isLeftToRight;

  CurvedLinePainter({
    required this.color,
    required this.strokeWidth,
    this.isLeftToRight = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    var path = Path();

    if (isLeftToRight) {
      path.moveTo(0, size.height * 0.8);
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.2,
        size.width,
        size.height * 0.5,
      );
    } else {
      path.moveTo(size.width, size.height * 0.8);
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.2,
        0,
        size.height * 0.5,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Wave line painter
class WavePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  WavePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    var path = Path();

    path.moveTo(0, size.height * 0.5);

    // First curve up
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.0,
      size.width * 0.25,
      size.height * 1.0,
      size.width * 0.5,
      size.height * 0.5,
    );

    // Second curve down
    path.cubicTo(
      size.width * 0.75,
      size.height * 0.0,
      size.width * 0.75,
      size.height * 1.0,
      size.width,
      size.height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}