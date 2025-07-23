import 'package:cloud_firestore/cloud_firestore.dart';

/// Review Model for Book Reviews
///
/// Represents a user review for a book with rating and comment.
/// Stored in Firestore under 'reviews' collection.
class Review {
  final String id;
  final String bookId;
  final String userId;
  final String userName;
  final String userEmail;
  final int rating; // 1-5 stars
  final String comment;
  final DateTime timestamp;
  final DateTime? updatedAt;
  final bool isEdited;

  const Review({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.updatedAt,
    this.isEdited = false,
  });

  /// Create Review from Firestore DocumentSnapshot
  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Review(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      rating: data['rating'] ?? 1,
      comment: data['comment'] ?? '',
      timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate(),
      isEdited: data['isEdited'] ?? false,
    );
  }

  /// Create Review from Map (for testing/manual creation)
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      bookId: map['bookId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      rating: map['rating'] ?? 1,
      comment: map['comment'] ?? '',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : map['timestamp'] is DateTime
          ? map['timestamp']
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : map['updatedAt'] is DateTime
          ? map['updatedAt']
          : null,
      isEdited: map['isEdited'] ?? false,
    );
  }

  /// Convert Review to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'rating': rating,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isEdited': isEdited,
    };
  }

  /// Convert Review to JSON (for debugging/logging)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isEdited': isEdited,
    };
  }

  /// Create a copy of Review with updated fields
  Review copyWith({
    String? id,
    String? bookId,
    String? userId,
    String? userName,
    String? userEmail,
    int? rating,
    String? comment,
    DateTime? timestamp,
    DateTime? updatedAt,
    bool? isEdited,
  }) {
    return Review(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  /// Get formatted timestamp string
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  /// Get formatted rating as stars
  String get ratingStars {
    return '★' * rating + '☆' * (5 - rating);
  }

  /// Get rating percentage (for progress indicators)
  double get ratingPercentage {
    return rating / 5.0;
  }

  /// Check if comment is long (more than 150 characters)
  bool get isLongComment {
    return comment.length > 150;
  }

  /// Get truncated comment for list view
  String get truncatedComment {
    if (comment.length <= 150) return comment;
    return '${comment.substring(0, 150)}...';
  }

  /// Get user initial for avatar
  String get userInitial {
    if (userName.isNotEmpty) {
      return userName.substring(0, 1).toUpperCase();
    }
    if (userEmail.isNotEmpty) {
      return userEmail.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  /// Get user display name
  String get userDisplayName {
    if (userName.isNotEmpty) return userName;
    return userEmail.split('@').first;
  }

  /// Check if review is recent (within last 7 days)
  bool get isRecent {
    return DateTime.now().difference(timestamp).inDays <= 7;
  }

  /// Get edited status text
  String? get editedText {
    if (!isEdited || updatedAt == null) return null;
    final now = DateTime.now();
    final difference = now.difference(updatedAt!);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce düzenlendi';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce düzenlendi';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce düzenlendi';
    } else {
      return 'Az önce düzenlendi';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Review &&
        other.id == id &&
        other.bookId == bookId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(id, bookId, userId);
  }

  @override
  String toString() {
    return 'Review(id: $id, bookId: $bookId, userId: $userId, rating: $rating, comment: ${comment.length > 50 ? comment.substring(0, 50) + '...' : comment})';
  }

  /// Create a sample review for testing
  static Review sample({
    String? id,
    String? bookId,
    String? userId,
    String? userName,
    String? userEmail,
    int? rating,
    String? comment,
    DateTime? timestamp,
  }) {
    return Review(
      id: id ?? 'sample_review_id',
      bookId: bookId ?? 'sample_book_id',
      userId: userId ?? 'sample_user_id',
      userName: userName ?? 'Örnek Kullanıcı',
      userEmail: userEmail ?? 'ornek@email.com',
      rating: rating ?? 4,
      comment:
          comment ??
          'Bu kitap gerçekten harika! Çok beğendim ve herkese tavsiye ederim.',
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Validate review data
  bool isValid() {
    return bookId.isNotEmpty &&
        userId.isNotEmpty &&
        rating >= 1 &&
        rating <= 5 &&
        comment.trim().isNotEmpty &&
        comment.trim().length >= 10;
  }

  /// Get validation error message
  String? getValidationError() {
    if (bookId.isEmpty) return 'Kitap ID boş olamaz';
    if (userId.isEmpty) return 'Kullanıcı ID boş olamaz';
    if (rating < 1 || rating > 5) return 'Puan 1-5 arasında olmalı';
    if (comment.trim().isEmpty) return 'Yorum boş olamaz';
    if (comment.trim().length < 10) return 'Yorum en az 10 karakter olmalı';
    return null;
  }

  /// Check if this review can be edited by user
  bool canBeEditedBy(String currentUserId) {
    return userId == currentUserId;
  }

  /// Check if this review can be deleted by user
  bool canBeDeletedBy(String currentUserId) {
    return userId == currentUserId;
  }
}

/// Book Rating Statistics Model
///
/// Contains aggregated rating information for a book
class BookRatingStats {
  final String bookId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingCounts; // rating -> count
  final int totalRatingSum;

  const BookRatingStats({
    required this.bookId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingCounts,
    required this.totalRatingSum,
  });

  /// Create from list of reviews
  factory BookRatingStats.fromReviews(String bookId, List<Review> reviews) {
    if (reviews.isEmpty) {
      return BookRatingStats(
        bookId: bookId,
        averageRating: 0.0,
        totalReviews: 0,
        ratingCounts: {},
        totalRatingSum: 0,
      );
    }

    final Map<int, int> counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    int totalSum = 0;

    for (final review in reviews) {
      counts[review.rating] = (counts[review.rating] ?? 0) + 1;
      totalSum += review.rating;
    }

    return BookRatingStats(
      bookId: bookId,
      averageRating: totalSum / reviews.length,
      totalReviews: reviews.length,
      ratingCounts: counts,
      totalRatingSum: totalSum,
    );
  }

  /// Get percentage for specific rating
  double getPercentageForRating(int rating) {
    if (totalReviews == 0) return 0.0;
    return (ratingCounts[rating] ?? 0) / totalReviews;
  }

  /// Get formatted average rating
  String get formattedAverageRating {
    if (averageRating == 0) return '0.0';
    return averageRating.toStringAsFixed(1);
  }

  /// Get star representation of average rating
  String get averageRatingStars {
    final fullStars = averageRating.floor();
    final hasHalfStar = (averageRating - fullStars) >= 0.5;

    String stars = '★' * fullStars;
    if (hasHalfStar) stars += '½';

    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    stars += '☆' * emptyStars;

    return stars;
  }

  /// Get rating summary text
  String get summaryText {
    if (totalReviews == 0) return 'Henüz değerlendirme yok';
    if (totalReviews == 1) return '1 değerlendirme';
    return '$totalReviews değerlendirme';
  }

  /// Get detailed summary text
  String get detailedSummaryText {
    if (totalReviews == 0) return 'Bu kitap henüz değerlendirilmemiş';
    return '$formattedAverageRating yıldız ($totalReviews değerlendirme)';
  }

  @override
  String toString() {
    return 'BookRatingStats(bookId: $bookId, averageRating: $formattedAverageRating, totalReviews: $totalReviews)';
  }
}
