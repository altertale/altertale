/// Production-Ready Story Model
///
/// Represents a story/book in the Altertale application:
/// - Story metadata and content information
/// - Author and publication details
/// - Categories, tags, and content ratings
/// - Reading statistics and engagement metrics
/// - Premium content and pricing
/// - Firestore-compatible serialization
class StoryModel {
  // ==================== CORE FIELDS ====================

  /// Unique story identifier
  final String id;

  /// Story title
  final String title;

  /// Story description/summary
  final String description;

  /// Story cover image URL
  final String? coverImageUrl;

  /// Author user ID
  final String authorId;

  /// Author display name
  final String authorName;

  // ==================== CONTENT DETAILS ====================

  /// Main story content (could be markdown or HTML)
  final String content;

  /// Story language code (tr, en, etc.)
  final String language;

  /// Total word count
  final int wordCount;

  /// Estimated reading time in minutes
  final int estimatedReadingTime;

  /// Number of chapters/parts
  final int chapterCount;

  /// Story completion status
  final bool isCompleted;

  // ==================== CATEGORIZATION ====================

  /// Primary genre/category
  final String category;

  /// Sub-category/genre
  final String? subCategory;

  /// Content tags for discovery
  final List<String> tags;

  /// Content maturity rating (all, teen, mature)
  final String contentRating;

  /// Content warnings (violence, adult themes, etc.)
  final List<String> contentWarnings;

  // ==================== PUBLISHING STATUS ====================

  /// Publication status (draft, published, archived)
  final String publishStatus;

  /// Whether story is featured/promoted
  final bool isFeatured;

  /// Whether story is premium content
  final bool isPremium;

  /// Price for premium content (in points or currency)
  final int? premiumPrice;

  /// Publication date
  final DateTime? publishedAt;

  /// Last content update date
  final DateTime? lastUpdatedAt;

  // ==================== ENGAGEMENT METRICS ====================

  /// Total number of views
  final int viewCount;

  /// Total number of likes
  final int likeCount;

  /// Total number of comments
  final int commentCount;

  /// Number of bookmarks/saves
  final int bookmarkCount;

  /// Number of shares
  final int shareCount;

  /// Average rating (1-5 stars)
  final double averageRating;

  /// Total number of ratings
  final int ratingCount;

  // ==================== READING TRACKING ====================

  /// Number of unique readers
  final int readerCount;

  /// Number of users who completed reading
  final int completionCount;

  /// Completion rate percentage
  final double completionRate;

  /// Average reading session time
  final int averageSessionTime;

  // ==================== TIMESTAMPS ====================

  /// Story creation timestamp
  final DateTime createdAt;

  /// Story last modified timestamp
  final DateTime updatedAt;

  /// Last interaction timestamp (view, like, etc.)
  final DateTime? lastInteractionAt;

  // ==================== ADMIN & MODERATION ====================

  /// Whether story is approved by moderators
  final bool isApproved;

  /// Whether story is reported/flagged
  final bool isReported;

  /// Moderator notes (for admin use)
  final String? moderatorNotes;

  /// Story visibility (public, private, unlisted)
  final String visibility;

  // ==================== CONSTRUCTOR ====================

  const StoryModel({
    required this.id,
    required this.title,
    required this.description,
    this.coverImageUrl,
    required this.authorId,
    required this.authorName,
    this.content = '',
    this.language = 'tr',
    this.wordCount = 0,
    this.estimatedReadingTime = 0,
    this.chapterCount = 1,
    this.isCompleted = false,
    this.category = 'genel',
    this.subCategory,
    this.tags = const [],
    this.contentRating = 'all',
    this.contentWarnings = const [],
    this.publishStatus = 'draft',
    this.isFeatured = false,
    this.isPremium = false,
    this.premiumPrice,
    this.publishedAt,
    this.lastUpdatedAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.bookmarkCount = 0,
    this.shareCount = 0,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.readerCount = 0,
    this.completionCount = 0,
    this.completionRate = 0.0,
    this.averageSessionTime = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastInteractionAt,
    this.isApproved = false,
    this.isReported = false,
    this.moderatorNotes,
    this.visibility = 'public',
  });

  // ==================== FACTORY CONSTRUCTORS ====================

