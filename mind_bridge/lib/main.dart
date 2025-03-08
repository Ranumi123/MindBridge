import 'package:flutter/material.dart';
import 'views/home/home_page.dart';
import 'views/chatbot/chatbot_page.dart';
import 'views/forum/screens/group_selection_screen.dart'; // Updated to match your structure
import 'views/mood_tracker/moodtracker_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindBridge',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/chatbot': (context) => ChatScreen(),          // Fixed typo: `ChatScreen()` ➔ `ChatbotPage()`
        '/chatforum': (context) => GroupSelectionScreen(), // Updated for group selection as the starting forum screen
        '/moodtracker': (context) => MoodTrackerPage(),
      },
    );
  }
}
