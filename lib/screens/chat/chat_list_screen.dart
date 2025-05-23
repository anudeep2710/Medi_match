import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medimatch/screens/chat/chat_screen.dart';
import 'package:medimatch/screens/chat/new_chat_screen.dart';
import 'package:medimatch/services/firebase_chat_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseChatService _chatService = FirebaseChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    // Ensure user is authenticated and profile is updated
    final user = _auth.currentUser;
    if (user != null) {
      print('🔐 User authenticated: ${user.uid} - ${user.email}');
      try {
        await _chatService.updateUserProfile(
          displayName: user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous User',
          photoUrl: user.photoURL,
        );
        await _chatService.setUserOnlineStatus(true);
        print('✅ User profile updated successfully');
      } catch (e) {
        print('❌ Error updating user profile: $e');
      }
    } else {
      print('❌ No user authenticated');
    }
  }

  @override
  void dispose() {
    // Set user offline when leaving chat
    _chatService.setUserOnlineStatus(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chats')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Please log in to access chat'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('💬 Live Chat'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _navigateToNewChat(context),
            tooltip: 'Start New Chat',
          ),
        ],
      ),
      body: StreamBuilder<List<ChatConversation>>(
        stream: _chatService.getConversationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return _buildEmptyState();
          }

          return _buildConversationsList(conversations);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNewChat(context),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Connect with other users to share medicine information and start meaningful conversations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToNewChat(context),
              icon: const Icon(Icons.add_comment),
              label: const Text('Start Your First Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationsList(List<ChatConversation> conversations) {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        final currentUserId = _auth.currentUser?.uid ?? '';
        final otherUserName = conversation.getOtherParticipantName(currentUserId);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.withOpacity(0.2),
              child: Text(
                otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              otherUserName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.lastMessage.isNotEmpty
                      ? conversation.lastMessage
                      : 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: conversation.lastMessage.isNotEmpty
                        ? Colors.grey.shade700
                        : Colors.grey.shade500,
                  ),
                ),
                if (conversation.lastMessageTime != null)
                  Text(
                    _formatTime(conversation.lastMessageTime!),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    conversationID: conversation.id,
                    targetUserID: conversation.participants.firstWhere(
                      (id) => id != currentUserId,
                      orElse: () => '',
                    ),
                    targetUserName: otherUserName,
                    isGroupChat: false,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToNewChat(BuildContext context) async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => const NewChatScreen(),
      ),
    );

    if (result != null) {
      final otherUserId = result['userId']!;
      final otherUserName = result['userName']!;

      try {
        // Create conversation with the selected user
        final conversationId = await _chatService.createConversation(
          otherUserId,
          otherUserName,
        );

        // Navigate to the chat screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                conversationID: conversationId,
                targetUserID: otherUserId,
                targetUserName: otherUserName,
                isGroupChat: false,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating conversation: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

/// Model class for a conversation
class ConversationInfo {
  final String id;
  final String name;
  final String? lastMessage;
  final int unreadCount;
  final bool isGroup;
  final DateTime? lastMessageTime;

  ConversationInfo({
    required this.id,
    required this.name,
    this.lastMessage,
    this.unreadCount = 0,
    this.isGroup = false,
    this.lastMessageTime,
  });
}
