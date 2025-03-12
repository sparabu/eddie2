import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eddie2/models/user.dart' as app_models;

// Provider for the AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider for the current user state
final authStateProvider = StreamProvider<app_models.User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  // Stream of auth state changes mapped to our app User model
  Stream<app_models.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebase_auth.User? firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return app_models.User.fromFirebase(firebaseUser);
    });
  }

  // Get current user
  app_models.User? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return app_models.User.fromFirebase(firebaseUser);
  }

  // Sign in with email and password
  Future<app_models.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user != null 
          ? app_models.User.fromFirebase(userCredential.user!) 
          : null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during sign in: $e');
      throw Exception('An unexpected error occurred. Please try again later.');
    }
  }

  // Create user with email and password
  Future<app_models.User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      debugPrint('Attempting to create user with email: $email');
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('User created successfully: ${userCredential.user?.uid}');
      return userCredential.user != null 
          ? app_models.User.fromFirebase(userCredential.user!) 
          : null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error during signup: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during signup: $e');
      if (e.toString().contains('api-key-not-valid')) {
        throw Exception('Firebase configuration error: Invalid API key. Please contact support.');
      }
      throw Exception('An unexpected error occurred. Please try again later. Error: ${e.toString()}');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
      debugPrint('Verification email sent successfully');
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error during email verification: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during email verification: $e');
      throw Exception('Failed to send verification email. Please try again later.');
    }
  }

  // Reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent successfully');
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error during password reset: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during password reset: $e');
      throw Exception('Failed to send password reset email. Please try again later.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Error during sign out: $e');
      throw Exception('Failed to sign out. Please try again.');
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName}) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
      debugPrint('User profile updated successfully');
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error during profile update: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during profile update: $e');
      throw Exception('Failed to update profile. Please try again later.');
    }
  }
  
  // Delete current user account
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }
      
      // For some operations like account deletion, Firebase requires recent authentication
      // If this fails with a 'requires-recent-login' error, you'll need to reauthenticate first
      await user.delete();
      debugPrint('User account deleted successfully');
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error during account deletion: ${e.code} - ${e.message}');
      
      // If the error is due to requiring recent login, handle it specially
      if (e.code == 'requires-recent-login') {
        throw Exception('For security reasons, please sign out and sign in again before deleting your account.');
      }
      
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during account deletion: $e');
      throw Exception('Failed to delete account. Please try again later.');
    }
  }
  
  // Reauthenticate user (needed for sensitive operations like account deletion)
  Future<void> reauthenticate(String email, String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }
      
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      debugPrint('User reauthenticated successfully');
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error during reauthentication: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during reauthentication: $e');
      throw Exception('Failed to reauthenticate. Please try again.');
    }
  }

  // Handle Firebase Auth exceptions
  Exception _handleAuthException(firebase_auth.FirebaseAuthException e) {
    debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
    
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email.');
      case 'wrong-password':
        return Exception('Wrong password provided.');
      case 'email-already-in-use':
        return Exception('The email address is already in use.');
      case 'weak-password':
        return Exception('The password is too weak.');
      case 'invalid-email':
        return Exception('The email address is invalid.');
      case 'operation-not-allowed':
        return Exception('This operation is not allowed.');
      case 'user-disabled':
        return Exception('This user has been disabled.');
      case 'too-many-requests':
        return Exception('Too many requests. Try again later.');
      case 'network-request-failed':
        return Exception('Network error. Check your connection.');
      case 'requires-recent-login':
        return Exception('This operation requires recent authentication. Please log in again.');
      case 'app-not-authorized':
        return Exception('App not authorized to use Firebase Authentication with the provided API key.');
      case 'api-key-not-valid':
        return Exception('Firebase configuration error: Invalid API key. Please contact support.');
      default:
        return Exception(e.message ?? 'An unknown error occurred.');
    }
  }
} 