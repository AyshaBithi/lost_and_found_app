import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lost_and_found_hub/models/user.dart';
import 'package:lost_and_found_hub/services/database_helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  User? _currentUser;

  AuthService._internal();

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  Future<void> init() async {
    final username = await _secureStorage.read(key: 'username');
    if (username != null && username == 'admin') {

      _currentUser = User(
        id: 'admin_default',
        username: 'admin',
        passwordHash: 'dummy',
        salt: 'dummy',
        isAdmin: true,
        name: 'Administrator',
        email: 'admin@example.com',
        createdAt: DateTime.now(),
      );
    }
  }


  Future<bool> login(String username, String password) async {
    final user = await _dbHelper.getUserByUsername(username);

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


  Future<void> logout() async {
    _currentUser = null;
    await _secureStorage.delete(key: 'username');
  }


  Future<User> register({
    required String username,
    required String password,
    required bool isAdmin,
    String? name,
    String? email,
  }) async {

    final existingUser = await _dbHelper.getUserByUsername(username);
    if (existingUser != null) {
      throw Exception('Username already exists');
    }


    final newUser = User.create(
      username: username,
      password: password,
      isAdmin: isAdmin,
      name: name,
      email: email,
    );

    await _dbHelper.insertUser(newUser);
    return newUser;
  }


  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) return false;


    if (!_currentUser!.verifyPassword(currentPassword)) {
      return false;
    }


    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final passwordHash = User.hashPassword(newPassword, salt);

    final updatedUser = _currentUser!.copyWith(
      passwordHash: passwordHash,
      salt: salt,
    );


    await _dbHelper.updateUser(updatedUser);
    _currentUser = updatedUser;

    return true;
  }
}
