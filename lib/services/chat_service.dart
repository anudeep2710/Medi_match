import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple chat service for MediMatch
class ChatService {
  // Singleton instance
  static final ChatService _instance = ChatService._internal();

  factory ChatService() {
    return _instance;
  }

  ChatService._internal();

  // Current user information
  String _currentUserId = '';
  String _currentUserName = '';

  String get currentUserId => _currentUserId;
  String get currentUserName => _currentUserName;

  /// Initialize the chat service
  Future<void> init() async {
    // Load user information from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('chat_user_id') ?? '';
    _currentUserName = prefs.getString('chat_user_name') ?? '';

    // If no user ID exists, create a new one
    if (_currentUserId.isEmpty) {
      _currentUserId = 'user_${Random().nextInt(10000)}';
      _currentUserName = 'User';

      // Save the new user information
      await prefs.setString('chat_user_id', _currentUserId);
      await prefs.setString('chat_user_name', _currentUserName);
    }
  }

  /// Set the current user for chat
  Future<void> setUser(String userId, String userName) async {
    _currentUserId = userId;
    _currentUserName = userName;

    // Save the user information
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_user_id', userId);
    await prefs.setString('chat_user_name', userName);
  }

  /// Generate a random user ID
  static String generateUserId() {
    return 'user_${Random().nextInt(100000)}';
  }

  /// Get all conversations for the current user
  Future<List<ChatConversation>> getConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = prefs.getString('chat_conversations') ?? '[]';
    final List<dynamic> conversationsList = jsonDecode(conversationsJson);

    return conversationsList
        .map((json) => ChatConversation.fromJson(json))
        .toList();
  }

  /// Save a list of conversations
  Future<void> saveConversations(List<ChatConversation> conversations) async {
    final prefs = await SharedPreferences.getInstance();
    final conversationsJson = jsonEncode(
      conversations.map((conv) => conv.toJson()).toList(),
    );
    await prefs.setString('chat_conversations', conversationsJson);
  }

  /// Get messages for a specific conversation
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('chat_messages_$conversationId') ?? '[]';
    final List<dynamic> messagesList = jsonDecode(messagesJson);

    return messagesList
        .map((json) => ChatMessage.fromJson(json))
        .toList();
  }

  /// Save messages for a specific conversation
  Future<void> saveMessages(String conversationId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = jsonEncode(
      messages.map((msg) => msg.toJson()).toList(),
    );
    await prefs.setString('chat_messages_$conversationId', messagesJson);
  }

  /// Send a message in a conversation
  Future<void> sendMessage(String conversationId, String recipientId, String content) async {
    // Create a new message
    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentUserId,
      senderName: _currentUserName,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Get existing messages
    final messages = await getMessages(conversationId);
    messages.add(message);

    // Save updated messages
    await saveMessages(conversationId, messages);

    // Update conversation with last message
    final conversations = await getConversations();
    final existingIndex = conversations.indexWhere(
      (conv) => conv.id == conversationId,
    );

    if (existingIndex >= 0) {
      // Update existing conversation
      conversations[existingIndex] = conversations[existingIndex].copyWith(
        lastMessage: content,
        lastMessageTime: DateTime.now(),
        unreadCount: conversations[existingIndex].unreadCount + 1,
      );
    } else {
      // Create new conversation
      conversations.add(ChatConversation(
        id: conversationId,
        userId: recipientId,
        name: 'User $recipientId', // This would be replaced with actual user name
        isGroup: false,
        lastMessage: content,
        lastMessageTime: DateTime.now(),
        unreadCount: 1,
      ));
    }

    // Save updated conversations
    await saveConversations(conversations);
  }
}

/// Model class for a chat conversation
class ChatConversation {
  final String id;
  final String userId;
  final String name;
  final bool isGroup;
  final String? lastMessage;
  final int unreadCount;
  final DateTime? lastMessageTime;

  ChatConversation({
    required this.id,
    required this.userId,
    required this.name,
    this.isGroup = false,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastMessageTime,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      isGroup: json['isGroup'] ?? false,
      lastMessage: json['lastMessage'],
      unreadCount: json['unreadCount'] ?? 0,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'isGroup': isGroup,
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
    };
  }

  ChatConversation copyWith({
    String? id,
    String? userId,
    String? name,
    bool? isGroup,
    String? lastMessage,
    int? unreadCount,
    DateTime? lastMessageTime,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      isGroup: isGroup ?? this.isGroup,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    );
  }
}

/// Model class for a chat message
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
