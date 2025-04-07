# Firebase Integration Code Snippets

This document contains key code snippets used for Firebase integration in our Lost and Found Hub application.

## Firebase Service Implementation

```dart
// lib/services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lost_and_found_hub/models/item.dart';
import 'package:lost_and_found_hub/models/user.dart' as app_user;

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  FirebaseService._internal();
  
  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }
  
  // Collection references
  CollectionReference get _itemsCollection => _firestore.collection('items');
  CollectionReference get _usersCollection => _firestore.collection('users');
  
  // CRUD Operations for Items
  
  // Create a new item
  Future<void> createItem(Item item) async {
    await _itemsCollection.doc(item.id).set(item.toJson());
  }
  
  // Read all items
  Future<List<Item>> getAllItems() async {
    final QuerySnapshot snapshot = await _itemsCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Item.fromJson(data);
    }).toList();
  }
  
  // Read items by status
  Future<List<Item>> getItemsByStatus(ItemStatus status) async {
    final QuerySnapshot snapshot = await _itemsCollection
        .where('status', isEqualTo: status.toString())
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Item.fromJson(data);
    }).toList();
  }
  
  // Get item by id
  Future<Item?> getItemById(String id) async {
    final DocumentSnapshot doc = await _itemsCollection.doc(id).get();
    
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    return Item.fromJson(data);
  }
  
  // Update an item
  Future<void> updateItem(Item item) async {
    await _itemsCollection.doc(item.id).update(item.toJson());
  }
  
  // Delete an item
  Future<void> deleteItem(String id) async {
    await _itemsCollection.doc(id).delete();
  }
}
```

## Firebase Configuration for Web

```javascript
// web/firebase-config.js

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
```

## Firebase Initialization in Main App

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:lost_and_found_hub/services/firebase_service.dart';
import 'package:lost_and_found_hub/services/auth_service.dart';

void main() async {
  // Ensure Flutter is initialized properly
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initialize();
  
  // Initialize auth service
  final authService = AuthService();
  await authService.init();
  
  runApp(const MyApp());
}
```

## Item Service with Firebase Integration

```dart
// lib/services/item_service.dart

import 'package:lost_and_found_hub/models/item.dart';
import 'package:lost_and_found_hub/services/firebase_service.dart';

class ItemService {
  final FirebaseService _firebaseService = FirebaseService();

  // Get all items
  Future<List<Item>> getAllItems() async {
    return await _firebaseService.getAllItems();
  }

  // Get items by status
  Future<List<Item>> getItemsByStatus(ItemStatus status) async {
    return await _firebaseService.getItemsByStatus(status);
  }

  // Get item by id
  Future<Item?> getItemById(String id) async {
    return await _firebaseService.getItemById(id);
  }

  // Add a new item
  Future<void> addItem(Item item) async {
    await _firebaseService.createItem(item);
  }

  // Update an existing item
  Future<void> updateItem(Item updatedItem) async {
    await _firebaseService.updateItem(updatedItem);
  }

  // Delete an item
  Future<void> deleteItem(String id) async {
    await _firebaseService.deleteItem(id);
  }
}
```

## Authentication Service with Firebase

```dart
// lib/services/auth_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lost_and_found_hub/models/user.dart';
import 'package:lost_and_found_hub/services/firebase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FirebaseService _firebaseService = FirebaseService();
  
  User? _currentUser;
  
  AuthService._internal();
  
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  
  Future<void> init() async {
    // Initialize Firebase
    await FirebaseService.initialize();
    
    final username = await _secureStorage.read(key: 'username');
    if (username != null) {
      _currentUser = await _firebaseService.getUserByUsername(username);
    }
  }
  
  Future<bool> login(String username, String password) async {
    final user = await _firebaseService.getUserByUsername(username);

    if (user == null) {
      return false;
    }

    if (user.verifyPassword(password)) {
      _currentUser = user;
      await _secureStorage.write(key: 'username', value: username);
      return true;
    }

    return false;
  }
}
```

## Firebase Web Integration in index.html

```html
<!-- web/index.html -->

<!DOCTYPE html>
<html>
<head>
  <!-- Other head elements -->
  
  <!-- Firebase SDK -->
  <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-firestore-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-auth-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-storage-compat.js"></script>
  
  <!-- Firebase Configuration -->
  <script src="firebase-config.js"></script>
</head>
<body>
  <!-- Body content -->
</body>
</html>
```

## Firestore Security Rules

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

## Firebase Dependencies in pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
```
