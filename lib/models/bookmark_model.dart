/// Production-Ready Bookmark Model
///
/// Represents a user's bookmark in the Altertale application:
/// - Content bookmarking and favorites
/// - Reading progress and position tracking
/// - Collections and categories organization
/// - Privacy and sharing settings
/// - Sync across devices
/// - Firestore-compatible serialization
class BookmarkModel {
  // ==================== CORE FIELDS ====================

  /// Unique bookmark identifier
  final String id;

  /// User ID who created the bookmark
  final String userId;

  /// ID of bookmarked content (story, chapter, etc.)
  final String contentId;

  /// Type of bookmarked content (story, chapter, author, collection)
  final String contentType;

  /// Title of bookmarked content at time of bookmarking
  final String contentTitle;

  /// Content author information
  final String? contentAuthor;

  // ==================== CONTENT DETAILS ====================

  /// Content cover image URL
  final String? coverImageUrl;

  /// Content description/summary
  final String? description;

  /// Content tags for categorization
  final List<String> tags;

  /// Content language
  final String? language;

  /// Content category/genre
  final String? category;

  // ==================== READING PROGRESS ====================

  /// Current reading position (character offset or percentage)
  final int? readingPosition;

  /// Reading progress percentage (0-100)
  final double progressPercentage;

  /// Last read chapter/section ID
  final String? lastReadChapterId;

  /// Total reading time for this content (in minutes)
  final int totalReadingTime;

  /// Whether content is completed
  final bool isCompleted;

  /// Reading status (unread, reading, completed, paused)
  final String readingStatus;

  // ==================== ORGANIZATION ====================

  /// Bookmark collection/folder ID
  final String? collectionId;

  /// Collection name for this bookmark
  final String? collectionName;

  /// User-defined bookmark title (overrides content title)
  final String? customTitle;

  /// User notes about this bookmark
  final String? notes;

  /// Bookmark priority/importance (1-5)
  final int priority;

  /// User rating for this content (1-5 stars)
  final double? userRating;

  // ==================== PRIVACY & SHARING ====================

  /// Whether bookmark is private or public
  final bool isPrivate;

  /// Whether bookmark is shared with followers
  final bool isSharedWithFollowers;

  /// Users who can view this bookmark
  final List<String> sharedWithUsers;

  /// Whether bookmark appears in recommendations
  final bool includeInRecommendations;

  // ==================== SYNC & DEVICE INFO ====================

  /// Device where bookmark was created
  final String? deviceId;

  /// Platform where bookmark was created (ios, android, web)
  final String platform;

  /// App version when bookmark was created
  final String? appVersion;

  /// Whether bookmark is synced across devices
  final bool isSynced;

  /// Last sync timestamp
  final DateTime? lastSyncedAt;

  // ==================== REMINDERS & NOTIFICATIONS ====================

  /// Whether user wants reading reminders
  final bool hasReminder;

  /// Reminder frequency (daily, weekly, never)
  final String? reminderFrequency;

  /// Next reminder date
  final DateTime? nextReminderAt;

  /// Whether to notify on content updates
  final bool notifyOnUpdates;

  // ==================== ANALYTICS & TRACKING ====================

  /// Number of times bookmark was accessed
  final int accessCount;

  /// Last access timestamp
  final DateTime? lastAccessedAt;

  /// Number of times bookmark was shared
  final int shareCount;

  /// Average session time when reading this content
  final int averageSessionTime;

  // ==================== TIMESTAMPS ====================

  /// Bookmark creation timestamp
  final DateTime createdAt;

  /// Bookmark last updated timestamp
  final DateTime updatedAt;

  /// When user last read this content
  final DateTime? lastReadAt;

  /// When bookmark was last modified by user
  final DateTime? lastModifiedAt;

  // ==================== METADATA ====================

  /// Additional bookmark metadata
  final Map<String, dynamic>? metadata;

  /// Content metadata snapshot
  final Map<String, dynamic>? contentMetadata;

  // ==================== CONSTRUCTOR ====================

