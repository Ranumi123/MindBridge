import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/message_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/loading_indicator.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isBackendAvailable = true; // Set to true to connect to the backend
  String _backendUrl = 'http://172.20.10.2:5001/chat'; // Update with your backend URL

  // Animation controllers
  late AnimationController _sendButtonController;
  late AnimationController _typingController;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: false);

    // Add welcome message
    _messages.add(Message(
      role: 'bot',
      content: 'Hello! I\'m your Mind Bridge assistant. How can I help you today?',
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    _typingController.dispose();
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
        timestamp: DateTime.now(),
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
          }),
        );

        print('Response status code: ${response.statusCode}'); // Debug log
        print('Response body: ${response.body}'); // Debug log

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _messages.add(Message(
              role: 'bot',
              content: data['reply'],
              timestamp: DateTime.now(),
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
              timestamp: DateTime.now(),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.support, color: Color(0xFF1EBBD7)),
            SizedBox(width: 10),
            Text('Help is on the way!',
              style: TextStyle(color: Color(0xFF1EBBD7)),
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
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF4B9FE1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF4B9FE1).withOpacity(0.3)),
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
              foregroundColor: Color(0xFF4A6572),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1EBBD7),
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
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });

    // Scroll to bottom after error message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _handleMockResponse(String userMessage) {
    // Simulate typing delay for more realistic effect
    Future.delayed(Duration(milliseconds: 1500), () {
      String response = "I'm your Mind Bridge assistant. The backend is not connected yet.";

      if (userMessage.toLowerCase().contains('hello') ||
          userMessage.toLowerCase().contains('hi')) {
        response = "Hello there! I'm here to support you on your mental health journey. How are you feeling today?";
      } else if (userMessage.toLowerCase().contains('how are you')) {
        response = "I'm here and ready to help you! How has your day been going?";
      } else if (userMessage.toLowerCase().contains('help') ||
          userMessage.toLowerCase().contains('sad') ||
          userMessage.toLowerCase().contains('anxious')) {
        response = "I understand that things can be difficult sometimes. Remember that you're not alone, and it's okay to seek support. Would you like to talk about what's on your mind?";
      } else if (userMessage.toLowerCase().contains('thanks') ||
          userMessage.toLowerCase().contains('thank you')) {
        response = "You're very welcome. I'm here anytime you need to talk.";
      }

      if (mounted) {
        setState(() {
          _messages.add(Message(
            role: 'bot',
            content: response,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });

        // Scroll to bottom after mock response
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the theme and colors for consistent styling
    final theme = Theme.of(context);
    final primaryColor = Color(0xFF4B9FE1); // Blue from your app
    final accentColor = Color(0xFF1EBBD7); // Teal from your app
    final tertiaryColor = Color(0xFF20E4B5); // Mint green from your app
    final backgroundColor = Colors.grey[50];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mind Bridge Assistant',
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
              colors: [primaryColor, accentColor, tertiaryColor], // Gradient matching your app
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        shadowColor: accentColor.withOpacity(0.4),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // Show app info or help
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mind Bridge Assistant v1.0'),
                    backgroundColor: accentColor,
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
            image: AssetImage('assets/images/new_bg.png'),
            opacity: 0.05, // More subtle background
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            if (!_isBackendAvailable)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFF9C4).withOpacity(0.7),
                      Color(0xFFFFECB3).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
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

                  // Add animation for new messages
                  return AnimatedBuilder(
                    animation: Listenable.merge([_typingController, _sendButtonController]),
                    builder: (context, child) {
                      // Staggered appearance for each message
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOutQuint,
                        child: AnimatedPadding(
                          duration: Duration(milliseconds: 300),
                          padding: EdgeInsets.only(
                            bottom: 16,
                            top: index == 0 ? 8 : 0,
                          ),
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
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: isUser
                                        ? LinearGradient(
                                      colors: [primaryColor, accentColor],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                        : null,
                                    color: isUser ? null : Colors.white,
                                    borderRadius: BorderRadius.circular(20).copyWith(
                                      bottomLeft: isUser ? Radius.circular(20) : Radius.circular(5),
                                      bottomRight: isUser ? Radius.circular(5) : Radius.circular(20),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isUser
                                            ? primaryColor.withOpacity(0.2)
                                            : Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Message content with animated typing effect for bot
                                      isUser
                                          ? Text(
                                        message.content,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      )
                                          : TypingText(
                                        text: message.content,
                                        style: TextStyle(
                                          color: Colors.black87,
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
                        ),
                      );
                    },
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, -4),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(30),
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
                  SizedBox(width: 12),
                  AnimatedBuilder(
                    animation: _sendButtonController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (0.1 * _sendButtonController.value),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, accentColor, tertiaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.3 * _sendButtonController.value),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          width: 56 + (4 * _sendButtonController.value),
                          height: 56 + (4 * _sendButtonController.value),
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
                                    backgroundColor: accentColor,
                                  ),
                                );
                              }
                            },
                          ),
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
    final primaryColor = Color(0xFF4B9FE1); // Blue from your app
    final accentColor = Color(0xFF1EBBD7); // Teal from your app
    final tertiaryColor = Color(0xFF20E4B5); // Mint green from your app

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _typingController,
            builder: (context, child) {
              // Create a staggered effect with different timing for each dot
              final delay = index * 0.3;
              final t = (_typingController.value + delay) % 1.0;

              // Create bouncing effect
              final bounce = math.sin(t * math.pi) * 8;

              // Color interpolation between all three brand colors
              Color dotColor;
              if (t < 0.5) {
                // Interpolate between primaryColor and accentColor
                dotColor = Color.lerp(primaryColor, accentColor, t * 2)!;
              } else {
                // Interpolate between accentColor and tertiaryColor
                dotColor = Color.lerp(accentColor, tertiaryColor, (t - 0.5) * 2)!;
              }

              return Padding(
                padding: EdgeInsets.only(right: 5),
                child: Transform.translate(
                  offset: Offset(0, -bounce),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: dotColor,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: dotColor.withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 0.5,
                          offset: Offset(0, 2 + bounce/4),
                        ),
                      ],
                    ),
                    // Add a subtle glow effect
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildBotAvatar({bool smaller = false}) {
    final primaryColor = Color(0xFF4B9FE1); // Blue from your app
    final tertiaryColor = Color(0xFF20E4B5); // Mint green from your app
    final size = smaller ? 32.0 : 38.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.2), tertiaryColor.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.psychology_rounded, // Mental health icon
          size: size * 0.6,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    final primaryColor = Color(0xFF4B9FE1); // Blue from your app
    final accentColor = Color(0xFF1EBBD7); // Teal from your app

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
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

// Typing text animation widget
class TypingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const TypingText({
    Key? key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  _TypingTextState createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> with SingleTickerProviderStateMixin {
  late String _displayedText;
  late int _characterCount;
  late AnimationController _controller;
  late Animation<int> _characterAnimation;

  @override
  void initState() {
    super.initState();
    _displayedText = "";
    _characterCount = 0;

    final typingSpeed = widget.text.length > 100
        ? Duration(milliseconds: widget.text.length * 15)
        : Duration(milliseconds: widget.text.length * 30);

    _controller = AnimationController(
      vsync: this,
      duration: typingSpeed,
    );

    _characterAnimation = IntTween(begin: 0, end: widget.text.length).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    )..addListener(() {
      setState(() {
        _characterCount = _characterAnimation.value;
        _displayedText = widget.text.substring(0, _characterCount);
      });
    });

    // Start the animation
    _controller.forward();
  }

  @override
  void didUpdateWidget(TypingText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.text != oldWidget.text) {
      _displayedText = widget.text;
      _characterCount = widget.text.length;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
}