import 'package:flutter/foundation.dart';
import '../models/rating_model.dart';
import '../services/rating_service.dart';

/// Rating Provider
/// Manages ratings and rating statistics with caching
class RatingProvider with ChangeNotifier {
  final RatingService _ratingService = RatingService();

  // Caches
  final Map<String, BookRatingStats> _bookStatsCache = {};
  final Map<String, double> _userRatingsCache = {};

  // Loading states
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize the provider
  Future<void> init() async {
    try {
      await _ratingService.initializeRatings();
      print('✅ RatingProvider initialized');
    } catch (e) {
      print('❌ RatingProvider initialization failed: $e');
      _error = e.toString();
    }
  }

  /// Get book rating statistics
  Future<BookRatingStats> getBookRatingStats(String bookId) async {
    // Check cache first
    if (_bookStatsCache.containsKey(bookId)) {
      return _bookStatsCache[bookId]!;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final statsMap = await _ratingService.getBookRatingStats(bookId);

      // Convert Map to BookRatingStats
      final stats = BookRatingStats.fromMap({
        'bookId': bookId,
        'averageRating': statsMap['averageRating'] ?? 0.0,
        'totalRatings': statsMap['ratingCount'] ?? 0,
        'ratingDistribution': <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      });

      _bookStatsCache[bookId] = stats;
      return stats;
    } catch (e) {
      print('❌ Error getting book rating stats: $e');
      _error = e.toString();
      final emptyStats = BookRatingStats.empty(bookId);
      _bookStatsCache[bookId] = emptyStats;
      return emptyStats;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get user's rating for a book
  Future<double?> getUserRating(String userId, String bookId) async {
    final cacheKey = '${userId}_$bookId';

    // Check cache first
    if (_userRatingsCache.containsKey(cacheKey)) {
      return _userRatingsCache[cacheKey];
    }

    try {
      final rating = await _ratingService.getUserRating(userId, bookId);
      if (rating != null) {
        _userRatingsCache[cacheKey] = rating;
      }
      return rating;
    } catch (e) {
      print('❌ Error getting user rating: $e');
      return null;
    }
  }

  /// Submit a rating
  Future<bool> submitRating({
    required String userId,
    required String bookId,
    required double rating,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _ratingService.submitRating(
        userId: userId,
        bookId: bookId,
        rating: rating,
      );

      if (success) {
        // Update caches
        final cacheKey = '${userId}_$bookId';
        _userRatingsCache[cacheKey] = rating;

        // Refresh book stats
        _bookStatsCache.remove(bookId);
        await getBookRatingStats(bookId);
      }

      return success;
    } catch (e) {
      print('❌ Error submitting rating: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stream book rating statistics
  Stream<BookRatingStats> streamBookRatingStats(String bookId) {
    return _ratingService.streamBookRatingStats(bookId).map((statsMap) {
      final stats = BookRatingStats.fromMap({
        'bookId': bookId,
        'averageRating': statsMap['averageRating'] ?? 0.0,
        'totalRatings': statsMap['ratingCount'] ?? 0,
        'ratingDistribution': <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      });

      // Update cache
      _bookStatsCache[bookId] = stats;
      return stats;
    });
  }

  /// Get top rated books (returns book IDs)
  Future<List<String>> getTopRatedBooks({int limit = 10}) async {
    try {
      final topRatedData = await _ratingService.getTopRatedBooks(limit: limit);
      return topRatedData.map((data) => data['bookId'] as String).toList();
    } catch (e) {
      print('❌ Error getting top rated books: $e');
      return [];
    }
  }

  /// Clear all caches
  void clearCache() {
    _bookStatsCache.clear();
    _userRatingsCache.clear();
    _error = null;
    notifyListeners();
  }

  /// Refresh book statistics
  Future<void> refreshBookStats(String bookId) async {
    _bookStatsCache.remove(bookId);
    await getBookRatingStats(bookId);
  }
}
