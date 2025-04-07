import 'dart:convert';
import 'package:crypto/crypto.dart';

class User {
  final String id;
  final String username;
  final String passwordHash;
  final String salt;
  final bool isAdmin;
  final String? name;
  final String? email;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.salt,
    required this.isAdmin,
    this.name,
    this.email,
    required this.createdAt,
  });

  // Convert User to Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'passwordHash': passwordHash,
      'salt': salt,
      'isAdmin': isAdmin ? 1 : 0,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create User from Map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      passwordHash: json['passwordHash'],
      salt: json['salt'],
      isAdmin: json['isAdmin'] == 1,
      name: json['name'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Create a copy of the user with some fields changed
  User copyWith({
    String? id,
    String? username,
    String? passwordHash,
    String? salt,
    bool? isAdmin,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      isAdmin: isAdmin ?? this.isAdmin,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Hash a password with the user's salt
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verify a password against the stored hash
  bool verifyPassword(String password) {
    final hashedPassword = User.hashPassword(password, salt);
    return hashedPassword == passwordHash;
  }

  // Create a new user with a hashed password
  static User create({
    required String username,
    required String password,
    required bool isAdmin,
    String? name,
    String? email,
  }) {
    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final passwordHash = hashPassword(password, salt);
    
    return User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      passwordHash: passwordHash,
      salt: salt,
      isAdmin: isAdmin,
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
  }
}
