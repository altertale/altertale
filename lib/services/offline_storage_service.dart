import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';

class OfflineStorageService {
  static const String _favoritesKey = 'offline_favorites';
  static const String _cartKey = 'offline_cart';
  static const String _myBooksKey = 'offline_mybooks';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _pendingActionsKey = 'pending_sync_actions';

  // Singleton pattern
  static final OfflineStorageService _instance =
      OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure initialization
  Future<SharedPreferences> get prefs async {
    await init();
    return _prefs!;
  }

  // ==================== FAVORITES ====================

  /// Save favorites offline
  Future<bool> saveFavoritesOffline(List<String> favoriteIds) async {
    try {
      final preferences = await prefs;
      final success = await preferences.setStringList(
        _favoritesKey,
        favoriteIds,
      );

      if (success) {
        await _updateLastSync();
        print('✅ Favorites saved offline: ${favoriteIds.length} items');
      }

      return success;
    } catch (e) {
      print('❌ Error saving favorites offline: $e');
      return false;
    }
  }

  /// Get favorites from offline storage
  Future<List<String>> getFavoritesOffline() async {
    try {
      final preferences = await prefs;
      final favoriteIds = preferences.getStringList(_favoritesKey) ?? [];
      print('📱 Loaded ${favoriteIds.length} favorites from offline storage');
      return favoriteIds;
    } catch (e) {
      print('❌ Error loading favorites offline: $e');
      return [];
    }
  }

