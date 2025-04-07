import 'package:flutter/material.dart';
import 'package:lost_and_found_hub/models/item.dart';
import 'package:lost_and_found_hub/services/item_service.dart';

class ItemProvider with ChangeNotifier {
  final ItemService _itemService = ItemService();

  // Local cache of items
  List<Item> _allItems = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Getters for state
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  // Getters for items
  List<Item> get allItems => _allItems;
  List<Item> get lostItems => _allItems.where((item) => item.status == ItemStatus.lost).toList();
  List<Item> get foundItems => _allItems.where((item) => item.status == ItemStatus.found).toList();

  // Filters
  ItemCategory? _selectedCategory;
  String _searchQuery = '';

  // Getters for filters
  ItemCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Constructor
  ItemProvider() {
    _initializeItems();
  }

  // Initialize items
  Future<void> _initializeItems() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      _allItems = await _itemService.getAllItems();
      _isInitialized = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh items
  Future<void> refreshItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allItems = await _itemService.getAllItems();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtered items
  List<Item> get filteredItems {
    List<Item> items = _allItems;

    // Apply category filter
    if (_selectedCategory != null) {
      items = items.where((item) => item.category == _selectedCategory).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) =>
        item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item.location.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Sort by date (newest first)
    items.sort((a, b) => b.date.compareTo(a.date));

    return items;
  }

  // Set category filter
  void setCategory(ItemCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    notifyListeners();
  }

  // Add a new item
  Future<void> addItem(Item item) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _itemService.addItem(item);
      await refreshItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing item
  Future<void> updateItem(Item item) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _itemService.updateItem(item);
      await refreshItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete an item
  Future<void> deleteItem(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _itemService.deleteItem(id);
      await refreshItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark an item as resolved
  Future<void> markItemAsResolved(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _itemService.markItemAsResolved(id);
      await refreshItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get item by id
  Item? getItemById(String id) {
    try {
      return _allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get item by id async
  Future<Item?> getItemByIdAsync(String id) async {
    try {
      return await _itemService.getItemById(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // Clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
