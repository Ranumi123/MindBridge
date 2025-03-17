import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../login_page/login_page.dart';
import '../signup_page/signup_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
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
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Top section with text (professional layout)
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
                          child: const Text(
                            'mind bridge',
                            style: TextStyle(
                              fontSize: 42, // Slightly larger for better readability
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: Colors.white, // This will be overridden by the shader
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
                        const SizedBox(height: 16), // Consistent spacing

                        // Tagline with professional styling
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                              fontWeight: FontWeight.w600, // Slightly bolder for emphasis
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),

                    // Center section with image
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
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

                                // Main image with glass morphism effect
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

                                // Dots have been removed from here
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom section with stylized interactive buttons - professionally spaced
                    Column(
                      children: [
                        // Get Started Button with clean, professional styling
                        Container(
                          width: double.infinity,
                          height: 58,
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
                            borderRadius: BorderRadius.circular(29),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1EBBD7).withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 1,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(29),
                              splashColor: Colors.white.withOpacity(0.3),
                              highlightColor: Colors.white.withOpacity(0.2),
                              hoverColor: Colors.white.withOpacity(0.1),
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
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22), // Professional spacing

                        // Sign In Link with cleaner styling
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            hoverColor: Colors.black.withOpacity(0.03),
                            splashColor: Colors.white.withOpacity(0.2),
                            highlightColor: Colors.white.withOpacity(0.1),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) {
                                    return LoginPage();
                                  },
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