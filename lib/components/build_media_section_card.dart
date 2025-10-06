import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BuildMediaSectionCard extends StatelessWidget {
  BuildMediaSectionCard({super.key});

  final List<String> mediaImages = [
    // 'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e',
    // 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0',
    // 'https://images.unsplash.com/photo-1531297484001-80022131f5a1',
    // 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05',
    // 'https://images.unsplash.com/photo-1521747116042-5a810fda9664',
    // 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
    // 'https://images.unsplash.com/photo-1555685812-4b943f1cb0eb',
    // 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Media Library',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: colorScheme.primary),
                  onPressed: () {
                    // Handle more actions
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 120,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: mediaImages.length,
                  itemBuilder: (context, index) {
                    return _buildMediaItem(context, mediaImages[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width > 600) return 4;
    if (width > 400) return 3;
    return 2;
  }

  Widget _buildMediaItem(BuildContext context, String imageUrl) {
    final theme = Theme.of(context);
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle media item tap
          _showImagePreview(context, imageUrl);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => _buildShimmerEffect(),
                errorWidget: (context, url, error) => 
                  const Icon(Icons.broken_image),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8)),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Hero(
            tag: imageUrl,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}