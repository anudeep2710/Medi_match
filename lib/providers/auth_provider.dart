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
      await _firebaseService.signUpWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _error = _getReadableAuthError(e);
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
    String errorMessage = error.toString();

    if (error is FirebaseAuthException) {
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
          errorMessage = 'The password is too weak.';
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
          errorMessage = 'Operation not allowed.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Check your connection.';
          break;
        default:
          errorMessage = 'An error occurred: ${error.code}';
          break;
      }
    }

    return errorMessage;
  }

  // Helper method to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