  const BookmarkModel({
    required this.id,
    required this.userId,
    required this.contentId,
    this.contentType = 'story',
    required this.contentTitle,
    this.contentAuthor,
    this.coverImageUrl,
    this.description,
    this.tags = const [],
    this.language,
    this.category,
    this.readingPosition,
    this.progressPercentage = 0.0,
    this.lastReadChapterId,
    this.totalReadingTime = 0,
    this.isCompleted = false,
    this.readingStatus = 'unread',
    this.collectionId,
    this.collectionName,
    this.customTitle,
    this.notes,
    this.priority = 3,
    this.userRating,
    this.isPrivate = false,
    this.isSharedWithFollowers = false,
    this.sharedWithUsers = const [],
    this.includeInRecommendations = true,
    this.deviceId,
    this.platform = 'unknown',
    this.appVersion,
    this.isSynced = false,
    this.lastSyncedAt,
    this.hasReminder = false,
    this.reminderFrequency,
    this.nextReminderAt,
    this.notifyOnUpdates = false,
    this.accessCount = 0,
    this.lastAccessedAt,
    this.shareCount = 0,
    this.averageSessionTime = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastReadAt,
    this.lastModifiedAt,
    this.metadata,
    this.contentMetadata,
  });

  // ==================== FACTORY CONSTRUCTORS ====================

