import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lost_and_found_hub/models/item.dart';
import 'package:lost_and_found_hub/models/user.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  final List<Item> _webItems = [];
  final List<User> _webUsers = [];
  bool _isWebInitialized = false;

  Future<Database?> get database async {
    if (kIsWeb) return null;

    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite database is not supported on web platform');
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'lost_and_found.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }


  Future<void> _initWebData() async {
    if (_isWebInitialized) return;


    final salt = 'default_salt';
    final passwordHash = User.hashPassword('password', salt);

    _webUsers.add(User(
      id: 'admin_default',
      username: 'admin',
      passwordHash: passwordHash,
      salt: salt,
      isAdmin: true,
      name: 'Administrator',
      email: 'admin@example.com',
      createdAt: DateTime.now(),
    ));


    await insertSampleData();

    _isWebInitialized = true;
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        category TEXT NOT NULL,
        location TEXT NOT NULL,
        date TEXT NOT NULL,
        imageUrl TEXT,
        reportedBy TEXT NOT NULL,
        isResolved INTEGER NOT NULL
      )
    ''');

    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        salt TEXT NOT NULL,
        isAdmin INTEGER NOT NULL,
        name TEXT,
        email TEXT,
        createdAt TEXT NOT NULL
      )
    ''');


    final salt = 'default_salt';
    final passwordHash = User.hashPassword('password', salt);

    await db.insert('users', {
      'id': 'admin_${DateTime.now().millisecondsSinceEpoch}',
      'username': 'admin',
      'passwordHash': passwordHash,
      'salt': salt,
      'isAdmin': 1,
      'name': 'Administrator',
      'email': 'admin@example.com',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Item>> getAllItems() async {
    if (kIsWeb) {
      if (!_isWebInitialized) await _initWebData();
      return [..._webItems];
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('items');

    return List.generate(maps.length, (i) {
      return Item.fromJson(maps[i]);
    });
  }

  Future<Item?> getItemById(String id) async {
    if (kIsWeb) {
      if (!_isWebInitialized) await _initWebData();
      try {
        return _webItems.firstWhere((item) => item.id == id);
      } catch (e) {
        return null;
      }
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Item.fromJson(maps.first);
  }

  Future<List<Item>> getItemsByStatus(ItemStatus status) async {
    if (kIsWeb) {
      if (!_isWebInitialized) await _initWebData();
      return _webItems.where((item) => item.status == status).toList();
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'items',
      where: 'status = ?',
      whereArgs: [status.toString()],
    );

    return List.generate(maps.length, (i) {
      return Item.fromJson(maps[i]);
    });
  }

  Future<List<Item>> getItemsByCategory(ItemCategory category) async {
    if (kIsWeb) {
      if (!_isWebInitialized) await _initWebData();
      return _webItems.where((item) => item.category == category).toList();
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'items',
      where: 'category = ?',
      whereArgs: [category.toString()],
    );

    return List.generate(maps.length, (i) {
      return Item.fromJson(maps[i]);
    });
  }

  Future<void> insertItem(Item item) async {
    if (kIsWeb) {
      if (!_isWebInitialized) await _initWebData();
      _webItems.add(item);
      return;
    }

    final db = await database;
    await db!.insert(
      'items',
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateItem(Item item) async {
    if (kIsWeb) {
      if (!_isWebInitialized) await _initWebData();
      final index = _webItems.indexWhere((i) => i.id == item.id);
      if (index >= 0) {
        _webItems[index] = item;
      }
      return;
    }

    final db = await database;
    await db!.update(
      'items',
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteItem(String id) async {
    if (kIsWeb) {
      if (!_isWebInitialized) await _initWebData();
      _webItems.removeWhere((item) => item.id == id);
      return;
    }

    final db = await database;
    await db!.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markItemAsResolved(String id) async {
    if (kIsWeb) {
      if (!_isWebInitialized) await _initWebData();
      final index = _webItems.indexWhere((item) => item.id == id);
      if (index >= 0) {
        _webItems[index] = _webItems[index].copyWith(isResolved: true);
      }
      return;
    }

    final db = await database;
    await db!.update(
      'items',
      {'isResolved': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<User?> getUserByUsername(String username) async {
    if (kIsWeb) {
      if (!_isWebInitialized) {
        await _initWebData();
      }

      try {
        final user = _webUsers.firstWhere((user) => user.username == username);
        return user;
      } catch (e) {
        return null;
      }
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isEmpty) {
      return null;
    }

    final user = User.fromJson(maps.first);
    return user;
  }

  Future<void> insertUser(User user) async {
    if (kIsWeb) {
      if (!_isWebInitialized) await _initWebData();
      _webUsers.add(user);
      return;
    }

    final db = await database;
    await db!.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUser(User user) async {
    if (kIsWeb) {
      if (!_isWebInitialized) await _initWebData();
      final index = _webUsers.indexWhere((u) => u.id == user.id);
      if (index >= 0) {
        _webUsers[index] = user;
      }
      return;
    }

    final db = await database;
    await db!.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(String id) async {
    if (kIsWeb) {
      if (!_isWebInitialized) await _initWebData();
      _webUsers.removeWhere((user) => user.id == id);
      return;
    }

    final db = await database;
    await db!.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertSampleData() async {
    if (kIsWeb) {
      if (_webItems.isNotEmpty) return;


      for (int i = 0; i < 10; i++) {
        final item = Item(
          id: 'L${i.toString().padLeft(3, '0')}',
          title: 'Lost ${_getSampleItemName(i)}',
          description: 'I lost this item and would appreciate any help finding it.',
          status: ItemStatus.lost,
          category: _getRandomCategory(i),
          location: _getSampleLocation(i),
          date: DateTime.now().subtract(Duration(days: i)),
          reportedBy: 'User${i % 5}',
          imageUrl: 'https://picsum.photos/200/300?random=$i',
        );

        _webItems.add(item);
      }


      for (int i = 0; i < 10; i++) {
        final item = Item(
          id: 'F${i.toString().padLeft(3, '0')}',
          title: 'Found ${_getSampleItemName(i + 10)}',
          description: 'I found this item. Contact me to claim it.',
          status: ItemStatus.found,
          category: _getRandomCategory(i + 10),
          location: _getSampleLocation(i + 5),
          date: DateTime.now().subtract(Duration(days: i)),
          reportedBy: 'User${(i + 3) % 5}',
          imageUrl: 'https://picsum.photos/200/300?random=${i + 10}',
        );

        _webItems.add(item);
      }

      return;
    }

    final db = await database;


    final itemCount = Sqflite.firstIntValue(
      await db!.rawQuery('SELECT COUNT(*) FROM items')
    );

    if (itemCount == 0) {

      for (int i = 0; i < 10; i++) {
        final item = Item(
          id: 'L${i.toString().padLeft(3, '0')}',
          title: 'Lost ${_getSampleItemName(i)}',
          description: 'I lost this item and would appreciate any help finding it.',
          status: ItemStatus.lost,
          category: _getRandomCategory(i),
          location: _getSampleLocation(i),
          date: DateTime.now().subtract(Duration(days: i)),
          reportedBy: 'User${i % 5}',
          imageUrl: 'https://picsum.photos/200/300?random=$i',
        );

        await insertItem(item);
      }


      for (int i = 0; i < 10; i++) {
        final item = Item(
          id: 'F${i.toString().padLeft(3, '0')}',
          title: 'Found ${_getSampleItemName(i + 10)}',
          description: 'I found this item. Contact me to claim it.',
          status: ItemStatus.found,
          category: _getRandomCategory(i + 10),
          location: _getSampleLocation(i + 5),
          date: DateTime.now().subtract(Duration(days: i)),
          reportedBy: 'User${(i + 3) % 5}',
          imageUrl: 'https://picsum.photos/200/300?random=${i + 10}',
        );

        await insertItem(item);
      }
    }
  }

  ItemCategory _getRandomCategory(int seed) {
    final categories = ItemCategory.values;
    return categories[seed % categories.length];
  }

  String _getSampleItemName(int index) {
    final items = [
      'Wallet', 'Phone', 'Keys', 'Laptop', 'Backpack',
      'Umbrella', 'Glasses', 'Headphones', 'Watch', 'Tablet',
      'Jacket', 'Book', 'Water Bottle', 'ID Card', 'Notebook',
      'Charger', 'Earbuds', 'Scarf', 'Hat', 'Gloves'
    ];

    return items[index % items.length];
  }

  String _getSampleLocation(int index) {
    final locations = [
      'Library', 'Cafeteria', 'Gym', 'Lecture Hall A', 'Student Center',
      'Parking Lot', 'Bus Stop', 'Dormitory', 'Science Building', 'Admin Office'
    ];

    return locations[index % locations.length];
  }
}
