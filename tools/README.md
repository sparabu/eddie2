# Eddie2 Admin Tools

This directory contains administrative tools for managing the Eddie2 application.

## User Account Management

### Delete User Account

We provide several options to delete a user account:

#### Option 1: Using the Firebase Console (Easiest)

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to Authentication > Users
4. Find the user by email
5. Click the three dots menu and select "Delete account"

#### Option 2: Using the Python Script

Requirements:
- Python 3.6+
- Firebase Admin SDK (`pip install firebase-admin`)
- Service Account Key (download from Firebase Console)

Steps:
1. Download the service account key from Firebase Console:
   - Go to Project Settings > Service Accounts
   - Click "Generate new private key"
   - Save the file as `service-account-key.json` in the project root

2. Run the script:
   ```
   python tools/delete_user.py <email>
   ```

#### Option 3: Using the Shell Script

Requirements:
- Firebase CLI (`npm install -g firebase-tools`)
- jq (`apt-get install jq` or `brew install jq`)

Steps:
1. Log in to Firebase:
   ```
   firebase login
   ```

2. Run the script:
   ```
   ./tools/delete_user.sh <email>
   ```

## Important Notes

- Deleting a user account will remove the user from Firebase Authentication
- You may also need to manually delete user data from Firestore and Storage
- After deleting an account, you should be able to sign up again with the same email 