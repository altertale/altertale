import 'package:cloud_firestore/cloud_firestore.dart';

/// User reading statistics model
class UserStatsModel {
  final String userId;
  final int totalBooksRead;
  final int totalReadingTimeMinutes;
  final Map<String, int> genreReadCount; // genre -> book count
  final Map<String, int> monthlyReadCount; // "2025-01" -> book count
  final List<String> readBookIds;
  final int currentStreak; // consecutive days reading
  final int longestStreak;
  final DateTime? lastReadingDate;
  final double averageRating; // average rating given by user
  final int totalRatingsGiven;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserStatsModel({
    required this.userId,
    required this.totalBooksRead,
    required this.totalReadingTimeMinutes,
    required this.genreReadCount,
    required this.monthlyReadCount,
    required this.readBookIds,
    required this.currentStreak,
    required this.longestStreak,
    this.lastReadingDate,
    required this.averageRating,
    required this.totalRatingsGiven,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create empty stats for new user
  factory UserStatsModel.empty(String userId) {
    final now = DateTime.now();
    return UserStatsModel(
      userId: userId,
      totalBooksRead: 0,
      totalReadingTimeMinutes: 0,
      genreReadCount: {},
      monthlyReadCount: {},
      readBookIds: [],
      currentStreak: 0,
      longestStreak: 0,
      lastReadingDate: null,
      averageRating: 0.0,
      totalRatingsGiven: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create from Firestore document
  factory UserStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserStatsModel(
      userId: doc.id,
      totalBooksRead: data['totalBooksRead'] ?? 0,
      totalReadingTimeMinutes: data['totalReadingTimeMinutes'] ?? 0,
      genreReadCount: Map<String, int>.from(data['genreReadCount'] ?? {}),
      monthlyReadCount: Map<String, int>.from(data['monthlyReadCount'] ?? {}),
      readBookIds: List<String>.from(data['readBookIds'] ?? []),
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastReadingDate: (data['lastReadingDate'] as Timestamp?)?.toDate(),
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      totalRatingsGiven: data['totalRatingsGiven'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'totalBooksRead': totalBooksRead,
      'totalReadingTimeMinutes': totalReadingTimeMinutes,
      'genreReadCount': genreReadCount,
      'monthlyReadCount': monthlyReadCount,
      'readBookIds': readBookIds,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastReadingDate': lastReadingDate != null
          ? Timestamp.fromDate(lastReadingDate!)
          : null,
      'averageRating': averageRating,
      'totalRatingsGiven': totalRatingsGiven,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Copy with new values
  UserStatsModel copyWith({
    String? userId,
    int? totalBooksRead,
    int? totalReadingTimeMinutes,
    Map<String, int>? genreReadCount,
    Map<String, int>? monthlyReadCount,
    List<String>? readBookIds,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReadingDate,
    double? averageRating,
    int? totalRatingsGiven,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserStatsModel(
      userId: userId ?? this.userId,
      totalBooksRead: totalBooksRead ?? this.totalBooksRead,
      totalReadingTimeMinutes:
          totalReadingTimeMinutes ?? this.totalReadingTimeMinutes,
      genreReadCount: genreReadCount ?? this.genreReadCount,
      monthlyReadCount: monthlyReadCount ?? this.monthlyReadCount,
      readBookIds: readBookIds ?? this.readBookIds,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReadingDate: lastReadingDate ?? this.lastReadingDate,
      averageRating: averageRating ?? this.averageRating,
      totalRatingsGiven: totalRatingsGiven ?? this.totalRatingsGiven,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Computed properties for display

  /// Format total reading time as human readable
  String get formattedReadingTime {
    if (totalReadingTimeMinutes < 60) {
      return '$totalReadingTimeMinutes dakika';
    } else if (totalReadingTimeMinutes < 1440) {
      // less than 24 hours
      final hours = totalReadingTimeMinutes ~/ 60;
      final minutes = totalReadingTimeMinutes % 60;
      return '${hours}sa ${minutes}dk';
    } else {
      final days = totalReadingTimeMinutes ~/ 1440;
      final hours = (totalReadingTimeMinutes % 1440) ~/ 60;
      return '${days}g ${hours}sa';
    }
  }

  /// Get most read genre
  String get favoriteGenre {
    if (genreReadCount.isEmpty) return 'Henüz yok';

    var maxEntry = genreReadCount.entries.first;
    for (var entry in genreReadCount.entries) {
      if (entry.value > maxEntry.value) {
        maxEntry = entry;
      }
    }
    return maxEntry.key;
  }

  /// Get reading level based on books read
  String get readingLevel {
    if (totalBooksRead == 0) return 'Yeni Başlayan';
    if (totalBooksRead < 5) return 'Okuyucu';
    if (totalBooksRead < 15) return 'Kitap Kurdu';
    if (totalBooksRead < 30) return 'Kitap Aşığı';
    if (totalBooksRead < 50) return 'Okuma Uzmanı';
    if (totalBooksRead < 100) return 'Kitap Efendisi';
    return 'Okuma Efsanesi';
  }

  /// Get reading level progress (0.0 to 1.0)
  double get readingLevelProgress {
    if (totalBooksRead == 0) return 0.0;
    if (totalBooksRead < 5) return totalBooksRead / 5.0;
    if (totalBooksRead < 15) return (totalBooksRead - 5) / 10.0;
    if (totalBooksRead < 30) return (totalBooksRead - 15) / 15.0;
    if (totalBooksRead < 50) return (totalBooksRead - 30) / 20.0;
    if (totalBooksRead < 100) return (totalBooksRead - 50) / 50.0;
    return 1.0;
  }

  /// Get current month reading count
  int get thisMonthBooksRead {
    final currentMonth =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    return monthlyReadCount[currentMonth] ?? 0;
  }

  /// Check if user read today
  bool get hasReadToday {
    if (lastReadingDate == null) return false;
    final today = DateTime.now();
    final lastRead = lastReadingDate!;
    return lastRead.year == today.year &&
        lastRead.month == today.month &&
        lastRead.day == today.day;
  }

  /// Get average reading rating given (formatted)
  String get formattedAverageRating {
    if (totalRatingsGiven == 0) return 'Henüz yok';
    return '${averageRating.toStringAsFixed(1)} ⭐';
  }

  /// Get streak status text
  String get streakStatusText {
    if (currentStreak == 0) return 'Streak yok';
    if (currentStreak == 1) return '1 günlük streak!';
    return '$currentStreak günlük streak! 🔥';
  }

  @override
  String toString() {
    return 'UserStatsModel(userId: $userId, booksRead: $totalBooksRead, readingTime: $formattedReadingTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStatsModel && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
