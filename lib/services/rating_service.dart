import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

class RatingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _ratingsCollection = 'ratings';
  static const String _bookStatsCollection = 'book_rating_stats';

  // Submit or update a rating
  static Future<bool> submitRating({
    required String userId,
    required String bookId,
    required double rating,
  }) async {
    try {
      // Validate rating
      if (rating < 1.0 || rating > 5.0) {
        throw ArgumentError('Rating must be between 1.0 and 5.0');
      }

      // Check if user already rated this book
      final existingRatingQuery = await _firestore
          .collection(_ratingsCollection)
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .limit(1)
          .get();

      if (existingRatingQuery.docs.isNotEmpty) {
        // Update existing rating
        final existingDoc = existingRatingQuery.docs.first;
        final oldRating = existingDoc.data()['rating'].toDouble();

        await existingDoc.reference.update({
          'rating': rating,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update book stats
        await _updateBookRatingStats(bookId, oldRating, rating, isUpdate: true);
      } else {
        // Create new rating
        await _firestore.collection(_ratingsCollection).add({
          'userId': userId,
          'bookId': bookId,
          'rating': rating,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': null,
        });

        // Update book stats
        await _updateBookRatingStats(bookId, 0.0, rating, isUpdate: false);
      }

      return true;
    } catch (e) {
      print('Error submitting rating: $e');
      return false;
    }
  }

  // Get user's rating for a specific book
  static Future<Rating?> getUserRating(String userId, String bookId) async {
    try {
      final query = await _firestore
          .collection(_ratingsCollection)
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return Rating.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting user rating: $e');
      return null;
    }
  }

  // Get book rating statistics
  static Future<BookRatingStats> getBookRatingStats(String bookId) async {
    try {
      final doc = await _firestore
          .collection(_bookStatsCollection)
          .doc(bookId)
          .get();

      if (doc.exists) {
        return BookRatingStats.fromMap(doc.data()!);
      } else {
        return BookRatingStats.empty(bookId);
      }
    } catch (e) {
      print('Error getting book rating stats: $e');
      return BookRatingStats.empty(bookId);
    }
  }

  // Get all ratings for a book
  static Future<List<Rating>> getBookRatings(
    String bookId, {
    int limit = 50,
  }) async {
    try {
      final query = await _firestore
          .collection(_ratingsCollection)
          .where('bookId', isEqualTo: bookId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => Rating.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting book ratings: $e');
      return [];
    }
  }

  // Update book rating statistics
  static Future<void> _updateBookRatingStats(
    String bookId,
    double oldRating,
    double newRating, {
    required bool isUpdate,
  }) async {
    try {
      final docRef = _firestore.collection(_bookStatsCollection).doc(bookId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (doc.exists) {
          final data = doc.data()!;
          final currentAvg = (data['averageRating'] ?? 0.0).toDouble();
          final currentTotal = data['totalRatings'] ?? 0;
          final distribution = Map<int, int>.from(
            data['ratingDistribution'] ?? {},
          );

          double newAvg;
          int newTotal;

          if (isUpdate) {
            // Update existing rating
            final totalSum = currentAvg * currentTotal;
            final newSum = totalSum - oldRating + newRating;
            newAvg = newSum / currentTotal;
            newTotal = currentTotal;

            // Update distribution
            if (oldRating > 0) {
              distribution[oldRating.round()] =
                  (distribution[oldRating.round()] ?? 0) - 1;
            }
            distribution[newRating.round()] =
                (distribution[newRating.round()] ?? 0) + 1;
          } else {
            // New rating
            final totalSum = currentAvg * currentTotal;
            final newSum = totalSum + newRating;
            newTotal = currentTotal + 1;
            newAvg = newSum / newTotal;

            // Update distribution
            distribution[newRating.round()] =
                (distribution[newRating.round()] ?? 0) + 1;
          }

          transaction.update(docRef, {
            'averageRating': newAvg,
            'totalRatings': newTotal,
            'ratingDistribution': distribution,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Create new stats document
          transaction.set(docRef, {
            'bookId': bookId,
            'averageRating': newRating,
            'totalRatings': 1,
            'ratingDistribution': {
              1: newRating.round() == 1 ? 1 : 0,
              2: newRating.round() == 2 ? 1 : 0,
              3: newRating.round() == 3 ? 1 : 0,
              4: newRating.round() == 4 ? 1 : 0,
              5: newRating.round() == 5 ? 1 : 0,
            },
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error updating book rating stats: $e');
    }
  }

  // Stream book rating stats for real-time updates
  static Stream<BookRatingStats> streamBookRatingStats(String bookId) {
    return _firestore
        .collection(_bookStatsCollection)
        .doc(bookId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return BookRatingStats.fromMap(doc.data()!);
          } else {
            return BookRatingStats.empty(bookId);
          }
        });
  }

  // Get top rated books
  static Future<List<String>> getTopRatedBooks({int limit = 10}) async {
    try {
      final query = await _firestore
          .collection(_bookStatsCollection)
          .where('totalRatings', isGreaterThan: 0)
          .orderBy('totalRatings', descending: false)
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => doc.data()['bookId'] as String).toList();
    } catch (e) {
      print('Error getting top rated books: $e');
      return [];
    }
  }

  // Delete a rating (for admin/moderation)
  static Future<bool> deleteRating(String ratingId) async {
    try {
      await _firestore.collection(_ratingsCollection).doc(ratingId).delete();
      return true;
    } catch (e) {
      print('Error deleting rating: $e');
      return false;
    }
  }

  // Local cache methods for offline support
  static const String _localRatingsKey = 'pending_ratings';

  // Cache rating locally when offline
  static Future<void> cacheRatingLocally({
    required String userId,
    required String bookId,
    required double rating,
  }) async {
    // Implementation depends on local storage preference
    // This is a placeholder for SharedPreferences or Hive implementation
    print('Caching rating locally: $bookId -> $rating');
  }

  // Sync cached ratings when online
  static Future<void> syncCachedRatings() async {
    // Implementation for syncing offline ratings
    print('Syncing cached ratings...');
  }
}
