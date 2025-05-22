import 'package:flutter/material.dart';
import 'package:medimatch/screens/chat/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<ConversationInfo> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSampleConversations();
  }

  void _loadSampleConversations() {
    setState(() {
      _isLoading = true;
    });

    // For demo purposes, we'll create some sample conversations
    final sampleConversations = [
      ConversationInfo(
        id: 'conversation_1',
        name: 'John Doe',
        lastMessage: 'Hello, do you have any unused medications?',
        unreadCount: 2,
        isGroup: false,
      ),
      ConversationInfo(
        id: 'conversation_2',
        name: 'Medication Donors Group',
        lastMessage: 'I have some unused antibiotics to donate.',
        unreadCount: 5,
        isGroup: true,
      ),
      ConversationInfo(
        id: 'conversation_3',
        name: 'Jane Smith',
        lastMessage: 'Thank you for the medication!',
        unreadCount: 0,
        isGroup: false,
      ),
    ];

    setState(() {
      _conversations = sampleConversations;
      _isLoading = false;
    });
  }

  void _addConversation(ConversationInfo conversation) {
    setState(() {
      // Check if conversation already exists
      final existingIndex = _conversations.indexWhere(
        (conv) => conv.id == conversation.id,
      );

      if (existingIndex >= 0) {
        // Update existing conversation
        _conversations[existingIndex] = conversation;
      } else {
        // Add new conversation
        _conversations.add(conversation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              // Navigate to create group chat screen
              _navigateToNewChat(context, isGroup: true);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? _buildEmptyState()
              : _buildConversationsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNewChat(context),
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a new chat to connect with other users',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToNewChat(context),
            icon: const Icon(Icons.add),
            label: const Text('Start a New Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    return ListView.builder(
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return ListTile(
          leading: CircleAvatar(
            child: conversation.isGroup
                ? const Icon(Icons.group)
                : Text(conversation.name[0].toUpperCase()),
          ),
          title: Text(conversation.name),
          subtitle: Text(
            conversation.lastMessage ?? 'No messages yet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: conversation.unreadCount > 0
              ? CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    conversation.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                )
              : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  conversationID: conversation.id,
                  targetUserID: conversation.id, // Use id as userId
                  targetUserName: conversation.name,
                  isGroupChat: conversation.isGroup,
                ),
              ),
            ).then((_) => _loadSampleConversations());
          },
        );
      },
    );
  }

  void _navigateToNewChat(BuildContext context, {bool isGroup = false}) async {
    // For simplicity, we'll just create a mock conversation
    if (isGroup) {
      final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';
      final groupName = 'New Group Chat';

      final conversation = ConversationInfo(
        id: groupId,
        name: groupName,
        isGroup: true,
      );

      _addConversation(conversation);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            conversationID: conversation.id,
            targetUserID: 'group_member',
            targetUserName: conversation.name,
            isGroupChat: conversation.isGroup,
          ),
        ),
      ).then((_) => _loadSampleConversations());
    } else {
      // Create a one-on-one chat with a mock user
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch % 1000}';
      final userName = 'User $userId';

      final conversation = ConversationInfo(
        id: 'chat_${userId}_${DateTime.now().millisecondsSinceEpoch}',
        name: userName,
        isGroup: false,
      );

      _addConversation(conversation);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            conversationID: conversation.id,
            targetUserID: userId,
            targetUserName: conversation.name,
            isGroupChat: conversation.isGroup,
          ),
        ),
      ).then((_) => _loadSampleConversations());
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
