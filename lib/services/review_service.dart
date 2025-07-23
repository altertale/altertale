import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/review.dart';

/// Review Service for Review Management
///
/// Handles all review-related operations including:
/// - Adding, updating, deleting reviews
/// - Fetching reviews for books
/// - Managing rating statistics
/// - Real-time review tracking
/// - Business rule enforcement (one review per user per book)
class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _reviewsCollection = 'reviews';

  // ==================== REVIEW MANAGEMENT ====================

  /// Add a new review for a book
  Future<Review> addReview({
    required String bookId,
    required String userId,
    required String userName,
    required String userEmail,
    required int rating,
    required String comment,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '⭐ ReviewService: Adding review for book: $bookId by user: $userId',
        );
      }

      // Check if user already has a review for this book
      final existingReview = await getUserReviewForBook(bookId, userId);
      if (existingReview != null) {
        throw 'Bu kitaba daha önce yorum yapmışsınız. Mevcut yorumunuzu düzenleyebilirsiniz.';
      }

      // Validate rating
      if (rating < 1 || rating > 5) {
        throw 'Puan 1-5 arasında olmalıdır.';
      }

      // Validate comment
      if (comment.trim().length < 10) {
        throw 'Yorum en az 10 karakter olmalıdır.';
      }

      // Create review object
      final review = Review(
        id: '', // Will be set by Firestore
        bookId: bookId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        rating: rating,
        comment: comment.trim(),
        timestamp: DateTime.now(),
      );

      // Validate review
      if (!review.isValid()) {
        final error = review.getValidationError();
        throw 'Yorum doğrulama hatası: $error';
      }

      // Save to Firestore
      final docRef = await _firestore
          .collection(_reviewsCollection)
          .add(review.toMap());

      // Return review with generated ID
      final createdReview = review.copyWith(id: docRef.id);

      if (kDebugMode) {
        print('✅ ReviewService: Review added successfully: ${docRef.id}');
        print('⭐ ReviewService: Rating: $rating stars');
      }

      return createdReview;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error adding review: $e');
      }
      throw 'Yorum eklenirken hata oluştu: $e';
    }
  }

  /// Update an existing review
  Future<Review> updateReview({
    required String reviewId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    try {
      if (kDebugMode) {
        print('⭐ ReviewService: Updating review: $reviewId');
      }

      // Get existing review
      final existingReview = await getReviewById(reviewId);
      if (existingReview == null) {
        throw 'Güncellenecek yorum bulunamadı.';
      }

      // Check ownership
      if (existingReview.userId != userId) {
        throw 'Bu yorumu düzenleme yetkiniz yok.';
      }

      // Validate rating
      if (rating < 1 || rating > 5) {
        throw 'Puan 1-5 arasında olmalıdır.';
      }

      // Validate comment
      if (comment.trim().length < 10) {
        throw 'Yorum en az 10 karakter olmalıdır.';
      }

      // Update review
      await _firestore.collection(_reviewsCollection).doc(reviewId).update({
        'rating': rating,
        'comment': comment.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isEdited': true,
      });

      // Return updated review
      final updatedReview = existingReview.copyWith(
        rating: rating,
        comment: comment.trim(),
        updatedAt: DateTime.now(),
        isEdited: true,
      );

      if (kDebugMode) {
        print('✅ ReviewService: Review updated successfully: $reviewId');
      }

      return updatedReview;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error updating review: $e');
      }
      throw 'Yorum güncellenirken hata oluştu: $e';
    }
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId, String userId) async {
    try {
      if (kDebugMode) {
        print('⭐ ReviewService: Deleting review: $reviewId');
      }

      // Get existing review to check ownership
      final existingReview = await getReviewById(reviewId);
      if (existingReview == null) {
        throw 'Silinecek yorum bulunamadı.';
      }

      // Check ownership
      if (existingReview.userId != userId) {
        throw 'Bu yorumu silme yetkiniz yok.';
      }

      // Delete from Firestore
      await _firestore.collection(_reviewsCollection).doc(reviewId).delete();

      if (kDebugMode) {
        print('✅ ReviewService: Review deleted successfully: $reviewId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error deleting review: $e');
      }
      throw 'Yorum silinirken hata oluştu: $e';
    }
  }

  // ==================== REVIEW QUERIES ====================

  /// Get real-time stream of reviews for a book
  Stream<List<Review>> getReviewsForBookStream(String bookId) {
    try {
      if (kDebugMode) {
        print('⭐ ReviewService: Starting reviews stream for book: $bookId');
      }

      return _firestore
          .collection(_reviewsCollection)
          .where('bookId', isEqualTo: bookId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            final reviews = snapshot.docs
                .map((doc) => Review.fromFirestore(doc))
                .toList();

            if (kDebugMode) {
              print(
                '⭐ ReviewService: Loaded ${reviews.length} reviews for book $bookId',
              );
            }

            return reviews;
          });
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error in reviews stream: $e');
      }
      throw 'Yorumlar yüklenirken hata oluştu: $e';
    }
  }

  /// Get reviews for a book as one-time fetch
  Future<List<Review>> getReviewsForBook(String bookId) async {
    try {
      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('bookId', isEqualTo: bookId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error getting reviews: $e');
      }
      throw 'Yorumlar alınırken hata oluştu: $e';
    }
  }

  /// Get single review by ID
  Future<Review?> getReviewById(String reviewId) async {
    try {
      if (kDebugMode) {
        print('⭐ ReviewService: Getting review with ID: $reviewId');
      }

      final doc = await _firestore
          .collection(_reviewsCollection)
          .doc(reviewId)
          .get();

      if (!doc.exists) {
        if (kDebugMode) {
          print('⚠️ ReviewService: Review not found: $reviewId');
        }
        return null;
      }

      final review = Review.fromFirestore(doc);

      if (kDebugMode) {
        print('✅ ReviewService: Review loaded: $reviewId');
      }

      return review;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error getting review $reviewId: $e');
      }
      throw 'Yorum detayları yüklenirken hata oluştu: $e';
    }
  }

  /// Get user's review for a specific book
  Future<Review?> getUserReviewForBook(String bookId, String userId) async {
    try {
      if (kDebugMode) {
        print(
          '⭐ ReviewService: Getting user review for book: $bookId, user: $userId',
        );
      }

      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('bookId', isEqualTo: bookId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        if (kDebugMode) {
          print('⚠️ ReviewService: No user review found for book: $bookId');
        }
        return null;
      }

      final review = Review.fromFirestore(snapshot.docs.first);

      if (kDebugMode) {
        print('✅ ReviewService: User review found: ${review.id}');
      }

      return review;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error getting user review: $e');
      }
      throw 'Kullanıcı yorumu alınırken hata oluştu: $e';
    }
  }

  /// Get user's review stream for a specific book
  Stream<Review?> getUserReviewForBookStream(String bookId, String userId) {
    try {
      if (kDebugMode) {
        print('⭐ ReviewService: Starting user review stream for book: $bookId');
      }

      return _firestore
          .collection(_reviewsCollection)
          .where('bookId', isEqualTo: bookId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isEmpty) return null;
            return Review.fromFirestore(snapshot.docs.first);
          });
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error in user review stream: $e');
      }
      throw 'Kullanıcı yorumu stream hatası: $e';
    }
  }

  // ==================== RATING STATISTICS ====================

  /// Get rating statistics for a book
  Future<BookRatingStats> getBookRatingStats(String bookId) async {
    try {
      final reviews = await getReviewsForBook(bookId);
      return BookRatingStats.fromReviews(bookId, reviews);
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error getting rating stats: $e');
      }
      return BookRatingStats.fromReviews(bookId, []);
    }
  }

  /// Get rating statistics stream for a book
  Stream<BookRatingStats> getBookRatingStatsStream(String bookId) {
    try {
      return getReviewsForBookStream(
        bookId,
      ).map((reviews) => BookRatingStats.fromReviews(bookId, reviews));
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error in rating stats stream: $e');
      }
      return Stream.value(BookRatingStats.fromReviews(bookId, []));
    }
  }

  // ==================== USER REVIEW HISTORY ====================

  /// Get all reviews by a user
  Future<List<Review>> getUserReviews(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error getting user reviews: $e');
      }
      throw 'Kullanıcı yorumları alınırken hata oluştu: $e';
    }
  }

  /// Get user reviews stream
  Stream<List<Review>> getUserReviewsStream(String userId) {
    try {
      return _firestore
          .collection(_reviewsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Review.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error in user reviews stream: $e');
      }
      throw 'Kullanıcı yorumları stream hatası: $e';
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Check if user can review a book (hasn't reviewed before)
  Future<bool> canUserReviewBook(String bookId, String userId) async {
    try {
      final existingReview = await getUserReviewForBook(bookId, userId);
      return existingReview == null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error checking review eligibility: $e');
      }
      return false;
    }
  }

  /// Get total review count for a book
  Future<int> getReviewCountForBook(String bookId) async {
    try {
      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('bookId', isEqualTo: bookId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error getting review count: $e');
      }
      return 0;
    }
  }

  /// Get recent reviews (last 7 days) for admin dashboard
  Future<List<Review>> getRecentReviews({int limit = 10}) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error getting recent reviews: $e');
      }
      return [];
    }
  }

  /// Get top rated books based on reviews
  Future<List<String>> getTopRatedBookIds({int limit = 10}) async {
    try {
      // This is a simplified version - in production you might want to maintain
      // a separate collection for book statistics for better performance
      final snapshot = await _firestore.collection(_reviewsCollection).get();

      final Map<String, List<int>> bookRatings = {};

      for (final doc in snapshot.docs) {
        final review = Review.fromFirestore(doc);
        bookRatings.putIfAbsent(review.bookId, () => []);
        bookRatings[review.bookId]!.add(review.rating);
      }

      // Calculate average ratings and sort
      final List<MapEntry<String, double>> sortedBooks =
          bookRatings.entries.map((entry) {
            final ratings = entry.value;
            final average = ratings.reduce((a, b) => a + b) / ratings.length;
            return MapEntry(entry.key, average);
          }).toList()..sort((a, b) => b.value.compareTo(a.value));

      return sortedBooks.take(limit).map((entry) => entry.key).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error getting top rated books: $e');
      }
      return [];
    }
  }

  /// Delete all reviews for a book (admin function)
  Future<void> deleteAllReviewsForBook(String bookId) async {
    try {
      if (kDebugMode) {
        print('⭐ ReviewService: Deleting all reviews for book: $bookId');
      }

      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('bookId', isEqualTo: bookId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) {
        print(
          '✅ ReviewService: Deleted ${snapshot.docs.length} reviews for book: $bookId',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error deleting book reviews: $e');
      }
      throw 'Kitap yorumları silinirken hata oluştu: $e';
    }
  }

  /// Get review statistics summary
  Future<Map<String, dynamic>> getReviewStatistics() async {
    try {
      final snapshot = await _firestore.collection(_reviewsCollection).get();

      final reviews = snapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .toList();

      final totalReviews = reviews.length;
      final averageRating = totalReviews > 0
          ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / totalReviews
          : 0.0;

      final ratingCounts = <int, int>{};
      for (int i = 1; i <= 5; i++) {
        ratingCounts[i] = reviews.where((r) => r.rating == i).length;
      }

      final uniqueBooks = reviews.map((r) => r.bookId).toSet().length;
      final uniqueUsers = reviews.map((r) => r.userId).toSet().length;

      return {
        'totalReviews': totalReviews,
        'averageRating': averageRating,
        'ratingCounts': ratingCounts,
        'uniqueBooks': uniqueBooks,
        'uniqueUsers': uniqueUsers,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReviewService: Error getting statistics: $e');
      }
      return {
        'totalReviews': 0,
        'averageRating': 0.0,
        'ratingCounts': {},
        'uniqueBooks': 0,
        'uniqueUsers': 0,
      };
    }
  }
}
