import 'package:flutter/material.dart';
import 'views/home/home_page.dart';
import 'views/chatbot/chatbot_page.dart';
import 'views/forum/screens/group_selection_screen.dart';
import 'views/forum/screens/chat_list_screen.dart';
import 'views/forum/screens/group_chat_screen.dart';
import 'views/forum/screens/group_details_screen.dart';
// Remove the problematic import and use the ChatGroup class from group_selection_screen.dart
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
        // Update theme colors to match the WhatsApp-like design
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: const Color.fromARGB(255, 240, 240, 240),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 1.0,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          shadowColor: Colors.grey.withOpacity(0.3),
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.teal,
          secondary: Colors.tealAccent,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/chatbot': (context) => ChatbotPage(),
        '/moodtracker': (context) => MoodTrackerPage(),
        '/chatforum': (context) => const GroupSelectionScreen(),
        '/chatlist': (context) => const ChatListScreen(),
      },
      // Use onGenerateRoute for dynamic routes that need parameters
      onGenerateRoute: (settings) {
        if (settings.name == '/chatdetail') {
          final args = settings.arguments;
          
          // Explicitly import the ChatGroup class from the file where we've defined it
          // Since we've defined it in group_selection_screen.dart
          
          // Handle different types of arguments
          if (args is Map<String, dynamic>) {
            try {
              // Use the ChatGroup constructor from group_selection_screen.dart
              final group = _createChatGroupFromMap(args);
              return MaterialPageRoute(
                builder: (context) => GroupChatScreen(group: group),
              );
            } catch (e) {
              // If conversion fails, show error
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: Center(child: Text('Invalid group data: ${e.toString()}')),
                ),
              );
            }
          }
          
          // For any other type, go to a default screen
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Invalid group data type')),
            ),
          );
        } else if (settings.name == '/groupdetails') {
          final args = settings.arguments;
          
          // Handle different types of arguments
          if (args is Map<String, dynamic>) {
            try {
              // Use the ChatGroup constructor from group_selection_screen.dart
              final group = _createChatGroupFromMap(args);
              
              return MaterialPageRoute(
                builder: (context) => GroupDetailsScreen(group: group),
              );
            } catch (e) {
              // If conversion fails, show error
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: Center(child: Text('Invalid group data: ${e.toString()}')),
                ),
              );
            }
          }
          
          // For any other type, go to a default screen
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Invalid parameters type')),
            ),
          );
        }
        
        // If unknown route, go to home
        return MaterialPageRoute(builder: (context) => HomePage());
      },
    );
  }
  
  // Helper method to create a ChatGroup from a Map
  // This will use the ChatGroup class from group_selection_screen.dart
  dynamic _createChatGroupFromMap(Map<String, dynamic> args) {
    // This function creates a ChatGroup using the constructor syntax
    // It will be automatically resolved to the ChatGroup class in group_selection_screen.dart
    return ChatGroup(
      id: args['id'] ?? '1',
      name: args['name'] ?? 'Group Chat',
      members: args['members'] ?? '1/10',
      description: args['description'] ?? 'No description available',
      membersList: args['membersList'] != null 
          ? List<String>.from(args['membersList']) 
          : ['You'],
    );
  }
}