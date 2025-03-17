import 'package:flutter/material.dart';
import 'views/home/home_page.dart';
import 'views/chatbot/chatbot_page.dart';
import 'views/forum/screens/group_selection_screen.dart';
import 'views/forum/screens/chat_list_screen.dart';
// We'll handle these screens differently
// import 'views/forum/screens/group_chat_screen.dart';
// import 'views/forum/screens/group_details_screen.dart';
import 'views/mood_tracker/moodtracker_page.dart';
import 'views/welcome_screen/welcome_page.dart'; // Import the welcome page
import 'views/login_page/login_page.dart'; // Import the login page
import 'views/signup_page/signup_page.dart'; // Import the signup page
import 'views/privacy_settings_page/privacy_setting_page.dart'; // Import privacy settings page


// Define ChatGroup class directly in main.dart to avoid import issues
class ChatGroup {
  final String id;
  final String name;
  final String members;
  final String description;
  final List<String> membersList;

  ChatGroup({
    required this.id,
    required this.name,
    required this.members,
    this.description = '',
    this.membersList = const [],
  });
}

// Simple placeholder screen for when we need to redirect to chat
class SimpleChatScreen extends StatelessWidget {
  final Map<String, dynamic> groupData;

  const SimpleChatScreen({Key? key, required this.groupData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupData['name'] ?? 'Chat'),
        backgroundColor: const Color.fromARGB(255, 63, 218, 203),
      ),
      body: Center(
        child: Text('Chat screen for ${groupData['name']}'),
      ),
    );
  }
}

// Simple placeholder for group details
class SimpleGroupDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> groupData;

  const SimpleGroupDetailsScreen({Key? key, required this.groupData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupData['name'] ?? 'Group Details'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text('Group details for ${groupData['name']}'),
      ),
    );
  }
}


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
      // Start with the welcome page as the initial route
      initialRoute: '/welcome',
      routes: {
        // Authentication routes
        '/welcome': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/privacy_settings': (context) => PrivacySettingsPage(),

        // Main app routes
        '/home': (context) => HomePage(),
        '/chatbot': (context) => ChatbotPage(),
        '/moodtracker': (context) => MoodTrackerPage(),
        '/chatforum': (context) => const GroupSelectionScreen(),
        '/chatlist': (context) => const ChatListScreen(),
      },
      // Use onGenerateRoute for dynamic routes that need parameters
      onGenerateRoute: (settings) {
        if (settings.name == '/chatdetail') {
          // Check if we have the right parameter type
          final args = settings.arguments;

          // If it's a map (most likely case from older parts of the app)
          if (args is Map<String, dynamic>) {
            try {
              // Use the simple chat screen with map data
              return MaterialPageRoute(
                builder: (context) => SimpleChatScreen(groupData: args),
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

          // If it's a map (most likely case)
          if (args is Map<String, dynamic>) {
            try {
              // Use the simple details screen with map data
              return MaterialPageRoute(
                builder: (context) => SimpleGroupDetailsScreen(groupData: args),
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
}