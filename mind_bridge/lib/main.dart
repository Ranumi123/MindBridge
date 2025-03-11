import 'package:flutter/material.dart';

// Import your screens
import 'views/home/home_page.dart';
import 'views/chatbot/chatbot_page.dart';
import 'views/forum/screens/group_selection_screen.dart';
import 'views/forum/screens/chat_list_screen.dart';
import 'views/forum/screens/group_chat_screen.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 213, 185, 185),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2.0,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          shadowColor: Colors.grey.withOpacity(0.5),
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/chatbot': (context) => ChatScreen(),
        '/chatforum': (context) => const GroupSelectionScreen(),
        '/chatlist': (context) => const ChatListScreen(),
        '/chatdetail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return GroupChatScreen(group: args);
        },
        '/moodtracker': (context) => const MoodTrackerPage(),
      },
    );
  }
}
