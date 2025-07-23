import 'package:cloud_firestore/cloud_firestore.dart';

/// Kullanıcı aktiviteleri için model
class UserActivityModel {
  final String id;
  final String userId;
  final String type; // daily_login, comment, rate, share
  final String? bookId;
  final String? commentId;
  final DateTime createdAt;

  UserActivityModel({
    required this.id,
    required this.userId,
    required this.type,
    this.bookId,
    this.commentId,
    required this.createdAt,
  });

  factory UserActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserActivityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      bookId: data['bookId'],
      commentId: data['commentId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'bookId': bookId,
      'commentId': commentId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 