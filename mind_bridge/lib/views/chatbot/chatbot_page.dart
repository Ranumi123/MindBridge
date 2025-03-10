import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/message_model.dart';
import '../widgets/chat_bubble.dart';
import 'widgets/loading_indicator.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isBackendAvailable = true; // Set to true to connect to the backend
<<<<<<< Updated upstream
  String _backendUrl = 'http://172.20.10.2:5001/chat'; // Update with your backend URL
=======
  String _backendUrl =
      'http://192.168.1.2:5001/chat'; // Update with your backend URL
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add(Message(
        role: 'user',
        content: message,
        timestamp: DateTime.now(), // Add timestamp
      ));
      _isLoading = true;
    });

    if (_isBackendAvailable) {
      try {
        print('Sending request to: $_backendUrl'); // Debug log
        final response = await http.post(
          Uri.parse(_backendUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': message, 'userId': '12345'}), // Add userId for emergency contacts
        );

        print('Response status code: ${response.statusCode}'); // Debug log
        print('Response body: ${response.body}'); // Debug log

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _messages.add(Message(
              role: 'bot',
              content: data['reply'], // Use 'reply' as per your backend response
              timestamp: DateTime.now(), // Add timestamp
            ));
            _isLoading = false;
          });

          // Check if emergency contacts have been notified (based on backend response)
          if (data['status'] == 'crisis') {
            _showSuicidalThoughtWarning();
          }
        } else if (response.statusCode == 400) {
          // Handle harmful or suicidal text detection
          final data = jsonDecode(response.body);
          final errorMessage = data['error'];

          if (errorMessage.contains("Suicidal thoughts detected")) {
            // Show a warning to the user
            _showSuicidalThoughtWarning();
          }

          setState(() {
            _messages.add(Message(
              role: 'bot',
              content: errorMessage,
              timestamp: DateTime.now(), // Add timestamp
            ));
            _isLoading = false;
          });
        } else {
          _handleError('Error: Server returned ${response.statusCode}');
        }
      } catch (e) {
        print('Error details: $e'); // Debug log
        _handleError('Error: Connection failed - $e');
        // Fallback to mock response if backend is unavailable
        _handleMockResponse(message);
      }
    } else {
      _handleMockResponse(message);
    }
  }

  void _showSuicidalThoughtWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help is on the way!'),
        content: Text(
            'We detected that you might be in distress. Your emergency contacts have been notified. Please stay safe.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleError(String errorMessage) {
    setState(() {
      _messages.add(Message(
        role: 'bot',
        content: errorMessage,
        timestamp: DateTime.now(), // Add timestamp
      ));
      _isLoading = false;
    });
  }

  void _handleMockResponse(String userMessage) {
    String response = "I'm a mock chatbot. Backend is not connected yet.";

    if (userMessage.toLowerCase().contains('hello') ||
        userMessage.toLowerCase().contains('hi')) {
      response = "Hello! I'm a chatbot. How can I assist you today?";
    } else if (userMessage.toLowerCase().contains('how are you')) {
      response = "I'm just a bot, but I'm here to help you!";
    } else if (userMessage.toLowerCase().contains('help')) {
      response = "This is a development version. Please connect to a backend.";
    }

    setState(() {
      _messages.add(Message(
        role: 'bot',
        content: response,
        timestamp: DateTime.now(), // Add timestamp
      ));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chatbot',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        shadowColor: Colors.purpleAccent.withOpacity(0.5),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blueAccent.withOpacity(0.1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            if (!_isBackendAvailable)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber[100]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.lightBlueAccent),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Development mode: Backend not connected',
                        style: TextStyle(fontSize: 12, color: Colors.blueAccent[800]),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatBubble(
                    message: message.content,
                    isUser: message.role == 'user',
                    timestamp: message.timestamp,
                  );
                },
              ),
            ),
            if (_isLoading) LoadingIndicator(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          final message = _controller.text.trim();
                          if (message.isNotEmpty) {
                            _sendMessage(message);
                            _controller.clear();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please enter a message')),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
