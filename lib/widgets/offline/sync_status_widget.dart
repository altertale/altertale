import 'package:flutter/material.dart';
import '../../services/offline/offline_service.dart';
import '../../services/offline/sync_manager.dart';

/// Senkronizasyon durumu widget'ı
class SyncStatusWidget extends StatelessWidget {
  final bool showProgress;
  final bool showMessage;
  final double? size;

  const SyncStatusWidget({
    super.key,
    this.showProgress = true,
    this.showMessage = true,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: OfflineService().syncStatus,
      builder: (context, snapshot) {
        final syncStatus = snapshot.data;
        
        if (syncStatus == null || !syncStatus.isSyncing) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final widgetSize = size ?? 20.0;

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.primary),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: widgetSize,
                height: widgetSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: syncStatus.progress,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              if (showMessage) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    syncStatus.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
