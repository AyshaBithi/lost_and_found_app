import 'package:flutter/material.dart';
import 'package:lost_and_found_hub/models/item.dart';
import 'package:lost_and_found_hub/providers/item_provider.dart';
import 'package:lost_and_found_hub/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);
    final theme = Theme.of(context);
    
    // Check if user is logged in and is admin
    if (!authProvider.isLoggedIn || !authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Access Required'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.5),
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
              
              const SizedBox(height: 24),
              
              Text(
                'Admin Access Required',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'You need to be logged in as an administrator to access this section.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Show loading indicator while items are loading
    if (itemProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Admin Dashboard',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            // Refresh button
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Data',
              onPressed: () => itemProvider.refreshItems(),
            ),
            // Logout button
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          authProvider.logout();
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Go back to home
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'All Items (${itemProvider.allItems.length})'),
              Tab(text: 'Lost Items (${itemProvider.lostItems.length})'),
              Tab(text: 'Found Items (${itemProvider.foundItems.length})'),
            ],
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // All items tab
            ItemsTable(
              itemSelector: (provider) => provider.allItems,
            ),
            
            // Lost items tab
            ItemsTable(
              itemSelector: (provider) => provider.lostItems,
            ),
            
            // Found items tab
            ItemsTable(
              itemSelector: (provider) => provider.foundItems,
            ),
          ],
        ),
      ),
    ).animate()
     .fadeIn(duration: 400.ms)
     .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuad);
  }
}

class ItemsTable extends StatelessWidget {
  final List<Item> Function(ItemProvider) itemSelector;

  const ItemsTable({
    Key? key,
    required this.itemSelector,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                  size: 64,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No items found',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'There are no items in this category',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ).animate()
           .fadeIn(duration: 400.ms)
           .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
        }

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  theme.colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                dataRowMinHeight: 64,
                dataRowMaxHeight: 64,
                columnSpacing: 24,
                horizontalMargin: 16,
                dividerThickness: 1,
                showBottomBorder: true,
                columns: [
                  DataColumn(label: Text(
                    'ID',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  )),
                  DataColumn(label: Text(
                    'Title',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  )),
                  DataColumn(label: Text(
                    'Category',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  )),
                  DataColumn(label: Text(
                    'Status',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  )),
                  DataColumn(label: Text(
                    'Date',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  )),
                  DataColumn(label: Text(
                    'Location',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  )),
                  DataColumn(label: Text(
                    'Reported By',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  )),
                  DataColumn(label: Text(
                    'Resolved',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  )),
                  DataColumn(label: Text(
                    'Actions',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  )),
                ],
                rows: items.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item.id)),
                      DataCell(Text(item.title)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.category.icon,
                              size: 16,
                              color: item.category.color,
                            ),
                            const SizedBox(width: 4),
                            Text(item.category.displayName),
                          ],
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.status.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.status.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(DateFormat('MM/dd/yyyy').format(item.date))),
                      DataCell(Text(item.location)),
                      DataCell(Text(item.reportedBy)),
                      DataCell(
                        item.isResolved
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.close, color: Colors.red),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Mark as resolved button
                            if (!item.isResolved)
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                tooltip: 'Mark as Resolved',
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.green.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  await itemProvider.markItemAsResolved(item.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Item marked as resolved',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            const SizedBox(width: 8),
                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete Item',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Delete Item',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete this item? This action cannot be undone.',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Cancel',
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        onPressed: () async {
                                          await itemProvider.deleteItem(item.id);
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Item deleted',
                                                  style: GoogleFonts.poppins(),
                                                ),
                                                backgroundColor: Colors.red,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          'Delete',
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
