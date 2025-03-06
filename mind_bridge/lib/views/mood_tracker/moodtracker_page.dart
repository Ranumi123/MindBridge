import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import 'gif_screen.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  String? selectedMood;
  final List<Map<String, String>> moodOptions = [
    {"image": "assets/images/Happy.jpg", "label": "Happy"},
    {"image": "assets/images/Calm.jpg", "label": "Calm"},
    {"image": "assets/images/Relaxed.png", "label": "Relaxed"},
    {"image": "assets/images/Focus.jpg", "label": "Focused"}
  ];
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool showThumbsUp = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  void _saveMood() {
    if (selectedMood == null && _textController.text.trim().isEmpty) return;

    setState(() {
      showThumbsUp = true;
    });
    _animationController.forward();

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        showThumbsUp = false;
      });
      _animationController.reset();
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mood saved!")));

    setState(() {
      selectedMood = null;
      _textController.clear();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Mood Tracker"),
        backgroundColor: Color(0xFF2DABCA),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.03),
        child: Column(
          children: [
            Text("How are you feeling today?", style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold)),
            SizedBox(height: screenHeight * 0.02),
            Wrap(
              spacing: screenWidth * 0.03,
              runSpacing: screenHeight * 0.015,
              alignment: WrapAlignment.center,
              children: moodOptions.map((mood) =>
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => selectedMood = mood['label']),
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(70, 70),
                        shape: CircleBorder(),
                        backgroundColor: selectedMood == mood['label'] ? Color(0xFF3CDFCA) : Colors.white,
                        side: BorderSide(color: selectedMood == mood['label'] ? Colors.blueAccent : Colors.transparent, width: 2),
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        width: 70,
                        height: 70,
                        child: ClipOval(
                          child: Image.asset(
                            mood['image']!,
                            fit: BoxFit.cover,
                            width: 70,
                            height: 70,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      mood['label']!,
                      style: TextStyle(fontSize: 12)
                    ),
                  ],
                )
              ).toList(),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text("Express yourself in words ✨", style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold)),
            SizedBox(height: screenHeight * 0.01),
            Container(
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  hintText: "Type your feelings here...",
                ),
                maxLines: 1,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(onPressed: _saveMood, child: Text("Submit")),
            SizedBox(height: screenHeight * 0.02),
            if (showThumbsUp)
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: screenWidth * 0.5,
                  height: screenWidth * 0.5,
                  child: Image.asset('assets/gifs/thumbs_up.gif', fit: BoxFit.contain),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
