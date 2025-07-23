/// Production-Ready User Model
///
/// Represents a user in the Altertale application with comprehensive data structure:
/// - Personal information (name, email, profile details)
/// - Account status and verification
/// - Subscription and preferences
/// - Activity tracking
/// - Firestore-compatible serialization
class UserModel {
  // ==================== CORE FIELDS ====================

  /// Unique user identifier (Firebase Auth UID)
  final String uid;

  /// User's email address
  final String email;

  /// User's display name
  final String name;

  /// Optional profile avatar URL
  final String? profileImageUrl;

  /// User's phone number (optional)
  final String? phoneNumber;

  // ==================== SUBSCRIPTION & STATUS ====================

  /// Whether user email is verified
  final bool isEmailVerified;

  /// Whether user account is active
  final bool isActive;

  /// Premium subscription status
  final bool isPremiumUser;

  /// User role (user, premium, admin, moderator)
  final String role;

  /// Subscription expiry date (for premium users)
  final DateTime? subscriptionExpiryDate;

  // ==================== PREFERENCES ====================

  /// User's preferred language code (en, tr, etc.)
  final String preferredLanguage;

  /// Theme preference (light, dark, system)
  final String themePreference;

  /// Push notification enabled
  final bool notificationsEnabled;

  /// Email marketing enabled
  final bool emailMarketingEnabled;

  /// Reading reminder notifications enabled
  final bool readingRemindersEnabled;

  // ==================== ACTIVITY & STATS ====================

  /// Total points earned by user
  final int totalPoints;

  /// Current available points
  final int currentPoints;

  /// Total books read
  final int booksRead;

  /// Total reading time in minutes
  final int totalReadingTimeMinutes;

  /// User's favorite genres
  final List<String> favoriteGenres;

  // ==================== TIMESTAMPS ====================

  /// Account creation timestamp
  final DateTime createdAt;

  /// Last login timestamp
  final DateTime? lastLoginAt;

  /// Profile last updated timestamp
  final DateTime updatedAt;

  /// Last activity timestamp
  final DateTime? lastActivityAt;

  // ==================== SOCIAL FEATURES ====================

  /// Number of followers
  final int followersCount;

  /// Number of following
  final int followingCount;

  /// Public profile visibility
  final bool isProfilePublic;

  /// Bio/description text
  final String? bio;

  // ==================== REFERRAL SYSTEM ====================

  /// Referral code for this user
  final String? referralCode;

  /// User who referred this user
  final String? referredByUserId;

  /// Total users referred by this user
  final int referralCount;

