import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  final TextEditingController _textController = TextEditingController();
  String? selectedMood;
  final PageController _pageController = PageController(viewportFraction: 0.6);

  final List<Map<String, String>> moodOptions = [
    {"image": "assets/images/Happy.jpg", "label": "Happy"},
    {"image": "assets/images/Calm.jpg", "label": "Calm"},
    {"image": "assets/images/Relaxed.png", "label": "Relaxed"},
    {"image": "assets/images/Focus.jpg", "label": "Focused"}
  ];

  int currentIndex = 0; // Tracks the index of the currently selected mood

  @override
  void dispose() {
    _pageController.dispose(); // Release resources used by the PageController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mood Tracker"), backgroundColor: Colors.blueAccent),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text("How are you feeling today?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          const SizedBox(height: 20),

          // Swipeable Mood Selector with Highlight on the Active One
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _pageController,
              itemCount: moodOptions.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index; // Update the selected mood's index
                  selectedMood = moodOptions[index]['label']; // Set the label of the selected mood
                });
              },
              itemBuilder: (context, index) {
                final mood = moodOptions[index];
                bool isSelected = index == currentIndex; // Identify if the mood is the current selection

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  transform: isSelected ? Matrix4.identity()..scale(1.2) : Matrix4.identity(), // Enlarge the selected mood
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentIndex = index; // Set the selected mood on tap
                            selectedMood = mood['label']; // Assign the corresponding label to the mood
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Reduce opacity or blur for unselected moods
                            Opacity(
                              opacity: isSelected ? 1.0 : 0.3, // Dim the non-selected moods
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage(mood['image']!),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(mood['label']!,
                          style: TextStyle(
                              fontSize: isSelected ? 16 : 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.black : Colors.grey)), // Emphasize the selected mood
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          const Text("Express yourself in words ✨",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Type your feelings here...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () {
              if (selectedMood != null || _textController.text.trim().isNotEmpty) {
                // Display a confirmation message when a mood is selected or text is entered
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Mood '$selectedMood' saved!")),
                );
                setState(() {
                  _textController.clear(); // Reset the text input field after submission
                });
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
