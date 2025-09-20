import 'package:flutter/material.dart';
import '../models/view_media.dart';
import 'beep_media_viewer.dart';

class MediaGrid extends StatelessWidget {
  final List<ViewMedia> items;
  final String? title;

  const MediaGrid({
    super.key,
    required this.items,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildThumbnail(context, items[index], index);
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2; // mobile
    if (width < 1200) return 3; // tablet
    return 4; // desktop
  }

  Widget _buildThumbnail(BuildContext context, ViewMedia item, int index) {
    return GestureDetector(
      onTap: () {
        // Direct call to BeepMediaViewer - no callbacks
        BeepMediaViewer.open(
          context,
          items: items,
          initialIndex: index,
          title: title,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.isVideo
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          item.thumbUrl ?? item.url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 32,
                              ),
                            );
                          },
                        ),
                        const Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            size: 48,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    )
                  : Image.network(
                      item.thumbUrl ?? item.url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}