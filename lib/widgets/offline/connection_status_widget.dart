import 'package:flutter/material.dart';
import '../../services/sync_manager_service.dart';

class ConnectionStatusWidget extends StatefulWidget {
  final bool showSyncButton;
  final EdgeInsets? padding;

  const ConnectionStatusWidget({
    Key? key,
    this.showSyncButton = true,
    this.padding,
  }) : super(key: key);

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget>
    with TickerProviderStateMixin {
  final SyncManagerService _syncManager = SyncManagerService();

  bool _isOnline = false;
  bool _isSyncing = false;
  String _syncStatus = '';
  String? _syncError;
  Map<String, dynamic> _storageInfo = {};

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSyncManager();
    _loadSyncStatus();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _initializeSyncManager() {
    _syncManager.onConnectivityChanged = (isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
          if (isOnline) {
            _syncError = null;
            _syncStatus = 'Çevrimiçi - Senkronizasyon hazır';
          } else {
            _syncStatus = 'Çevrimdışı - Yerel depolama aktif';
          }
        });
      }
    };

    _syncManager.onSyncStatus = (status) {
      if (mounted) {
        setState(() {
          _syncStatus = status;
          _syncError = null;
        });
      }
    };

    _syncManager.onSyncError = (error) {
      if (mounted) {
        setState(() {
          _syncError = error;
        });
      }
    };
  }

  Future<void> _loadSyncStatus() async {
    try {
      final status = await _syncManager.getSyncStatus();
      if (mounted) {
        setState(() {
          _isOnline = status['isOnline'] ?? false;
          _isSyncing = status['isSyncing'] ?? false;
          _storageInfo = status['storage'] ?? {};

          if (_isOnline) {
            _syncStatus = 'Çevrimiçi - Senkronizasyon hazır';
          } else {
            _syncStatus = 'Çevrimdışı - Yerel depolama aktif';
          }
        });
      }
    } catch (e) {
      print('Error loading sync status: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConnectionStatus(theme),
          if (_storageInfo.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildStorageInfo(theme),
          ],
          if (widget.showSyncButton && _isOnline) ...[
            const SizedBox(height: 12),
            _buildSyncButton(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isOnline
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isOnline ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isSyncing ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _isOnline ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                _isOnline ? 'Çevrimiçi' : 'Çevrimdışı',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _isOnline ? Colors.green : Colors.orange,
                ),
              ),
              const Spacer(),
              if (_isSyncing) ...[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isOnline ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _syncError ?? _syncStatus,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _syncError != null
                  ? Colors.red
                  : theme.colorScheme.onSurface,
            ),
          ),
          if (_syncError != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Senkronizasyon hatası',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStorageInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yerel Depolama',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStorageItem(
                theme,
                'Favoriler',
                '${_storageInfo['favorites_count'] ?? 0}',
                Icons.favorite,
                Colors.red,
              ),
              const SizedBox(width: 16),
              _buildStorageItem(
                theme,
                'Sepet',
                '${_storageInfo['cart_count'] ?? 0}',
                Icons.shopping_cart,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildStorageItem(
                theme,
                'Kitaplarım',
                '${_storageInfo['mybooks_count'] ?? 0}',
                Icons.library_books,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageItem(
    ThemeData theme,
    String label,
    String count,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSyncing ? null : _performManualSync,
        icon: _isSyncing
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : const Icon(Icons.sync),
        label: Text(
          _isSyncing ? 'Senkronize ediliyor...' : 'Manuel Senkronizasyon',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _performManualSync() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = 'Manuel senkronizasyon başlatılıyor...';
      _syncError = null;
    });

    final success = await _syncManager.forceSyncNow();

    if (mounted) {
      setState(() {
        _isSyncing = false;
        if (success) {
          _syncStatus = 'Senkronizasyon başarıyla tamamlandı';
        }
      });

      // Reload storage info
      await _loadSyncStatus();

      // Show result
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Senkronizasyon tamamlandı!'
                  : 'Senkronizasyon başarısız',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// Simple connection indicator for app bars
class ConnectionIndicator extends StatefulWidget {
  const ConnectionIndicator({Key? key}) : super(key: key);

  @override
  State<ConnectionIndicator> createState() => _ConnectionIndicatorState();
}

class _ConnectionIndicatorState extends State<ConnectionIndicator> {
  final SyncManagerService _syncManager = SyncManagerService();
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _initializeStatus();
  }

  void _initializeStatus() {
    _syncManager.onConnectivityChanged = (isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    };

    _loadInitialStatus();
  }

  Future<void> _loadInitialStatus() async {
    final status = await _syncManager.getSyncStatus();
    if (mounted) {
      setState(() {
        _isOnline = status['isOnline'] ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _isOnline ? Colors.green : Colors.orange,
        shape: BoxShape.circle,
      ),
    );
  }
}
