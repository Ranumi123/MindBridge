import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import 'gif_screen.dart';

class MoodTrackerPage extends StatefulWidget {
  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  final TextEditingController _textController = TextEditingController();
  String? selectedMood;
  final List<String> moodOptions = ["😢", "😞", "😐", "😊", "😄"];
  int _selectedIndex = 0;

  void _saveMood() {
    if (selectedMood == null && _textController.text.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GifScreen()),
    );

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Mood Tracker"),
        backgroundColor: Color(0xFF2DABCA),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            Text("How are you feeling today?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: moodOptions.map((mood) => ElevatedButton(
                onPressed: () => setState(() => selectedMood = mood),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMood == mood ? Color(0xFF3CDFCA) : Colors.transparent,
                  side: BorderSide(color: selectedMood == mood ? Colors.blueAccent : Colors.transparent, width: 2),
                  minimumSize: Size(60, 60),
                ),
                child: Text(mood, style: TextStyle(fontSize: 30)),
              )).toList(),
            ),
            SizedBox(height: 20),
            Text("Express yourself in words ✨", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Type your feelings here...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveMood, child: Text("Submit")),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
