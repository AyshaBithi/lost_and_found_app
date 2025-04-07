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
  
  // Read items by category
  Future<List<Item>> getItemsByCategory(ItemCategory category) async {
    final QuerySnapshot snapshot = await _itemsCollection
        .where('category', isEqualTo: category.toString())
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
  
  // Mark an item as resolved
  Future<void> markItemAsResolved(String id) async {
    await _itemsCollection.doc(id).update({'isResolved': true});
  }
  
  // User operations
  
  // Create a new user
  Future<void> createUser(app_user.User user) async {
    await _usersCollection.doc(user.id).set(user.toJson());
  }
  
  // Get user by username
  Future<app_user.User?> getUserByUsername(String username) async {
    final QuerySnapshot snapshot = await _usersCollection
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    return app_user.User.fromJson(data);
  }
  
  // Update a user
  Future<void> updateUser(app_user.User user) async {
    await _usersCollection.doc(user.id).update(user.toJson());
  }
  
  // Delete a user
  Future<void> deleteUser(String id) async {
    await _usersCollection.doc(id).delete();
  }
  
  // Insert sample data for testing
  Future<void> insertSampleData() async {
    // Check if data already exists
    final QuerySnapshot itemsSnapshot = await _itemsCollection.limit(1).get();
    
    if (itemsSnapshot.docs.isEmpty) {
      // Insert sample lost items
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
        
        await createItem(item);
      }
      
      // Insert sample found items
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
        
        await createItem(item);
      }
    }
    
    // Check if admin user exists
    final QuerySnapshot adminSnapshot = await _usersCollection
        .where('username', isEqualTo: 'admin')
        .limit(1)
        .get();
    
    if (adminSnapshot.docs.isEmpty) {
      // Create default admin user
      final salt = 'default_salt';
      final passwordHash = app_user.User.hashPassword('password', salt);
      
      final adminUser = app_user.User(
        id: 'admin_default',
        username: 'admin',
        passwordHash: passwordHash,
        salt: salt,
        isAdmin: true,
        name: 'Administrator',
        email: 'admin@example.com',
        createdAt: DateTime.now(),
      );
      
      await createUser(adminUser);
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
