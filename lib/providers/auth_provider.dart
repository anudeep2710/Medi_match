import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:medimatch/services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService;

  // Constructor
  AuthProvider(this._firebaseService) {
    // Listen to auth state changes
    _firebaseService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;

    try {
      final userCredential = await _firebaseService.signInWithGoogle();
      _setLoading(false);
      return userCredential != null;
    } catch (e) {
      _setLoading(false);
      _error = e.toString();
      return false;
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      debugPrint('Attempting to sign up user with email: $email');
      final userCredential = await _firebaseService.signUpWithEmailAndPassword(
        email,
        password,
      );
      debugPrint('Sign up successful: ${userCredential.user?.uid}');
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Sign up error: $e');
      _setLoading(false);
      _error = _getReadableAuthError(e);
      notifyListeners();
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      await _firebaseService.signInWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _error = _getReadableAuthError(e);
      return false;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _error = null;

    try {
      await _firebaseService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _error = _getReadableAuthError(e);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _error = null;

    try {
      await _firebaseService.signOut();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _error = e.toString();
    }
  }

  // Helper method to convert Firebase auth errors to readable messages
  String _getReadableAuthError(dynamic error) {
    debugPrint('Processing auth error: $error');
    String errorMessage = error.toString();

    if (error is FirebaseAuthException) {
      debugPrint(
        'Firebase Auth Exception - Code: ${error.code}, Message: ${error.message}',
      );
      switch (error.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak. Use at least 6 characters.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Try again later.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'Email/password authentication is not enabled. Please contact support.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Check your internet connection.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid credentials provided.';
          break;
        case 'credential-already-in-use':
          errorMessage =
              'This credential is already associated with another account.';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please log in again to perform this action.';
          break;
        default:
          errorMessage =
              'Authentication error: ${error.code}\nMessage: ${error.message ?? "Unknown error"}';
          break;
      }
    } else {
      // Handle other types of errors
      if (errorMessage.contains('PlatformException')) {
        errorMessage = 'Platform error occurred. Please try again.';
      } else if (errorMessage.contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (errorMessage.contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again.';
      } else {
        errorMessage =
            'An unexpected error occurred: ${errorMessage.length > 100 ? "${errorMessage.substring(0, 100)}..." : errorMessage}';
      }
    }

    debugPrint('Readable error message: $errorMessage');
    return errorMessage;
  }

  // Helper method to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
