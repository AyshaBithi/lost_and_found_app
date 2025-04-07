import 'package:flutter/material.dart';
import 'package:lost_and_found_hub/models/item.dart';
import 'package:lost_and_found_hub/providers/item_provider.dart';
import 'package:provider/provider.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final selectedCategory = itemProvider.selectedCategory;

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // All categories option
          CategoryChip(
            label: 'All',
            icon: Icons.all_inclusive,
            color: Colors.blue,
            isSelected: selectedCategory == null,
            onTap: () => itemProvider.setCategory(null),
          ),
          // Category chips for each category
          ...ItemCategory.values.map((category) => CategoryChip(
                label: category.displayName,
                icon: category.icon,
                color: category.color,
                isSelected: selectedCategory == category,
                onTap: () => itemProvider.setCategory(category),
              )),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(51) : Colors.transparent, // 0.2 opacity = 51 in alpha (255 * 0.2)
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
