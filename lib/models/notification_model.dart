/// Production-Ready Notification Model
///
/// Represents a notification in the Altertale application:
/// - Push notifications and in-app messages
/// - System alerts and user notifications
/// - Action-based notifications (likes, comments, follows)
/// - Content updates and recommendations
/// - Delivery tracking and analytics
/// - Firestore-compatible serialization
class NotificationModel {
  // ==================== CORE FIELDS ====================

  /// Unique notification identifier
  final String id;

  /// Target user ID who receives the notification
  final String userId;

  /// User who triggered the notification (can be null for system notifications)
  final String? triggeredByUserId;

  /// Display name of user who triggered the notification
  final String? triggeredByUserName;

  /// Avatar URL of user who triggered the notification
  final String? triggeredByUserAvatar;

  /// Notification type (like, comment, follow, system, update, etc.)
  final String type;

  // ==================== CONTENT & MESSAGE ====================

  /// Notification title
  final String title;

  /// Notification message/body
  final String message;

  /// Rich message with formatting (HTML or markdown)
  final String? richMessage;

  /// Notification subtitle/summary
  final String? subtitle;

  /// Language of the notification
  final String language;

  /// Notification template ID (for templated notifications)
  final String? templateId;

  // ==================== RELATED CONTENT ====================

  /// Related content ID (story, comment, user, etc.)
  final String? relatedContentId;

  /// Type of related content (story, comment, user, purchase, etc.)
  final String? relatedContentType;

  /// Title of related content
  final String? relatedContentTitle;

  /// URL or image for related content
  final String? relatedContentImage;

  /// Metadata about related content
  final Map<String, dynamic>? relatedContentMetadata;

  // ==================== DELIVERY & CHANNELS ====================

  /// Delivery channels (push, email, in_app, sms)
  final List<String> channels;

  /// Whether notification was sent via push
  final bool sentViaPush;

  /// Whether notification was sent via email
  final bool sentViaEmail;

  /// Whether notification is shown in-app
  final bool sentViaInApp;

  /// Push notification payload
  final Map<String, dynamic>? pushPayload;

  /// Email notification data
  final Map<String, dynamic>? emailData;

  // ==================== ACTIONS & INTERACTION ====================

  /// Available actions for this notification (view, like, reply, etc.)
  final List<String> availableActions;

  /// Deep link URL for notification action
  final String? actionUrl;

  /// Action parameters
  final Map<String, dynamic>? actionParams;

  /// Whether notification requires user action
  final bool requiresAction;

  /// Expiry date for actionable notifications
  final DateTime? actionExpiresAt;

  // ==================== STATUS & TRACKING ====================

  /// Notification status (pending, sent, delivered, read, failed)
  final String status;

  /// Whether notification was read by user
  final bool isRead;

  /// Whether notification was clicked/opened
  final bool isClicked;

  /// Whether notification was dismissed
  final bool isDismissed;

  /// Whether notification is archived
  final bool isArchived;

  /// Number of times notification was viewed
  final int viewCount;

  // ==================== PRIORITY & CATEGORIZATION ====================

  /// Notification priority (low, normal, high, urgent)
  final String priority;

  /// Notification category for grouping
  final String category;

  /// Tags for filtering and organization
  final List<String> tags;

  /// Whether notification is promotional
  final bool isPromotional;

  /// Whether notification is critical/system alert
  final bool isCritical;

  // ==================== SCHEDULING & TIMING ====================

  /// Scheduled delivery time (null for immediate)
  final DateTime? scheduledAt;

  /// When notification was actually sent
  final DateTime? sentAt;

  /// When notification was delivered to device
  final DateTime? deliveredAt;

  /// When notification was read by user
  final DateTime? readAt;

  /// When notification was clicked/opened
  final DateTime? clickedAt;

  /// When notification expires and should be removed
  final DateTime? expiresAt;

  // ==================== PERSONALIZATION ====================

  /// User's notification preferences at time of creation
  final Map<String, dynamic>? userPreferences;

  /// Personalization data used for this notification
  final Map<String, dynamic>? personalizationData;

  /// A/B testing variant ID
  final String? abTestVariant;

  /// Localization data
  final Map<String, dynamic>? localizationData;

  // ==================== ANALYTICS & TRACKING ====================

  /// Campaign ID for marketing notifications
  final String? campaignId;

