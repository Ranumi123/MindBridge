import 'package:flutter/material.dart';

// Correctly import your files with proper paths
import 'views/home/home_page.dart';
import 'views/chatbot/chatbot_page.dart';
import 'views/forum/screens/group_chat_screen.dart';
import 'views/forum/screens/chat_list_screen.dart';

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
        '/': (context) => const HomePage(),
        '/chatbot': (context) => ChatScreen(),
        '/chatforum': (context) => const GroupSelectionScreen(),
        '/chatlist': (context) => const ChatListScreen(),
        '/chatdetail': (context) => const GroupSelectionScreen(), // FIXED REFERENCE
        '/moodtracker': (context) => const MoodTrackerPage(),
      },
    );
  }
}
