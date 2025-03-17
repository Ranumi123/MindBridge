import 'package:flutter/material.dart';
import '../mood_tracker/gif_screen.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  final TextEditingController _textController = TextEditingController();
  String selectedMood = "Happy"; // Default mood

  // Map to store mood emojis
  final Map<String, IconData> moodEmojis = {
    "Happy": Icons.sentiment_very_satisfied,
    "Calm": Icons.sentiment_satisfied,
    "Relaxed": Icons.sentiment_satisfied_alt,
    "Sad": Icons.sentiment_dissatisfied,
    "Angry": Icons.mood_bad,
  };

  // Colors for different moods
  final Map<String, Color> moodColors = {
    "Happy": Colors.amber,
    "Calm": Colors.blue,
    "Relaxed": Colors.green,
    "Sad": Colors.grey,
    "Angry": Colors.red,
  };

  // Mock data for mood statistics
  final Map<String, int> weeklyMoods = {
    "Mon":
        2, // 0 = No data, 1 = Sad, 2 = Calm, 3 = Happy, 4 = Angry, 5 = Relaxed
    "Tue": 0,
    "Wed": 3,
    "Thu": 3,
    "Fri": 2,
    "Sat": 0,
    "Sun": 1,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: moodColors[selectedMood]!.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Mood",
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Emoji display
          Expanded(
            flex: 5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(75),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      moodEmojis[selectedMood]!,
                      size: 80,
                      color: moodColors[selectedMood],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    selectedMood,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mood selection button
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.brown.shade800,
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              icon: const Icon(Icons.mood, color: Colors.white),
              onPressed: () {
                _showMoodSelectionDialog();
              },
            ),
          ),

          const SizedBox(height: 20),

          // Mood Statistics
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Mood Statistics",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {
                          // Show more options
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Weekly chart
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: weeklyMoods.entries.map((entry) {
                        final day = entry.key;
                        final moodValue = entry.value;

                        // Height calculation - 0 means no data
                        final double barHeight =
                            moodValue == 0 ? 10 : 20.0 * moodValue;

                        // Color based on mood value
                        Color barColor =
                            Colors.grey.shade300; // Default for no data
                        if (moodValue > 0) {
                          final List<Color> colors = [
                            Colors.grey.shade300, // No data
                            Colors.grey, // Sad
                            Colors.green, // Calm
                            Colors.amber, // Happy
                            Colors.red, // Angry
                            Colors.blue, // Relaxed
                          ];
                          barColor = colors[moodValue];
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 30,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: moodValue > 0
                                  ? Center(
                                      child: Icon(
                                        [
                                          Icons.sentiment_very_dissatisfied,
                                          Icons.sentiment_dissatisfied,
                                          Icons.sentiment_satisfied,
                                          Icons.sentiment_very_satisfied,
                                          Icons.mood_bad
                                        ][moodValue - 1],
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Text(day,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        );
                      }).toList(),
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

  void _showMoodSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("How are you feeling today?"),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            children: [
              "Happy",
              "Calm",
              "Relaxed",
              "Sad",
              "Angry",
            ]
                .map((mood) => GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMood = mood;
                        });
                        Navigator.of(context).pop();

                        // Show confirmation and navigate to animation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Mood '$mood' saved!")),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GifScreen(
                              mood: mood,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            moodEmojis[mood]!,
                            size: 40,
                            color: moodColors[mood],
                          ),
                          const SizedBox(height: 8),
                          Text(mood),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
