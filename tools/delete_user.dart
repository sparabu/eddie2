// A script to delete a Firebase user account using the Admin SDK
// Usage: dart tools/delete_user.dart <email>

import 'dart:io';
import 'package:firebase_admin/firebase_admin.dart';
import 'package:firebase_admin/src/auth/credential.dart';
import 'package:firebase_admin/src/auth/user_record.dart';

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('Usage: dart tools/delete_user.dart <email>');
    exit(1);
  }

  final email = arguments[0];
  print('Attempting to delete user with email: $email');

  try {
    // Initialize Firebase Admin SDK
    final credential = ServiceAccountCredential.fromFile('service-account-key.json');
    FirebaseAdmin.instance.initializeApp(
      AppOptions(
        credential: credential,
        projectId: credential.projectId,
        databaseURL: 'https://${credential.projectId}.firebaseio.com',
      ),
    );

    // Get the Auth instance
    final auth = FirebaseAdmin.instance.auth();

    // Find user by email
    UserRecord? user;
    try {
      user = await auth.getUserByEmail(email);
      print('Found user with UID: ${user.uid}');
    } catch (e) {
      print('User not found with email: $email');
      print('Error: $e');
      exit(1);
    }

    // Delete user
    await auth.deleteUser(user.uid);
    print('Successfully deleted user with email: $email');

    // Also delete user data from Firestore if needed
    // This would require additional setup with Firestore Admin SDK

  } catch (e) {
    print('Error: $e');
    exit(1);
  }
} 