  /// Create a new story with minimal required fields
  factory StoryModel.create({
    required String id,
    required String title,
    required String description,
    required String authorId,
    required String authorName,
    String category = 'genel',
  }) {
    final now = DateTime.now();
    return StoryModel(
      id: id,
      title: title,
      description: description,
      authorId: authorId,
      authorName: authorName,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create an empty story model
  factory StoryModel.empty() {
    final now = DateTime.now();
    return StoryModel(
      id: '',
      title: '',
      description: '',
      authorId: '',
      authorName: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  // ==================== SERIALIZATION ====================

  /// Convert StoryModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'language': language,
      'wordCount': wordCount,
      'estimatedReadingTime': estimatedReadingTime,
      'chapterCount': chapterCount,
      'isCompleted': isCompleted,
      'category': category,
      'subCategory': subCategory,
      'tags': tags,
      'contentRating': contentRating,
      'contentWarnings': contentWarnings,
      'publishStatus': publishStatus,
      'isFeatured': isFeatured,
      'isPremium': isPremium,
      'premiumPrice': premiumPrice,
      'publishedAt': publishedAt?.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'bookmarkCount': bookmarkCount,
      'shareCount': shareCount,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'readerCount': readerCount,
      'completionCount': completionCount,
      'completionRate': completionRate,
      'averageSessionTime': averageSessionTime,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastInteractionAt': lastInteractionAt?.toIso8601String(),
      'isApproved': isApproved,
      'isReported': isReported,
      'moderatorNotes': moderatorNotes,
      'visibility': visibility,
    };
  }

  /// Create StoryModel from Firestore Map
  factory StoryModel.fromMap(Map<String, dynamic> map) {
    return StoryModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      coverImageUrl: map['coverImageUrl'],
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      content: map['content'] ?? '',
      language: map['language'] ?? 'tr',
      wordCount: map['wordCount'] ?? 0,
      estimatedReadingTime: map['estimatedReadingTime'] ?? 0,
      chapterCount: map['chapterCount'] ?? 1,
      isCompleted: map['isCompleted'] ?? false,
      category: map['category'] ?? 'genel',
      subCategory: map['subCategory'],
      tags: List<String>.from(map['tags'] ?? []),
      contentRating: map['contentRating'] ?? 'all',
      contentWarnings: List<String>.from(map['contentWarnings'] ?? []),
      publishStatus: map['publishStatus'] ?? 'draft',
      isFeatured: map['isFeatured'] ?? false,
      isPremium: map['isPremium'] ?? false,
      premiumPrice: map['premiumPrice'],
      publishedAt: map['publishedAt'] != null
          ? DateTime.parse(map['publishedAt'])
          : null,
      lastUpdatedAt: map['lastUpdatedAt'] != null
          ? DateTime.parse(map['lastUpdatedAt'])
          : null,
      viewCount: map['viewCount'] ?? 0,
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      bookmarkCount: map['bookmarkCount'] ?? 0,
      shareCount: map['shareCount'] ?? 0,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      readerCount: map['readerCount'] ?? 0,
      completionCount: map['completionCount'] ?? 0,
      completionRate: (map['completionRate'] ?? 0.0).toDouble(),
      averageSessionTime: map['averageSessionTime'] ?? 0,
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastInteractionAt: map['lastInteractionAt'] != null
          ? DateTime.parse(map['lastInteractionAt'])
          : null,
      isApproved: map['isApproved'] ?? false,
      isReported: map['isReported'] ?? false,
      moderatorNotes: map['moderatorNotes'],
      visibility: map['visibility'] ?? 'public',
    );
  }

  // ==================== COPY WITH ====================

  /// Create a copy of StoryModel with updated fields
  StoryModel copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImageUrl,
    String? authorId,
    String? authorName,
    String? content,
    String? language,
    int? wordCount,
    int? estimatedReadingTime,
    int? chapterCount,
    bool? isCompleted,
    String? category,
    String? subCategory,
    List<String>? tags,
    String? contentRating,
    List<String>? contentWarnings,
    String? publishStatus,
    bool? isFeatured,
    bool? isPremium,
    int? premiumPrice,
    DateTime? publishedAt,
    DateTime? lastUpdatedAt,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? bookmarkCount,
    int? shareCount,
    double? averageRating,
    int? ratingCount,
    int? readerCount,
    int? completionCount,
    double? completionRate,
    int? averageSessionTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastInteractionAt,
    bool? isApproved,
    bool? isReported,
    String? moderatorNotes,
    String? visibility,
  }) {
    return StoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      language: language ?? this.language,
      wordCount: wordCount ?? this.wordCount,
      estimatedReadingTime: estimatedReadingTime ?? this.estimatedReadingTime,
      chapterCount: chapterCount ?? this.chapterCount,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      tags: tags ?? this.tags,
      contentRating: contentRating ?? this.contentRating,
      contentWarnings: contentWarnings ?? this.contentWarnings,
      publishStatus: publishStatus ?? this.publishStatus,
      isFeatured: isFeatured ?? this.isFeatured,
      isPremium: isPremium ?? this.isPremium,
      premiumPrice: premiumPrice ?? this.premiumPrice,
      publishedAt: publishedAt ?? this.publishedAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      shareCount: shareCount ?? this.shareCount,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      readerCount: readerCount ?? this.readerCount,
      completionCount: completionCount ?? this.completionCount,
      completionRate: completionRate ?? this.completionRate,
      averageSessionTime: averageSessionTime ?? this.averageSessionTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      isApproved: isApproved ?? this.isApproved,
      isReported: isReported ?? this.isReported,
      moderatorNotes: moderatorNotes ?? this.moderatorNotes,
      visibility: visibility ?? this.visibility,
    );
  }

  // ==================== HELPER METHODS ====================

  /// Check if story is published and visible
  bool get isPublished {
    return publishStatus == 'published' && visibility == 'public' && isApproved;
  }

  /// Check if story is premium and requires payment
  bool get requiresPayment {
    return isPremium && premiumPrice != null && premiumPrice! > 0;
  }

  /// Get category display name in Turkish
  String get categoryDisplayName {
    switch (category) {
      case 'roman':
        return 'Roman';
      case 'hikaye':
        return 'Hikaye';
      case 'siir':
        return 'Şiir';
      case 'deneme':
        return 'Deneme';
      case 'biyografi':
        return 'Biyografi';
      case 'fantastik':
        return 'Fantastik';
      case 'bilimkurgu':
        return 'Bilim Kurgu';
      case 'gerilim':
        return 'Gerilim';
      case 'romantik':
        return 'Romantik';
      case 'tarih':
        return 'Tarih';
      case 'genel':
      default:
        return 'Genel';
    }
  }

  /// Get content rating display name
  String get contentRatingDisplayName {
    switch (contentRating) {
      case 'all':
        return 'Herkese Uygun';
      case 'teen':
        return '13+ Yaş';
      case 'mature':
        return '18+ Yaş';
      default:
        return 'Belirtilmemiş';
    }
  }

  /// Get reading time display text
  String get readingTimeText {
    if (estimatedReadingTime < 60) {
      return '$estimatedReadingTime dakika';
    } else {
      final hours = estimatedReadingTime ~/ 60;
      final minutes = estimatedReadingTime % 60;
      if (minutes == 0) {
        return '$hours saat';
      } else {
        return '$hours saat $minutes dakika';
      }
    }
  }

  /// Get popularity score based on engagement
  double get popularityScore {
    const viewWeight = 1.0;
    const likeWeight = 3.0;
    const commentWeight = 5.0;
    const bookmarkWeight = 4.0;
    const ratingWeight = 2.0;

    return (viewCount * viewWeight +
            likeCount * likeWeight +
            commentCount * commentWeight +
            bookmarkCount * bookmarkWeight +
            ratingCount * ratingWeight) /
        100.0;
  }

  /// Get engagement rate percentage
  double get engagementRate {
    if (viewCount == 0) return 0.0;
    final engagements = likeCount + commentCount + bookmarkCount + shareCount;
    return (engagements / viewCount) * 100;
  }

  /// Check if story has content warnings
  bool get hasContentWarnings {
    return contentWarnings.isNotEmpty;
  }

  /// Get status display text
  String get statusDisplayText {
    switch (publishStatus) {
      case 'published':
        return isApproved ? 'Yayınlandı' : 'Onay Bekliyor';
      case 'draft':
        return 'Taslak';
      case 'archived':
        return 'Arşivlendi';
      default:
        return 'Bilinmiyor';
    }
  }

  // ==================== EQUALITY & HASH ====================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StoryModel) return false;
    return id == other.id &&
        title == other.title &&
        authorId == other.authorId &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, authorId, createdAt);
  }

  @override
  String toString() {
    return 'StoryModel(id: $id, title: $title, author: $authorName, '
        'category: $category, status: $publishStatus, views: $viewCount, '
        'likes: $likeCount, rating: $averageRating, createdAt: $createdAt)';
  }
}
