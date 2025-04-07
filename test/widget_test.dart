// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_found_hub/main.dart';
import 'package:lost_and_found_hub/models/item.dart';
import 'package:lost_and_found_hub/providers/item_provider.dart';
import 'package:lost_and_found_hub/screens/home_screen.dart';
import 'package:lost_and_found_hub/widgets/item_card.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for any animations to complete
    await tester.pumpAndSettle();

    // Verify that the app has a bottom navigation bar
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('Home screen should display items', (WidgetTester tester) async {
    // Create a test ItemProvider with mock data
    final itemProvider = ItemProvider();

    // Build our app with the provider
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ItemProvider>.value(
          value: itemProvider,
          child: const Scaffold(
            body: HomeScreen(),
          ),
        ),
      ),
    );

    // Wait for any animations to complete
    await tester.pumpAndSettle();

    // Verify that some items are displayed
    expect(find.byType(ItemCard), findsWidgets);
  });

  test('ItemProvider should filter items correctly', () {
    final provider = ItemProvider();

    // Test initial state
    expect(provider.allItems.isNotEmpty, true);
    expect(provider.lostItems.every((item) => item.status == ItemStatus.lost), true);
    expect(provider.foundItems.every((item) => item.status == ItemStatus.found), true);

    // Test category filter
    provider.setCategory(ItemCategory.electronics);
    expect(
      provider.filteredItems.every((item) => item.category == ItemCategory.electronics),
      true,
    );

    // Test search filter
    provider.clearFilters();
    provider.setSearchQuery('wallet');
    expect(
      provider.filteredItems.every(
        (item) => item.title.toLowerCase().contains('wallet') ||
            item.description.toLowerCase().contains('wallet') ||
            item.location.toLowerCase().contains('wallet'),
      ) || provider.filteredItems.isEmpty,
      true,
    );

    // Test clearing filters
    provider.clearFilters();
    expect(provider.selectedCategory, null);
    expect(provider.searchQuery, '');
  });
}
