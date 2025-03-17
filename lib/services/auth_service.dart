import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eddie2/models/user.dart' as app_models;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '36016290730-9323ol33h5ih0j2iafji5o9m38cpg2c2.apps.googleusercontent.com' : null,
    scopes: [
      'email',
      'profile',
    ],
  );
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes mapped to our app User model
  Stream<app_models.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebase_auth.User? firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }
      
      // Create basic user from Firebase
      app_models.User user = app_models.User.fromFirebase(firebaseUser);
      
      // Try to get additional user data from Firestore
      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists && doc.data() != null) {
          final userData = doc.data()!;
          // Update user with Firestore data (username, etc.)
          user = user.copyWith(
            username: userData['username'] as String?,
            // Only use Firestore photoURL if Firebase Auth doesn't have one
            photoURL: user.photoURL ?? userData['photoURL'] as String?,
          );
        }
      } catch (e) {
        debugPrint('Error fetching user data from Firestore: $e');
      }
      
      return user;
    });
  }

  // Get current user
  Future<app_models.User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    
    // Create basic user from Firebase
    app_models.User user = app_models.User.fromFirebase(firebaseUser);
    
    // Try to get additional user data from Firestore
    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists && doc.data() != null) {
        final userData = doc.data()!;
        // Update user with Firestore data
        user = user.copyWith(
          username: userData['username'] as String?,
          // Only use Firestore photoURL if Firebase Auth doesn't have one
          photoURL: user.photoURL ?? userData['photoURL'] as String?,
        );
      }
    } catch (e) {
      debugPrint('Error fetching user data from Firestore: $e');
    }
    
    return user;
  }

  // Sign in with email and password
  Future<app_models.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Ensure user data exists in Firestore
        await _ensureUserInFirestore(userCredential.user!, 'password');
        return await getCurrentUser();
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during sign in: $e');
      throw Exception('An unexpected error occurred. Please try again later.');
    }
  }

  // Sign in with Google
  Future<app_models.User?> signInWithGoogle() async {
    debugPrint('Starting Google Sign-In process...');
    try {
      // Sign out first to ensure a clean state
      await signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // If user canceled the sign-in flow
      if (googleUser == null) {
        debugPrint('Google Sign-In canceled by user');
        return null;
      }
      
      debugPrint('Google Sign-In successful, getting auth details...');
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      debugPrint('Got Google auth tokens, creating Firebase credential...');
      
      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      debugPrint('Signing in to Firebase with Google credential...');
      
      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      
      if (firebaseUser == null) {
        debugPrint('Firebase sign-in failed: user is null after credential sign-in');
        return null;
      }
      
      debugPrint('Firebase sign-in successful, ensuring user in Firestore...');
      
      // Create basic user from Firebase
      app_models.User user = app_models.User.fromFirebase(firebaseUser);
      
      // Ensure user exists in Firestore with retry logic
      int retryCount = 0;
      bool firestoreSuccess = false;
      
      while (!firestoreSuccess && retryCount < 3) {
        try {
          // Check if user document exists
          final docRef = _firestore.collection('users').doc(firebaseUser.uid);
          final docSnapshot = await docRef.get();
          
          if (!docSnapshot.exists) {
            // Create new user document if it doesn't exist
            await docRef.set({
              'uid': firebaseUser.uid,
              'email': firebaseUser.email,
              'displayName': firebaseUser.displayName,
              'photoURL': firebaseUser.photoURL,
              'createdAt': FieldValue.serverTimestamp(),
              'lastLoginAt': FieldValue.serverTimestamp(),
            });
            debugPrint('Created new user document in Firestore');
          } else {
            // Update last login timestamp
            await docRef.update({
              'lastLoginAt': FieldValue.serverTimestamp(),
              // Update these fields in case they've changed in Google account
              'displayName': firebaseUser.displayName,
              'photoURL': firebaseUser.photoURL,
            });
            debugPrint('Updated existing user document in Firestore');
          }
          
          firestoreSuccess = true;
        } catch (e) {
          retryCount++;
          debugPrint('Error ensuring user in Firestore (attempt $retryCount/3): $e');
          
          if (e.toString().contains('offline')) {
            // If offline, wait a bit before retrying
            await Future.delayed(Duration(seconds: 1 * retryCount));
          } else if (retryCount >= 3) {
            // Log but don't fail the sign-in process for Firestore errors
            debugPrint('Failed to ensure user in Firestore after 3 attempts, continuing with sign-in');
          }
        }
      }
      
      // Force a reload of the Firebase user to ensure we have the latest data
      await firebaseUser.reload();
      final refreshedUser = _firebaseAuth.currentUser;
      
      // Update the user object with the refreshed data if available
      if (refreshedUser != null) {
        user = app_models.User.fromFirebase(refreshedUser);
        debugPrint('User data refreshed after Google sign-in: ${user.email}');
      }
      
      // Manually notify listeners about the auth state change
      _notifyAuthStateListeners();
      
      return user;
    } catch (e) {
      debugPrint('Error during Google sign-in: $e');
      rethrow;
    }
  }

  // Helper method to manually trigger auth state listeners
  void _notifyAuthStateListeners() {
    debugPrint('Manually notifying auth state listeners');
    // This will cause Firebase Auth to emit a new auth state event
    _firebaseAuth.currentUser?.getIdToken(true);
  }

  // Create user with email and password
  Future<app_models.User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      debugPrint('Attempting to create user with email: $email');
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Ensure user data exists in Firestore
        await _ensureUserInFirestore(userCredential.user!, 'password');
        debugPrint('User created successfully: ${userCredential.user?.uid}');
        return await getCurrentUser();
      }
      return null;
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

  // Ensure user exists in Firestore
  Future<void> _ensureUserInFirestore(firebase_auth.User user, String provider) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final doc = await userRef.get();
      
      if (!doc.exists) {
        // Create new user document
        await userRef.set({
          'email': user.email,
          'displayName': user.displayName ?? '',
          'photoURL': user.photoURL,
          'username': null,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'provider': provider,
        });
      } else {
        // Update last login time
        await userRef.update({
          'lastLoginAt': FieldValue.serverTimestamp(),
          // Update these fields only if they're not already set
          'displayName': user.displayName ?? doc.data()?['displayName'] ?? '',
          'photoURL': user.photoURL ?? doc.data()?['photoURL'],
        });
      }
    } catch (e) {
      debugPrint('Error ensuring user in Firestore: $e');
      // Non-critical error, don't throw
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
      // Try to sign out from Google if signed in
      try {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
          debugPrint('User signed out from Google successfully');
        }
      } catch (e) {
        // Just log the error but don't rethrow - we still want to sign out from Firebase
        debugPrint('Error signing out from Google: $e');
      }
      
      // Sign out from Firebase
      await _firebaseAuth.signOut();
      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Error signing out: $e');
      throw Exception('Failed to sign out. Please try again.');
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? username}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }
      
      // Update Firebase Auth display name
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      
      // Update Firestore data
      final updates = <String, dynamic>{};
      if (displayName != null) {
        updates['displayName'] = displayName;
      }
      if (username != null) {
        updates['username'] = username;
      }
      
      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }
      
      debugPrint('User profile updated successfully');
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error during profile update: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during profile update: $e');
      throw Exception('Failed to update profile. Please try again later.');
    }
  }
  
  // Upload profile picture
  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }
      
      // Create a reference to the location you want to upload to in Firebase Storage
      final storageRef = _storage.ref().child('profile_pictures/${user.uid}');
      
      // Upload the file
      final uploadTask = storageRef.putFile(imageFile);
      
      // Wait for the upload to complete
      final snapshot = await uploadTask;
      
      // Get the download URL
      final downloadURL = await snapshot.ref.getDownloadURL();
      
      // Update user's photoURL in Firebase Auth
      await user.updatePhotoURL(downloadURL);
      
      // Update user's photoURL in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoURL': downloadURL,
      });
      
      debugPrint('Profile picture uploaded successfully: $downloadURL');
      return downloadURL;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      throw Exception('Failed to upload profile picture. Please try again later.');
    }
  }
  
  // Upload profile picture from web (for web platform)
  Future<String?> uploadProfilePictureWeb(Uint8List imageBytes, String fileName) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }
      
      // Create a reference to the location you want to upload to in Firebase Storage
      final storageRef = _storage.ref().child('profile_pictures/${user.uid}');
      
      // Upload the file
      final uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/${fileName.split('.').last}'),
      );
      
      // Wait for the upload to complete
      final snapshot = await uploadTask;
      
      // Get the download URL
      final downloadURL = await snapshot.ref.getDownloadURL();
      
      // Update user's photoURL in Firebase Auth
      await user.updatePhotoURL(downloadURL);
      
      // Update user's photoURL in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoURL': downloadURL,
      });
      
      debugPrint('Profile picture uploaded successfully: $downloadURL');
      return downloadURL;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      throw Exception('Failed to upload profile picture. Please try again later.');
    }
  }
  
  // Delete current user account
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }
      
      debugPrint('Starting account deletion process for user: ${user.uid}');
      
      // First, check if the user needs to be reauthenticated
      try {
        // Try to get user token to check authentication status
        await user.getIdToken(true);
        debugPrint('User authentication is still valid');
      } catch (e) {
        debugPrint('User may need to reauthenticate: $e');
        throw Exception('For security reasons, please sign out and sign in again before deleting your account.');
      }
      
      // Delete user data from Firestore
      try {
        debugPrint('Attempting to delete user data from Firestore');
        await _firestore.collection('users').doc(user.uid).delete();
        debugPrint('Successfully deleted user data from Firestore');
      } catch (e) {
        debugPrint('Error deleting user data from Firestore: $e');
        // Continue with account deletion even if Firestore deletion fails
      }
      
      // Delete profile picture from Storage if it exists
      try {
        debugPrint('Attempting to delete profile picture from Storage');
        final storageRef = _storage.ref().child('profile_pictures/${user.uid}');
        await storageRef.delete();
        debugPrint('Successfully deleted profile picture from Storage');
      } catch (e) {
        debugPrint('Error deleting profile picture from Storage: $e');
        // Continue with account deletion even if Storage deletion fails
      }
      
      // Delete the Firebase Auth user account
      debugPrint('Attempting to delete Firebase Auth user account');
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
      throw Exception('Failed to delete account. Please try again later. Error: ${e.toString()}');
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
      case 'account-exists-with-different-credential':
        return Exception('An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address.');
      case 'invalid-credential':
        return Exception('The credential is malformed or has expired.');
      case 'popup-closed-by-user':
        return Exception('The sign-in popup was closed before completing the sign-in process.');
      default:
        return Exception(e.message ?? 'An unknown error occurred.');
    }
  }
  
  // Sign in anonymously
  Future<app_models.User?> signInAnonymously() async {
    try {
      debugPrint('Attempting anonymous sign-in');
      final userCredential = await _firebaseAuth.signInAnonymously();
      
      if (userCredential.user != null) {
        // Ensure user data exists in Firestore
        await _ensureUserInFirestore(userCredential.user!, 'anonymous');
        debugPrint('User signed in anonymously: ${userCredential.user?.uid}');
        return await getCurrentUser();
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error during anonymous sign-in: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during anonymous sign-in: $e');
      throw Exception('An unexpected error occurred. Please try again later.');
    }
  }
} 