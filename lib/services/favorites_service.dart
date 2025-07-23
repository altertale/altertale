import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Favorites Service - Manages user favorites with web compatibility
class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Demo mode for testing - Always true to support all users
  bool get isDemoMode => true;

  // In-memory storage for demo favorites
  static final Map<String, Set<String>> _demoFavorites = {};

  /// Safe conversion for web compatibility
  List<String> _safeStringListFromPrefs(List<String>? rawList) {
    if (rawList == null) return [];

    try {
      // Handle both native List<String> and web JSArray<String>
      return rawList.map((item) {
        if (item is String) {
          return item;
        } else {
          return item.toString();
        }
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ FavoritesService: Error converting string list: $e');
      }
      return [];
    }
  }

  /// Initialize favorites from SharedPreferences
  Future<void> _initializeFavorites(String userId) async {
    if (_demoFavorites.containsKey(userId)) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorites_$userId');

      // Safely convert to List<String> to handle web JSArray<String> issue
      final favoritesList = favoritesJson != null
          ? favoritesJson.map((item) => item.toString()).toList()
          : <String>[];

      _demoFavorites[userId] = favoritesList.toSet();

      if (kDebugMode) {
        print(
          '💖 FavoritesService: Loaded ${favoritesList.length} favorites from storage for user: $userId',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FavoritesService: Error loading favorites: $e');
      }
      _demoFavorites[userId] = <String>{};
    }
  }

  /// Save favorites to SharedPreferences with web compatibility
  Future<void> _saveFavorites(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = _demoFavorites[userId]?.toList() ?? [];

      // Ensure all items are properly typed as String for web compatibility
      final safeFavorites = favorites.map((item) => item.toString()).toList();

      await prefs.setStringList('favorites_$userId', safeFavorites);

      if (kDebugMode) {
        print(
          '💖 FavoritesService: Saved ${safeFavorites.length} favorites to storage for user: $userId',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FavoritesService: Error saving favorites: $e');
      }
    }
  }

  /// Toggle favorite status of a book
  Future<bool> toggleFavorite(String userId, String bookId) async {
    if (kDebugMode) {
      print(
        '💖 FavoritesService: Toggling favorite for user: $userId, book: $bookId',
      );
    }

    if (isDemoMode) {
      await _initializeFavorites(userId);

      if (_demoFavorites[userId]!.contains(bookId)) {
        _demoFavorites[userId]!.remove(bookId);
        await _saveFavorites(userId);
        if (kDebugMode) {
          print('💖 FavoritesService: Removed from favorites');
        }
        return false; // No longer favorite
      } else {
        _demoFavorites[userId]!.add(bookId);
        await _saveFavorites(userId);
        if (kDebugMode) {
          print('💖 FavoritesService: Added to favorites');
        }
        return true; // Now favorite
      }
    }

    try {
      final userRef = _firestore.collection('userFavorites').doc(userId);
      final doc = await userRef.get();

      List<String> favorites = [];
      if (doc.exists) {
        favorites = List<String>.from(doc.data()?['bookIds'] ?? []);
      }

      if (favorites.contains(bookId)) {
        favorites.remove(bookId);
        await userRef.set({'bookIds': favorites});
        return false;
      } else {
        favorites.add(bookId);
        await userRef.set({'bookIds': favorites});
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ FavoritesService: Error toggling favorite: $e');
      }
      rethrow;
    }
  }

  /// Check if a book is favorite
  Future<bool> isFavorite(String userId, String bookId) async {
    if (isDemoMode) {
      await _initializeFavorites(userId);
      return _demoFavorites[userId]?.contains(bookId) ?? false;
    }

    try {
      final doc = await _firestore
          .collection('userFavorites')
          .doc(userId)
          .get();
      if (doc.exists) {
        final favorites = List<String>.from(doc.data()?['bookIds'] ?? []);
        return favorites.contains(bookId);
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ FavoritesService: Error checking favorite: $e');
      }
      return false;
    }
  }

  /// Get all favorite book IDs for a user
  Future<List<String>> getFavoriteBookIds(String userId) async {
    if (isDemoMode) {
      return _demoFavorites[userId]?.toList() ?? [];
    }

    try {
      final doc = await _firestore
          .collection('userFavorites')
          .doc(userId)
          .get();
      if (doc.exists) {
        return List<String>.from(doc.data()?['bookIds'] ?? []);
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ FavoritesService: Error getting favorites: $e');
      }
      return [];
    }
  }

  /// Get favorite books stream
  Stream<List<String>> getFavoriteBookIdsStream(String userId) {
    if (isDemoMode) {
      return Stream.periodic(const Duration(milliseconds: 100), (count) {
        return _demoFavorites[userId]?.toList() ?? [];
      }).take(1);
    }

    return _firestore.collection('userFavorites').doc(userId).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return List<String>.from(doc.data()?['bookIds'] ?? []);
      }
      return <String>[];
    });
  }

  /// Initialize demo favorites for testing
  void initializeDemoFavorites(String userId) {
    if (isDemoMode && !_demoFavorites.containsKey(userId)) {
      _demoFavorites[userId] = <String>{};
      if (kDebugMode) {
        print(
          '💖 FavoritesService: Demo favorites initialized for user: $userId',
        );
      }
    }
  }
}
