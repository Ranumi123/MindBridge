import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'mood_data.dart';
import 'gif_screen.dart';
import '../../services/mood_service.dart';
import '../widgets/mood_chart_views.dart';
import '../widgets/mood_display_view.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  String selectedMood = "Happy"; // Default mood
  bool _showChart = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = false;

  // Initialize MoodService directly
  final MoodService _moodService = MoodService(
    baseUrl: 'http://localhost:5001', // Change to your actual IP and port
  );

  // Weekly mood data
  Map<String, int> weeklyMoods = {
    "Mon": 0,
    "Tue": 0,
    "Wed": 0,
    "Thu": 0,
    "Fri": 0,
    "Sat": 0,
    "Sun": 0
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Initialize service and load mood data
    _initializeAndLoadData();
  }

  // Initialize service and load data
  Future<void> _initializeAndLoadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize the service
      await _moodService.initialize();

      // Then load the data
      if (mounted) {
        await _loadMoodData();
      }
    } catch (e) {
      debugPrint('Error initializing mood service: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Load mood data from backend
  Future<void> _loadMoodData() async {
    if (!mounted) return;

    try {
      final loadedMoods = await _moodService.getWeeklyMoods(forceRefresh: true);

      if (!mounted) return;

      setState(() {
        weeklyMoods = loadedMoods;

        // Set selectedMood based on today's mood if available
        final today = DateTime.now().weekday - 1; // 0 = Monday
        final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        final todayMood = weeklyMoods[days[today]];

        if (todayMood != null && todayMood > 0) {
          // Convert mood value to mood string
          if (todayMood == 1)
            selectedMood = "Sad";
          else if (todayMood == 2)
            selectedMood = "Calm";
          else if (todayMood == 3)
            selectedMood = "Happy";
          else if (todayMood == 4)
            selectedMood = "Angry";
          else if (todayMood == 5) selectedMood = "Relaxed";
        }

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading mood data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Save mood to backend
  Future<void> _saveMood(String mood) async {
    try {
      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      // First update locally for immediate feedback
      setState(() {
        selectedMood = mood;

        // Map the mood to a value for the chart
        int moodValue = 3; // Default (Happy)
        if (mood == "Sad") moodValue = 1;
        if (mood == "Calm") moodValue = 2;
        if (mood == "Happy") moodValue = 3;
        if (mood == "Angry") moodValue = 4;
        if (mood == "Relaxed") moodValue = 5;

        // Update today's mood in the local data
        final today = DateTime.now().weekday - 1; // 0 = Monday
        final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        weeklyMoods[days[today]] = moodValue;
      });

      // Then save to backend
      final success = await _moodService.saveMood(mood, notes: _textController.text);

      if (!mounted) return;

      if (!success) {
        // If backend save failed, still keep the local update but show warning
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save mood to server, but stored locally.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // On success, refresh the data from the server to ensure sync
        await _loadMoodData();
      }
    } catch (e) {
      debugPrint('Error saving mood: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      // Hide loading indicator
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showChart
            ? MoodChartView(
          animation: _animation,
          weeklyMoods: weeklyMoods,
          moodData: moodData,
        )
            : MoodDisplayView(
          animation: _animation,
          selectedMood: selectedMood,
          weeklyMoods: weeklyMoods,
          onMoodSelect: _showMoodSelectionDialog,
          moodData: moodData,
        ),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black54, size: 20),
        ),
      ),
      title: Text(
        "Mood Tracker",
        style: GoogleFonts.montserrat(
          textStyle: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showChart = !_showChart;
              if (_showChart) {
                _animationController.reset();
                _animationController.forward();
                // Refresh data when switching to chart view
                _loadMoodData();
              } else {
                _animationController.reset();
                _animationController.forward();
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _showChart ? Icons.person_rounded : Icons.insert_chart_rounded,
              color: Colors.black54,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  void _showMoodSelectionDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Mood Selection",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Container(); // Not used
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.only(
                  top: 24, left: 24, right: 24, bottom: 8),
              title: Column(
                children: [
                  const Icon(
                    Icons.waves,
                    size: 36,
                    color: Color(0xFF6A42F4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "How are you feeling?",
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Select your current mood",
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: moodData.entries.map((entry) {
                      final String mood = entry.key;
                      final IconData icon = entry.value["icon"];
                      final Color color = entry.value["color"];
                      final LinearGradient gradient = entry.value["gradient"];
                      final String description = entry.value["description"];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              Navigator.of(context).pop();

                              // Save mood to backend
                              await _saveMood(mood);

                              if (!mounted) return;

                              _animationController.reset();
                              _animationController.forward();

                              // Show confirmation
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Mood '$mood' saved!",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: color,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );

                              // Navigate to animation
                              await Future.delayed(
                                  const Duration(milliseconds: 300));
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) =>
                                        GifScreen(
                                          mood: mood,
                                        ),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin = Offset(0.0, 0.2);
                                      const end = Offset.zero;
                                      const curve = Curves.easeOutCubic;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));

                                      return SlideTransition(
                                        position: animation.drive(tween),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    color.withOpacity(0.1),
                                    color.withOpacity(0.05)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 16.0),
                                child: Row(
                                  children: [
                                    // Mood icon with gradient background
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: gradient,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        icon,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Mood text
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mood,
                                            style: GoogleFonts.montserrat(
                                              textStyle: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            description,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.navigate_next_rounded,
                                      color: Colors.grey[400],
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}