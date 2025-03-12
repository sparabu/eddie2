#!/bin/bash

# A script to delete a Firebase user account using the Firebase CLI
# Usage: ./tools/delete_user.sh <email>

if [ $# -eq 0 ]; then
  echo "Usage: ./tools/delete_user.sh <email>"
  exit 1
fi

EMAIL=$1
echo "Attempting to delete user with email: $EMAIL"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
  echo "Firebase CLI is not installed. Please install it using:"
  echo "npm install -g firebase-tools"
  exit 1
fi

# Check if user is logged in to Firebase
if ! firebase auth:export --format=json 2>&1 | grep -q "Error: Authentication Error"; then
  echo "You need to log in to Firebase first. Run:"
  echo "firebase login"
  exit 1
fi

# Find the user by email
USER_UID=$(firebase auth:export --format=json | jq -r ".users[] | select(.email == \"$EMAIL\") | .localId")

if [ -z "$USER_UID" ]; then
  echo "User not found with email: $EMAIL"
  exit 1
fi

echo "Found user with UID: $USER_UID"

# Delete the user
firebase auth:delete $USER_UID

if [ $? -eq 0 ]; then
  echo "Successfully deleted user with email: $EMAIL"
else
  echo "Failed to delete user with email: $EMAIL"
  exit 1
fi

echo "Note: You may also need to manually delete user data from Firestore and Storage." 