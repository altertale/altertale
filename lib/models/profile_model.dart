import 'package:cloud_firestore/cloud_firestore.dart';

/// Kullanıcı profil veri modeli
/// Kullanıcının profil bilgilerini ve tercihlerini temsil eder
class ProfileModel {
  final String uid;
  final String name;
  final String? username;
  final String? profileImageUrl;
  final String? bio;
  final String email;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> notificationSettings;
  final Map<String, dynamic> readingSettings;

  // UserProfile ile uyumluluk için eklenen property'ler
  final String? displayName;
  final DateTime? joinDate;
  final DateTime? lastActiveDate;
  final bool isPremium;
  final bool isActive;
  final bool isDeleted;

  ProfileModel({
    required this.uid,
    required this.name,
    this.username,
    this.profileImageUrl,
    this.bio,
    required this.email,
    required this.createdAt,
    required this.lastUpdated,
    this.preferences = const {},
    this.notificationSettings = const {},
    this.readingSettings = const {},
    // Yeni property'ler
    this.displayName,
    DateTime? joinDate,
    DateTime? lastActiveDate,
    this.isPremium = false,
    this.isActive = true,
    this.isDeleted = false,
  }) : joinDate = joinDate ?? createdAt,
       lastActiveDate = lastActiveDate ?? DateTime.now();

  /// Varsayılan profil oluşturur
  factory ProfileModel.defaultProfile(
    String uid, {
    String? name,
    String? email,
  }) {
    final now = DateTime.now();
    return ProfileModel(
      uid: uid,
      name: name ?? 'Kullanıcı',
      email: email ?? '',
      createdAt: now,
      lastUpdated: now,
      joinDate: now,
      lastActiveDate: now,
    );
  }

  /// UserProfile'dan ProfileModel'e dönüştürür
  factory ProfileModel.fromUserProfile(dynamic userProfile) {
    return ProfileModel(
      uid: userProfile.userId,
      name: userProfile.displayName ?? userProfile.username,
      username: userProfile.username,
      email: userProfile.email,
      bio: userProfile.bio,
      profileImageUrl: userProfile.profilePhotoUrl,
      displayName: userProfile.displayName,
      joinDate: userProfile.joinDate,
      lastActiveDate: userProfile.lastActiveDate,
      isPremium: userProfile.isPremium,
      isActive: userProfile.isActive,
      isDeleted: userProfile.isDeleted,
      createdAt: userProfile.createdAt,
      lastUpdated: userProfile.lastUpdated,
    );
  }

  /// Firestore'dan ProfileModel oluşturur
  factory ProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ProfileModel(
      uid: doc.id,
      name: data['name'] ?? data['displayName'] ?? '',
      username: data['username'],
      profileImageUrl: data['profileImageUrl'] ?? data['profilePhotoUrl'],
      bio: data['bio'],
      email: data['email'] ?? '',
      displayName: data['displayName'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
      joinDate: data['joinDate'] != null
          ? (data['joinDate'] as Timestamp).toDate()
          : null,
      lastActiveDate: data['lastActiveDate'] != null
          ? (data['lastActiveDate'] as Timestamp).toDate()
          : null,
      isPremium: data['isPremium'] ?? false,
      isActive: data['isActive'] ?? true,
      isDeleted: data['isDeleted'] ?? false,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      notificationSettings: Map<String, dynamic>.from(
        data['notificationSettings'] ?? {},
      ),
      readingSettings: Map<String, dynamic>.from(data['readingSettings'] ?? {}),
    );
  }

