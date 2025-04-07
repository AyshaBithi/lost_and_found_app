import 'dart:math';
import 'package:lost_and_found_hub/models/item.dart';
import 'package:lost_and_found_hub/services/database_helper.dart';

class ItemService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Constructor to initialize with sample data
  ItemService() {
    _initializeDatabase();
  }

  // Initialize the database with sample data
  Future<void> _initializeDatabase() async {
    await _dbHelper.insertSampleData();
  }

  // Get all items
  Future<List<Item>> getAllItems() async {
    return await _dbHelper.getAllItems();
  }

  // Get items by status
  Future<List<Item>> getItemsByStatus(ItemStatus status) async {
    return await _dbHelper.getItemsByStatus(status);
  }

  // Get items by category
  Future<List<Item>> getItemsByCategory(ItemCategory category) async {
    return await _dbHelper.getItemsByCategory(category);
  }

  // Get item by id
  Future<Item?> getItemById(String id) async {
    return await _dbHelper.getItemById(id);
  }

  // Add a new item
  Future<void> addItem(Item item) async {
    await _dbHelper.insertItem(item);
  }

  // Update an existing item
  Future<void> updateItem(Item updatedItem) async {
    await _dbHelper.updateItem(updatedItem);
  }

  // Delete an item
  Future<void> deleteItem(String id) async {
    await _dbHelper.deleteItem(id);
  }

  // Mark an item as resolved
  Future<void> markItemAsResolved(String id) async {
    await _dbHelper.markItemAsResolved(id);
  }
  void _generateMockItems() {
    // This method is now empty as I'm using the database helper to generate sample data
  }
}
