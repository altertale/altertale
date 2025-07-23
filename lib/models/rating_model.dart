import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String userId;
  final String bookId;
  final double rating; // 1.0 to 5.0
  final DateTime createdAt;
  final DateTime? updatedAt;

  Rating({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.rating,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory constructor from Firestore
  factory Rating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Rating(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Factory constructor from Map
  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      bookId: map['bookId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bookId': bookId,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Copy with method for updates
  Rating copyWith({
    String? id,
    String? userId,
    String? bookId,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Rating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Rating(id: $id, userId: $userId, bookId: $bookId, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Rating &&
        other.id == id &&
        other.userId == userId &&
        other.bookId == bookId &&
        other.rating == rating;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ bookId.hashCode ^ rating.hashCode;
  }
}

// Book rating statistics model
class BookRatingStats {
  final String bookId;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution; // star count -> number of ratings

  BookRatingStats({
    required this.bookId,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  factory BookRatingStats.fromMap(Map<String, dynamic> map) {
    return BookRatingStats(
      bookId: map['bookId'] ?? '',
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      ratingDistribution: Map<int, int>.from(map['ratingDistribution'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'ratingDistribution': ratingDistribution,
    };
  }

  // Empty constructor for no ratings
  factory BookRatingStats.empty(String bookId) {
    return BookRatingStats(
      bookId: bookId,
      averageRating: 0.0,
      totalRatings: 0,
      ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
    );
  }

  @override
  String toString() {
    return 'BookRatingStats(bookId: $bookId, avg: $averageRating, total: $totalRatings)';
  }
}
