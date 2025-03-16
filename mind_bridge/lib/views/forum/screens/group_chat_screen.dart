import 'package:flutter/material.dart';

// Define models inline to avoid import errors
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

class MessageModel {
  final String id;
  final String message;
  final String sender;
  final DateTime timestamp;
  final bool isMe;

  MessageModel({
    required this.id,
    required this.message,
    required this.sender,
    required this.timestamp,
    this.isMe = false,
  });

  // Format the timestamp for display
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

// Chat bubble widget directly defined in this file
class ChatBubble extends StatelessWidget {
  final MessageModel message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: message.isMe 
                ? const Color(0xFFDCF8C6) // Light green for sent messages
                : Colors.white, // White for received messages
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message.sender,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              
              Text(
                message.message,
                style: const TextStyle(fontSize: 16),
              ),
              
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(width: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.formattedTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (message.isMe) ...[
                          const SizedBox(width: 3),
                          Icon(
                            Icons.done_all,
                            size: 14,
                            color: Colors.blue.shade600,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple repository implementation
class ChatRepository {
  // Mock messages
  static final Map<String, List<MessageModel>> _mockMessages = {};

  Future<List<MessageModel>> getMessages(String groupId) async {
    // Return mock data 
    if (!_mockMessages.containsKey(groupId)) {
      _mockMessages[groupId] = [
        MessageModel(
          id: '1',
          message: 'Welcome to the group!',
          sender: 'Admin',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    }
    return _mockMessages[groupId]!;
  }

  Future<void> sendMessage(String groupId, String message) async {
    // Store message locally
    if (!_mockMessages.containsKey(groupId)) {
      _mockMessages[groupId] = [];
    }
    
    _mockMessages[groupId]!.add(
      MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: message,
        sender: 'You',
        timestamp: DateTime.now(),
        isMe: true,
      ),
    );
  }
}

class GroupChatScreen extends StatefulWidget {
  final ChatGroup group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatRepository _chatRepository = ChatRepository();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _chatRepository.getMessages(widget.group.id);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        // Scroll to bottom after messages load
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load messages: ${e.toString()}')),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients && _messages.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    // Clear text field immediately for better UX
    _messageController.clear();
    
    // Add optimistic message to the UI
    final optimisticMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: messageText,
      sender: 'You',
      timestamp: DateTime.now(),
      isMe: true,
    );
    
    setState(() {
      _messages.add(optimisticMessage);
      _isSending = true;
    });

    // Scroll to show the new message
    _scrollToBottom();

    try {
      // Send message to server
      await _chatRepository.sendMessage(widget.group.id, messageText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leadingWidth: 40,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.teal.shade200,
              child: Text(
                widget.group.name.substring(0, 1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.group.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.group.members,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // WhatsApp-like chat background
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                // Light pattern background
                color: Colors.grey.shade200,
                image: const DecorationImage(
                  image: NetworkImage('https://i.pinimg.com/originals/97/c0/07/97c00759d90d786d9b6096d274ad3e07.png'),
                  repeat: ImageRepeat.repeat,
                  opacity: 0.2,
                ),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? Center(
                          child: Text(
                            'No messages yet. Say hello!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(10.0),
                          reverse: true, // Show newest messages at the bottom
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            // Reverse the index to show newest at bottom
                            final reverseIndex = _messages.length - 1 - index;
                            return ChatBubble(message: _messages[reverseIndex]);
                          },
                        ),
            ),
          ),
          
          // Message input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            color: Colors.white,
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  color: Colors.grey.shade600,
                  onPressed: () {},
                ),
                
                // Text input field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                
                // Camera button
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  color: Colors.grey.shade600,
                  onPressed: () {},
                ),
                
                // Send button
                _messageController.text.isEmpty && !_isSending
                    ? IconButton(
                        icon: const Icon(Icons.mic),
                        color: Colors.teal,
                        onPressed: () {},
                      )
                    : IconButton(
                        icon: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                        color: Colors.teal,
                        onPressed: _isSending ? null : _sendMessage,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}