  // ==================== CONSTRUCTOR ====================

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.phoneNumber,
    this.isEmailVerified = false,
    this.isActive = true,
    this.isPremiumUser = false,
    this.role = 'user',
    this.subscriptionExpiryDate,
    this.preferredLanguage = 'tr',
    this.themePreference = 'system',
    this.notificationsEnabled = true,
    this.emailMarketingEnabled = false,
    this.readingRemindersEnabled = true,
    this.totalPoints = 0,
    this.currentPoints = 0,
    this.booksRead = 0,
    this.totalReadingTimeMinutes = 0,
    this.favoriteGenres = const [],
    required this.createdAt,
    this.lastLoginAt,
    required this.updatedAt,
    this.lastActivityAt,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isProfilePublic = true,
    this.bio,
    this.referralCode,
    this.referredByUserId,
    this.referralCount = 0,
  });

  // ==================== FACTORY CONSTRUCTORS ====================

  /// Create a new user with minimal required fields
  factory UserModel.create({
    required String uid,
    required String email,
    required String name,
    String? profileImageUrl,
  }) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      email: email,
      name: name,
      profileImageUrl: profileImageUrl,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create an empty user model
  factory UserModel.empty() {
    final now = DateTime.now();
    return UserModel(
      uid: '',
      email: '',
      name: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  // ==================== SERIALIZATION ====================

  /// Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
      'isPremiumUser': isPremiumUser,
      'role': role,
      'subscriptionExpiryDate': subscriptionExpiryDate?.toIso8601String(),
      'preferredLanguage': preferredLanguage,
      'themePreference': themePreference,
      'notificationsEnabled': notificationsEnabled,
      'emailMarketingEnabled': emailMarketingEnabled,
      'readingRemindersEnabled': readingRemindersEnabled,
      'totalPoints': totalPoints,
      'currentPoints': currentPoints,
      'booksRead': booksRead,
      'totalReadingTimeMinutes': totalReadingTimeMinutes,
      'favoriteGenres': favoriteGenres,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastActivityAt': lastActivityAt?.toIso8601String(),
      'followersCount': followersCount,
      'followingCount': followingCount,
      'isProfilePublic': isProfilePublic,
      'bio': bio,
      'referralCode': referralCode,
      'referredByUserId': referredByUserId,
      'referralCount': referralCount,
    };
  }

  /// Create UserModel from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      phoneNumber: map['phoneNumber'],
      isEmailVerified: map['isEmailVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      isPremiumUser: map['isPremiumUser'] ?? false,
      role: map['role'] ?? 'user',
      subscriptionExpiryDate: map['subscriptionExpiryDate'] != null
          ? DateTime.parse(map['subscriptionExpiryDate'])
          : null,
      preferredLanguage: map['preferredLanguage'] ?? 'tr',
      themePreference: map['themePreference'] ?? 'system',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      emailMarketingEnabled: map['emailMarketingEnabled'] ?? false,
      readingRemindersEnabled: map['readingRemindersEnabled'] ?? true,
      totalPoints: map['totalPoints'] ?? 0,
      currentPoints: map['currentPoints'] ?? 0,
      booksRead: map['booksRead'] ?? 0,
      totalReadingTimeMinutes: map['totalReadingTimeMinutes'] ?? 0,
      favoriteGenres: List<String>.from(map['favoriteGenres'] ?? []),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'])
          : null,
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastActivityAt: map['lastActivityAt'] != null
          ? DateTime.parse(map['lastActivityAt'])
          : null,
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      isProfilePublic: map['isProfilePublic'] ?? true,
      bio: map['bio'],
      referralCode: map['referralCode'],
      referredByUserId: map['referredByUserId'],
      referralCount: map['referralCount'] ?? 0,
    );
  }

  // ==================== COPY WITH ====================

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? profileImageUrl,
    String? phoneNumber,
    bool? isEmailVerified,
    bool? isActive,
    bool? isPremiumUser,
    String? role,
    DateTime? subscriptionExpiryDate,
    String? preferredLanguage,
    String? themePreference,
    bool? notificationsEnabled,
    bool? emailMarketingEnabled,
    bool? readingRemindersEnabled,
    int? totalPoints,
    int? currentPoints,
    int? booksRead,
    int? totalReadingTimeMinutes,
    List<String>? favoriteGenres,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? updatedAt,
    DateTime? lastActivityAt,
    int? followersCount,
    int? followingCount,
    bool? isProfilePublic,
    String? bio,
    String? referralCode,
    String? referredByUserId,
    int? referralCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      role: role ?? this.role,
      subscriptionExpiryDate:
          subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      themePreference: themePreference ?? this.themePreference,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailMarketingEnabled:
          emailMarketingEnabled ?? this.emailMarketingEnabled,
      readingRemindersEnabled:
          readingRemindersEnabled ?? this.readingRemindersEnabled,
      totalPoints: totalPoints ?? this.totalPoints,
      currentPoints: currentPoints ?? this.currentPoints,
      booksRead: booksRead ?? this.booksRead,
      totalReadingTimeMinutes:
          totalReadingTimeMinutes ?? this.totalReadingTimeMinutes,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      bio: bio ?? this.bio,
      referralCode: referralCode ?? this.referralCode,
      referredByUserId: referredByUserId ?? this.referredByUserId,
      referralCount: referralCount ?? this.referralCount,
    );
  }

  // ==================== HELPER METHODS ====================

  /// Check if user is premium and subscription is valid
  bool get isPremiumActive {
    if (!isPremiumUser) return false;
    if (subscriptionExpiryDate == null) return false;
    return DateTime.now().isBefore(subscriptionExpiryDate!);
  }

  /// Get user role display name
  String get roleDisplayName {
    switch (role) {
      case 'admin':
        return 'Yönetici';
      case 'moderator':
        return 'Moderatör';
      case 'premium':
        return 'Premium Üye';
      case 'user':
      default:
        return 'Üye';
    }
  }

  /// Get user's first name
  String get firstName {
    final parts = name.split(' ');
    return parts.isNotEmpty ? parts.first : name;
  }

  /// Get user's initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }

  /// Check if user has completed profile setup
  bool get isProfileComplete {
    return name.isNotEmpty && email.isNotEmpty && isEmailVerified;
  }

  /// Get subscription status text
  String get subscriptionStatusText {
    if (!isPremiumUser) return 'Ücretsiz Üye';
    if (!isPremiumActive) return 'Premium Süresi Dolmuş';
    return 'Premium Üye';
  }

  /// Calculate user activity level based on points and reading time
  String get activityLevel {
    final totalActivity = totalPoints + (totalReadingTimeMinutes ~/ 60);
    if (totalActivity >= 1000) return 'Çok Aktif';
    if (totalActivity >= 500) return 'Aktif';
    if (totalActivity >= 100) return 'Orta';
    return 'Yeni Başlayan';
  }

  // ==================== EQUALITY & HASH ====================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserModel) return false;
    return uid == other.uid &&
        email == other.email &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(uid, email, createdAt);
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, role: $role, '
        'isPremiumUser: $isPremiumUser, totalPoints: $totalPoints, '
        'booksRead: $booksRead, createdAt: $createdAt)';
  }
}
