import 'package:cloud_firestore/cloud_firestore.dart';

/// Kullanıcı istatistikleri modeli
class UserStats {
  final String userId;
  final int totalBooksRead;
  final int totalReadingTime; // dakika cinsinden
  final int totalBooksPurchased;
  final int totalBooksFavorited;
  final int totalPointsEarned;
  final int totalPointsSpent;
  final double averageBookCompletionTime; // saat cinsinden
  final String mostReadCategory;
  final int mostReadCategoryTime; // dakika cinsinden
  final DateTime lastReadingDate;
  final DateTime createdAt;
  final DateTime lastUpdated;

  const UserStats({
    required this.userId,
    this.totalBooksRead = 0,
    this.totalReadingTime = 0,
    this.totalBooksPurchased = 0,
    this.totalBooksFavorited = 0,
    this.totalPointsEarned = 0,
    this.totalPointsSpent = 0,
    this.averageBookCompletionTime = 0.0,
    this.mostReadCategory = '',
    this.mostReadCategoryTime = 0,
    required this.lastReadingDate,
    required this.createdAt,
    required this.lastUpdated,
  });

  /// Varsayılan istatistikler
  factory UserStats.defaultStats(String userId) {
    final now = DateTime.now();
    return UserStats(
      userId: userId,
      lastReadingDate: now,
      createdAt: now,
      lastUpdated: now,
    );
  }

  /// Firestore'dan model oluştur
  factory UserStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserStats(
      userId: doc.id,
      totalBooksRead: data['totalBooksRead'] ?? 0,
      totalReadingTime: data['totalReadingTime'] ?? 0,
      totalBooksPurchased: data['totalBooksPurchased'] ?? 0,
      totalBooksFavorited: data['totalBooksFavorited'] ?? 0,
      totalPointsEarned: data['totalPointsEarned'] ?? 0,
      totalPointsSpent: data['totalPointsSpent'] ?? 0,
      averageBookCompletionTime: (data['averageBookCompletionTime'] ?? 0.0).toDouble(),
      mostReadCategory: data['mostReadCategory'] ?? '',
      mostReadCategoryTime: data['mostReadCategoryTime'] ?? 0,
      lastReadingDate: (data['lastReadingDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'totalBooksRead': totalBooksRead,
      'totalReadingTime': totalReadingTime,
      'totalBooksPurchased': totalBooksPurchased,
      'totalBooksFavorited': totalBooksFavorited,
      'totalPointsEarned': totalPointsEarned,
      'totalPointsSpent': totalPointsSpent,
      'averageBookCompletionTime': averageBookCompletionTime,
      'mostReadCategory': mostReadCategory,
      'mostReadCategoryTime': mostReadCategoryTime,
      'lastReadingDate': Timestamp.fromDate(lastReadingDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// İstatistikleri güncelle
  UserStats copyWith({
    int? totalBooksRead,
    int? totalReadingTime,
    int? totalBooksPurchased,
    int? totalBooksFavorited,
    int? totalPointsEarned,
    int? totalPointsSpent,
    double? averageBookCompletionTime,
    String? mostReadCategory,
    int? mostReadCategoryTime,
    DateTime? lastReadingDate,
  }) {
    return UserStats(
      userId: userId,
      totalBooksRead: totalBooksRead ?? this.totalBooksRead,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      totalBooksPurchased: totalBooksPurchased ?? this.totalBooksPurchased,
      totalBooksFavorited: totalBooksFavorited ?? this.totalBooksFavorited,
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
      totalPointsSpent: totalPointsSpent ?? this.totalPointsSpent,
      averageBookCompletionTime: averageBookCompletionTime ?? this.averageBookCompletionTime,
      mostReadCategory: mostReadCategory ?? this.mostReadCategory,
      mostReadCategoryTime: mostReadCategoryTime ?? this.mostReadCategoryTime,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      createdAt: createdAt,
      lastUpdated: DateTime.now(),
    );
  }

  /// Toplam okuma süresini saat olarak al
  double get totalReadingTimeInHours => totalReadingTime / 60.0;

  /// Toplam okuma süresini gün olarak al
  double get totalReadingTimeInDays => totalReadingTime / (60.0 * 24.0);

  /// Mevcut puan bakiyesi
  int get currentPointsBalance => totalPointsEarned - totalPointsSpent;

  /// Okuma hızı (dakika/kitap)
  double get readingSpeed {
    if (totalBooksRead == 0) return 0.0;
    return totalReadingTime / totalBooksRead;
  }

  /// Günlük ortalama okuma süresi (dakika)
  double get dailyAverageReadingTime {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    if (daysSinceCreation == 0) return totalReadingTime.toDouble();
    return totalReadingTime / daysSinceCreation;
  }

  /// Haftalık ortalama okuma süresi (dakika)
  double get weeklyAverageReadingTime {
    final weeksSinceCreation = DateTime.now().difference(createdAt).inDays / 7;
    if (weeksSinceCreation == 0) return totalReadingTime.toDouble();
    return totalReadingTime / weeksSinceCreation;
  }

  /// Aylık ortalama okuma süresi (dakika)
  double get monthlyAverageReadingTime {
    final monthsSinceCreation = DateTime.now().difference(createdAt).inDays / 30;
    if (monthsSinceCreation == 0) return totalReadingTime.toDouble();
    return totalReadingTime / monthsSinceCreation;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStats &&
        other.userId == userId &&
        other.totalBooksRead == totalBooksRead &&
        other.totalReadingTime == totalReadingTime &&
        other.totalBooksPurchased == totalBooksPurchased &&
        other.totalBooksFavorited == totalBooksFavorited &&
        other.totalPointsEarned == totalPointsEarned &&
        other.totalPointsSpent == totalPointsSpent &&
        other.averageBookCompletionTime == averageBookCompletionTime &&
        other.mostReadCategory == mostReadCategory &&
        other.mostReadCategoryTime == mostReadCategoryTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      totalBooksRead,
      totalReadingTime,
      totalBooksPurchased,
      totalBooksFavorited,
      totalPointsEarned,
      totalPointsSpent,
      averageBookCompletionTime,
      mostReadCategory,
      mostReadCategoryTime,
    );
  }

  @override
  String toString() {
    return 'UserStats('
        'userId: $userId, '
        'totalBooksRead: $totalBooksRead, '
        'totalReadingTime: $totalReadingTime, '
        'totalBooksPurchased: $totalBooksPurchased, '
        'totalBooksFavorited: $totalBooksFavorited, '
        'totalPointsEarned: $totalPointsEarned, '
        'totalPointsSpent: $totalPointsSpent, '
        'averageBookCompletionTime: $averageBookCompletionTime, '
        'mostReadCategory: $mostReadCategory, '
        'mostReadCategoryTime: $mostReadCategoryTime)';
  }
}

/// Günlük aktivite modeli
class DailyActivity {
  final DateTime date;
  final int readingTime; // dakika cinsinden
  final int booksRead;
  final int pagesRead;

  const DailyActivity({
    required this.date,
    this.readingTime = 0,
    this.booksRead = 0,
    this.pagesRead = 0,
  });

  /// Firestore'dan model oluştur
  factory DailyActivity.fromFirestore(Map<String, dynamic> data) {
    return DailyActivity(
      date: (data['date'] as Timestamp).toDate(),
      readingTime: data['readingTime'] ?? 0,
      booksRead: data['booksRead'] ?? 0,
      pagesRead: data['pagesRead'] ?? 0,
    );
  }

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'readingTime': readingTime,
      'booksRead': booksRead,
      'pagesRead': pagesRead,
    };
  }

  /// Günlük aktiviteyi güncelle
  DailyActivity copyWith({
    int? readingTime,
    int? booksRead,
    int? pagesRead,
  }) {
    return DailyActivity(
      date: date,
      readingTime: readingTime ?? this.readingTime,
      booksRead: booksRead ?? this.booksRead,
      pagesRead: pagesRead ?? this.pagesRead,
    );
  }

  /// Okuma süresini saat olarak al
  double get readingTimeInHours => readingTime / 60.0;

  /// Aktif gün mü?
  bool get isActive => readingTime > 0 || booksRead > 0 || pagesRead > 0;
}

/// Aylık okuma süresi modeli
class MonthlyReadingTime {
  final int year;
  final int month;
  final int totalReadingTime; // dakika cinsinden
  final int totalBooksRead;
  final int totalPagesRead;