  /// Source that triggered this notification
  final String? source;

  /// UTM parameters for tracking
  final Map<String, String>? utmParams;

  /// Custom tracking data
  final Map<String, dynamic>? trackingData;

  /// Conversion tracking (if user completed desired action)
  final bool hasConverted;

  /// Conversion value (revenue, points, etc.)
  final double? conversionValue;

  // ==================== TIMESTAMPS ====================

  /// Notification creation timestamp
  final DateTime createdAt;

  /// Notification last updated timestamp
  final DateTime updatedAt;

  /// When notification was last modified
  final DateTime? lastModifiedAt;

  // ==================== METADATA ====================

  /// Platform where notification was created (ios, android, web, server)
  final String platform;

  /// App version when notification was created
  final String? appVersion;

  /// Additional notification metadata
  final Map<String, dynamic>? metadata;

  // ==================== CONSTRUCTOR ====================

  const NotificationModel({
    required this.id,
    required this.userId,
    this.triggeredByUserId,
    this.triggeredByUserName,
    this.triggeredByUserAvatar,
    required this.type,
    required this.title,
    required this.message,
    this.richMessage,
    this.subtitle,
    this.language = 'tr',
    this.templateId,
    this.relatedContentId,
    this.relatedContentType,
    this.relatedContentTitle,
    this.relatedContentImage,
    this.relatedContentMetadata,
    this.channels = const ['in_app'],
    this.sentViaPush = false,
    this.sentViaEmail = false,
    this.sentViaInApp = true,
    this.pushPayload,
    this.emailData,
    this.availableActions = const [],
    this.actionUrl,
    this.actionParams,
    this.requiresAction = false,
    this.actionExpiresAt,
    this.status = 'pending',
    this.isRead = false,
    this.isClicked = false,
    this.isDismissed = false,
    this.isArchived = false,
    this.viewCount = 0,
    this.priority = 'normal',
    this.category = 'general',
    this.tags = const [],
    this.isPromotional = false,
    this.isCritical = false,
    this.scheduledAt,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.clickedAt,
    this.expiresAt,
    this.userPreferences,
    this.personalizationData,
    this.abTestVariant,
    this.localizationData,
    this.campaignId,
    this.source,
    this.utmParams,
    this.trackingData,
    this.hasConverted = false,
    this.conversionValue,
    required this.createdAt,
    required this.updatedAt,
    this.lastModifiedAt,
    this.platform = 'server',
    this.appVersion,
    this.metadata,
  });

  // ==================== FACTORY CONSTRUCTORS ====================

