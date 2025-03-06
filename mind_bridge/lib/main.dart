import 'package:flutter/material.dart';
import 'views/home/home_page.dart';
import 'views/chatbot/chatbot_page.dart';
import 'views/forum/chatforum_page.dart';
import 'views/mood_tracker/moodtracker_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindBridge',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/chatbot': (context) => ChatbotPage(),
        '/chatforum': (context) => ChatForumPage(),
        '/moodtracker': (context) => MoodTrackerPage(),
      },
    );
  }
}
