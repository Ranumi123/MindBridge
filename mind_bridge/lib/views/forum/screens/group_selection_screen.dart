import 'package:flutter/material.dart';
import 'group_details_screen.dart';

// Define ChatGroup class directly in this file to resolve the import error
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

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    List<String> membersListData = [];
    if (json.containsKey('membersList') && json['membersList'] != null) {
      membersListData = List<String>.from(json['membersList']);
    }

    return ChatGroup(
      id: json['id'],
      name: json['name'],
      members: json['members'],
      description: json['description'] ?? '',
      membersList: membersListData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'description': description,
      'membersList': membersList,
    };
  }
}

// Define ChatRepository class directly in this file to resolve the import error
class ChatRepository {
  final List<ChatGroup> _mockGroups = [
    ChatGroup(
      id: '1',
      name: 'Group 1',
      members: '0/10',
      description:
          'Discuss the latest tech trends and innovations. Share news about gadgets, software, and tech events!',
    ),
    ChatGroup(
      id: '2',
      name: 'Group 2',
      members: '0/10',
      description:
          'Stay fit and healthy with others! Share workout routines, nutrition tips, and fitness motivation.',
    ),
    ChatGroup(
      id: '3',
      name: 'Group 3',
      members: '0/10',
      description:
          'Share and discuss your favorite books! From classics to contemporary, fiction to non-fiction.',
    ),
    ChatGroup(
      id: '4',
      name: 'Group 4',
      members: '0/10',
      description:
          'Talk about games and play together! PC, console, or mobile - all gamers welcome here.',
    ),
    ChatGroup(
      id: '5',
      name: 'Group 5',
      members: '0/10',
      description:
          'Share your favorite music and artists! Discover new songs, discuss concerts, and connect through music.',
    ),
  ];

  final Map<String, List<dynamic>> _mockMessages = {};

  Future<List<ChatGroup>> getGroups() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockGroups;
  }

  Future<List<dynamic>> getMessages(String groupId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_mockMessages.containsKey(groupId)) {
      _mockMessages[groupId] = [
        {
          'id': '1',
          'message': 'Welcome to the group!',
          'sender': 'Admin',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'isMe': false,
        },
      ];
    }

    return _mockMessages[groupId]!;
  }

  Future<void> sendMessage(String groupId, String message) async {
    if (!_mockMessages.containsKey(groupId)) {
      _mockMessages[groupId] = [];
    }

    _mockMessages[groupId]!.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'message': message,
      'sender': 'You',
      'timestamp': DateTime.now().toIso8601String(),
      'isMe': true,
    });
  }

  Future<bool> joinGroup(String groupId, String username) async {
    final groupIndex = _mockGroups.indexWhere((group) => group.id == groupId);
    if (groupIndex != -1) {
      final parts = _mockGroups[groupIndex].members.split('/');
      final currentMembers = int.parse(parts[0]);
      final maxMembers = int.parse(parts[1]);

      if (currentMembers < maxMembers) {
        _mockGroups[groupIndex] = ChatGroup(
          id: _mockGroups[groupIndex].id,
          name: _mockGroups[groupIndex].name,
          members: '${currentMembers + 1}/$maxMembers',
          description: _mockGroups[groupIndex].description,
          membersList: [...(_mockGroups[groupIndex].membersList), username],
        );
        return true;
      }
    }
    return false;
  }
}

// Define the app's color scheme
class AppColors {
  static const Color primaryColor = Color(0xFF4B9FE1);
  static const Color accentColor = Color(0xFF1EBBD7);
  static const Color tertiaryColor = Color(0xFF20E4B5);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor, tertiaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [accentColor, tertiaryColor],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  State<GroupSelectionScreen> createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen>
    with SingleTickerProviderStateMixin {
  final ChatRepository _chatRepository = ChatRepository();
  List<ChatGroup> _groups = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _loadGroups();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await _chatRepository.getGroups();
      if (mounted) {
        setState(() {
          _groups = groups;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load groups: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.tertiaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  Future<void> _joinGroup(ChatGroup group) async {
    final membersParts = group.members.split('/');
    final currentMembers = int.parse(membersParts[0]);
    final maxMembers = int.parse(membersParts[1]);

    if (currentMembers >= maxMembers) {
      _showErrorSnackBar('This group is full! Max 10 members.');
      return;
    }

    try {
      final success = await _chatRepository.joinGroup(group.id, 'You');
      if (success) {
        // Reload groups to show updated member count
        await _loadGroups();

        _showSuccessSnackBar('Successfully joined ${group.name}!');

        // Navigate to Group Details Screen
        if (mounted) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  GroupDetailsScreen(group: group),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                var begin = const Offset(1.0, 0.0);
                var end = Offset.zero;
                var curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ).then((_) => _loadGroups()); // Refresh when returning
        }
      } else {
        _showErrorSnackBar('Failed to join group. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Error joining group: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Join a Group',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade100,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accentColor),
                ),
              )
            : FadeTransition(
                opacity: _opacityAnimation,
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                      top: 100, bottom: 20, left: 16, right: 16),
                  itemCount: _groups.length,
                  itemBuilder: (context, index) {
                    final group = _groups[index];

                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final delay = index * 0.2;
                        final slideAnimation = Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              delay.clamp(0.0, 0.9),
                              (delay + 0.4).clamp(0.0, 1.0),
                              curve: Curves.easeOut,
                            ),
                          ),
                        );

                        return SlideTransition(
                          position: slideAnimation,
                          child: child,
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        shadowColor: AppColors.primaryColor.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.grey.shade50,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryColor,
                                    AppColors.accentColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.primaryColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  group.name.isNotEmpty ? group.name[0] : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              group.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  group.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.people,
                                        size: 16,
                                        color: AppColors.primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Members: ${group.members}',
                                        style: const TextStyle(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: AppColors.buttonGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.accentColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => _joinGroup(group),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 0),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Join',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}