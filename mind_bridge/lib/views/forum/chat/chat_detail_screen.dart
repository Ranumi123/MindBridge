// lib/chat/chat_detail_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mind_bridge/views/models/chat_group.dart';
import 'package:mind_bridge/views/models/chat_message.dart';
import 'package:mind_bridge/services/chat_api_service.dart';
import 'package:mind_bridge/services/chat_socket_service.dart';
import 'package:mind_bridge/services/chat_service_manager.dart';
import 'package:mind_bridge/views/widgets/animated_gradient_background.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatGroup group;
  final String username;
  final VoidCallback onLeaveGroup;

  const ChatDetailScreen({
    Key? key,
    required this.group,
    required this.username,
    required this.onLeaveGroup,
  }) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> with TickerProviderStateMixin {
  late ChatApiService _chatApiService;
  late ChatSocketService _chatSocketService;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isAnonymous = false;
  String? _errorMessage;

  Map<String, bool> _typingUsers = {}; // Track users who are typing
  Timer? _typingTimer;

  // Animation controllers
  late AnimationController _slideController;
  late List<AnimationController> _dotControllers;

  @override
  void initState() {
    super.initState();

    // Get API service from ChatServiceManager
    _chatApiService = ChatServiceManager().getChatApiService(widget.username);

    // Setup socket service with callbacks through ChatServiceManager
    _chatSocketService = ChatServiceManager().createSocketService(
      username: widget.username,
      onNewMessage: (dynamic data) => _handleNewMessage(data), // Fixed: using dynamic parameter
      onMemberJoined: _handleMemberJoined,
      onMemberLeft: _handleMemberLeft,
      onMessageError: _handleMessageError,
      onUserTyping: _handleUserTyping,
    );

    // Join socket room for this group
    _chatSocketService.joinGroup(widget.group.id);

    // Init animation controllers
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // Create dot animation controllers
    _dotControllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + (index * 200)),
      )..repeat(reverse: true);
    });

    // Load initial messages
    _loadMessages();

    // Setup typing detection
    _messageController.addListener(_onTyping);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    _slideController.dispose();

    // Dispose dot controllers
    for (var controller in _dotControllers) {
      controller.dispose();
    }

    _typingTimer?.cancel();

    // Leave socket room
    _chatSocketService.leaveGroup(widget.group.id);
    // Note: We don't disconnect the socket here as the ChatServiceManager handles that

    super.dispose();
  }

  // Handle socket events - now accepting dynamic data
  void _handleNewMessage(dynamic messageData) {
    // If it's already a ChatMessage, use it directly
    if (messageData is ChatMessage) {
      if (mounted) {
        setState(() {
          _messages.add(messageData);
        });
        _scrollToBottom();
      }
      return;
    }

    // Otherwise, try to convert it from JSON
    try {
      final message = ChatMessage.fromJson(messageData as Map<String, dynamic>, widget.username);
      if (mounted) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('Error processing message: $e');
      print('Message data received: $messageData');
    }
  }

  void _handleMemberJoined(String groupId, String username, String memberCount) {
    if (groupId == widget.group.id) {
      // Add a system message
      final systemMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        groupId: groupId,
        message: '$username joined the group',
        sender: 'System',
        isAnonymous: false,
        timestamp: DateTime.now(),
        isMe: false,
      );

      setState(() {
        _messages.add(systemMessage);
      });
      _scrollToBottom();

      // Show a snackbar notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$username joined the group'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleMemberLeft(String groupId, String username, String memberCount) {
    if (groupId == widget.group.id) {
      // Add a system message
      final systemMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        groupId: groupId,
        message: '$username left the group',
        sender: 'System',
        isAnonymous: false,
        timestamp: DateTime.now(),
        isMe: false,
      );

      setState(() {
        _messages.add(systemMessage);
      });
      _scrollToBottom();

      // Show a snackbar notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$username left the group'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleMessageError(Map<String, dynamic> error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error['error'] ?? 'Error sending message'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        _isSending = false;
      });
    }
  }

  void _handleUserTyping(Map<String, dynamic> data) {
    final userId = data['userId'] as String;
    final groupId = data['groupId'] as String;
    final isTyping = data['isTyping'] as bool;

    // Only process if for this group and not self
    if (groupId == widget.group.id && userId != widget.username && mounted) {
      setState(() {
        if (isTyping) {
          _typingUsers[userId] = true;
        } else {
          _typingUsers.remove(userId);
        }
      });
    }
  }

  // Typing indicator management
  void _onTyping() {
    // If the user is typing, send typing status
    if (_typingTimer?.isActive ?? false) {
      // Timer is active, so we're already in "typing" state
      _typingTimer!.cancel();
    } else {
      // Send "typing" event
      _chatSocketService.sendTypingStatus(widget.group.id, true);
    }

    // Set timer to stop "typing" status after delay
    _typingTimer = Timer(Duration(seconds: 2), () {
      _chatSocketService.sendTypingStatus(widget.group.id, false);
    });
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final messages = await _chatApiService.getGroupMessages(widget.group.id);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _slideController.forward();
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load messages. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    _messageController.clear();
    _messageFocusNode.requestFocus(); // Keep focus for next message

    try {
      // Use the API to send the message
      await _chatApiService.sendMessage(widget.group.id, message, _isAnonymous);

      // Note: We don't need to add the message to the list manually because
      // we'll receive it via the socket connection in _handleNewMessage

      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    // Add a small delay to ensure the list is built
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final time = '$hour:$minute';

    if (messageDate == today) {
      return time;
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday, $time';
    } else {
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      return '$day/$month, $time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.group.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${widget.group.members} members',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF39B0E5),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Show leave confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Leave Group'),
                  content: Text('Are you sure you want to leave ${widget.group.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        widget.onLeaveGroup();
                        Navigator.pop(context); // Go back to group list
                      },
                      child: Text('Leave', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: Column(
          children: [
            // Typing indicator
            if (_typingUsers.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black.withOpacity(0.05),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Stack(
                        children: [
                          _buildTypingDot(0, 0),
                          _buildTypingDot(10, 1),
                          _buildTypingDot(20, 2),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _typingUsers.length == 1
                          ? '${_typingUsers.keys.first} is typing...'
                          : '${_typingUsers.length} people are typing...',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // Messages List
            Expanded(
              child: _buildMessagesList(),
            ),

            // Message input area
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingDot(double leftPosition, int index) {
    return Positioned(
      left: leftPosition,
      child: AnimatedBuilder(
        animation: _dotControllers[index],
        builder: (context, child) {
          return SizedBox(
            width: 10,
            height: 10,
            child: Transform.scale(
              scale: 0.5 + (_dotControllers[index].value * 0.5),
              child: Opacity(
                opacity: 0.5 + (_dotControllers[index].value * 0.5),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.white70),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadMessages,
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF39B0E5),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 60, color: Colors.white70),
            SizedBox(height: 16),
            Text(
              'No messages yet.\nBe the first to say hello!',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: child,
          ),
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final isSystem = message.sender == 'System';
          final showAvatar = !message.isMe && !isSystem;

          // Group messages by sender and time proximity
          final bool showHeader = index == 0 ||
              _messages[index - 1].sender != message.sender ||
              _messages[index].timestamp.difference(_messages[index - 1].timestamp).inMinutes > 5;

          return Column(
            children: [
              if (isSystem)
                _buildSystemMessage(message)
              else
                _buildMessageBubble(message, showHeader, showAvatar),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSystemMessage(ChatMessage message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool showHeader, bool showAvatar) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar && !message.isMe)
            _buildAvatar(message)
          else if (!message.isMe)
            SizedBox(width: 36),

          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Show sender name header - use displayName for proper anonymous handling
                if (showHeader && !message.isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      message.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: message.isAnonymous ? Colors.grey[700] : Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),

                // Message bubble - always shows the message content regardless of anonymity
                Container(
                  margin: EdgeInsets.only(
                    left: message.isMe ? 50 : 0,
                    right: message.isMe ? 0 : 50,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? Colors.white
                        : (message.isAnonymous ? Colors.grey[300] : Color(0xFF39B0E5)),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message content - always visible
                      Text(
                        message.message,
                        style: TextStyle(
                          color: message.isMe || message.isAnonymous ? Colors.black87 : Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),

                      // Time information
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.timestamp),
                            style: TextStyle(
                              color: message.isMe || message.isAnonymous
                                  ? Colors.grey[600]
                                  : Colors.white70,
                              fontSize: 10,
                            ),
                          ),

                          // Add indicator for anonymous messages
                          if (message.isAnonymous && message.isMe)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.visibility_off,
                                size: 10,
                                color: message.isMe ? Colors.grey[600] : Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: message.isAnonymous ? Colors.grey[400] : Color(0xFF1ED4B5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          message.isAnonymous ? 'A' : message.sender[0].toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Anonymous toggle
          Row(
            children: [
              Switch(
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value;
                  });
                },
                activeColor: Color(0xFF39B0E5),
              ),
              Text(
                'Send as Anonymous',
                style: TextStyle(
                  color: _isAnonymous ? Color(0xFF39B0E5) : Colors.grey[700],
                  fontWeight: _isAnonymous ? FontWeight.bold : FontWeight.normal,
                ),
              ),

              if (_isAnonymous)
                Expanded(
                  child: Text(
                    '(Note: Only your name will be hidden, not your message)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),

          SizedBox(height: 8),

          // Message input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF39B0E5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF39B0E5).withOpacity(0.4),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: _isSending
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Icon(Icons.send, color: Colors.white),
                  onPressed: _isSending ? null : _sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}