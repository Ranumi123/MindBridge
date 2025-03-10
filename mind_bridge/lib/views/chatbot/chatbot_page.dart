import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/message_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/loading_indicator.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isBackendAvailable = true; // Set to true to connect to the backend
  String _backendUrl =
      'http://192.168.1.2:5001/chat'; // Update with your backend URL

  // Animation controller for send button
  late AnimationController _sendButtonController;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add(Message(
        role: 'user',
        content: message,
        timestamp: DateTime.now(), // Add timestamp
      ));
      _isLoading = true;
    });

    // Scroll to bottom after adding message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    if (_isBackendAvailable) {
      try {
        print('Sending request to: $_backendUrl'); // Debug log
        final response = await http.post(
          Uri.parse(_backendUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': message,
            'userId': '12345'
          }), // Add userId for emergency contacts
        );

        print('Response status code: ${response.statusCode}'); // Debug log
        print('Response body: ${response.body}'); // Debug log

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _messages.add(Message(
              role: 'bot',
              content:
              data['reply'], // Use 'reply' as per your backend response
              timestamp: DateTime.now(), // Add timestamp
            ));
            _isLoading = false;
          });

          // Scroll to bottom after receiving response
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

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

          // Scroll to bottom after error message
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.support, color: Colors.red[700]),
            SizedBox(width: 10),
            Text('Help is on the way!',
              style: TextStyle(color: Colors.red[700]),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We detected that you might be in distress. Your emergency contacts have been notified.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('National Suicide Prevention Lifeline',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('1-800-273-8255'),
                  SizedBox(height: 8),
                  Text('Crisis Text Line',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Text HOME to 741741'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
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

    // Scroll to bottom after error message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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

    // Scroll to bottom after mock response
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    // Get the theme and colors for consistent styling
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final backgroundColor = Colors.grey[50];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Assistant',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        shadowColor: Colors.blue.withOpacity(0.4),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // Show app info or help
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('AI Chatbot v1.0'),
                    behavior: SnackBarBehavior.floating,
                  )
              );
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          image: DecorationImage(
            image: AssetImage('assets/images/chat_pattern.png'),
            opacity: 5,
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            if (!_isBackendAvailable)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.amber[100],
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber[800], size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Development mode: Backend not connected',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[900],
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message.role == 'user';
                  final time = _formatTime(message.timestamp);

                  return Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bot avatar
                        if (!isUser) _buildBotAvatar(),

                        SizedBox(width: 8),

                        // Message bubble
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue[700] : Colors.white,
                              borderRadius: BorderRadius.circular(20).copyWith(
                                bottomLeft: isUser ? Radius.circular(20) : Radius.circular(5),
                                bottomRight: isUser ? Radius.circular(5) : Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.content,
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    time,
                                    style: TextStyle(
                                      color: isUser ? Colors.white70 : Colors.black38,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 8),

                        // User avatar
                        if (isUser) _buildUserAvatar(),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.only(left: 24, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildBotAvatar(smaller: true),
                    SizedBox(width: 12),
                    _buildTypingIndicator(),
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        maxLines: 4,
                        minLines: 1,
                        onChanged: (text) {
                          if (text.isNotEmpty) {
                            _sendButtonController.forward();
                          } else {
                            _sendButtonController.reverse();
                          }
                        },
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: _sendButtonController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[700]!, Colors.blue[500]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4 * _sendButtonController.value),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.send_rounded, color: Colors.white),
                          onPressed: () {
                            final message = _controller.text.trim();
                            if (message.isNotEmpty) {
                              _sendMessage(message);
                              _controller.clear();
                              _sendButtonController.reverse();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter a message'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: List.generate(3, (index) {
          return Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: Colors.blue[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBotAvatar({bool smaller = false}) {
    final size = smaller ? 30.0 : 36.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Center(
        child: Icon(
          Icons.android_rounded,
          size: size * 0.6,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 22,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}