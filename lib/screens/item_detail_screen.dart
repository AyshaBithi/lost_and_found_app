import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_found_hub/models/item.dart';
import 'package:lost_and_found_hub/providers/item_provider.dart';
import 'package:lost_and_found_hub/services/api_service.dart';
import 'package:provider/provider.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailScreen({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    final item = Provider.of<ItemProvider>(context, listen: false).getItemById(widget.itemId);
    if (item != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final weatherData = await _apiService.getWeatherForLocation(item.location);
        setState(() {
          _weatherData = weatherData;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemProvider>(
      builder: (context, itemProvider, child) {
        final item = itemProvider.getItemById(widget.itemId);

        if (item == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Item Not Found'),
            ),
            body: const Center(
              child: Text('The requested item could not be found.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${item.status.displayName} Item'),
            actions: [
              if (!item.isResolved)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  tooltip: 'Mark as Resolved',
                  onPressed: () {
                    itemProvider.markItemAsResolved(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Item marked as resolved'),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item image
                if (item.imageUrl != null)
                  SizedBox(
                    width: double.infinity,
                    height: 250,
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      },
                    ),
                  ),

                // Item details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status and category badges
                      Row(
                        children: [
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: item.status.color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.status.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: item.category.color.withAlpha(51), // 0.2 opacity = 51 in alpha (255 * 0.2)
                              border: Border.all(color: item.category.color),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.category.icon,
                                  size: 16,
                                  color: item.category.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.category.displayName,
                                  style: TextStyle(
                                    color: item.category.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Resolved badge
                          if (item.isResolved)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Resolved',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Date and location
                      DetailRow(
                        icon: Icons.calendar_today,
                        text: DateFormat('MMMM dd, yyyy').format(item.date),
                      ),
                      const SizedBox(height: 4),
                      DetailRow(
                        icon: Icons.location_on,
                        text: item.location,
                      ),
                      const SizedBox(height: 4),
                      DetailRow(
                        icon: Icons.person,
                        text: 'Reported by ${item.reportedBy}',
                      ),
                      const SizedBox(height: 16),

                      // Weather information (API integration)
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_weatherData != null)
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Weather at Location',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.wb_sunny,
                                      color: Colors.orange[400],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_weatherData!['main']['temp']}°C in ${_weatherData!['name']}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Weather: ${_weatherData!['weather'][0]['description']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Contact button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // In a real app, this would open a chat or contact form
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contact feature would open here'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.message),
                          label: const Text('Contact Reporter'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const DetailRow({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
