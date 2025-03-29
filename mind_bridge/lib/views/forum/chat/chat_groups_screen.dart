// lib/chat/chat_groups_screen.dart
import 'package:flutter/material.dart';
import '../../models/chat_group.dart';
import 'package:mind_bridge/services/chat_api_service.dart';
import '../../widgets/animated_gradient_background.dart';
import 'package:mind_bridge/views/forum/chat/chat_detail_screen.dart';

class ChatGroupsScreen extends StatefulWidget {
  final String username;

  const ChatGroupsScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ChatGroupsScreenState createState() => _ChatGroupsScreenState();
}

class _ChatGroupsScreenState extends State<ChatGroupsScreen> with SingleTickerProviderStateMixin {
  late ChatApiService _chatApiService;
  List<ChatGroup> _chatGroups = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _chatApiService = ChatApiService(currentUsername: widget.username);

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _loadChatGroups();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadChatGroups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final groups = await _chatApiService.getChatGroups();
      setState(() {
        _chatGroups = groups;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load chat groups. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _joinGroup(ChatGroup group) async {
    if (group.isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This group is full! Max 10 members.')),
      );
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      final success = await _chatApiService.joinChatGroup(group.id);
      if (success) {
        setState(() {
          // Update the local group data
          final index = _chatGroups.indexWhere((g) => g.id == group.id);
          if (index != -1) {
            _chatGroups[index].isJoined = true;

            // Update member count
            final parts = _chatGroups[index].members.split('/');
            if (parts.length == 2) {
              final current = int.parse(parts[0]);
              _chatGroups[index] = ChatGroup(
                id: group.id,
                name: group.name,
                description: group.description,
                members: '${current + 1}/${parts[1]}',
                membersList: [...group.membersList, widget.username],
                createdAt: group.createdAt,
                isJoined: true,
              );
            }
          }
        });

        // Navigate to chat detail screen
        _navigateToChatDetail(group);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _leaveGroup(ChatGroup group) async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final success = await _chatApiService.leaveChatGroup(group.id);
      if (success) {
        setState(() {
          // Update the local group data
          final index = _chatGroups.indexWhere((g) => g.id == group.id);
          if (index != -1) {
            _chatGroups[index].isJoined = false;

            // Update member count
            final parts = _chatGroups[index].members.split('/');
            if (parts.length == 2) {
              final current = int.parse(parts[0]);
              _chatGroups[index] = ChatGroup(
                id: group.id,
                name: group.name,
                description: group.description,
                members: '${current - 1}/${parts[1]}',
                membersList: group.membersList.where((member) => member != widget.username).toList(),
                createdAt: group.createdAt,
                isJoined: false,
              );
            }
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have left ${group.name}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  void _navigateToChatDetail(ChatGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          group: group,
          username: widget.username,
          onLeaveGroup: () => _leaveGroup(group),
        ),
      ),
    ).then((_) => _loadChatGroups());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community Chat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF39B0E5),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadChatGroups,
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: RefreshIndicator(
          onRefresh: _loadChatGroups,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
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
              onPressed: _loadChatGroups,
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

    if (_chatGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 60, color: Colors.white70),
            SizedBox(height: 16),
            Text(
              'No chat groups available',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _chatGroups.length,
            itemBuilder: (context, index) {
              final group = _chatGroups[index];
              final isLastItem = index == _chatGroups.length - 1;

              return Transform.translate(
                offset: Offset(0, 30 * (1 - _animationController.value) * (index + 1)),
                child: _buildGroupCard(group, isLastItem),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupCard(ChatGroup group, bool isLastItem) {
    return Card(
      margin: EdgeInsets.only(bottom: isLastItem ? 0 : 16),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: group.isJoined ? () => _navigateToChatDetail(group) : null,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2D3D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: group.isFull
                          ? Colors.red.withOpacity(0.1)
                          : Color(0xFF39B0E5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      group.members,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: group.isFull ? Colors.red : Color(0xFF39B0E5),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                group.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (group.isJoined)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Joined',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Available',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  if (group.isJoined)
                    Row(
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.logout, size: 18),
                          label: Text('Leave'),
                          onPressed: () => _leaveGroup(group),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: Icon(Icons.forum, size: 18),
                          label: Text('Chat'),
                          onPressed: () => _navigateToChatDetail(group),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF39B0E5),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ],
                    )
                  else
                    ElevatedButton(
                      onPressed: group.isFull ? null : () => _joinGroup(group),
                      child: Text(group.isFull ? 'Full' : 'Join'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: group.isFull ? Colors.grey : Color(0xFF39B0E5),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(horizontal: 24),
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