  /// Create a new notification
  factory NotificationModel.create({
    required String id,
    required String userId,
    required String type,
    required String title,
    required String message,
    String? triggeredByUserId,
    String? relatedContentId,
    String priority = 'normal',
    List<String> channels = const ['in_app'],
  }) {
    final now = DateTime.now();
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      title: title,
      message: message,
      triggeredByUserId: triggeredByUserId,
      relatedContentId: relatedContentId,
      priority: priority,
      channels: channels,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a system notification
  factory NotificationModel.system({
    required String id,
    required String userId,
    required String title,
    required String message,
    String priority = 'normal',
    bool isCritical = false,
  }) {
    final now = DateTime.now();
    return NotificationModel(
      id: id,
      userId: userId,
      type: 'system',
      title: title,
      message: message,
      priority: priority,
      category: 'system',
      isCritical: isCritical,
      source: 'system',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create an empty notification model
  factory NotificationModel.empty() {
    final now = DateTime.now();
    return NotificationModel(
      id: '',
      userId: '',
      type: '',
      title: '',
      message: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  // ==================== SERIALIZATION ====================

  /// Convert NotificationModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'triggeredByUserId': triggeredByUserId,
      'triggeredByUserName': triggeredByUserName,
      'triggeredByUserAvatar': triggeredByUserAvatar,
      'type': type,
      'title': title,
      'message': message,
      'richMessage': richMessage,
      'subtitle': subtitle,
      'language': language,
      'templateId': templateId,
      'relatedContentId': relatedContentId,
      'relatedContentType': relatedContentType,
      'relatedContentTitle': relatedContentTitle,
      'relatedContentImage': relatedContentImage,
      'relatedContentMetadata': relatedContentMetadata,
      'channels': channels,
      'sentViaPush': sentViaPush,
      'sentViaEmail': sentViaEmail,
      'sentViaInApp': sentViaInApp,
      'pushPayload': pushPayload,
      'emailData': emailData,
      'availableActions': availableActions,
      'actionUrl': actionUrl,
      'actionParams': actionParams,
      'requiresAction': requiresAction,
      'actionExpiresAt': actionExpiresAt?.toIso8601String(),
      'status': status,
      'isRead': isRead,
      'isClicked': isClicked,
      'isDismissed': isDismissed,
      'isArchived': isArchived,
      'viewCount': viewCount,
      'priority': priority,
      'category': category,
      'tags': tags,
      'isPromotional': isPromotional,
      'isCritical': isCritical,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'clickedAt': clickedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'userPreferences': userPreferences,
      'personalizationData': personalizationData,
      'abTestVariant': abTestVariant,
      'localizationData': localizationData,
      'campaignId': campaignId,
      'source': source,
      'utmParams': utmParams,
      'trackingData': trackingData,
      'hasConverted': hasConverted,
      'conversionValue': conversionValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastModifiedAt': lastModifiedAt?.toIso8601String(),
      'platform': platform,
      'appVersion': appVersion,
      'metadata': metadata,
    };
  }

  /// Create NotificationModel from Firestore Map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      triggeredByUserId: map['triggeredByUserId'],
      triggeredByUserName: map['triggeredByUserName'],
      triggeredByUserAvatar: map['triggeredByUserAvatar'],
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      richMessage: map['richMessage'],
      subtitle: map['subtitle'],
      language: map['language'] ?? 'tr',
      templateId: map['templateId'],
      relatedContentId: map['relatedContentId'],
      relatedContentType: map['relatedContentType'],
      relatedContentTitle: map['relatedContentTitle'],
      relatedContentImage: map['relatedContentImage'],
      relatedContentMetadata: map['relatedContentMetadata'] != null
          ? Map<String, dynamic>.from(map['relatedContentMetadata'])
          : null,
      channels: List<String>.from(map['channels'] ?? ['in_app']),
      sentViaPush: map['sentViaPush'] ?? false,
      sentViaEmail: map['sentViaEmail'] ?? false,
      sentViaInApp: map['sentViaInApp'] ?? true,
      pushPayload: map['pushPayload'] != null
          ? Map<String, dynamic>.from(map['pushPayload'])
          : null,
      emailData: map['emailData'] != null
          ? Map<String, dynamic>.from(map['emailData'])
          : null,
      availableActions: List<String>.from(map['availableActions'] ?? []),
      actionUrl: map['actionUrl'],
      actionParams: map['actionParams'] != null
          ? Map<String, dynamic>.from(map['actionParams'])
          : null,
      requiresAction: map['requiresAction'] ?? false,
      actionExpiresAt: map['actionExpiresAt'] != null
          ? DateTime.parse(map['actionExpiresAt'])
          : null,
      status: map['status'] ?? 'pending',
      isRead: map['isRead'] ?? false,
      isClicked: map['isClicked'] ?? false,
      isDismissed: map['isDismissed'] ?? false,
      isArchived: map['isArchived'] ?? false,
      viewCount: map['viewCount'] ?? 0,
      priority: map['priority'] ?? 'normal',
      category: map['category'] ?? 'general',
      tags: List<String>.from(map['tags'] ?? []),
      isPromotional: map['isPromotional'] ?? false,
      isCritical: map['isCritical'] ?? false,
      scheduledAt: map['scheduledAt'] != null
          ? DateTime.parse(map['scheduledAt'])
          : null,
      sentAt: map['sentAt'] != null ? DateTime.parse(map['sentAt']) : null,
      deliveredAt: map['deliveredAt'] != null
          ? DateTime.parse(map['deliveredAt'])
          : null,
      readAt: map['readAt'] != null ? DateTime.parse(map['readAt']) : null,
      clickedAt: map['clickedAt'] != null
          ? DateTime.parse(map['clickedAt'])
          : null,
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'])
          : null,
      userPreferences: map['userPreferences'] != null
          ? Map<String, dynamic>.from(map['userPreferences'])
          : null,
      personalizationData: map['personalizationData'] != null
          ? Map<String, dynamic>.from(map['personalizationData'])
          : null,
      abTestVariant: map['abTestVariant'],
      localizationData: map['localizationData'] != null
          ? Map<String, dynamic>.from(map['localizationData'])
          : null,
      campaignId: map['campaignId'],
      source: map['source'],
      utmParams: map['utmParams'] != null
          ? Map<String, String>.from(map['utmParams'])
          : null,
      trackingData: map['trackingData'] != null
          ? Map<String, dynamic>.from(map['trackingData'])
          : null,
      hasConverted: map['hasConverted'] ?? false,
      conversionValue: map['conversionValue']?.toDouble(),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastModifiedAt: map['lastModifiedAt'] != null
          ? DateTime.parse(map['lastModifiedAt'])
          : null,
      platform: map['platform'] ?? 'server',
      appVersion: map['appVersion'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  // ==================== COPY WITH ====================

  /// Create a copy of NotificationModel with updated fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? triggeredByUserId,
    String? triggeredByUserName,
    String? triggeredByUserAvatar,
    String? type,
    String? title,
    String? message,
    String? richMessage,
    String? subtitle,
    String? language,
    String? templateId,
    String? relatedContentId,
    String? relatedContentType,
    String? relatedContentTitle,
    String? relatedContentImage,
    Map<String, dynamic>? relatedContentMetadata,
    List<String>? channels,
    bool? sentViaPush,
    bool? sentViaEmail,
    bool? sentViaInApp,
    Map<String, dynamic>? pushPayload,
    Map<String, dynamic>? emailData,
    List<String>? availableActions,
    String? actionUrl,
    Map<String, dynamic>? actionParams,
    bool? requiresAction,
    DateTime? actionExpiresAt,
    String? status,
    bool? isRead,
    bool? isClicked,
    bool? isDismissed,
    bool? isArchived,
    int? viewCount,
    String? priority,
    String? category,
    List<String>? tags,
    bool? isPromotional,
    bool? isCritical,
    DateTime? scheduledAt,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    DateTime? clickedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? userPreferences,
    Map<String, dynamic>? personalizationData,
    String? abTestVariant,
    Map<String, dynamic>? localizationData,
    String? campaignId,
    String? source,
    Map<String, String>? utmParams,
    Map<String, dynamic>? trackingData,
    bool? hasConverted,
    double? conversionValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastModifiedAt,
    String? platform,
    String? appVersion,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      triggeredByUserId: triggeredByUserId ?? this.triggeredByUserId,
      triggeredByUserName: triggeredByUserName ?? this.triggeredByUserName,
      triggeredByUserAvatar:
          triggeredByUserAvatar ?? this.triggeredByUserAvatar,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      richMessage: richMessage ?? this.richMessage,
      subtitle: subtitle ?? this.subtitle,
      language: language ?? this.language,
      templateId: templateId ?? this.templateId,
      relatedContentId: relatedContentId ?? this.relatedContentId,
      relatedContentType: relatedContentType ?? this.relatedContentType,
      relatedContentTitle: relatedContentTitle ?? this.relatedContentTitle,
      relatedContentImage: relatedContentImage ?? this.relatedContentImage,
      relatedContentMetadata:
          relatedContentMetadata ?? this.relatedContentMetadata,
      channels: channels ?? this.channels,
      sentViaPush: sentViaPush ?? this.sentViaPush,
      sentViaEmail: sentViaEmail ?? this.sentViaEmail,
      sentViaInApp: sentViaInApp ?? this.sentViaInApp,
      pushPayload: pushPayload ?? this.pushPayload,
      emailData: emailData ?? this.emailData,
      availableActions: availableActions ?? this.availableActions,
      actionUrl: actionUrl ?? this.actionUrl,
      actionParams: actionParams ?? this.actionParams,
      requiresAction: requiresAction ?? this.requiresAction,
      actionExpiresAt: actionExpiresAt ?? this.actionExpiresAt,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      isClicked: isClicked ?? this.isClicked,
      isDismissed: isDismissed ?? this.isDismissed,
      isArchived: isArchived ?? this.isArchived,
      viewCount: viewCount ?? this.viewCount,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isPromotional: isPromotional ?? this.isPromotional,
      isCritical: isCritical ?? this.isCritical,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      clickedAt: clickedAt ?? this.clickedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      userPreferences: userPreferences ?? this.userPreferences,
      personalizationData: personalizationData ?? this.personalizationData,
      abTestVariant: abTestVariant ?? this.abTestVariant,
      localizationData: localizationData ?? this.localizationData,
      campaignId: campaignId ?? this.campaignId,
      source: source ?? this.source,
      utmParams: utmParams ?? this.utmParams,
      trackingData: trackingData ?? this.trackingData,
      hasConverted: hasConverted ?? this.hasConverted,
      conversionValue: conversionValue ?? this.conversionValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      metadata: metadata ?? this.metadata,
    );
  }

  // ==================== HELPER METHODS ====================

  /// Check if notification is unread
  bool get isUnread {
    return !isRead;
  }

  /// Check if notification is delivered successfully
  bool get isDelivered {
    return status == 'delivered' || status == 'read';
  }

  /// Check if notification has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if notification is scheduled for future
  bool get isScheduled {
    if (scheduledAt == null) return false;
    return DateTime.now().isBefore(scheduledAt!);
  }

  /// Check if notification action has expired
  bool get isActionExpired {
    if (!requiresAction || actionExpiresAt == null) return false;
    return DateTime.now().isAfter(actionExpiresAt!);
  }

  /// Get notification type display name
  String get typeDisplayName {
    switch (type) {
      case 'like':
        return 'Beğeni';
      case 'comment':
        return 'Yorum';
      case 'follow':
        return 'Takip';
      case 'mention':
        return 'Bahsetme';
      case 'story_update':
        return 'Hikaye Güncellemesi';
      case 'system':
        return 'Sistem';
      case 'promotion':
        return 'Kampanya';
      case 'reminder':
        return 'Hatırlatma';
      default:
        return type;
    }
  }

  /// Get priority display name
  String get priorityDisplayName {
    switch (priority) {
      case 'low':
        return 'Düşük';
      case 'normal':
        return 'Normal';
      case 'high':
        return 'Yüksek';
      case 'urgent':
        return 'Acil';
      default:
        return priority;
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'sent':
        return 'Gönderildi';
      case 'delivered':
        return 'Teslim Edildi';
      case 'read':
        return 'Okundu';
      case 'failed':
        return 'Başarısız';
      default:
        return status;
    }
  }

  /// Get category display name
  String get categoryDisplayName {
    switch (category) {
      case 'social':
        return 'Sosyal';
      case 'content':
        return 'İçerik';
      case 'system':
        return 'Sistem';
      case 'marketing':
        return 'Pazarlama';
      case 'reminder':
        return 'Hatırlatma';
      case 'general':
      default:
        return 'Genel';
    }
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

  /// Check if notification has actions
  bool get hasActions {
    return availableActions.isNotEmpty && !isActionExpired;
  }

  /// Check if notification is from another user
  bool get isFromUser {
    return triggeredByUserId != null;
  }

  /// Check if notification is system generated
  bool get isSystemNotification {
    return triggeredByUserId == null || source == 'system';
  }

  /// Get delivery channels as display text
  String get channelsDisplayText {
    final displayChannels = channels.map((channel) {
      switch (channel) {
        case 'push':
          return 'Push';
        case 'email':
          return 'E-posta';
        case 'in_app':
          return 'Uygulama İçi';
        case 'sms':
          return 'SMS';
        default:
          return channel;
      }
    }).toList();

    return displayChannels.join(', ');
  }

  /// Calculate engagement score
  double get engagementScore {
    double score = 0.0;

    if (isDelivered) score += 1.0;
    if (isRead) score += 2.0;
    if (isClicked) score += 3.0;
    if (hasConverted) score += 5.0;

    // Factor in view count
    score += (viewCount * 0.5);

    return score;
  }

  /// Check if notification is recent (within last 24 hours)
  bool get isRecent {
    final daysSinceCreation = DateTime.now().difference(createdAt).inHours;
    return daysSinceCreation <= 24;
  }

  /// Get priority icon based on priority level
  String get priorityIcon {
    switch (priority) {
      case 'low':
        return '🔵';
      case 'normal':
        return '⚪';
      case 'high':
        return '🟡';
      case 'urgent':
        return '🔴';
      default:
        return '⚪';
    }
  }

  // ==================== EQUALITY & HASH ====================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NotificationModel) return false;
    return id == other.id &&
        userId == other.userId &&
        type == other.type &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, type, createdAt);
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, user: $userId, type: $type, '
        'title: $title, status: $status, priority: $priority, '
        'isRead: $isRead, createdAt: $createdAt)';
  }
}
