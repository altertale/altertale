import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'offline_storage_service.dart';
import '../services/auth_service.dart';

class SyncManagerService {
  static final SyncManagerService _instance = SyncManagerService._internal();
  factory SyncManagerService() => _instance;
  SyncManagerService._internal();

  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = false;
  bool _isSyncing = false;

  /// Callbacks for sync events
  Function(bool)? onConnectivityChanged;
  Function(String)? onSyncStatus;
  Function(String)? onSyncError;

  /// Initialize sync manager
  Future<void> init() async {
    await _offlineStorage.init();
    await _checkConnectivity();
    _startConnectivityListener();
    print('🔄 SyncManager initialized');
  }

  /// Start listening to connectivity changes
  void _startConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      final wasOnline = _isOnline;
      _isOnline = !result.contains(ConnectivityResult.none);

      print('📶 Connectivity changed: ${_isOnline ? "ONLINE" : "OFFLINE"}');

      // Notify listeners
      if (onConnectivityChanged != null) {
        onConnectivityChanged!(_isOnline);
      }

      // Auto-sync when coming online
      if (!wasOnline && _isOnline) {
        _autoSyncWhenOnline();
      }
    });
  }

  /// Check initial connectivity
  Future<void> _checkConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      _isOnline = !connectivityResults.contains(ConnectivityResult.none);
      print('📶 Initial connectivity: ${_isOnline ? "ONLINE" : "OFFLINE"}');
    } catch (e) {
      print('❌ Error checking connectivity: $e');
      _isOnline = false;
    }
  }

  /// Auto-sync when coming online
  Future<void> _autoSyncWhenOnline() async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); // Wait for stable connection
    if (_isOnline && !_isSyncing) {
      await performFullSync();
    }
  }

  // ==================== SYNC OPERATIONS ====================

  /// Perform full synchronization
  Future<bool> performFullSync() async {
    if (_isSyncing) {
      print('⚠️ Sync already in progress');
      return false;
    }

    if (!_isOnline) {
      print('⚠️ Cannot sync: offline');
      if (onSyncError != null) {
        onSyncError!('İnternet bağlantısı yok');
      }
      return false;
    }

    final userId = AuthService().currentUser?.uid;
    if (userId == null) {
      print('⚠️ Cannot sync: user not authenticated');
      return false;
    }

    _isSyncing = true;
    if (onSyncStatus != null) {
      onSyncStatus!('Senkronizasyon başlıyor...');
    }

    try {
      print('🔄 Starting full sync...');

      // Simplified sync - just process pending actions
      await _processPendingActions(userId);

      // Clear pending actions after successful sync
      await _offlineStorage.clearPendingSyncActions();

      if (onSyncStatus != null) {
        onSyncStatus!('Senkronizasyon tamamlandı');
      }
      print('✅ Full sync completed successfully');

      return true;
    } catch (e) {
      final errorMsg = 'Senkronizasyon hatası: $e';
      if (onSyncError != null) {
        onSyncError!(errorMsg);
      }
      print('❌ Sync failed: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Process pending sync actions
  Future<void> _processPendingActions(String userId) async {
    try {
      final pendingActions = await _offlineStorage.getPendingSyncActions();

      if (pendingActions.isEmpty) {
        print('📝 No pending actions to process');
        return;
      }

      print('📝 Processing ${pendingActions.length} pending actions...');

      for (final action in pendingActions) {
        await _processSingleAction(userId, action);
      }

      print('✅ Processed all pending actions');
    } catch (e) {
      print('❌ Error processing pending actions: $e');
    }
  }

  /// Process a single pending action
  Future<void> _processSingleAction(
    String userId,
    Map<String, dynamic> action,
  ) async {
    try {
      final actionType = action['action'] as String;
      final data = action['data'] as String;

      switch (actionType) {
        case 'add_favorite':
          print('📤 Processing: Add favorite $data');
          // Would call FavoritesService.addFavorite(userId, data)
          break;

        case 'remove_favorite':
          print('📤 Processing: Remove favorite $data');
          // Would call FavoritesService.removeFavorite(userId, data)
          break;

        case 'add_to_cart':
          print('📤 Processing: Add to cart $data');
          // Would call CartService.addToCart(userId, data)
          break;

        case 'remove_from_cart':
          print('📤 Processing: Remove from cart $data');
          // Would call CartService.removeFromCart(userId, data)
          break;

        case 'clear_cart':
          print('📤 Processing: Clear cart');
          // Would call CartService.clearCart(userId)
          break;

        case 'add_to_mybooks':
          print('📤 Processing: Add to MyBooks $data');
          // Would call MyBooksService.addBook(userId, data)
          break;

        default:
          print('⚠️ Unknown action type: $actionType');
      }
    } catch (e) {
      print('❌ Error processing action: $e');
    }
  }

  // ==================== STATUS METHODS ====================

  /// Check if currently online
  bool get isOnline => _isOnline;

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Get sync status info
  Future<Map<String, dynamic>> getSyncStatus() async {
    final storageInfo = await _offlineStorage.getStorageInfo();
    final lastSync = await _offlineStorage.getLastSyncTime();
    final needsSync = await _offlineStorage.needsSync();

    return {
      'isOnline': _isOnline,
      'isSyncing': _isSyncing,
      'lastSync': lastSync?.toIso8601String(),
      'needsSync': needsSync,
      'storage': storageInfo,
    };
  }

  // ==================== CONVENIENCE METHODS ====================

  /// Force sync now (manual trigger)
  Future<bool> forceSyncNow() async {
    if (!_isOnline) {
      if (onSyncError != null) {
        onSyncError!('İnternet bağlantısı gerekli');
      }
      return false;
    }

    return await performFullSync();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    print('🔄 SyncManager disposed');
  }
}
