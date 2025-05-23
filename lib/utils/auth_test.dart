import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Quick authentication test utility
class AuthTest {
  static Future<Map<String, dynamic>> testLogin(String email, String password) async {
    final results = <String, dynamic>{};
    
    try {
      debugPrint('🔥 Testing login with email: $email');
      
      final auth = FirebaseAuth.instance;
      
      // Test 1: Try to sign in
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      results['login_success'] = true;
      results['user_id'] = userCredential.user?.uid;
      results['user_email'] = userCredential.user?.email;
      results['email_verified'] = userCredential.user?.emailVerified;
      
      debugPrint('✅ Login successful: ${userCredential.user?.uid}');
      
    } catch (e) {
      results['login_success'] = false;
      results['error'] = e.toString();
      
      if (e is FirebaseAuthException) {
        results['error_code'] = e.code;
        results['error_message'] = e.message;
        
        debugPrint('❌ Login failed - Code: ${e.code}');
        debugPrint('❌ Message: ${e.message}');
        
        // Specific error handling
        switch (e.code) {
          case 'user-not-found':
            results['suggestion'] = 'User does not exist. Try signing up first.';
            break;
          case 'wrong-password':
            results['suggestion'] = 'Incorrect password. Please check your password.';
            break;
          case 'invalid-email':
            results['suggestion'] = 'Invalid email format.';
            break;
          case 'user-disabled':
            results['suggestion'] = 'This account has been disabled.';
            break;
          case 'too-many-requests':
            results['suggestion'] = 'Too many failed attempts. Try again later.';
            break;
          case 'operation-not-allowed':
            results['suggestion'] = 'Email/Password authentication is not enabled in Firebase Console.';
            break;
          case 'network-request-failed':
            results['suggestion'] = 'Network error. Check your internet connection.';
            break;
          default:
            results['suggestion'] = 'Unknown authentication error. Check Firebase configuration.';
        }
      } else {
        debugPrint('❌ Unexpected error: $e');
        results['suggestion'] = 'Unexpected error occurred.';
      }
    }
    
    return results;
  }
  
  static Future<Map<String, dynamic>> testSignup(String email, String password) async {
    final results = <String, dynamic>{};
    
    try {
      debugPrint('🔥 Testing signup with email: $email');
      
      final auth = FirebaseAuth.instance;
      
      // Test signup
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      results['signup_success'] = true;
      results['user_id'] = userCredential.user?.uid;
      results['user_email'] = userCredential.user?.email;
      
      debugPrint('✅ Signup successful: ${userCredential.user?.uid}');
      
      // Clean up test user
      await userCredential.user?.delete();
      debugPrint('✅ Test user cleaned up');
      
    } catch (e) {
      results['signup_success'] = false;
      results['error'] = e.toString();
      
      if (e is FirebaseAuthException) {
        results['error_code'] = e.code;
        results['error_message'] = e.message;
        
        debugPrint('❌ Signup failed - Code: ${e.code}');
        debugPrint('❌ Message: ${e.message}');
      }
    }
    
    return results;
  }
  
  static Future<void> printAuthStatus() async {
    debugPrint('\n🔥 FIREBASE AUTH STATUS 🔥');
    debugPrint('================================');
    
    try {
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      
      debugPrint('Current User: ${currentUser?.uid ?? "None"}');
      debugPrint('User Email: ${currentUser?.email ?? "None"}');
      debugPrint('Email Verified: ${currentUser?.emailVerified ?? false}');
      debugPrint('Auth State: ${currentUser != null ? "Signed In" : "Signed Out"}');
      
    } catch (e) {
      debugPrint('❌ Error checking auth status: $e');
    }
    
    debugPrint('================================\n');
  }
}
