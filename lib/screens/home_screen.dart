import 'package:flutter/material.dart';
import 'package:lost_and_found_hub/models/item.dart';
import 'package:lost_and_found_hub/providers/item_provider.dart';
import 'package:lost_and_found_hub/screens/item_detail_screen.dart';
import 'package:lost_and_found_hub/screens/report_item_screen.dart';
import 'package:lost_and_found_hub/widgets/category_filter.dart';
import 'package:lost_and_found_hub/widgets/item_card.dart';
import 'package:lost_and_found_hub/widgets/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found Hub'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Lost'),
            Tab(text: 'Found'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          const CustomSearchBar(),
          
          // Category filter
          const CategoryFilter(),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All items tab
                ItemsGrid(itemSelector: (provider) => provider.filteredItems),
                
                // Lost items tab
                ItemsGrid(
                  itemSelector: (provider) => provider.filteredItems
                      .where((item) => item.status == ItemStatus.lost)
                      .toList(),
                ),
                
                // Found items tab
                ItemsGrid(
                  itemSelector: (provider) => provider.filteredItems
                      .where((item) => item.status == ItemStatus.found)
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReportItemScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Report Item'),
      ),
    );
  }
}

class ItemsGrid extends StatelessWidget {
  final List<Item> Function(ItemProvider) itemSelector;

  const ItemsGrid({
    Key? key,
    required this.itemSelector,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemProvider>(
      builder: (context, itemProvider, child) {
        final items = itemSelector(itemProvider);

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No items found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                if (itemProvider.searchQuery.isNotEmpty ||
                    itemProvider.selectedCategory != null)
                  TextButton.icon(
                    onPressed: () {
                      itemProvider.clearFilters();
                    },
                    icon: const Icon(Icons.filter_alt_off),
                    label: const Text('Clear filters'),
                  ),
              ],
            ),
          );
        }

        // Use MediaQuery to make the grid responsive
        return LayoutBuilder(
          builder: (context, constraints) {
            // Determine number of columns based on screen width
            final crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
            
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: MasonryGridView.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ItemCard(
                    item: item,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailScreen(itemId: item.id),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
