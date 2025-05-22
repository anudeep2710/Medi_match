import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String conversationID;
  final String targetUserID;
  final String targetUserName;
  final bool isGroupChat;

  const ChatScreen({
    super.key,
    required this.conversationID,
    required this.targetUserID,
    required this.targetUserName,
    this.isGroupChat = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize chat screen
  }

  // Sample messages for demo
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      sender: 'User',
      text: 'Hello, do you have any unused medications?',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    ChatMessage(
      id: '2',
      sender: 'John',
      text: 'Yes, I have some unused antibiotics. They expire next month.',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
    ),
    ChatMessage(
      id: '3',
      sender: 'User',
      text: 'Great! Are they still sealed in the original packaging?',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 23)),
    ),
    ChatMessage(
      id: '4',
      sender: 'John',
      text: 'Yes, they are unopened. I can share a photo if you want.',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 22)),
    ),
    ChatMessage(
      id: '5',
      sender: 'User',
      text: 'That would be helpful. When can we meet for the handover?',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isGroupChat ? 'Group: ${widget.targetUserName}' : widget.targetUserName),
        actions: [
          if (widget.isGroupChat)
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: () {
                // Show dialog to add members to the group
                _showAddMembersDialog(context);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                reverse: true,
                itemBuilder: (context, index) {
                  final message = _messages[_messages.length - 1 - index];
                  return _buildMessageBubble(message);
                },
              ),
            ),

            // Message input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isMe)
              Text(
                message.sender,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: message.isMe
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                color: message.isMe
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: message.isMe
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // In a real app, you would send the message to the server
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message sent!'),
        duration: Duration(seconds: 1),
      ),
    );

    _messageController.clear();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return 'Today ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showAddMembersDialog(BuildContext context) {
    // This is a placeholder for adding members to a group chat
    // In a real implementation, you would show a list of users to add
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Members'),
        content: const Text('This feature will allow you to add members to the group chat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Model class for a chat message
class ChatMessage {
  final String id;
  final String sender;
  final String text;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}
