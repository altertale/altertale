import 'package:cloud_firestore/cloud_firestore.dart';

/// Comment Status Enum
enum CommentStatus { pending, approved, rejected, hidden }

/// Comment Sort Order Enum
enum CommentSortOrder { newest, mostLiked, mostHelpful, mostControversial }

/// Vote Type Enum
enum VoteType { like, dislike }

/// Simplified Comment Model for Altertale
class CommentModel {
  // Core fields
  final String id;
  final String bookId; // Changed from contentId to bookId
  final String userId;
  final String userDisplayName;
  final String? userPhotoUrl;

  // Comment content
  final String text;
  final int? rating; // 1-5 rating for the book
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEdited;

  // Status and moderation
  final CommentStatus status;
  final bool isHidden;
  final List<String> reportedBy;
  final int reportCount;

  // Engagement
  final int likeCount;
  final int dislikeCount;
  final double helpfulnessScore;

  // Threading (optional)
  final String? parentCommentId;
  final String? mentionedUserId;

  CommentModel({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userDisplayName,
    this.userPhotoUrl,
    required this.text,
    this.rating,
    required this.createdAt,
    this.updatedAt,
    this.isEdited = false,
    this.status = CommentStatus.approved,
    this.isHidden = false,
    this.reportedBy = const [],
    this.reportCount = 0,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.helpfulnessScore = 0.0,
    this.parentCommentId,
    this.mentionedUserId,
  });

  /// Create from Firestore document
  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CommentModel(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      userId: data['userId'] ?? '',
      userDisplayName: data['userDisplayName'] ?? 'Anonim',
      userPhotoUrl: data['userPhotoUrl'],
      text: data['text'] ?? '',
      rating: data['rating'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isEdited: data['isEdited'] ?? false,
      status: CommentStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => CommentStatus.approved,
      ),
      isHidden: data['isHidden'] ?? false,
      reportedBy: List<String>.from(data['reportedBy'] ?? []),
      reportCount: data['reportCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      dislikeCount: data['dislikeCount'] ?? 0,
      helpfulnessScore: (data['helpfulnessScore'] ?? 0.0).toDouble(),
      parentCommentId: data['parentCommentId'],
      mentionedUserId: data['mentionedUserId'],
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'bookId': bookId,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isEdited': isEdited,
      'status': status.name,
      'isHidden': isHidden,
      'reportedBy': reportedBy,
      'reportCount': reportCount,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'helpfulnessScore': helpfulnessScore,
      'parentCommentId': parentCommentId,
      'mentionedUserId': mentionedUserId,
    };
  }

  /// Check if comment is liked by user
  bool isLikedBy(String userId) {
    // This would need to be implemented with a separate votes collection
    return false; // Placeholder
  }

  /// Copy with updated fields
  CommentModel copyWith({
    String? id,
    String? bookId,
    String? userId,
    String? userDisplayName,
    String? userPhotoUrl,
    String? text,
    int? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
    CommentStatus? status,
    bool? isHidden,
    List<String>? reportedBy,
    int? reportCount,
    int? likeCount,
    int? dislikeCount,
    double? helpfulnessScore,
    String? parentCommentId,
    String? mentionedUserId,
  }) {
    return CommentModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      text: text ?? this.text,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
      status: status ?? this.status,
      isHidden: isHidden ?? this.isHidden,
      reportedBy: reportedBy ?? this.reportedBy,
      reportCount: reportCount ?? this.reportCount,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      helpfulnessScore: helpfulnessScore ?? this.helpfulnessScore,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      mentionedUserId: mentionedUserId ?? this.mentionedUserId,
    );
  }
}

/// Comment Vote Model
class CommentVote {
  final String id;
  final String commentId;
  final String userId;
  final VoteType voteType;
  final DateTime createdAt;

  CommentVote({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.voteType,
    required this.createdAt,
  });

  factory CommentVote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CommentVote(
      id: doc.id,
      commentId: data['commentId'] ?? '',
      userId: data['userId'] ?? '',
      voteType: VoteType.values.firstWhere(
        (v) => v.name == data['voteType'],
        orElse: () => VoteType.like,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'commentId': commentId,
      'userId': userId,
      'voteType': voteType.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Comment Report Model
class CommentReport {
  final String id;
  final String commentId;
  final String reporterId;
  final String reason;
  final String? description;
  final DateTime createdAt;

  CommentReport({
    required this.id,
    required this.commentId,
    required this.reporterId,
    required this.reason,
    this.description,
    required this.createdAt,
  });

  factory CommentReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CommentReport(
      id: doc.id,
      commentId: data['commentId'] ?? '',
      reporterId: data['reporterId'] ?? '',
      reason: data['reason'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'commentId': commentId,
      'reporterId': reporterId,
      'reason': reason,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
