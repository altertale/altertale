import 'package:flutter/material.dart';
import '../../services/offline/offline_service.dart';

/// Offline kullanılabilir rozeti
class OfflineBadge extends StatelessWidget {
  final String bookId;
  final String contentType;
  final double? size;
  final Color? color;

  const OfflineBadge({
    super.key,
    required this.bookId,
    required this.contentType,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = OfflineService().isBookAvailableOffline(bookId, contentType);
    
    if (!isAvailable) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final badgeColor = color ?? Colors.green;
    final badgeSize = size ?? 16.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.download_done,
            color: Colors.white,
            size: badgeSize * 0.8,
          ),
          const SizedBox(width: 2),
          Text(
            'Offline',
            style: TextStyle(
              color: Colors.white,
              fontSize: badgeSize * 0.6,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
