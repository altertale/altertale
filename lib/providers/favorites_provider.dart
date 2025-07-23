import 'package:flutter/foundation.dart';
import '../services/favorites_service.dart';
import '../models/book_model.dart';
import '../providers/book_provider.dart';
import 'package:flutter/widgets.dart'; // Added for WidgetsBinding

/// Favorites Provider - Manages favorite books state
class FavoritesProvider with ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();

  // State variables
  List<BookModel> _favoriteBooks = [];
  List<String> _favoriteIds = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  // Getters
  List<BookModel> get favoriteBooks => _favoriteBooks;
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasFavorites => _favoriteBooks.isNotEmpty;
  int get favoriteCount => _favoriteBooks.length;

  /// Initialize favorites for user
  Future<void> initializeFavorites(
    String userId,
    BookProvider bookProvider,
  ) async {
    if (_currentUserId == userId && _favoriteIds.isNotEmpty) {
      return; // Already initialized for this user
    }

    _currentUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get favorite IDs from service
      _favoriteIds = await _favoritesService.getFavoriteBookIds(userId);

      // Get favorite books from BookProvider
      _favoriteBooks = bookProvider.books
          .where((book) => _favoriteIds.contains(book.id))
          .toList();

      if (kDebugMode) {
        print(
          '💖 FavoritesProvider: Initialized ${_favoriteBooks.length} favorites for user: $userId',
        );
      }
    } catch (e) {
      _error = 'Favoriler yüklenirken hata oluştu: $e';
      if (kDebugMode) {
        print('❌ FavoritesProvider: Error initializing favorites: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle favorite status of a book
  Future<bool> toggleFavorite(String userId, BookModel book) async {
    try {
      final wasFavorite = _favoriteIds.contains(book.id);

      // Toggle in service
      final isNowFavorite = await _favoritesService.toggleFavorite(
        userId,
        book.id,
      );

      // Update local state only if it actually changed
      bool stateChanged = false;
      if (isNowFavorite && !wasFavorite) {
        _favoriteIds.add(book.id);
        _favoriteBooks.add(book);
        stateChanged = true;
      } else if (!isNowFavorite && wasFavorite) {
        _favoriteIds.remove(book.id);
        _favoriteBooks.removeWhere((b) => b.id == book.id);
        stateChanged = true;
      }

      // Always notify listeners for instant UI update
      if (stateChanged) {
        notifyListeners();

        // Post frame callback to ensure all listeners are notified
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }

      if (kDebugMode) {
        print(
          '💖 FavoritesProvider: ${isNowFavorite ? 'Added' : 'Removed'} favorite: ${book.title} - Instant sync',
        );
      }

      return isNowFavorite;
    } catch (e) {
      _error = 'Favori durumu değiştirilirken hata oluştu: $e';
      if (kDebugMode) {
        print('❌ FavoritesProvider: Error toggling favorite: $e');
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Add a book to favorites with instant feedback
  Future<void> addFavoriteInstant(String userId, BookModel book) async {
    try {
      if (_favoriteIds.contains(book.id)) return;

      // Add to local state first for instant UI
      _favoriteIds.add(book.id);
      _favoriteBooks.add(book);
      notifyListeners();

      // Then sync with service
      await _favoritesService.toggleFavorite(userId, book.id);

      if (kDebugMode) {
        print(
          '💖 FavoritesProvider: Added favorite with instant feedback: ${book.title}',
        );
      }
    } catch (e) {
      // Rollback on error
      _favoriteIds.remove(book.id);
      _favoriteBooks.removeWhere((b) => b.id == book.id);
      _error = 'Favori eklenirken hata oluştu: $e';
      notifyListeners();

      if (kDebugMode) {
        print('❌ FavoritesProvider: Error adding favorite: $e');
      }
      rethrow;
    }
  }

  /// Remove a book from favorites with instant feedback
  Future<void> removeFavoriteInstant(String userId, String bookId) async {
    BookModel? removedBook; // Declare at method level

    try {
      if (!_favoriteIds.contains(bookId)) return;

      // Keep reference for potential rollback
      try {
        removedBook = _favoriteBooks.firstWhere((book) => book.id == bookId);
      } catch (e) {
        removedBook = BookModel(
          id: bookId,
          title: 'Unknown',
          author: 'Unknown',
          description: '',
          coverImageUrl: '',
          categories: [],
          tags: [],
          price: 0,
          points: 0,
          averageRating: 0,
          ratingCount: 0,
          readCount: 0,
          pageCount: 0,
          language: 'tr',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isPublished: true,
          isFeatured: false,
          isPopular: false,
          previewStart: 0,
          previewEnd: 0,
          pointPrice: 0,
        );
      }

      // Remove from local state first for instant UI
      _favoriteIds.remove(bookId);
      _favoriteBooks.removeWhere((book) => book.id == bookId);
      notifyListeners();

      // Then sync with service
      await _favoritesService.toggleFavorite(userId, bookId);

      if (kDebugMode) {
        print(
          '💖 FavoritesProvider: Removed favorite with instant feedback: $bookId',
        );
      }
    } catch (e) {
      // Rollback on error
      if (!_favoriteIds.contains(bookId)) {
        _favoriteIds.add(bookId);
        if (removedBook != null) {
          _favoriteBooks.add(removedBook!);
        }
      }
      _error = 'Favori kaldırılırken hata oluştu: $e';
      notifyListeners();

      if (kDebugMode) {
        print('❌ FavoritesProvider: Error removing favorite: $e');
      }
      rethrow;
    }
  }

  /// Force refresh and notify all listeners
  Future<void> forceRefresh(String userId, BookProvider bookProvider) async {
    await refreshFavorites(userId, bookProvider);

    // Double notification for stubborn UI
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Check if a book is favorite
  bool isFavorite(String bookId) {
    return _favoriteIds.contains(bookId);
  }

  /// Refresh favorites from service
  Future<void> refreshFavorites(
    String userId,
    BookProvider bookProvider,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get fresh favorite IDs from service
      _favoriteIds = await _favoritesService.getFavoriteBookIds(userId);

      // Get favorite books from BookProvider
      _favoriteBooks = bookProvider.books
          .where((book) => _favoriteIds.contains(book.id))
          .toList();

      if (kDebugMode) {
        print(
          '💖 FavoritesProvider: Refreshed ${_favoriteBooks.length} favorites for user: $userId',
        );
      }
    } catch (e) {
      _error = 'Favoriler yenilenirken hata oluştu: $e';
      if (kDebugMode) {
        print('❌ FavoritesProvider: Error refreshing favorites: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove a book from favorites
  Future<void> removeFavorite(String userId, String bookId) async {
    try {
      if (!_favoriteIds.contains(bookId)) return;

      // Remove from service (toggle will remove it)
      await _favoritesService.toggleFavorite(userId, bookId);

      // Update local state
      _favoriteIds.remove(bookId);
      _favoriteBooks.removeWhere((book) => book.id == bookId);

      notifyListeners();

      if (kDebugMode) {
        print('💖 FavoritesProvider: Removed favorite: $bookId');
      }
    } catch (e) {
      _error = 'Favori kaldırılırken hata oluştu: $e';
      if (kDebugMode) {
        print('❌ FavoritesProvider: Error removing favorite: $e');
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Clear all favorites (for logout)
  void clearFavorites() {
    _favoriteBooks.clear();
    _favoriteIds.clear();
    _currentUserId = null;
    _error = null;
    _isLoading = false;
    notifyListeners();

    if (kDebugMode) {
      print('💖 FavoritesProvider: Cleared all favorites');
    }
  }

  /// Add book to favorites
  Future<void> addFavorite(String userId, BookModel book) async {
    try {
      if (_favoriteIds.contains(book.id)) return;

      // Add to service (toggle will add it)
      await _favoritesService.toggleFavorite(userId, book.id);

      // Update local state
      _favoriteIds.add(book.id);
      _favoriteBooks.add(book);

      notifyListeners();

      if (kDebugMode) {
        print('💖 FavoritesProvider: Added favorite: ${book.title}');
      }
    } catch (e) {
      _error = 'Favori eklenirken hata oluştu: $e';
      if (kDebugMode) {
        print('❌ FavoritesProvider: Error adding favorite: $e');
      }
      notifyListeners();
      rethrow;
    }
  }
}
