import 'package:flutter/material.dart';
import 'views/home/home_page.dart';
import 'views/chatbot/chatbot_page.dart';
import 'views/forum/chatforum_page.dart';
import 'views/mood_tracker/moodtracker_page.dart';

void main() {
  runApp(MyApp());
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
<<<<<<< Updated upstream
        '/': (context) => HomePage(),
        '/chatbot': (context) => ChatbotPage(),
        '/chatforum': (context) => ChatForumPage(),
        '/moodtracker': (context) => MoodTrackerPage(),
=======
        '/': (context) => const HomePage(),
        '/chatbot': (context) => ChatbotPage(),
        '/chatforum': (context) => const GroupSelectionScreen(),
        '/chatlist': (context) => const ChatListScreen(),
        '/chatdetail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return GroupChatScreen(group: args);
        },
        '/moodtracker': (context) => const MoodTrackerPage(),
>>>>>>> Stashed changes
      },
    );
  }
}
