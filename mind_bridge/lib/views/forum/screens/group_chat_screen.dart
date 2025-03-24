import 'package:flutter/material.dart';
import 'toxic_words_filter.dart'; // Local import in the same directory

// Import your models with relative paths and prefixes
import '../../models/chat_group_model.dart' as models; // Using prefix to avoid ambiguity
import '../../models/message_model_new.dart' as models; // Using prefix to avoid ambiguity
import '../repositories/chat_repository.dart'; // Repository import

class ChatBubble extends StatelessWidget {
  final models.MessageModel message; // Using the prefix to specify which MessageModel
  final bool isAnonymous;

  const ChatBubble({
    super.key, 
    required this.message,
    this.isAnonymous = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final anonymousColor = const Color(0xFF6E01A1); // Deep purple
    
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
                ? (message.sender == 'Anonymous' ? anonymousColor.withOpacity(0.3) : const Color(0xFFDCF8C6))
                : Colors.white,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.sender,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: message.sender == 'Anonymous' ? anonymousColor : Colors.blue.shade800,
                        ),
                      ),
                      if (message.sender == 'Anonymous') ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.visibility_off,
                          size: 12,
                          color: anonymousColor,
                        ),
                      ],
                    ],
                  ),
                ),
              
              Text(
                message.message,
                style: TextStyle(
                  fontSize: 16,
                  color: message.isMe && message.sender == 'Anonymous' 
                      ? const Color(0xFF4A0072) // Darker purple color
                      : Colors.black,
                ),
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
                            color: message.sender == 'Anonymous' 
                                ? anonymousColor 
                                : Colors.blue.shade600,
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

class GroupChatScreen extends StatefulWidget {
  final models.ChatGroup group; // Using the prefix to specify which ChatGroup
  final bool isAnonymous;

  const GroupChatScreen({
    super.key, 
    required this.group, 
    this.isAnonymous = false,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final ChatRepository _chatRepository = ChatRepository();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  List<models.MessageModel> _messages = []; // Using the prefix for the list type
  bool _isLoading = true;
  bool _isSending = false;

  // Define app color scheme
  static const Color primaryColor = Color(0xFF4B9FE1); // Blue
  static const Color accentColor = Color(0xFF1EBBD7); // Teal
  static const Color tertiaryColor = Color(0xFF20E4B5); // Turquoise
  
  // Define anonymous mode colors
  static const Color anonymousColor = Color(0xFF6E01A1); // Deep purple
  static const Color anonymousDarkColor = Color(0xFF4A0072); // Darker purple for text
  
  // Define warning color for toxic content
  static const Color warningColor = Color(0xFFFF3D00); // Deep orange/red

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
      final repositoryMessages = await _chatRepository.getMessages(widget.group.id);
      
      // Convert repository MessageModel objects to models.MessageModel objects
      final convertedMessages = repositoryMessages.map((repoMsg) => models.MessageModel(
        id: repoMsg.id,
        message: repoMsg.message,
        sender: repoMsg.sender,
        timestamp: repoMsg.timestamp,
        isMe: repoMsg.isMe,
      )).toList();
      
      if (mounted) {
        setState(() {
          _messages = convertedMessages;
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
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    // Check for toxic words before sending
    final toxicCheck = ToxicWordsFilter.containsToxicWord(messageText);
    if (toxicCheck['containsToxicWord']) {
      // Show error dialog if toxic word is found
      _showToxicWordWarning(toxicCheck['toxicWord']);
      return;
    }

    // Clear text field immediately for better UX
    _messageController.clear();
    
    // Add optimistic message to the UI with anonymous sender if enabled
    final optimisticMessage = models.MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: messageText,
      sender: widget.isAnonymous ? 'Anonymous' : 'You',
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

  // Show warning dialog for toxic words
  void _showToxicWordWarning(String toxicWord) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: warningColor, size: 28),
            const SizedBox(width: 8),
            const Text('Inappropriate Content'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black87, fontSize: 16),
            children: [
              TextSpan(
                text: 'Your message contains inappropriate language ',
              ),
              TextSpan(
                text: '("$toxicWord")',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: '. Please be respectful and considerate of others in this community.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('EDIT MESSAGE'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Add method to leave the group
  Future<void> _leaveGroup() async {
    // Show confirmation dialog
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Are you sure you want to leave "${widget.group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('LEAVE'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    ) ?? false;

    if (shouldLeave) {
      // Navigate back to group selection screen
      if (mounted) {
        Navigator.of(context).pop();
        // Show confirmation snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You left "${widget.group.name}"')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.isAnonymous ? anonymousColor : primaryColor,
        leadingWidth: 40,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: widget.isAnonymous ? anonymousColor.withOpacity(0.7) : accentColor,
              child: widget.isAnonymous
                  ? const Icon(Icons.visibility_off, color: Colors.white)
                  : Text(
                      widget.group.name.isNotEmpty ? widget.group.name[0] : '?',
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
                  Row(
                    children: [
                      Text(
                        widget.group.members,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      if (widget.isAnonymous) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white38, width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.visibility_off, size: 12, color: Colors.white),
                              SizedBox(width: 2),
                              Text(
                                'ANONYMOUS',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Add leave group option in the app bar menu
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'leave') {
                _leaveGroup();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Leave group', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
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
                image: DecorationImage(
                  image: const NetworkImage('https://i.pinimg.com/originals/97/c0/07/97c00759d90d786d9b6096d274ad3e07.png'),
                  repeat: ImageRepeat.repeat,
                  opacity: widget.isAnonymous ? 0.1 : 0.2,
                  colorFilter: widget.isAnonymous
                      ? ColorFilter.mode(anonymousColor.withOpacity(0.05), BlendMode.overlay)
                      : null,
                ),
              ),
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: widget.isAnonymous ? anonymousColor : primaryColor,
                      ),
                    )
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isAnonymous ? Icons.visibility_off : Icons.chat_bubble_outline,
                                size: 48,
                                color: widget.isAnonymous 
                                    ? anonymousColor.withOpacity(0.5)
                                    : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.isAnonymous
                                    ? 'No messages yet. Say hello anonymously!'
                                    : 'No messages yet. Say hello!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: widget.isAnonymous
                                      ? anonymousColor.withOpacity(0.7)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(10.0),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return ChatBubble(
                              message: _messages[index],
                              isAnonymous: widget.isAnonymous,
                            );
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
                  color: widget.isAnonymous ? anonymousColor.withOpacity(0.6) : Colors.grey.shade600,
                  onPressed: () {},
                ),
                
                // Text input field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: widget.isAnonymous 
                          ? 'Type as Anonymous' 
                          : 'Type a message',
                      hintStyle: TextStyle(
                        color: widget.isAnonymous 
                            ? anonymousColor.withOpacity(0.6)  
                            : Colors.grey.shade500,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: widget.isAnonymous
                          ? anonymousColor.withOpacity(0.05)
                          : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      prefixIcon: widget.isAnonymous 
                          ? const Icon(Icons.visibility_off, color: anonymousColor)
                          : null,
                      enabledBorder: widget.isAnonymous
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: anonymousColor.withOpacity(0.3)),
                            )
                          : null,
                      focusedBorder: widget.isAnonymous
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: anonymousColor),
                            )
                          : null,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => _sendMessage(),
                    style: TextStyle(
                      color: widget.isAnonymous ? anonymousDarkColor : null,
                    ),
                  ),
                ),
                
                // Send button
                IconButton(
                  icon: _isSending
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: widget.isAnonymous ? anonymousColor : primaryColor,
                          ),
                        )
                      : Icon(
                          Icons.send,
                          color: widget.isAnonymous ? anonymousColor : primaryColor,
                        ),
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