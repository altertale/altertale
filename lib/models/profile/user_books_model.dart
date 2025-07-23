import 'package:cloud_firestore/cloud_firestore.dart';

/// Kitap durumu
enum BookStatus {
  reading('Okunuyor'),
  completed('Tamamlandı'),
  paused('Duraklatıldı'),
  abandoned('Bırakıldı');

  const BookStatus(this.displayName);
  final String displayName;
}

/// Kitap satın alma durumu
enum PurchaseType {
  points('Puan ile'),
  free('Ücretsiz'),
  premium('Premium');

  const PurchaseType(this.displayName);
  final String displayName;
}

/// Kullanıcı kitap modeli
class UserBook {
  final String id;
  final String userId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookCoverUrl;
  final BookStatus status;
  final PurchaseType purchaseType;
  final int? pointsSpent;
  final DateTime purchaseDate;
  final DateTime? startReadingDate;
  final DateTime? completedDate;
  final int currentPage;
  final int totalPages;
  final int readingTime; // dakika cinsinden
  final double? rating;
  final String? review;
  final bool isFavorite;
  final DateTime lastReadDate;
  final DateTime createdAt;
  final DateTime lastUpdated;

  const UserBook({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    this.bookCoverUrl,
    this.status = BookStatus.reading,
    this.purchaseType = PurchaseType.points,
    this.pointsSpent,
    required this.purchaseDate,
    this.startReadingDate,
    this.completedDate,
    this.currentPage = 0,
    this.totalPages = 0,
    this.readingTime = 0,
    this.rating,
    this.review,
    this.isFavorite = false,
    required this.lastReadDate,
    required this.createdAt,
    required this.lastUpdated,
  });

