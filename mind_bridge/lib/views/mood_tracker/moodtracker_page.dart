import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../mood_tracker/gif_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  String selectedMood = "Happy"; // Default mood
  bool _showChart = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Professional mood data
  final Map<String, Map<String, dynamic>> moodData = {
    "Happy": {
      "icon": Icons.sentiment_very_satisfied_rounded,
      "color": const Color(0xFFFFC640),
      "gradient": const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFA000)], 
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      "description": "Joyful and content",
      "message": "Embrace the positive energy!"
    },
    "Calm": {
      "icon": Icons.spa_rounded,
      "color": const Color(0xFF4A9BFF),
      "gradient": const LinearGradient(
        colors: [Color(0xFF4A9BFF), Color(0xFF006EE6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      "description": "Peaceful and relaxed",
      "message": "Stay centered and mindful"
    },
    "Relaxed": {
      "icon": Icons.self_improvement_rounded,
      "color": const Color(0xFF4CD964),
      "gradient": const LinearGradient(
        colors: [Color(0xFF4CD964), Color(0xFF2EA043)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      "description": "At ease and tranquil",
      "message": "Enjoy this serene moment"
    },
    "Sad": {
      "icon": Icons.sentiment_dissatisfied_rounded,
      "color": const Color(0xFF8E8E93),
      "gradient": const LinearGradient(
        colors: [Color(0xFF8E8E93), Color(0xFF636366)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      "description": "Feeling down",
      "message": "It's okay not to be okay"
    },
    "Angry": {
      "icon": Icons.sentiment_very_dissatisfied_rounded,
      "color": const Color(0xFFFF3B30),
      "gradient": const LinearGradient(
        colors: [Color(0xFFFF3B30), Color(0xFFDC2626)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      "description": "Frustrated or irritated",
      "message": "Take deep breaths"
    },
  };

  // Mock data for mood statistics
  final Map<String, int> weeklyMoods = {
    "Mon": 2, // 0 = No data, 1 = Sad, 2 = Calm, 3 = Happy, 4 = Angry, 5 = Relaxed
    "Tue": 0,
    "Wed": 3,
    "Thu": 3,
    "Fri": 2,
    "Sat": 0,
    "Sun": 1,
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black54, size: 20),
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
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showChart ? _buildChartView() : _buildMoodView(),
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

  Widget _buildMoodView() {
    final Color primaryColor = moodData[selectedMood]!["color"];
    final LinearGradient gradient = moodData[selectedMood]!["gradient"];
    final String description = moodData[selectedMood]!["description"];
    final String message = moodData[selectedMood]!["message"];

    return Stack(
      key: const ValueKey<String>('moodView'),
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.15),
                Colors.white,
              ],
            ),
          ),
        ),
        
        SafeArea(
          child: Column(
            children: [
              // Top spacer
              const SizedBox(height: 20),
              
              // Emoji display with card
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FadeTransition(
                    opacity: _animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_animation),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: gradient,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 0,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Mood emoji icon
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      moodData[selectedMood]!["icon"],
                                      size: 64,
                                      color: primaryColor,
                                    ),
                                  ).animate()
                                    .scale(delay: 300.ms, duration: 600.ms, curve: Curves.elasticOut),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Mood name
                                  Text(
                                    selectedMood,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                        shadows: [
                                          Shadow(
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                            color: Colors.black.withOpacity(0.25),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Mood description
                                  Text(
                                    description,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Motivational message
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.lightbulb_outline,
                                            color: Colors.white.withOpacity(0.9),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              message,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
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
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Mood selection button
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _showMoodSelectionDialog();
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple[400]!, Colors.purple[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      width: 180,
                      height: 56,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_reaction_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Update Mood",
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate()
                .fade(delay: 600.ms, duration: 600.ms)
                .slideY(delay: 600.ms, duration: 600.ms, begin: 0.2, end: 0),

              // Information container
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mood Insights",
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          // Date display with calendar icon
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Today",
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Chart tip card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[700]!, Colors.blue[500]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.insights_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: 48,
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "View Your Weekly Insights",
                                      style: GoogleFonts.montserrat(
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Tap the chart icon to see your mood patterns and trends",
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate()
                        .fade(delay: 800.ms, duration: 600.ms)
                        .slideX(delay: 800.ms, duration: 600.ms, begin: 0.1, end: 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartView() {
    return Stack(
      key: const ValueKey<String>('chartView'),
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF9FAFF), Colors.white],
            ),
          ),
        ),
        
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                FadeTransition(
                  opacity: _animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.indigo[700]!, Colors.indigo[500]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.analytics_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Weekly Mood Analysis",
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Your mood patterns at a glance",
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Track your mood daily to build more comprehensive insights",
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
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
                
                const SizedBox(height: 24),
                
                // Chart Card
                Expanded(
                  child: FadeTransition(
                    opacity: _animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_animation),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Weekly Mood Pattern",
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                // Refresh button
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.refresh_rounded,
                                    size: 20,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              "Number of times each mood was recorded per day",
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Chart
                            Expanded(
                              child: _buildStylizedBarChart(),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Legend
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: moodData.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            gradient: entry.value["gradient"],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          entry.key,
                                          style: GoogleFonts.montserrat(
                                            textStyle: const TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
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
          ),
        ),
      ],
    );
  }

  Widget _buildStylizedBarChart() {
    // Convert existing weeklyMoods into the format needed for BarChart
    final barGroups = <BarChartGroupData>[];
    
    weeklyMoods.entries.toList().asMap().forEach((index, entry) {
      final moodValue = entry.value;
      
      // Get the corresponding mood and color
      String mood = "None";
      Color color = Colors.grey.shade300;
      
      switch (moodValue) {
        case 1:
          mood = "Sad";
          color = moodData["Sad"]!["color"];
          break;
        case 2:
          mood = "Calm";
          color = moodData["Calm"]!["color"];
          break;
        case 3:
          mood = "Happy";
          color = moodData["Happy"]!["color"];
          break;
        case 4:
          mood = "Angry";
          color = moodData["Angry"]!["color"];
          break;
        case 5:
          mood = "Relaxed";
          color = moodData["Relaxed"]!["color"];
          break;
      }
      
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: moodValue > 0 ? moodValue.toDouble() : 0.2, // Small bar for empty days
              color: moodValue > 0 ? color : Colors.grey.shade200,
              width: 18,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 5,
                color: Colors.grey.shade100,
              ),
            ),
          ],
        ),
      );
    });
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 5.5, // Maximum value for y-axis with some padding
        minY: 0, // Minimum value for y-axis
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(
          show: false,
        ),
        titlesData: FlTitlesData(
          // Show all titles
          show: true,
          // Bottom titles (days)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Convert the value (index) to the corresponding day
                final days = weeklyMoods.keys.toList();
                final index = value.toInt();
                if (index >= 0 && index < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      days[index],
                      style: GoogleFonts.montserrat(
                        textStyle: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 32,
            ),
          ),
          // Left titles (mood values)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Only show whole numbers
                if (value == value.roundToDouble() && value > 0) {
                  String title = '';
                  switch (value.toInt()) {
                    case 1:
                      title = 'Sad';
                      break;
                    case 2:
                      title = 'Calm';
                      break;
                    case 3:
                      title = 'Happy';
                      break;
                    case 4:
                      title = 'Angry';
                      break;
                    case 5:
                      title = 'Relaxed';
                      break;
                    default:
                      return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      title,
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 60, // More space for mood names
              interval: 1,
            ),
          ),
          // Don't show top titles
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          // Don't show right titles
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.shade800.withOpacity(0.9),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final int moodValue = rod.toY.round();
              String mood = "None";
              
              switch (moodValue) {
                case 1:
                  mood = "Sad";
                  break;
                case 2:
                  mood = "Calm";
                  break;
                case 3:
                  mood = "Happy";
                  break;
                case 4:
                  mood = "Angry";
                  break;
                case 5:
                  mood = "Relaxed";
                  break;
                default:
                  mood = "None";
              }
              
              final days = weeklyMoods.keys.toList();
              final day = days[group.x.toInt()];
              
              return BarTooltipItem(
                '$day: $mood',
                GoogleFonts.montserrat(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
        barGroups: barGroups,
      ),
      swapAnimationDuration: const Duration(milliseconds: 500),
      swapAnimationCurve: Curves.easeInOut,
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
              contentPadding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
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
                              
                              setState(() {
                                selectedMood = mood;
                                
                                // Map the mood to a value for the chart
                                int moodValue = 3; // Default (Happy)
                                if (mood == "Sad") moodValue = 1;
                                if (mood == "Calm") moodValue = 2;
                                if (mood == "Happy") moodValue = 3;
                                if (mood == "Angry") moodValue = 4;
                                if (mood == "Relaxed") moodValue = 5;
                                
                                // Update today's mood in the mock data
                                final today = DateTime.now().weekday - 1; // 0 = Monday
                                final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                                weeklyMoods[days[today]] = moodValue;
                              });
                              
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
                              await Future.delayed(const Duration(milliseconds: 300));
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => GifScreen(
                                    mood: mood,
                                  ),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(0.0, 0.2);
                                    const end = Offset.zero;
                                    const curve = Curves.easeOutCubic;
                                    
                                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                    
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
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
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
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
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