  /// Firestore'a kaydetmek için Map'e dönüştürür
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'profilePhotoUrl': profileImageUrl, // UserProfile uyumluluğu için
      'bio': bio,
      'email': email,
      'displayName': displayName,
      'joinDate': joinDate != null ? Timestamp.fromDate(joinDate!) : null,
      'lastActiveDate': lastActiveDate != null
          ? Timestamp.fromDate(lastActiveDate!)
          : null,
      'isPremium': isPremium,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'preferences': preferences,
      'notificationSettings': notificationSettings,
      'readingSettings': readingSettings,
    };
  }

  /// Profil verilerini günceller
  ProfileModel copyWith({
    String? uid,
    String? name,
    String? username,
    String? profileImageUrl,
    String? bio,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastUpdated,
    DateTime? joinDate,
    DateTime? lastActiveDate,
    bool? isPremium,
    bool? isActive,
    bool? isDeleted,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? notificationSettings,
    Map<String, dynamic>? readingSettings,
  }) {
    return ProfileModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? DateTime.now(),
      joinDate: joinDate ?? this.joinDate,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      isPremium: isPremium ?? this.isPremium,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      preferences: preferences ?? this.preferences,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      readingSettings: readingSettings ?? this.readingSettings,
    );
  }

  // MARK: - Reading Settings Getters

  /// Tema ayarını döndürür
  String get theme => readingSettings['theme'] ?? 'system';

  /// Yazı tipi ayarını döndürür
  String get fontFamily => readingSettings['fontFamily'] ?? 'sans';

  /// Yazı boyutu ayarını döndürür
  String get fontSize => readingSettings['fontSize'] ?? 'medium';

  /// Satır aralığı ayarını döndürür
  String get lineHeight => readingSettings['lineHeight'] ?? 'normal';

  /// Arka plan rengi ayarını döndürür
  String get backgroundColor => readingSettings['backgroundColor'] ?? 'default';

  // MARK: - Notification Settings Getters

  /// Yeni kitap bildirimi açık mı
  bool get newBookNotifications =>
      notificationSettings['newBookNotifications'] ?? true;

  /// Kampanya bildirimi açık mı
  bool get campaignNotifications =>
      notificationSettings['campaignNotifications'] ?? true;

  /// Günlük özet bildirimi açık mı
  bool get dailySummaryNotifications =>
      notificationSettings['dailySummaryNotifications'] ?? false;

  /// Referans bildirimi açık mı
  bool get referralNotifications =>
      notificationSettings['referralNotifications'] ?? true;

  // MARK: - Preferences Getters

  /// Dil ayarını döndürür
  String get language => preferences['language'] ?? 'tr';

  /// Ses efektleri açık mı
  bool get soundEffects => preferences['soundEffects'] ?? true;

  /// Haptic feedback açık mı
  bool get hapticFeedback => preferences['hapticFeedback'] ?? true;

  /// Otomatik kaydetme açık mı
  bool get autoSave => preferences['autoSave'] ?? true;

  // MARK: - UserProfile Uyumluluk Getters

  /// Görünen ad (displayName veya name)
  String get displayNameOrUsername => displayName ?? name;

  /// UserProfile uyumluluğu için userId
  String get userId => uid;

  /// UserProfile uyumluluğu için profilePhotoUrl
  String? get profilePhotoUrl => profileImageUrl;

  // MARK: - Reading Settings Setters

  /// Tema ayarını günceller
  ProfileModel updateTheme(String theme) {
    final updatedSettings = Map<String, dynamic>.from(readingSettings);
    updatedSettings['theme'] = theme;
    return copyWith(
      readingSettings: updatedSettings,
      lastUpdated: DateTime.now(),
    );
  }

  /// Yazı tipi ayarını günceller
  ProfileModel updateFontFamily(String fontFamily) {
    final updatedSettings = Map<String, dynamic>.from(readingSettings);
    updatedSettings['fontFamily'] = fontFamily;
    return copyWith(
      readingSettings: updatedSettings,
      lastUpdated: DateTime.now(),
    );
  }

  /// Yazı boyutu ayarını günceller
  ProfileModel updateFontSize(String fontSize) {
    final updatedSettings = Map<String, dynamic>.from(readingSettings);
    updatedSettings['fontSize'] = fontSize;
    return copyWith(
      readingSettings: updatedSettings,
      lastUpdated: DateTime.now(),
    );
  }

  /// Satır aralığı ayarını günceller
  ProfileModel updateLineHeight(String lineHeight) {
    final updatedSettings = Map<String, dynamic>.from(readingSettings);
    updatedSettings['lineHeight'] = lineHeight;
    return copyWith(
      readingSettings: updatedSettings,
      lastUpdated: DateTime.now(),
    );
  }

  // MARK: - Notification Settings Setters

  /// Bildirim ayarını günceller
  ProfileModel updateNotificationSetting(String key, bool value) {
    final updatedSettings = Map<String, dynamic>.from(notificationSettings);
    updatedSettings[key] = value;
    return copyWith(
      notificationSettings: updatedSettings,
      lastUpdated: DateTime.now(),
    );
  }

  // MARK: - Preferences Setters

  /// Tercih ayarını günceller
  ProfileModel updatePreference(String key, dynamic value) {
    final updatedPreferences = Map<String, dynamic>.from(preferences);
    updatedPreferences[key] = value;
    return copyWith(
      preferences: updatedPreferences,
      lastUpdated: DateTime.now(),
    );
  }

  // MARK: - Profile Info Setters

  /// Profil bilgilerini günceller
  ProfileModel updateProfileInfo({
    String? name,
    String? username,
    String? bio,
    String? profileImageUrl,
    String? displayName,
  }) {
    return copyWith(
      name: name,
      username: username,
      bio: bio,
      profileImageUrl: profileImageUrl,
      displayName: displayName,
      lastUpdated: DateTime.now(),
      lastActiveDate: DateTime.now(),
    );
  }

  // MARK: - Utility Methods

  /// Profil fotoğrafı var mı kontrol eder
  bool get hasProfileImage =>
      profileImageUrl != null && profileImageUrl!.isNotEmpty;

  /// Kullanıcı adı var mı kontrol eder
  bool get hasUsername => username != null && username!.isNotEmpty;

  /// Bio var mı kontrol eder
  bool get hasBio => bio != null && bio!.isNotEmpty;

  /// Profil fotoğrafı var mı? (UserProfile uyumluluğu)
  bool get hasProfilePhoto => hasProfileImage;

  /// Üyelik süresi (gün)
  int get membershipDays {
    final join = joinDate ?? createdAt;
    return DateTime.now().difference(join).inDays;
  }

  /// Son aktiflik (gün)
  int get lastActiveDays {
    final lastActive = lastActiveDate ?? DateTime.now();
    return DateTime.now().difference(lastActive).inDays;
  }

  /// Profil tamamlanma yüzdesini hesaplar
  double get profileCompletionPercentage {
    int completedFields = 1; // name her zaman var
    int totalFields = 4; // name, username, bio, profileImage

    if (hasUsername) completedFields++;
    if (hasBio) completedFields++;
    if (hasProfileImage) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  @override
  String toString() {
    return 'ProfileModel(uid: $uid, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
