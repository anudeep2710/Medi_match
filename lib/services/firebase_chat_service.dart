import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase-powered real-time chat service for MediMatch
class FirebaseChatService {
  static final FirebaseChatService _instance = FirebaseChatService._internal();
  factory FirebaseChatService() => _instance;
  FirebaseChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get current user display name
  String? get currentUserName => _auth.currentUser?.displayName ?? 'Anonymous';

  /// Create or get a conversation between two users
  Future<String> createConversation(String otherUserId, String otherUserName) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('❌ User not authenticated for chat');
      throw Exception('User not authenticated');
    }

    print('✅ Creating conversation between ${currentUser.uid} and $otherUserId');

    // Create conversation ID by sorting user IDs to ensure consistency
    final userIds = [currentUser.uid, otherUserId]..sort();
    final conversationId = '${userIds[0]}_${userIds[1]}';

    try {
      // Check if conversation already exists
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!conversationDoc.exists) {
        // Create new conversation
        await _firestore.collection('conversations').doc(conversationId).set({
          'id': conversationId,
          'participants': [currentUser.uid, otherUserId],
          'participantNames': {
            currentUser.uid: currentUserName,
            otherUserId: otherUserName,
          },
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'isGroup': false,
        });
        print('✅ New conversation created: $conversationId');
      } else {
        print('✅ Existing conversation found: $conversationId');
      }

      return conversationId;
    } catch (e) {
      print('❌ Error creating conversation: $e');
      throw Exception('Failed to create conversation: $e');
    }
  }

  /// Send a message in a conversation
  Future<void> sendMessage(String conversationId, String content, {String? medicineInfo}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final messageData = {
      'id': _firestore.collection('conversations').doc().id,
      'senderId': currentUser.uid,
      'senderName': currentUserName,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'text',
      if (medicineInfo != null) 'medicineInfo': medicineInfo,
    };

    // Add message to subcollection
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add(messageData);

    // Update conversation with last message
    await _firestore.collection('conversations').doc(conversationId).update({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  /// Get messages stream for a conversation
  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  /// Get conversations stream for current user
  Stream<List<ChatConversation>> getConversationsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('conversations')
          .where('participants', arrayContains: currentUser.uid)
          .snapshots()
          .map((snapshot) {
        final conversations = snapshot.docs.map((doc) {
          final data = doc.data();
          return ChatConversation.fromFirestore(data, doc.id);
        }).toList();

        // Sort manually to avoid index requirement
        conversations.sort((a, b) {
          if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
          if (a.lastMessageTime == null) return 1;
          if (b.lastMessageTime == null) return -1;
          return b.lastMessageTime!.compareTo(a.lastMessageTime!);
        });

        return conversations;
      });
    } catch (e) {
      print('❌ Error getting conversations: $e');
      return Stream.value([]);
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({String? displayName, String? photoUrl}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('users').doc(currentUser.uid).set({
      'uid': currentUser.uid,
      'displayName': displayName ?? currentUserName,
      'email': currentUser.email,
      'photoUrl': photoUrl,
      'lastSeen': FieldValue.serverTimestamp(),
      'isOnline': true,
    }, SetOptions(merge: true));
  }

  /// Set user online status
  Future<void> setUserOnlineStatus(bool isOnline) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('users').doc(currentUser.uid).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  /// Search for users to start a conversation
  Future<List<UserProfile>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final usersQuery = await _firestore
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(10)
        .get();

    return usersQuery.docs.map((doc) {
      final data = doc.data();
      return UserProfile.fromFirestore(data, doc.id);
    }).toList();
  }
}

/// Chat message model
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String type;
  final String? medicineInfo;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.type = 'text',
    this.medicineInfo,
  });

  factory ChatMessage.fromFirestore(Map<String, dynamic> data, String id) {
    return ChatMessage(
      id: id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      type: data['type'] ?? 'text',
      medicineInfo: data['medicineInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
      if (medicineInfo != null) 'medicineInfo': medicineInfo,
    };
  }
}

/// Chat conversation model
class ChatConversation {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final bool isGroup;

  ChatConversation({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    this.lastMessageTime,
    this.isGroup = false,
  });

  factory ChatConversation.fromFirestore(Map<String, dynamic> data, String id) {
    return ChatConversation(
      id: id,
      participants: List<String>.from(data['participants'] ?? []),
      participantNames: Map<String, String>.from(data['participantNames'] ?? {}),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      isGroup: data['isGroup'] ?? false,
    );
  }

  String getOtherParticipantName(String currentUserId) {
    final otherParticipant = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return participantNames[otherParticipant] ?? 'Unknown User';
  }
}

/// User profile model
class UserProfile {
  final String uid;
  final String displayName;
  final String? email;
  final String? photoUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  UserProfile({
    required this.uid,
    required this.displayName,
    this.email,
    this.photoUrl,
    this.isOnline = false,
    this.lastSeen,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String id) {
    return UserProfile(
      uid: id,
      displayName: data['displayName'] ?? 'Unknown User',
      email: data['email'],
      photoUrl: data['photoUrl'],
      isOnline: data['isOnline'] ?? false,
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
    );
  }
}
