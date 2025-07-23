import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';
import '../services/offline_storage_service.dart';
import '../services/sync_manager_service.dart';
import '../services/auth_service.dart';

class FavoritesProvider with ChangeNotifier {
  final List<BookModel> _favorites = [];
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final SyncManagerService _syncManager = SyncManagerService();

  bool _isLoading = false;
  String? _error;

  List<BookModel> get favorites => List.unmodifiable(_favorites);
  List<BookModel> get favoriteBooks =>
      List.unmodifiable(_favorites); // Backward compatibility
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _favorites.length;

  /// Initialize favorites (load from persistent storage first)
  Future<void> init() async {
    await _offlineStorage.init();
    await _loadFavoritesFromPersistentStorage();
  }

  /// Initialize favorites for backward compatibility
  Future<void> initializeFavorites(String userId, dynamic bookProvider) async {
    await init();
  }

  /// Load favorites from persistent storage (SharedPreferences + OfflineStorage)
  Future<void> _loadFavoritesFromPersistentStorage() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = AuthService().currentUser?.uid;
      if (userId == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Load from SharedPreferences first (more reliable)
      final prefs = await SharedPreferences.getInstance();
      final favoriteIdsString = prefs.getString('favorites_$userId');
      Set<String> favoriteIds = {};

      if (favoriteIdsString != null && favoriteIdsString.isNotEmpty) {
        favoriteIds = favoriteIdsString.split(',').toSet();
        print(
          '📱 Loaded ${favoriteIds.length} favorites from SharedPreferences',
        );
      } else {
        // Fallback to OfflineStorage
        final offlineFavorites = await _offlineStorage.getFavoritesOffline();
        favoriteIds = offlineFavorites.toSet();
        print('📱 Loaded ${favoriteIds.length} favorites from OfflineStorage');
      }

      // Convert IDs to BookModel objects
      _favorites.clear();
      for (final id in favoriteIds) {
        // Try to load book details from SharedPreferences
        final bookDataString = prefs.getString('book_$id');
        if (bookDataString != null) {
          try {
            // Parse book data from stored string
            final parts = bookDataString.split('|');
            if (parts.length >= 6) {
              final book = BookModel(
                id: parts[0],
                title: parts[1],
                author: parts[2],
                description: parts[3],
                price: double.tryParse(parts[4]) ?? 0.0,
                coverImageUrl: parts[5],
                categories: parts.length > 6 ? parts[6].split(',') : ['Genel'],
                tags: [],
                points: 0,
                averageRating: 0.0,
                ratingCount: 0,
                readCount: 0,
                pageCount: 100,
                language: 'tr',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                isPublished: true,
                isFeatured: false,
                isPopular: false,
                previewStart: 0,
                previewEnd: 10,
                pointPrice: 0,
              );
              _favorites.add(book);
              continue;
            }
          } catch (e) {
            print('❌ Error parsing stored book data: $e');
          }
        }

        // Fallback: Create minimal BookModel
        final book = BookModel(
          id: id,
          title: 'Favori Kitap $id',
          author: 'Yazar',
          description: 'Bu kitap favorilerinizde kayıtlı.',
          price: 0.0,
          coverImageUrl:
              'https://picsum.photos/400/600?random=${id.hashCode % 100}',
          categories: ['Genel'],
          tags: [],
          points: 0,
          averageRating: 0.0,
          ratingCount: 0,
          readCount: 0,
          pageCount: 100,
          language: 'tr',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isPublished: true,
          isFeatured: false,
          isPopular: false,
          previewStart: 0,
          previewEnd: 10,
          pointPrice: 0,
        );
        _favorites.add(book);
      }

      print('📱 Loaded ${_favorites.length} favorites total');
    } catch (e) {
      _error = 'Favoriler yüklenemedi: $e';
      print('❌ Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save favorites to persistent storage
  Future<void> _saveFavoritesToPersistentStorage() async {
    try {
      final userId = AuthService().currentUser?.uid;
      if (userId == null) return;

      final prefs = await SharedPreferences.getInstance();

      // Save favorite IDs
      final favoriteIds = _favorites.map((book) => book.id).join(',');
      await prefs.setString('favorites_$userId', favoriteIds);

      // Save book details for each favorite
      for (final book in _favorites) {
        final bookData =
            '${book.id}|${book.title}|${book.author}|${book.description}|${book.price}|${book.coverImageUrl}|${book.categories.join(',')}';
        await prefs.setString('book_${book.id}', bookData);
      }

      print('📱 Saved ${_favorites.length} favorites to persistent storage');
    } catch (e) {
      print('❌ Error saving favorites: $e');
    }
  }

  /// Add favorite (with persistent storage)
  Future<bool> addFavorite(String? userId, BookModel book) async {
    try {
      // Add to local state immediately
      if (!_favorites.any((fav) => fav.id == book.id)) {
        _favorites.add(book);
        notifyListeners();
      }

      // Save to persistent storage
      await _saveFavoritesToPersistentStorage();

      // Also save to offline storage for backward compatibility
      await _offlineStorage.addFavoriteOffline(book.id);

      return true;
    } catch (e) {
      _error = 'Favori eklenemedi: $e';
      print('❌ Error adding favorite: $e');
      notifyListeners();
      return false;
    }
  }

  /// Remove favorite (with persistent storage)
  Future<bool> removeFavorite(String? userId, BookModel book) async {
    try {
      // Remove from local state immediately
      _favorites.removeWhere((fav) => fav.id == book.id);
      notifyListeners();

      // Save to persistent storage
      await _saveFavoritesToPersistentStorage();

      // Remove from offline storage
      await _offlineStorage.removeFavoriteOffline(book.id);

      return true;
    } catch (e) {
      _error = 'Favori kaldırılamadı: $e';
      print('❌ Error removing favorite: $e');
      notifyListeners();
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String? userId, BookModel book) async {
    final isFavorite = _favorites.any((fav) => fav.id == book.id);

    if (isFavorite) {
      return await removeFavorite(userId, book);
    } else {
      return await addFavorite(userId, book);
    }
  }

  /// Check if book is favorite
  bool isFavorite(String bookId) {
    return _favorites.any((book) => book.id == bookId);
  }

  /// Refresh favorites (load from persistent storage)
  Future<void> refreshFavorites() async {
    await _loadFavoritesFromPersistentStorage();
  }

  /// Force refresh for backward compatibility
  Future<void> forceRefresh(String userId, dynamic bookProvider) async {
    await refreshFavorites();
  }

  /// Get offline status info
  Future<Map<String, dynamic>> getOfflineInfo() async {
    final favoriteIds = await _offlineStorage.getFavoritesOffline();
    return {
      'offline_count': favoriteIds.length,
      'loaded_count': _favorites.length,
      'is_online': _syncManager.isOnline,
    };
  }

  /// Clear all favorites (for logout)
  void clearFavorites() async {
    _favorites.clear();
    _error = null;
    notifyListeners();

    // Clear persistent storage
    try {
      final userId = AuthService().currentUser?.uid;
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('favorites_$userId');

        // Remove book details from cache
        for (final book in _favorites) {
          await prefs.remove('book_${book.id}');
        }
      }
    } catch (e) {
      print('❌ Error clearing favorites cache: $e');
    }
  }
}
