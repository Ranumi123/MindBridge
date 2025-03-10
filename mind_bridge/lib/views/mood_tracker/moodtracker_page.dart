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

  int currentIndex = 0; // To track the selected mood index

  @override
  void dispose() {
    // Dispose of the PageController when no longer needed
    _pageController.dispose();
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
          
          // Swipeable Mood Selector with Emphasis on the Selected One
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _pageController,
              itemCount: moodOptions.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                  selectedMood = moodOptions[index]['label'];
                });
              },
              itemBuilder: (context, index) {
                final mood = moodOptions[index];
                bool isSelected = index == currentIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  transform: isSelected ? Matrix4.identity()..scale(1.2) : Matrix4.identity(),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentIndex = index;
                            selectedMood = mood['label'];
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Blur or Opacity Effect to emphasize the selected emoji
                            Opacity(
                              opacity: isSelected ? 1.0 : 0.3, // Reduce opacity for non-selected
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
                              color: isSelected ? Colors.black : Colors.grey)),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Mood '$selectedMood' saved!")),
                );
                setState(() {
                  _textController.clear();
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
