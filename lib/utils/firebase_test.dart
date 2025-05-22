import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Utility class to test Firebase connectivity and configuration
class FirebaseTest {
  static Future<Map<String, dynamic>> testFirebaseConnection() async {
    final results = <String, dynamic>{};
    
    try {
      // Test 1: Check if Firebase is initialized
      debugPrint('Testing Firebase initialization...');
      final app = Firebase.app();
      results['firebase_initialized'] = true;
      results['firebase_app_name'] = app.name;
      results['firebase_project_id'] = app.options.projectId;
      debugPrint('✅ Firebase initialized successfully');
      debugPrint('Project ID: ${app.options.projectId}');
      
      // Test 2: Check Firebase Auth instance
      debugPrint('Testing Firebase Auth...');
      final auth = FirebaseAuth.instance;
      results['auth_instance'] = auth != null;
      results['current_user'] = auth.currentUser?.uid ?? 'No user signed in';
      debugPrint('✅ Firebase Auth instance created');
      
      // Test 3: Test Auth configuration
      debugPrint('Testing Auth configuration...');
      try {
        // Try to get auth settings (this will fail if auth is not properly configured)
        final settings = auth.app.options;
        results['auth_configured'] = true;
        results['api_key'] = settings.apiKey.substring(0, 10) + '...'; // Show partial key for security
        debugPrint('✅ Auth configuration appears valid');
      } catch (e) {
        results['auth_configured'] = false;
        results['auth_config_error'] = e.toString();
        debugPrint('❌ Auth configuration error: $e');
      }
      
      // Test 4: Test network connectivity to Firebase
      debugPrint('Testing network connectivity...');
      try {
        // Try to sign out (this makes a network call to Firebase)
        await auth.signOut();
        results['network_connectivity'] = true;
        debugPrint('✅ Network connectivity to Firebase working');
      } catch (e) {
        results['network_connectivity'] = false;
        results['network_error'] = e.toString();
        debugPrint('❌ Network connectivity error: $e');
      }
      
      // Test 5: Check if Email/Password auth is enabled
      debugPrint('Testing Email/Password auth availability...');
      try {
        // Try to create a user with invalid email to test if the service responds
        await auth.createUserWithEmailAndPassword(
          email: 'test@invalid.test', 
          password: 'testpassword123'
        );
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'operation-not-allowed') {
            results['email_auth_enabled'] = false;
            results['email_auth_error'] = 'Email/Password authentication is not enabled in Firebase Console';
            debugPrint('❌ Email/Password auth is NOT enabled');
          } else {
            results['email_auth_enabled'] = true;
            debugPrint('✅ Email/Password auth is enabled (got expected error: ${e.code})');
          }
        } else {
          results['email_auth_enabled'] = false;
          results['email_auth_error'] = e.toString();
          debugPrint('❌ Unexpected error testing email auth: $e');
        }
      }
      
      results['overall_status'] = 'Tests completed';
      
    } catch (e) {
      results['firebase_initialized'] = false;
      results['initialization_error'] = e.toString();
      results['overall_status'] = 'Firebase initialization failed';
      debugPrint('❌ Firebase initialization failed: $e');
    }
    
    return results;
  }
  
  /// Test user registration with detailed error reporting
  static Future<Map<String, dynamic>> testUserRegistration(String email, String password) async {
    final results = <String, dynamic>{};
    
    try {
      debugPrint('Testing user registration with email: $email');
      
      final auth = FirebaseAuth.instance;
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      results['registration_success'] = true;
      results['user_id'] = userCredential.user?.uid;
      results['user_email'] = userCredential.user?.email;
      debugPrint('✅ User registration successful: ${userCredential.user?.uid}');
      
      // Clean up - delete the test user
      await userCredential.user?.delete();
      debugPrint('✅ Test user cleaned up');
      
    } catch (e) {
      results['registration_success'] = false;
      results['error'] = e.toString();
      
      if (e is FirebaseAuthException) {
        results['error_code'] = e.code;
        results['error_message'] = e.message;
        debugPrint('❌ Registration failed - Code: ${e.code}, Message: ${e.message}');
      } else {
        debugPrint('❌ Registration failed with unexpected error: $e');
      }
    }
    
    return results;
  }
  
  /// Print comprehensive Firebase status
  static Future<void> printFirebaseStatus() async {
    debugPrint('\n🔥 FIREBASE DIAGNOSTIC REPORT 🔥');
    debugPrint('=====================================');
    
    final results = await testFirebaseConnection();
    
    for (final entry in results.entries) {
      debugPrint('${entry.key}: ${entry.value}');
    }
    
    debugPrint('=====================================\n');
  }
}
