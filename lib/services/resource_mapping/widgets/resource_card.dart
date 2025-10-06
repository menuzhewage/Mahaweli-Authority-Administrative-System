// lib/widgets/resource_card.dart
import 'package:flutter/material.dart';
import '../data/models/resource.dart';

class ResourceCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback onClose;
  final VoidCallback? onShowPath;

  const ResourceCard({
    super.key,
    required this.resource,
    required this.onClose,
    this.onShowPath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  resource.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Category: ${resource.category}'),
            Text('Description: ${resource.description}'),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  color: resource.isAvailable ? Colors.green : Colors.red,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  resource.isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    color: resource.isAvailable ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            if (onShowPath != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onShowPath,
                child: const Text('Show Path from Current Location'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}