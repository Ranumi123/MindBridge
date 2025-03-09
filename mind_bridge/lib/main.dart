import 'package:flutter/material.dart';

// Import your screens correctly
import 'views/home/home_page.dart';
import 'views/chatbot/chatbot_page.dart';
import 'views/forum/screens/group_selection_screen.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/chatbot': (context) => ChatScreen(),
        '/chatforum': (context) => const GroupSelectionScreen(),
        '/chatlist': (context) => const ChatListScreen(),
        '/moodtracker': (context) => const MoodTrackerPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/groupchat') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => GroupChatScreen(groupName: args['groupName']),
          );
        }
        return null; // Return null for undefined routes
      },
    );
  }
}
