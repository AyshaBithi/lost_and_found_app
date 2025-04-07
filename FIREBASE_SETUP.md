# Firebase Setup Instructions

This document provides instructions on how to set up Firebase for the Lost and Found Hub application.

## Prerequisites

1. A Google account
2. Flutter SDK installed
3. Firebase CLI installed (optional, but recommended)

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click on "Add project"
3. Enter a project name (e.g., "Lost and Found Hub")
4. Choose whether to enable Google Analytics (recommended)
5. Accept the terms and click "Create project"
6. Wait for the project to be created and click "Continue"

## Step 2: Register Your App with Firebase

### Web App

1. In the Firebase console, click on the web icon (</>) to add a web app
2. Register your app with a nickname (e.g., "lost-and-found-hub-web")
3. Check the box for "Also set up Firebase Hosting" (optional)
4. Click "Register app"
5. Copy the Firebase configuration object
6. Open the `web/firebase-config.js` file in your project
7. Replace the placeholder values with your actual Firebase configuration

### Android App (Optional)

1. In the Firebase console, click on the Android icon to add an Android app
2. Enter your app's package name (e.g., "com.example.lost_and_found_hub")
3. Enter a nickname (optional)
4. Download the `google-services.json` file
5. Place the file in the `android/app` directory of your Flutter project

### iOS App (Optional)

1. In the Firebase console, click on the iOS icon to add an iOS app
2. Enter your app's bundle ID (e.g., "com.example.lostAndFoundHub")
3. Enter a nickname (optional)
4. Download the `GoogleService-Info.plist` file
5. Place the file in the `ios/Runner` directory of your Flutter project

## Step 3: Enable Firestore Database

1. In the Firebase console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database (choose the closest to your users)
5. Click "Enable"

## Step 4: Set Up Authentication

1. In the Firebase console, go to "Authentication"
2. Click "Get started"
3. Enable the "Email/Password" sign-in method
4. (Optional) Enable other sign-in methods as needed

## Step 5: Set Up Storage (for Images)

1. In the Firebase console, go to "Storage"
2. Click "Get started"
3. Choose "Start in test mode" (for development)
4. Select a location for your storage (choose the same as your Firestore database)
5. Click "Done"

## Step 6: Update Security Rules

### Firestore Rules

1. In the Firebase console, go to "Firestore Database"
2. Click on the "Rules" tab
3. Update the rules to match your security requirements:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to all documents
    match /{document=**} {
      allow read: if true;
    }
    
    // Allow write access to authenticated users
    match /items/{itemId} {
      allow write: if request.auth != null;
    }
    
    // Only allow admin users to write to users collection
    match /users/{userId} {
      allow write: if request.auth != null && 
                    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

### Storage Rules

1. In the Firebase console, go to "Storage"
2. Click on the "Rules" tab
3. Update the rules to match your security requirements:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Step 7: Deploy Your App (Optional)

If you want to deploy your app to Firebase Hosting:

1. Install the Firebase CLI: `npm install -g firebase-tools`
2. Login to Firebase: `firebase login`
3. Initialize your project: `firebase init`
4. Select "Hosting" and your Firebase project
5. Set your public directory to "build/web"
6. Configure as a single-page app: "Yes"
7. Build your Flutter web app: `flutter build web`
8. Deploy to Firebase: `firebase deploy`

## Troubleshooting

- If you encounter CORS issues, make sure to configure your Firebase Storage CORS settings
- If authentication fails, check that you've enabled the correct sign-in methods
- For Firestore permission issues, review your security rules

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview/)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
