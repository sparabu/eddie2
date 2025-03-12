#!/usr/bin/env python3

# A script to delete a Firebase user account using the Firebase Admin SDK
# Usage: python tools/delete_user.py <email>

import sys
import firebase_admin
from firebase_admin import auth, credentials, firestore

def main():
    if len(sys.argv) < 2:
        print("Usage: python tools/delete_user.py <email>")
        sys.exit(1)

    email = sys.argv[1]
    print(f"Attempting to delete user with email: {email}")

    try:
        # Initialize Firebase Admin SDK
        # You need to download the service account key from Firebase Console
        # and save it as service-account-key.json in the project root
        cred = credentials.Certificate("service-account-key.json")
        firebase_admin.initialize_app(cred)

        # Get the Auth instance
        auth_instance = auth.Client(app=firebase_admin.get_app())
        
        # Find user by email
        try:
            user = auth.get_user_by_email(email)
            print(f"Found user with UID: {user.uid}")
        except auth.UserNotFoundError:
            print(f"User not found with email: {email}")
            sys.exit(1)

        # Delete user data from Firestore
        try:
            db = firestore.client()
            db.collection('users').document(user.uid).delete()
            print(f"Deleted user data from Firestore for UID: {user.uid}")
        except Exception as e:
            print(f"Error deleting user data from Firestore: {e}")
            print("Continuing with account deletion...")

        # Delete user
        auth.delete_user(user.uid)
        print(f"Successfully deleted user with email: {email}")

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 