  /// Create a new bookmark
  factory BookmarkModel.create({
    required String id,
    required String userId,
    required String contentId,
    required String contentTitle,
    String contentType = 'story',
    String? contentAuthor,
    String? collectionId,
    bool isPrivate = false,
  }) {
    final now = DateTime.now();
    return BookmarkModel(
      id: id,
      userId: userId,
      contentId: contentId,
      contentType: contentType,
      contentTitle: contentTitle,
      contentAuthor: contentAuthor,
      collectionId: collectionId,
      isPrivate: isPrivate,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create an empty bookmark model
  factory BookmarkModel.empty() {
    final now = DateTime.now();
    return BookmarkModel(
      id: '',
      userId: '',
      contentId: '',
      contentTitle: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  // ==================== SERIALIZATION ====================

  /// Convert BookmarkModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'contentId': contentId,
      'contentType': contentType,
      'contentTitle': contentTitle,
      'contentAuthor': contentAuthor,
      'coverImageUrl': coverImageUrl,
      'description': description,
      'tags': tags,
      'language': language,
      'category': category,
      'readingPosition': readingPosition,
      'progressPercentage': progressPercentage,
      'lastReadChapterId': lastReadChapterId,
      'totalReadingTime': totalReadingTime,
      'isCompleted': isCompleted,
      'readingStatus': readingStatus,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'customTitle': customTitle,
      'notes': notes,
      'priority': priority,
      'userRating': userRating,
      'isPrivate': isPrivate,
      'isSharedWithFollowers': isSharedWithFollowers,
      'sharedWithUsers': sharedWithUsers,
      'includeInRecommendations': includeInRecommendations,
      'deviceId': deviceId,
      'platform': platform,
      'appVersion': appVersion,
      'isSynced': isSynced,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'hasReminder': hasReminder,
      'reminderFrequency': reminderFrequency,
      'nextReminderAt': nextReminderAt?.toIso8601String(),
      'notifyOnUpdates': notifyOnUpdates,
      'accessCount': accessCount,
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'shareCount': shareCount,
      'averageSessionTime': averageSessionTime,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastReadAt': lastReadAt?.toIso8601String(),
      'lastModifiedAt': lastModifiedAt?.toIso8601String(),
      'metadata': metadata,
      'contentMetadata': contentMetadata,
    };
  }

  /// Create BookmarkModel from Firestore Map
  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      contentId: map['contentId'] ?? '',
      contentType: map['contentType'] ?? 'story',
      contentTitle: map['contentTitle'] ?? '',
      contentAuthor: map['contentAuthor'],
      coverImageUrl: map['coverImageUrl'],
      description: map['description'],
      tags: List<String>.from(map['tags'] ?? []),
      language: map['language'],
      category: map['category'],
      readingPosition: map['readingPosition'],
      progressPercentage: (map['progressPercentage'] ?? 0.0).toDouble(),
      lastReadChapterId: map['lastReadChapterId'],
      totalReadingTime: map['totalReadingTime'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      readingStatus: map['readingStatus'] ?? 'unread',
      collectionId: map['collectionId'],
      collectionName: map['collectionName'],
      customTitle: map['customTitle'],
      notes: map['notes'],
      priority: map['priority'] ?? 3,
      userRating: map['userRating']?.toDouble(),
      isPrivate: map['isPrivate'] ?? false,
      isSharedWithFollowers: map['isSharedWithFollowers'] ?? false,
      sharedWithUsers: List<String>.from(map['sharedWithUsers'] ?? []),
      includeInRecommendations: map['includeInRecommendations'] ?? true,
      deviceId: map['deviceId'],
      platform: map['platform'] ?? 'unknown',
      appVersion: map['appVersion'],
      isSynced: map['isSynced'] ?? false,
      lastSyncedAt: map['lastSyncedAt'] != null
          ? DateTime.parse(map['lastSyncedAt'])
          : null,
      hasReminder: map['hasReminder'] ?? false,
      reminderFrequency: map['reminderFrequency'],
      nextReminderAt: map['nextReminderAt'] != null
          ? DateTime.parse(map['nextReminderAt'])
          : null,
      notifyOnUpdates: map['notifyOnUpdates'] ?? false,
      accessCount: map['accessCount'] ?? 0,
      lastAccessedAt: map['lastAccessedAt'] != null
          ? DateTime.parse(map['lastAccessedAt'])
          : null,
      shareCount: map['shareCount'] ?? 0,
      averageSessionTime: map['averageSessionTime'] ?? 0,
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastReadAt: map['lastReadAt'] != null
          ? DateTime.parse(map['lastReadAt'])
          : null,
      lastModifiedAt: map['lastModifiedAt'] != null
          ? DateTime.parse(map['lastModifiedAt'])
          : null,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      contentMetadata: map['contentMetadata'] != null
          ? Map<String, dynamic>.from(map['contentMetadata'])
          : null,
    );
  }

  // ==================== COPY WITH ====================

  /// Create a copy of BookmarkModel with updated fields
  BookmarkModel copyWith({
    String? id,
    String? userId,
    String? contentId,
    String? contentType,
    String? contentTitle,
    String? contentAuthor,
    String? coverImageUrl,
    String? description,
    List<String>? tags,
    String? language,
    String? category,
    int? readingPosition,
    double? progressPercentage,
    String? lastReadChapterId,
    int? totalReadingTime,
    bool? isCompleted,
    String? readingStatus,
    String? collectionId,
    String? collectionName,
    String? customTitle,
    String? notes,
    int? priority,
    double? userRating,
    bool? isPrivate,
    bool? isSharedWithFollowers,
    List<String>? sharedWithUsers,
    bool? includeInRecommendations,
    String? deviceId,
    String? platform,
    String? appVersion,
    bool? isSynced,
    DateTime? lastSyncedAt,
    bool? hasReminder,
    String? reminderFrequency,
    DateTime? nextReminderAt,
    bool? notifyOnUpdates,
    int? accessCount,
    DateTime? lastAccessedAt,
    int? shareCount,
    int? averageSessionTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastReadAt,
    DateTime? lastModifiedAt,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? contentMetadata,
  }) {
    return BookmarkModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      contentTitle: contentTitle ?? this.contentTitle,
      contentAuthor: contentAuthor ?? this.contentAuthor,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      language: language ?? this.language,
      category: category ?? this.category,
      readingPosition: readingPosition ?? this.readingPosition,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      lastReadChapterId: lastReadChapterId ?? this.lastReadChapterId,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      isCompleted: isCompleted ?? this.isCompleted,
      readingStatus: readingStatus ?? this.readingStatus,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      customTitle: customTitle ?? this.customTitle,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      userRating: userRating ?? this.userRating,
      isPrivate: isPrivate ?? this.isPrivate,
      isSharedWithFollowers:
          isSharedWithFollowers ?? this.isSharedWithFollowers,
      sharedWithUsers: sharedWithUsers ?? this.sharedWithUsers,
      includeInRecommendations:
          includeInRecommendations ?? this.includeInRecommendations,
      deviceId: deviceId ?? this.deviceId,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      isSynced: isSynced ?? this.isSynced,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      nextReminderAt: nextReminderAt ?? this.nextReminderAt,
      notifyOnUpdates: notifyOnUpdates ?? this.notifyOnUpdates,
      accessCount: accessCount ?? this.accessCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      shareCount: shareCount ?? this.shareCount,
      averageSessionTime: averageSessionTime ?? this.averageSessionTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      metadata: metadata ?? this.metadata,
      contentMetadata: contentMetadata ?? this.contentMetadata,
    );
  }