  /// Add single favorite offline
  Future<bool> addFavoriteOffline(String bookId) async {
    try {
      final favorites = await getFavoritesOffline();
      if (!favorites.contains(bookId)) {
        favorites.add(bookId);
        await saveFavoritesOffline(favorites);
        await _addPendingAction('add_favorite', bookId);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error adding favorite offline: $e');
      return false;
    }
  }

  /// Remove single favorite offline
  Future<bool> removeFavoriteOffline(String bookId) async {
    try {
      final favorites = await getFavoritesOffline();
      if (favorites.contains(bookId)) {
        favorites.remove(bookId);
        await saveFavoritesOffline(favorites);
        await _addPendingAction('remove_favorite', bookId);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error removing favorite offline: $e');
      return false;
    }
  }

  // ==================== CART ====================

  /// Save cart offline
  Future<bool> saveCartOffline(List<Map<String, dynamic>> cartItems) async {
    try {
      final preferences = await prefs;
      final success = await preferences.setString(
        _cartKey,
        jsonEncode(cartItems),
      );

      if (success) {
        await _updateLastSync();
        print('✅ Cart saved offline: ${cartItems.length} items');
      }

      return success;
    } catch (e) {
      print('❌ Error saving cart offline: $e');
      return false;
    }
  }

  /// Get cart from offline storage
  Future<List<Map<String, dynamic>>> getCartOffline() async {
    try {
      final preferences = await prefs;
      final cartString = preferences.getString(_cartKey);

      if (cartString == null || cartString.isEmpty) {
        return [];
      }

      final cartJson = jsonDecode(cartString) as List;
      final cartItems = cartJson
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      print('📱 Loaded ${cartItems.length} cart items from offline storage');
      return cartItems;
    } catch (e) {
      print('❌ Error loading cart offline: $e');
      return [];
    }
  }

  /// Add item to cart offline
  Future<bool> addToCartOffline(Map<String, dynamic> item) async {
    try {
      final cart = await getCartOffline();

      // Check for duplicates
      if (cart.any((cartItem) => cartItem['bookId'] == item['bookId'])) {
        print('⚠️ Book already in cart: ${item['bookId']}');
        return false;
      }

      cart.add(item);
      await saveCartOffline(cart);
      await _addPendingAction('add_to_cart', item['bookId']);
      return true;
    } catch (e) {
      print('❌ Error adding to cart offline: $e');
      return false;
    }
  }

  /// Remove item from cart offline
  Future<bool> removeFromCartOffline(String bookId) async {
    try {
      final cart = await getCartOffline();
      cart.removeWhere((item) => item['bookId'] == bookId);
      await saveCartOffline(cart);
      await _addPendingAction('remove_from_cart', bookId);
      return true;
    } catch (e) {
      print('❌ Error removing from cart offline: $e');
      return false;
    }
  }

  /// Clear cart offline
  Future<bool> clearCartOffline() async {
    try {
      final preferences = await prefs;
      final success = await preferences.remove(_cartKey);
      await _addPendingAction('clear_cart', 'all');
      return success;
    } catch (e) {
      print('❌ Error clearing cart offline: $e');
      return false;
    }
  }

  // ==================== MY BOOKS ====================

  /// Save my books offline
  Future<bool> saveMyBooksOffline(List<String> bookIds) async {
    try {
      final preferences = await prefs;
      final success = await preferences.setStringList(_myBooksKey, bookIds);

      if (success) {
        await _updateLastSync();
        print('✅ MyBooks saved offline: ${bookIds.length} items');
      }

      return success;
    } catch (e) {
      print('❌ Error saving MyBooks offline: $e');
      return false;
    }
  }

  /// Get my books from offline storage
  Future<List<String>> getMyBooksOffline() async {
    try {
      final preferences = await prefs;
      final bookIds = preferences.getStringList(_myBooksKey) ?? [];
      print('📱 Loaded ${bookIds.length} MyBooks from offline storage');
      return bookIds;
    } catch (e) {
      print('❌ Error loading MyBooks offline: $e');
      return [];
    }
  }

  /// Add book to my books offline
  Future<bool> addToMyBooksOffline(String bookId) async {
    try {
      final myBooks = await getMyBooksOffline();
      if (!myBooks.contains(bookId)) {
        myBooks.add(bookId);
        await saveMyBooksOffline(myBooks);
        await _addPendingAction('add_to_mybooks', bookId);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error adding to MyBooks offline: $e');
      return false;
    }
  }

  // ==================== SYNC MANAGEMENT ====================

  /// Add pending action for sync
  Future<void> _addPendingAction(String action, String data) async {
    try {
      final preferences = await prefs;
      final existingActions =
          preferences.getStringList(_pendingActionsKey) ?? [];

      final actionData = jsonEncode({
        'action': action,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });

      existingActions.add(actionData);
      await preferences.setStringList(_pendingActionsKey, existingActions);

      print('📝 Added pending action: $action - $data');
    } catch (e) {
      print('❌ Error adding pending action: $e');
    }
  }

  /// Get pending sync actions
  Future<List<Map<String, dynamic>>> getPendingSyncActions() async {
    try {
      final preferences = await prefs;
      final actions = preferences.getStringList(_pendingActionsKey) ?? [];

      return actions.map((actionString) {
        final actionData = jsonDecode(actionString) as Map<String, dynamic>;
        return actionData;
      }).toList();
    } catch (e) {
      print('❌ Error getting pending actions: $e');
      return [];
    }
  }

  /// Clear pending sync actions
  Future<bool> clearPendingSyncActions() async {
    try {
      final preferences = await prefs;
      final success = await preferences.remove(_pendingActionsKey);
      print('🧹 Cleared pending sync actions');
      return success;
    } catch (e) {
      print('❌ Error clearing pending actions: $e');
      return false;
    }
  }

  /// Update last sync timestamp
  Future<void> _updateLastSync() async {
    try {
      final preferences = await prefs;
      await preferences.setString(
        _lastSyncKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('❌ Error updating last sync: $e');
    }
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    try {
      final preferences = await prefs;
      final timeString = preferences.getString(_lastSyncKey);
      return timeString != null ? DateTime.parse(timeString) : null;
    } catch (e) {
      print('❌ Error getting last sync time: $e');
      return null;
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Check if data needs sync (older than 5 minutes)
  Future<bool> needsSync() async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;

    final difference = DateTime.now().difference(lastSync);
    return difference.inMinutes > 5;
  }

  /// Get storage info for debugging
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final favorites = await getFavoritesOffline();
      final cart = await getCartOffline();
      final myBooks = await getMyBooksOffline();
      final pendingActions = await getPendingSyncActions();
      final lastSync = await getLastSyncTime();

      return {
        'favorites_count': favorites.length,
        'cart_count': cart.length,
        'mybooks_count': myBooks.length,
        'pending_actions_count': pendingActions.length,
        'last_sync': lastSync?.toIso8601String(),
        'needs_sync': await needsSync(),
      };
    } catch (e) {
      print('❌ Error getting storage info: $e');
      return {};
    }
  }

  /// Clear all offline data
  Future<bool> clearAllOfflineData() async {
    try {
      final preferences = await prefs;
      final keys = [
        _favoritesKey,
        _cartKey,
        _myBooksKey,
        _pendingActionsKey,
        _lastSyncKey,
      ];

      for (final key in keys) {
        await preferences.remove(key);
      }

      print('🧹 Cleared all offline data');
      return true;
    } catch (e) {
      print('❌ Error clearing offline data: $e');
      return false;
    }
  }
}