  const MonthlyReadingTime({
    required this.year,
    required this.month,
    this.totalReadingTime = 0,
    this.totalBooksRead = 0,
    this.totalPagesRead = 0,
  });

  /// Firestore'dan model oluştur
  factory MonthlyReadingTime.fromFirestore(Map<String, dynamic> data) {
    return MonthlyReadingTime(
      year: data['year'] ?? 0,
      month: data['month'] ?? 0,
      totalReadingTime: data['totalReadingTime'] ?? 0,
      totalBooksRead: data['totalBooksRead'] ?? 0,
      totalPagesRead: data['totalPagesRead'] ?? 0,
    );
  }

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'year': year,
      'month': month,
      'totalReadingTime': totalReadingTime,
      'totalBooksRead': totalBooksRead,
      'totalPagesRead': totalPagesRead,
    };
  }

  /// Aylık okuma süresini güncelle
  MonthlyReadingTime copyWith({
    int? totalReadingTime,
    int? totalBooksRead,
    int? totalPagesRead,
  }) {
    return MonthlyReadingTime(
      year: year,
      month: month,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      totalBooksRead: totalBooksRead ?? this.totalBooksRead,
      totalPagesRead: totalPagesRead ?? this.totalPagesRead,
    );
  }

  /// Okuma süresini saat olarak al
  double get totalReadingTimeInHours => totalReadingTime / 60.0;

  /// Ay adını al
  String get monthName {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }

  /// Tarih formatı
  String get formattedDate => '$monthName $year';
}
