import 'package:flutter/material.dart';

enum ItemStatus { lost, found }

enum ItemCategory {
  electronics,
  clothing,
  accessories,
  documents,
  keys,
  pets,
  other,
}

class Item {
  final String id;
  final String title;
  final String description;
  final ItemStatus status;
  final ItemCategory category;
  final String location;
  final DateTime date;
  final String? imageUrl;
  final String reportedBy;
  final bool isResolved;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.location,
    required this.date,
    this.imageUrl,
    required this.reportedBy,
    this.isResolved = false,
  });

  // Convert Item to Map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.toString(),
      'category': category.toString(),
      'location': location,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
      'reportedBy': reportedBy,
      'isResolved': isResolved,
    };
  }

  // Create Item from Map
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: ItemStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
          orElse: () => ItemStatus.lost),
      category: ItemCategory.values.firstWhere(
          (e) => e.toString() == json['category'],
          orElse: () => ItemCategory.other),
      location: json['location'],
      date: DateTime.parse(json['date']),
      imageUrl: json['imageUrl'],
      reportedBy: json['reportedBy'],
      isResolved: json['isResolved'] ?? false,
    );
  }

  // Create a copy of the item with some fields changed
  Item copyWith({
    String? id,
    String? title,
    String? description,
    ItemStatus? status,
    ItemCategory? category,
    String? location,
    DateTime? date,
    String? imageUrl,
    String? reportedBy,
    bool? isResolved,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      location: location ?? this.location,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      reportedBy: reportedBy ?? this.reportedBy,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}

// Extension to get color based on category
extension ItemCategoryExtension on ItemCategory {
  String get displayName {
    switch (this) {
      case ItemCategory.electronics:
        return 'Electronics';
      case ItemCategory.clothing:
        return 'Clothing';
      case ItemCategory.accessories:
        return 'Accessories';
      case ItemCategory.documents:
        return 'Documents';
      case ItemCategory.keys:
        return 'Keys';
      case ItemCategory.pets:
        return 'Pets';
      case ItemCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ItemCategory.electronics:
        return Icons.devices;
      case ItemCategory.clothing:
        return Icons.checkroom;
      case ItemCategory.accessories:
        return Icons.watch;
      case ItemCategory.documents:
        return Icons.description;
      case ItemCategory.keys:
        return Icons.key;
      case ItemCategory.pets:
        return Icons.pets;
      case ItemCategory.other:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case ItemCategory.electronics:
        return Colors.blue;
      case ItemCategory.clothing:
        return Colors.purple;
      case ItemCategory.accessories:
        return Colors.amber;
      case ItemCategory.documents:
        return Colors.green;
      case ItemCategory.keys:
        return Colors.orange;
      case ItemCategory.pets:
        return Colors.pink;
      case ItemCategory.other:
        return Colors.grey;
    }
  }
}

// Extension to get color and text for status
extension ItemStatusExtension on ItemStatus {
  String get displayName {
    switch (this) {
      case ItemStatus.lost:
        return 'Lost';
      case ItemStatus.found:
        return 'Found';
    }
  }

  Color get color {
    switch (this) {
      case ItemStatus.lost:
        return Colors.red;
      case ItemStatus.found:
        return Colors.green;
    }
  }
}
