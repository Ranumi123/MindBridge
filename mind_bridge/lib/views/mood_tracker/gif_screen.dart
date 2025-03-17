import 'package:flutter/material.dart';
import 'dart:math';

class GifScreen extends StatefulWidget {
  final String? mood;

  // Make mood optional to maintain compatibility with existing code
  const GifScreen({super.key, this.mood});

  @override
  _GifScreenState createState() => _GifScreenState();
}

class _GifScreenState extends State<GifScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 1.0;
  late AnimationController _controller;
  late Animation<double> _animation;
  String _affirmation = "";
  bool _showConfetti = true;

  @override
  void initState() {
    super.initState();

    // Animation controller for additional elements
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Bouncing animation
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();

    // Select a random affirmation
    _selectAffirmation();

    // Original fade out behavior after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _opacity = 0.0;
        });
      }
    });

    // Original navigation behavior after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _selectAffirmation() {
    final List<String> happyAffirmations = [
      "Keep that positive energy flowing!",
      "Your happiness brightens everyone's day!",
      "Wonderful! Happiness looks great on you!",
    ];

    final List<String> calmAffirmations = [
      "Finding your inner peace is a beautiful thing.",
      "A calm mind leads to better decisions.",
      "Peace of mind is the true wealth.",
    ];

    final List<String> generalAffirmations = [
      "Mood tracked successfully!",
      "Thank you for sharing how you feel today!",
      "Tracking your moods helps build emotional awareness.",
    ];

    // Select appropriate list based on mood
    List<String> affirmations = generalAffirmations;
    if (widget.mood != null) {
      if (widget.mood!.toLowerCase() == "happy") {
        affirmations = happyAffirmations;
      } else if (widget.mood!.toLowerCase() == "calm") {
        affirmations = calmAffirmations;
      }
    }

    // Random selection
    final random = Random();
    _affirmation = affirmations[random.nextInt(affirmations.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get background color based on mood
    Color backgroundColor = Colors.white;
    if (widget.mood != null) {
      switch (widget.mood!.toLowerCase()) {
        case "happy":
          backgroundColor = Colors.amber.withOpacity(0.1);
          break;
        case "calm":
          backgroundColor = Colors.blue.withOpacity(0.1);
          break;
        case "relaxed":
          backgroundColor = Colors.green.withOpacity(0.1);
          break;
        default:
          backgroundColor = Colors.white;
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Confetti effect if enabled
          if (_showConfetti && widget.mood != null) ..._buildConfetti(),

          // Main content with animation
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 800),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display a simple message with a check icon
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 80,
                          color: widget.mood != null
                              ? _getMoodColor(widget.mood!)
                              : Colors.green,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Saved!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: widget.mood != null
                                ? _getMoodColor(widget.mood!)
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // New affirmation text with scale animation
                  ScaleTransition(
                    scale: _animation,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        _affirmation,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get color based on mood
  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case "happy":
        return Colors.amber;
      case "calm":
        return Colors.blue;
      case "relaxed":
        return Colors.green;
      case "sad":
        return Colors.grey;
      case "angry":
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  // Helper method to build confetti effect
  List<Widget> _buildConfetti() {
    final random = Random();
    final List<Widget> confetti = [];
    Color confettiColor = Colors.amber.withOpacity(0.3); // Default

    // Set color based on mood
    if (widget.mood != null) {
      switch (widget.mood!.toLowerCase()) {
        case "happy":
          confettiColor = Colors.amber.withOpacity(0.3);
          break;
        case "calm":
          confettiColor = Colors.blue.withOpacity(0.3);
          break;
        case "relaxed":
          confettiColor = Colors.green.withOpacity(0.3);
          break;
        default:
          confettiColor = Colors.purple.withOpacity(0.3);
      }
    }

    // Create 20 confetti particles
    for (int i = 0; i < 20; i++) {
      final size = random.nextDouble() * 15 + 5;

      confetti.add(
        Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          top: random.nextDouble() * MediaQuery.of(context).size.height,
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 800),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: random.nextInt(1500) + 500),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(
                    sin(value * 2 * pi) * 15,
                    value * 100,
                  ),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: confettiColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return confetti;
  }
}
