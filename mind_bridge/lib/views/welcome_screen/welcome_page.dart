import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../login_page/login_page.dart';
import '../signup_page/signup_page.dart';
import 'dart:math' as math;

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

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

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Top section with logo and text
                    Column(
                      children: [
                        // App logo image - ENLARGED with better fit
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.scale(
                                scale: value,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            height: 100, // Increased from 80 to 100
                            width: 100, // Increased from 80 to 100
                            padding: const EdgeInsets.all(2), // Reduced padding from 8 to 2
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipOval( // Added ClipOval for perfect circle clipping
                              child: Image.asset(
                                'assets/images/1.png',
                                fit: BoxFit.cover, // Changed from BoxFit.contain to BoxFit.cover
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

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
                              // Background animation glow
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.9, end: 1.1),
                                duration: const Duration(milliseconds: 3000),
                                curve: Curves.easeInOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Opacity(
                                      opacity: 0.1,
                                      child: Container(
                                        width: screenSize.width * 1.0,
                                        height: screenSize.width * 1.0,
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
                                  );
                                },
                              ),

                              // Decorative curved line 1 (upper left)
                              Positioned(
                                top: screenSize.height * 0.05,
                                left: -20,
                                child: CustomPaint(
                                  size: Size(screenSize.width * 0.5, screenSize.height * 0.1),
                                  painter: CurvedLinePainter(
                                    color: const Color(0xFF4B9FE1).withOpacity(0.2),
                                    strokeWidth: 2,
                                    isLeftToRight: true,
                                  ),
                                ),
                              ),

                              // Decorative curved line 2 (upper right)
                              Positioned(
                                top: screenSize.height * 0.08,
                                right: 0,
                                child: CustomPaint(
                                  size: Size(screenSize.width * 0.4, screenSize.height * 0.07),
                                  painter: CurvedLinePainter(
                                    color: const Color(0xFF1EBBD7).withOpacity(0.15),
                                    strokeWidth: 3,
                                    isLeftToRight: false,
                                  ),
                                ),
                              ),

                              // Decorative curved line 3 (lower left)
                              Positioned(
                                bottom: screenSize.height * 0.12,
                                left: 10,
                                child: CustomPaint(
                                  size: Size(screenSize.width * 0.4, screenSize.height * 0.08),
                                  painter: CurvedLinePainter(
                                    color: const Color(0xFF20E4B5).withOpacity(0.2),
                                    strokeWidth: 2.5,
                                    isLeftToRight: false,
                                  ),
                                ),
                              ),

                              // Decorative curved line 4 (lower right)
                              Positioned(
                                bottom: screenSize.height * 0.05,
                                right: -10,
                                child: CustomPaint(
                                  size: Size(screenSize.width * 0.45, screenSize.height * 0.1),
                                  painter: CurvedLinePainter(
                                    color: const Color(0xFF4B9FE1).withOpacity(0.15),
                                    strokeWidth: 3,
                                    isLeftToRight: true,
                                  ),
                                ),
                              ),

                              // Wave curve along the middle
                              Positioned(
                                top: screenSize.height * 0.2,
                                left: 0,
                                child: CustomPaint(
                                  size: Size(screenSize.width * 0.85, screenSize.height * 0.08),
                                  painter: WavePainter(
                                    color: const Color(0xFF1EBBD7).withOpacity(0.15),
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),

                              // Decorative elements - circles
                              Positioned(
                                top: screenSize.height * 0.05,
                                right: screenSize.width * 0.15,
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF4B9FE1).withOpacity(0.2),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: screenSize.height * 0.05,
                                left: screenSize.width * 0.1,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF20E4B5).withOpacity(0.3),
                                  ),
                                ),
                              ),

                              // Additional decorative element
                              Positioned(
                                top: screenSize.height * 0.12,
                                left: screenSize.width * 0.15,
                                child: Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF1EBBD7).withOpacity(0.2),
                                  ),
                                ),
                              ),

                              // Main image with frosted glass effect frame
                              Container(
                                width: screenSize.width * 0.9,
                                height: screenSize.width * 0.9,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Stack(
                                    children: [
                                      // Background blur
                                      BackdropFilter(
                                        filter: ui.ImageFilter.blur(
                                          sigmaX: 10,
                                          sigmaY: 10,
                                        ),
                                        child: Container(
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                      ),

                                      // Gradient overlay
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withOpacity(0.5),
                                              Colors.white.withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(40),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),

                                      // Inner decorative curved line (top)
                                      Positioned(
                                        top: 30,
                                        left: 20,
                                        child: CustomPaint(
                                          size: Size(screenSize.width * 0.6, 40),
                                          painter: CurvedLinePainter(
                                            color: const Color(0xFF4B9FE1).withOpacity(0.1),
                                            strokeWidth: 3,
                                            isLeftToRight: true,
                                          ),
                                        ),
                                      ),

                                      // Inner decorative curved line (bottom)
                                      Positioned(
                                        bottom: 40,
                                        right: 20,
                                        child: CustomPaint(
                                          size: Size(screenSize.width * 0.55, 40),
                                          painter: CurvedLinePainter(
                                            color: const Color(0xFF20E4B5).withOpacity(0.1),
                                            strokeWidth: 3,
                                            isLeftToRight: false,
                                          ),
                                        ),
                                      ),

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

                              // Animated floating dot
                              Positioned(
                                top: screenSize.height * 0.1,
                                right: screenSize.width * 0.25,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 2500),
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 10 * math.sin(value * 2 * math.pi)),
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF4B9FE1).withOpacity(0.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF4B9FE1).withOpacity(0.3),
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
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom section with stylized buttons
                    Column(
                      children: [
                        // Advanced Get Started Button with animation
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
                                splashColor: Colors.white.withOpacity(0.2),
                                highlightColor: Colors.white.withOpacity(0.1),
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
                                      Container(
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Sign In Link with better styling
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: child,
                            );
                          },
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
                            child: GestureDetector(
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

// Animation class for floating pulse effect
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulseAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
  }) : super(key: key);

  @override
  _PulseAnimationState createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.scale(
        scale: _animation.value,
        child: child,
      ),
      child: widget.child,
    );
  }
}