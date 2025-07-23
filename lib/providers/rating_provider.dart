import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/rating_model.dart';
import '../services/rating_service.dart';
import '../services/auth_service.dart';

class RatingProvider with ChangeNotifier {
  // Cache for book rating stats
  final Map<String, BookRatingStats> _bookStatsCache = {};

  // Cache for user ratings
  final Map<String, Rating> _userRatingsCache = {};

  // Loading states
  final Map<String, bool> _loadingStates = {};

  // Submission states
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // Get cached book rating stats
  BookRatingStats? getCachedBookStats(String bookId) {
    return _bookStatsCache[bookId];
  }

  // Get cached user rating for a book
  Rating? getCachedUserRating(String bookId) {
    final userId = AuthService().currentUser?.uid;
    if (userId == null) return null;

    final key = '${userId}_$bookId';
    return _userRatingsCache[key];
  }

  // Check if book stats are loading
  bool isLoadingBookStats(String bookId) {
    return _loadingStates['book_stats_$bookId'] ?? false;
  }

  // Load book rating statistics
  Future<BookRatingStats> loadBookRatingStats(String bookId) async {
    // Return cached if available
    if (_bookStatsCache.containsKey(bookId)) {
      return _bookStatsCache[bookId]!;
    }

    _loadingStates['book_stats_$bookId'] = true;
    notifyListeners();

    try {
      final stats = await RatingService.getBookRatingStats(bookId);
      _bookStatsCache[bookId] = stats;
      return stats;
    } catch (e) {
      print('Error loading book rating stats: $e');
      return BookRatingStats.empty(bookId);
    } finally {
      _loadingStates['book_stats_$bookId'] = false;
      notifyListeners();
    }
  }

  // Load user's rating for a book
  Future<Rating?> loadUserRating(String bookId) async {
    final userId = AuthService().currentUser?.uid;
    if (userId == null) return null;

    final key = '${userId}_$bookId';

    // Return cached if available
    if (_userRatingsCache.containsKey(key)) {
      return _userRatingsCache[key];
    }

    _loadingStates['user_rating_$key'] = true;
    notifyListeners();

    try {
      final rating = await RatingService.getUserRating(userId, bookId);
      if (rating != null) {
        _userRatingsCache[key] = rating;
      }
      return rating;
    } catch (e) {
      print('Error loading user rating: $e');
      return null;
    } finally {
      _loadingStates['user_rating_$key'] = false;
      notifyListeners();
    }
  }

  // Submit a rating
  Future<bool> submitRating(String bookId, double rating) async {
    final userId = AuthService().currentUser?.uid;
    if (userId == null) {
      print('User not authenticated');
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final success = await RatingService.submitRating(
        userId: userId,
        bookId: bookId,
        rating: rating,
      );

      if (success) {
        // Update local caches
        await _refreshCachesAfterRating(userId, bookId, rating);
      }

      return success;
    } catch (e) {
      print('Error submitting rating: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Refresh caches after rating submission
  Future<void> _refreshCachesAfterRating(
    String userId,
    String bookId,
    double rating,
  ) async {
    try {
      // Refresh book stats
      final newStats = await RatingService.getBookRatingStats(bookId);
      _bookStatsCache[bookId] = newStats;

      // Update user rating cache
      final key = '${userId}_$bookId';
      final existingRating = _userRatingsCache[key];

      if (existingRating != null) {
        // Update existing rating
        _userRatingsCache[key] = existingRating.copyWith(
          rating: rating,
          updatedAt: DateTime.now(),
        );
      } else {
        // Create new rating cache entry
        _userRatingsCache[key] = Rating(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          bookId: bookId,
          rating: rating,
          createdAt: DateTime.now(),
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error refreshing caches: $e');
    }
  }

  // Stream book rating stats for real-time updates
  Stream<BookRatingStats> streamBookRatingStats(String bookId) {
    return RatingService.streamBookRatingStats(bookId).map((stats) {
      // Update cache
      _bookStatsCache[bookId] = stats;

      // Notify listeners on next frame to avoid build issues
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      return stats;
    });
  }

  // Get multiple book stats efficiently
  Future<Map<String, BookRatingStats>> loadMultipleBookStats(
    List<String> bookIds,
  ) async {
    final results = <String, BookRatingStats>{};
    final toLoad = <String>[];

    // Check cache first
    for (final bookId in bookIds) {
      if (_bookStatsCache.containsKey(bookId)) {
        results[bookId] = _bookStatsCache[bookId]!;
      } else {
        toLoad.add(bookId);
      }
    }

    // Load missing stats
    if (toLoad.isNotEmpty) {
      for (final bookId in toLoad) {
        _loadingStates['book_stats_$bookId'] = true;
      }
      notifyListeners();

      try {
        for (final bookId in toLoad) {
          final stats = await RatingService.getBookRatingStats(bookId);
          _bookStatsCache[bookId] = stats;
          results[bookId] = stats;
        }
      } catch (e) {
        print('Error loading multiple book stats: $e');
        // Add empty stats for failed loads
        for (final bookId in toLoad) {
          if (!results.containsKey(bookId)) {
            results[bookId] = BookRatingStats.empty(bookId);
          }
        }
      } finally {
        for (final bookId in toLoad) {
          _loadingStates['book_stats_$bookId'] = false;
        }
        notifyListeners();
      }
    }

    return results;
  }

  // Clear cache for a specific book (useful after rating submission)
  void clearBookCache(String bookId) {
    _bookStatsCache.remove(bookId);

    // Remove user rating cache for this book
    final userId = AuthService().currentUser?.uid;
    if (userId != null) {
      final key = '${userId}_$bookId';
      _userRatingsCache.remove(key);
    }

    notifyListeners();
  }

  // Clear all caches
  void clearAllCaches() {
    _bookStatsCache.clear();
    _userRatingsCache.clear();
    _loadingStates.clear();
    notifyListeners();
  }

  // Get top rated books
  Future<List<String>> getTopRatedBooks({int limit = 10}) async {
    try {
      return await RatingService.getTopRatedBooks(limit: limit);
    } catch (e) {
      print('Error getting top rated books: $e');
      return [];
    }
  }

  // Handle user logout
  void onUserLogout() {
    _userRatingsCache.clear();
    notifyListeners();
  }

  // Handle user login
  void onUserLogin() {
    // Clear user-specific caches to force refresh
    _userRatingsCache.clear();
    notifyListeners();
  }
}
