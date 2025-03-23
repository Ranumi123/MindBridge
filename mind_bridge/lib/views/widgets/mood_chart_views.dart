import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodChartView extends StatelessWidget {
  final Animation<double> animation;
  final Map<String, int> weeklyMoods;
  final Map<String, Map<String, dynamic>> moodData;

  const MoodChartView({
    Key? key,
    required this.animation,
    required this.weeklyMoods,
    required this.moodData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
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
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
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
                                            borderRadius:
                                            BorderRadius.circular(4),
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
              toY: moodValue > 0
                  ? moodValue.toDouble()
                  : 0.2, // Small bar for empty days
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
            tooltipPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
}
