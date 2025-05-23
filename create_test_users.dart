import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

/// Script to create test users in Firebase for testing chat functionality
void main() async {
  print('🔥 Creating test users in Firebase...');
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final firestore = FirebaseFirestore.instance;
    
    // Test users to create
    final testUsers = [
      {
        'uid': 'test_user_1',
        'displayName': 'Dr. Sarah Johnson',
        'email': 'sarah.johnson@medimatch.com',
        'photoUrl': null,
        'location': 'New York, NY',
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'test_user_2',
        'displayName': 'Mike Chen',
        'email': 'mike.chen@medimatch.com',
        'photoUrl': null,
        'location': 'San Francisco, CA',
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'test_user_3',
        'displayName': 'Emily Rodriguez',
        'email': 'emily.rodriguez@medimatch.com',
        'photoUrl': null,
        'location': 'Los Angeles, CA',
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'test_user_4',
        'displayName': 'David Kim',
        'email': 'david.kim@medimatch.com',
        'photoUrl': null,
        'location': 'Chicago, IL',
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'test_user_5',
        'displayName': 'Lisa Thompson',
        'email': 'lisa.thompson@medimatch.com',
        'photoUrl': null,
        'location': 'Miami, FL',
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];
    
    print('📝 Creating ${testUsers.length} test users...');
    
    // Create users in Firestore
    for (final userData in testUsers) {
      final uid = userData['uid'] as String;
      
      await firestore.collection('users').doc(uid).set(userData);
      print('✅ Created user: ${userData['displayName']} (${userData['email']})');
    }
    
    print('\n🎉 Successfully created all test users!');
    print('\n📋 Test Users Created:');
    for (final userData in testUsers) {
      print('  • ${userData['displayName']} - ${userData['email']}');
    }
    
    print('\n🔍 How to test:');
    print('1. Open your MediMatch app');
    print('2. Make sure you\'re logged in');
    print('3. Go to Chat section');
    print('4. Tap "Start Your First Chat"');
    print('5. Search for names like "Sarah", "Mike", "Emily", etc.');
    print('6. You should see the test users appear!');
    
    print('\n💡 Note: These are test users for development only.');
    print('In production, real users will be created when they sign up.');
    
  } catch (e) {
    print('❌ Error creating test users: $e');
  }
}
