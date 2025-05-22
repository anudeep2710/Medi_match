import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
    if (currentUser == null) throw Exception('User not authenticated');

    // Create conversation ID by sorting user IDs to ensure consistency
    final userIds = [currentUser.uid, otherUserId]..sort();
    final conversationId = '${userIds[0]}_${userIds[1]}';

    // Check if conversation already exists
    final conversationDoc = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .get();

    if (!conversationDoc.exists) {
      // Create new conversation
      await _firestore.collection('conversations').doc(conversationId).set({
        'id': conversationId,
        'participants': userIds,
        'participantNames': {
          currentUser.uid: currentUserName,
          otherUserId: otherUserName,
        },
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return conversationId;
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
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get real-time stream of messages for a conversation
  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  /// Get real-time stream of conversations for current user
  Stream<List<ChatConversation>> getConversationsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatConversation.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String conversationId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final messagesQuery = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messagesQuery.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
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

  /// Create or update user profile
  Future<void> updateUserProfile({
    required String displayName,
    String? photoUrl,
    String? location,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('users').doc(currentUser.uid).set({
      'uid': currentUser.uid,
      'displayName': displayName,
      'email': currentUser.email,
      'photoUrl': photoUrl,
      'location': location,
      'lastSeen': FieldValue.serverTimestamp(),
      'isOnline': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
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
}

/// Chat message model for Firestore
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime? timestamp;
  final bool isRead;
  final String type;
  final String? medicineInfo;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.timestamp,
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
      timestamp: data['timestamp'] != null 
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
      isRead: data['isRead'] ?? false,
      type: data['type'] ?? 'text',
      medicineInfo: data['medicineInfo'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'isRead': isRead,
      'type': type,
      if (medicineInfo != null) 'medicineInfo': medicineInfo,
    };
  }
}

/// Chat conversation model for Firestore
class ChatConversation {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final DateTime? createdAt;

  ChatConversation({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    this.lastMessageTime,
    this.createdAt,
  });

  factory ChatConversation.fromFirestore(Map<String, dynamic> data, String id) {
    return ChatConversation(
      id: id,
      participants: List<String>.from(data['participants'] ?? []),
      participantNames: Map<String, String>.from(data['participantNames'] ?? {}),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Get the other participant's name (not current user)
  String getOtherParticipantName(String currentUserId) {
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return participantNames[otherUserId] ?? 'Unknown User';
  }
}

/// User profile model for Firestore
class UserProfile {
  final String uid;
  final String displayName;
  final String? email;
  final String? photoUrl;
  final String? location;
  final bool isOnline;
  final DateTime? lastSeen;

  UserProfile({
    required this.uid,
    required this.displayName,
    this.email,
    this.photoUrl,
    this.location,
    this.isOnline = false,
    this.lastSeen,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String id) {
    return UserProfile(
      uid: id,
      displayName: data['displayName'] ?? 'Unknown',
      email: data['email'],
      photoUrl: data['photoUrl'],
      location: data['location'],
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] as Timestamp).toDate()
          : null,
    );
  }
}
