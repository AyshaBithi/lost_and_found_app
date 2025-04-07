import 'dart:math';
import 'package:lost_and_found_hub/models/item.dart';
import 'package:lost_and_found_hub/services/firebase_service.dart';

class ItemService {
  final FirebaseService _firebaseService = FirebaseService();

  // Constructor to initialize with sample data
  ItemService() {
    _initializeDatabase();
  }

  // Initialize the database with sample data
  Future<void> _initializeDatabase() async {
    await _firebaseService.insertSampleData();
  }

  // Get all items
  Future<List<Item>> getAllItems() async {
    return await _firebaseService.getAllItems();
  }

  // Get items by status
  Future<List<Item>> getItemsByStatus(ItemStatus status) async {
    return await _firebaseService.getItemsByStatus(status);
  }

  // Get items by category
  Future<List<Item>> getItemsByCategory(ItemCategory category) async {
    return await _firebaseService.getItemsByCategory(category);
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

  // Mark an item as resolved
  Future<void> markItemAsResolved(String id) async {
    await _firebaseService.markItemAsResolved(id);
  }
  void _generateMockItems() {
    // This method is now empty as I'm using the Firebase service to generate sample data
  }
}