  // ==================== HELPER METHODS ====================

  /// Get display title (custom title or content title)
  String get displayTitle {
    return customTitle?.isNotEmpty == true ? customTitle! : contentTitle;
  }

  /// Check if bookmark is actively being read
  bool get isActivelyReading {
    return readingStatus == 'reading' && progressPercentage > 0 && !isCompleted;
  }

  /// Check if bookmark is recently accessed (within last 7 days)
  bool get isRecentlyAccessed {
    if (lastAccessedAt == null) return false;
    final daysSinceAccess = DateTime.now().difference(lastAccessedAt!).inDays;
    return daysSinceAccess <= 7;
  }

  /// Get reading status display name
  String get readingStatusDisplayName {
    switch (readingStatus) {
      case 'unread':
        return 'Okunmamış';
      case 'reading':
        return 'Okunuyor';
      case 'completed':
        return 'Tamamlandı';
      case 'paused':
        return 'Duraklatıldı';
      case 'dropped':
        return 'Bırakıldı';
      default:
        return readingStatus;
    }
  }

  /// Get priority display name
  String get priorityDisplayName {
    switch (priority) {
      case 1:
        return 'Çok Düşük';
      case 2:
        return 'Düşük';
      case 3:
        return 'Orta';
      case 4:
        return 'Yüksek';
      case 5:
        return 'Çok Yüksek';
      default:
        return 'Orta';
    }
  }

  /// Get reading time display text
  String get readingTimeText {
    if (totalReadingTime < 60) {
      return '$totalReadingTime dakika';
    } else {
      final hours = totalReadingTime ~/ 60;
      final minutes = totalReadingTime % 60;
      if (minutes == 0) {
        return '$hours saat';
      } else {
        return '$hours saat $minutes dakika';
      }
    }
  }

  /// Get progress display text
  String get progressText {
    return '${progressPercentage.toStringAsFixed(1)}%';
  }

  /// Check if bookmark has notes
  bool get hasNotes {
    return notes?.isNotEmpty == true;
  }

  /// Check if bookmark has rating
  bool get hasRating {
    return userRating != null && userRating! > 0;
  }

  /// Check if bookmark is shared
  bool get isShared {
    return !isPrivate && (isSharedWithFollowers || sharedWithUsers.isNotEmpty);
  }

  /// Check if reminder is due
  bool get isReminderDue {
    if (!hasReminder || nextReminderAt == null) return false;
    return DateTime.now().isAfter(nextReminderAt!);
  }

  /// Get content type display name
  String get contentTypeDisplayName {
    switch (contentType) {
      case 'story':
        return 'Hikaye';
      case 'chapter':
        return 'Bölüm';
      case 'author':
        return 'Yazar';
      case 'collection':
        return 'Koleksiyon';
      default:
        return contentType;
    }
  }

  /// Calculate estimated remaining reading time
  int get estimatedRemainingTime {
    if (progressPercentage >= 100 || averageSessionTime == 0) return 0;
    final remainingPercentage = 100 - progressPercentage;
    final estimatedTotalTime = totalReadingTime / (progressPercentage / 100);
    return ((estimatedTotalTime * remainingPercentage) / 100).round();
  }

  /// Get days since last read
  int? get daysSinceLastRead {
    if (lastReadAt == null) return null;
    return DateTime.now().difference(lastReadAt!).inDays;
  }

  /// Check if bookmark needs sync
  bool get needsSync {
    if (lastSyncedAt == null) return true;
    return updatedAt.isAfter(lastSyncedAt!);
  }

  /// Get activity level based on access count and reading time
  String get activityLevel {
    final activityScore = accessCount + (totalReadingTime ~/ 30);
    if (activityScore >= 20) return 'Çok Aktif';
    if (activityScore >= 10) return 'Aktif';
    if (activityScore >= 5) return 'Orta';
    return 'Düşük';
  }

  // ==================== EQUALITY & HASH ====================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BookmarkModel) return false;
    return id == other.id &&
        userId == other.userId &&
        contentId == other.contentId &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, contentId, createdAt);
  }

  @override
  String toString() {
    return 'BookmarkModel(id: $id, user: $userId, content: $displayTitle, '
        'progress: $progressText, status: $readingStatus, '
        'priority: $priority, createdAt: $createdAt)';
  }
}