  /// Firestore'dan model oluştur
  factory UserBook.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserBook(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      bookAuthor: data['bookAuthor'] ?? '',
      bookCoverUrl: data['bookCoverUrl'],
      status: BookStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'reading'),
        orElse: () => BookStatus.reading,
      ),
      purchaseType: PurchaseType.values.firstWhere(
        (e) => e.name == (data['purchaseType'] ?? 'points'),
        orElse: () => PurchaseType.points,
      ),
      pointsSpent: data['pointsSpent'],
      purchaseDate: (data['purchaseDate'] as Timestamp).toDate(),
      startReadingDate: data['startReadingDate'] != null 
          ? (data['startReadingDate'] as Timestamp).toDate() 
          : null,
      completedDate: data['completedDate'] != null 
          ? (data['completedDate'] as Timestamp).toDate() 
          : null,
      currentPage: data['currentPage'] ?? 0,
      totalPages: data['totalPages'] ?? 0,
      readingTime: data['readingTime'] ?? 0,
      rating: data['rating'] != null ? (data['rating'] as num).toDouble() : null,
      review: data['review'],
      isFavorite: data['isFavorite'] ?? false,
      lastReadDate: (data['lastReadDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookCoverUrl': bookCoverUrl,
      'status': status.name,
      'purchaseType': purchaseType.name,
      'pointsSpent': pointsSpent,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'startReadingDate': startReadingDate != null 
          ? Timestamp.fromDate(startReadingDate!) 
          : null,
      'completedDate': completedDate != null 
          ? Timestamp.fromDate(completedDate!) 
          : null,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'readingTime': readingTime,
      'rating': rating,
      'review': review,
      'isFavorite': isFavorite,
      'lastReadDate': Timestamp.fromDate(lastReadDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Kitabı güncelle
  UserBook copyWith({
    BookStatus? status,
    int? currentPage,
    int? readingTime,
    double? rating,
    String? review,
    bool? isFavorite,
    DateTime? lastReadDate,
    DateTime? startReadingDate,
    DateTime? completedDate,
  }) {
    return UserBook(
      id: id,
      userId: userId,
      bookId: bookId,
      bookTitle: bookTitle,
      bookAuthor: bookAuthor,
      bookCoverUrl: bookCoverUrl,
      status: status ?? this.status,
      purchaseType: purchaseType,
      pointsSpent: pointsSpent,
      purchaseDate: purchaseDate,
      startReadingDate: startReadingDate ?? this.startReadingDate,
      completedDate: completedDate ?? this.completedDate,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages,
      readingTime: readingTime ?? this.readingTime,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      isFavorite: isFavorite ?? this.isFavorite,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      createdAt: createdAt,
      lastUpdated: DateTime.now(),
    );
  }

  /// Okuma yüzdesi
  double get readingProgress {
    if (totalPages == 0) return 0.0;
    return (currentPage / totalPages) * 100;
  }

  /// Kitap tamamlandı mı?
  bool get isCompleted => status == BookStatus.completed;

  /// Kitap okunuyor mu?
  bool get isReading => status == BookStatus.reading;

  /// Kitap duraklatıldı mı?
  bool get isPaused => status == BookStatus.paused;

  /// Kitap bırakıldı mı?
  bool get isAbandoned => status == BookStatus.abandoned;

  /// Okuma süresini saat olarak al
  double get readingTimeInHours => readingTime / 60.0;

  /// Tamamlanma süresi (gün)
  int? get completionTimeInDays {
    if (startReadingDate == null || completedDate == null) return null;
    return completedDate!.difference(startReadingDate!).inDays;
  }

  /// Günlük ortalama okuma süresi (dakika)
  double? get dailyAverageReadingTime {
    if (startReadingDate == null) return null;
    final daysSinceStart = DateTime.now().difference(startReadingDate!).inDays;
    if (daysSinceStart == 0) return readingTime.toDouble();
    return readingTime / daysSinceStart;
  }

  /// Kalan sayfa sayısı
  int get remainingPages => totalPages - currentPage;

  /// Tahmini kalan okuma süresi (dakika)
  double? get estimatedRemainingTime {
    if (currentPage == 0 || readingTime == 0) return null;
    final pagesPerMinute = readingTime / currentPage;
    return remainingPages * pagesPerMinute;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserBook &&
        other.id == id &&
        other.userId == userId &&
        other.bookId == bookId &&
        other.status == status &&
        other.currentPage == currentPage &&
        other.readingTime == readingTime &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      bookId,
      status,
      currentPage,
      readingTime,
      isFavorite,
    );
  }

  @override
  String toString() {
    return 'UserBook('
        'id: $id, '
        'bookTitle: $bookTitle, '
        'status: $status, '
        'currentPage: $currentPage/$totalPages, '
        'readingTime: $readingTime, '
        'isFavorite: $isFavorite)';
  }
}

/// Kullanıcı profil modeli
class UserProfile {
  final String userId;
  final String username;
  final String email;
  final String? displayName;
  final String? bio;
  final String? profilePhotoUrl;
  final DateTime joinDate;
  final DateTime lastActiveDate;
  final bool isPremium;
  final bool isActive;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime lastUpdated;

  const UserProfile({
    required this.userId,
    required this.username,
    required this.email,
    this.displayName,
    this.bio,
    this.profilePhotoUrl,
    required this.joinDate,
    required this.lastActiveDate,
    this.isPremium = false,
    this.isActive = true,
    this.isDeleted = false,
    required this.createdAt,
    required this.lastUpdated,
  });

  /// Varsayılan profil
  factory UserProfile.defaultProfile(String userId, String username, String email) {
    final now = DateTime.now();
    return UserProfile(
      userId: userId,
      username: username,
      email: email,
      joinDate: now,
      lastActiveDate: now,
      createdAt: now,
      lastUpdated: now,
    );
  }

  /// Firestore'dan model oluştur
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      userId: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      bio: data['bio'],
      profilePhotoUrl: data['profilePhotoUrl'],
      joinDate: (data['joinDate'] as Timestamp).toDate(),
      lastActiveDate: (data['lastActiveDate'] as Timestamp).toDate(),
      isPremium: data['isPremium'] ?? false,
      isActive: data['isActive'] ?? true,
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'joinDate': Timestamp.fromDate(joinDate),
      'lastActiveDate': Timestamp.fromDate(lastActiveDate),
      'isPremium': isPremium,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Profili güncelle
  UserProfile copyWith({
    String? username,
    String? displayName,
    String? bio,
    String? profilePhotoUrl,
    DateTime? lastActiveDate,
    bool? isPremium,
    bool? isActive,
    bool? isDeleted,
  }) {
    return UserProfile(
      userId: userId,
      username: username ?? this.username,
      email: email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      joinDate: joinDate,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      isPremium: isPremium ?? this.isPremium,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt,
      lastUpdated: DateTime.now(),
    );
  }

  /// Görünen ad
  String get displayNameOrUsername => displayName ?? username;

  /// Bio var mı?
  bool get hasBio => bio != null && bio!.isNotEmpty;

  /// Profil fotoğrafı var mı?
  bool get hasProfilePhoto => profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty;

  /// Üyelik süresi (gün)
  int get membershipDays => DateTime.now().difference(joinDate).inDays;

  /// Son aktiflik (gün)
  int get lastActiveDays => DateTime.now().difference(lastActiveDate).inDays;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.userId == userId &&
        other.username == username &&
        other.email == email &&
        other.displayName == displayName &&
        other.bio == bio &&
        other.profilePhotoUrl == profilePhotoUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      username,
      email,
      displayName,
      bio,
      profilePhotoUrl,
    );
  }

  @override
  String toString() {
    return 'UserProfile('
        'userId: $userId, '
        'username: $username, '
        'email: $email, '
        'displayName: $displayName, '
        'bio: $bio)';
  }
}
