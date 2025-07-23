import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Cache for user ratings
  final Map<String, double> _userRatings = {};
  bool _ratingsLoaded = false;

  /// Initialize user ratings
  Future<void> initializeRatings() async {
    if (_ratingsLoaded) return;

    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      // Load from SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      final ratingsString = prefs.getString('user_ratings_$userId');

      if (ratingsString != null) {
        final ratingsMap = Map<String, dynamic>.from(
          Uri.splitQueryString(ratingsString),
        );
        ratingsMap.forEach((bookId, rating) {
          _userRatings[bookId] = double.tryParse(rating) ?? 0.0;
        });
        print('⭐ Loaded ${_userRatings.length} ratings from local storage');
      }

      // Try to load from Firestore and merge
      final userRatingsDoc = await _firestore
          .collection('userRatings')
          .doc(userId)
          .get();

      if (userRatingsDoc.exists) {
        final data = userRatingsDoc.data() as Map<String, dynamic>;
        final remoteRatings = Map<String, double>.from(
          data['ratings']?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
              {},
        );

        // Merge with local ratings
        _userRatings.addAll(remoteRatings);

        // Save merged ratings to local storage
        await _saveRatingsToLocal(userId);

        print('⭐ Merged with remote ratings, total: ${_userRatings.length}');
      }

      _ratingsLoaded = true;
    } catch (e) {
      print('❌ Error loading ratings: $e');
      _ratingsLoaded = true;
    }
  }

  /// Rate a book
  Future<bool> rateBook(String bookId, double rating) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      throw Exception('Kullanıcı girişi gerekli');
    }

    if (rating < 1.0 || rating > 5.0) {
      throw Exception('Puan 1-5 arasında olmalıdır');
    }

    try {
      await initializeRatings();

      // Store old rating for potential rollback
      final oldRating = _userRatings[bookId];

      // Update local cache immediately
      _userRatings[bookId] = rating;

      // Save to local storage immediately
      await _saveRatingsToLocal(userId);

      // Update Firestore
      await _firestore.collection('userRatings').doc(userId).set({
        'ratings': _userRatings,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update book's average rating
      await _updateBookRating(bookId, rating, oldRating);

      print('⭐ Book rated successfully: $bookId = $rating stars');
      return true;
    } catch (e) {
      // Rollback local changes on error
      if (_userRatings.containsKey(bookId)) {
        _userRatings.remove(bookId);
      }
      print('❌ Error rating book: $e');
      throw Exception('Puanlama işlemi başarısız: $e');
    }
  }

  /// Update book's average rating
  Future<void> _updateBookRating(
    String bookId,
    double newRating,
    double? oldRating,
  ) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final bookRef = _firestore.collection('books').doc(bookId);
        final bookDoc = await transaction.get(bookRef);

        if (!bookDoc.exists) {
          // Create rating document if book doesn't exist in Firestore
          transaction.set(_firestore.collection('bookRatings').doc(bookId), {
            'totalRating': newRating,
            'ratingCount': 1,
            'averageRating': newRating,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          return;
        }

        final data = bookDoc.data() as Map<String, dynamic>;
        final currentTotal = (data['totalRating'] ?? 0.0) as double;
        final currentCount = (data['ratingCount'] ?? 0) as int;

        double newTotal;
        int newCount;

        if (oldRating != null) {
          // User is updating their rating
          newTotal = currentTotal - oldRating + newRating;
          newCount = currentCount; // Count stays the same
        } else {
          // User is rating for the first time
          newTotal = currentTotal + newRating;
          newCount = currentCount + 1;
        }

        final newAverage = newCount > 0 ? newTotal / newCount : 0.0;

        transaction.update(bookRef, {
          'totalRating': newTotal,
          'ratingCount': newCount,
          'averageRating': newAverage,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        print(
          '⭐ Updated book rating: $bookId - Average: ${newAverage.toStringAsFixed(1)} (${newCount} ratings)',
        );
      });
    } catch (e) {
      print('❌ Error updating book rating: $e');
      // Non-critical error, don't throw
    }
  }

  /// Save ratings to local storage
  Future<void> _saveRatingsToLocal(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratingsString = _userRatings.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      await prefs.setString('user_ratings_$userId', ratingsString);
    } catch (e) {
      print('❌ Error saving ratings to local storage: $e');
    }
  }

  /// Get user's rating for a book
  Future<double?> getUserRating(String userId, String bookId) async {
    await initializeRatings();
    return _userRatings[bookId];
  }

  /// Check if user has rated a book
  Future<bool> hasUserRated(String bookId) async {
    final rating = await getUserRating(
      _authService.currentUser?.uid ?? '',
      bookId,
    );
    return rating != null;
  }

  /// Get all user ratings
  Future<Map<String, double>> getAllUserRatings() async {
    await initializeRatings();
    return Map.from(_userRatings);
  }

  /// Remove rating (for testing)
  Future<void> removeRating(String bookId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      final oldRating = _userRatings[bookId];
      if (oldRating == null) return;

      // Remove from local cache
      _userRatings.remove(bookId);

      // Save to local storage
      await _saveRatingsToLocal(userId);

      // Update Firestore
      await _firestore.collection('userRatings').doc(userId).set({
        'ratings': _userRatings,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('⭐ Rating removed for book: $bookId');
    } catch (e) {
      print('❌ Error removing rating: $e');
    }
  }

  /// Clear all ratings (for logout)
  void clearCache() async {
    _userRatings.clear();
    _ratingsLoaded = false;

    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_ratings_$userId');
      }
    } catch (e) {
      print('❌ Error clearing ratings cache: $e');
    }
  }

  /// Get book rating statistics
  Future<Map<String, dynamic>> getBookRatingStats(String bookId) async {
    try {
      final ratingDoc = await _firestore
          .collection('bookRatings')
          .doc(bookId)
          .get();

      if (ratingDoc.exists) {
        final data = ratingDoc.data() as Map<String, dynamic>;
        return {
          'averageRating': (data['averageRating'] ?? 0.0) as double,
          'ratingCount': (data['ratingCount'] ?? 0) as int,
          'totalRating': (data['totalRating'] ?? 0.0) as double,
        };
      }

      return {'averageRating': 0.0, 'ratingCount': 0, 'totalRating': 0.0};
    } catch (e) {
      print('❌ Error getting book rating stats: $e');
      return {'averageRating': 0.0, 'ratingCount': 0, 'totalRating': 0.0};
    }
  }

  /// Submit a rating for a book
  Future<bool> submitRating({
    required String userId,
    required String bookId,
    required double rating,
  }) async {
    try {
      await rateBook(bookId, rating);
      return true;
    } catch (e) {
      print('❌ Error submitting rating: $e');
      return false;
    }
  }

  /// Stream book rating statistics
  Stream<Map<String, dynamic>> streamBookRatingStats(String bookId) {
    return _firestore.collection('bookRatings').doc(bookId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return {
          'averageRating': (data['averageRating'] ?? 0.0) as double,
          'ratingCount': (data['ratingCount'] ?? 0) as int,
          'totalRating': (data['totalRating'] ?? 0.0) as double,
        };
      }
      return {'averageRating': 0.0, 'ratingCount': 0, 'totalRating': 0.0};
    });
  }

  /// Get top rated books
  Future<List<Map<String, dynamic>>> getTopRatedBooks({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('bookRatings')
          .where('ratingCount', isGreaterThan: 0)
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'bookId': doc.id,
          'averageRating': (data['averageRating'] ?? 0.0) as double,
          'ratingCount': (data['ratingCount'] ?? 0) as int,
          'totalRating': (data['totalRating'] ?? 0.0) as double,
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting top rated books: $e');
      return [];
    }
  }
}
