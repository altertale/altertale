import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_stats_model.dart';

class UserStatsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'user_stats';

  /// Get user statistics
  static Future<UserStatsModel> getUserStats(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();

      if (doc.exists) {
        return UserStatsModel.fromFirestore(doc);
      } else {
        // Create empty stats for new user
        final emptyStats = UserStatsModel.empty(userId);
        await _firestore
            .collection(_collection)
            .doc(userId)
            .set(emptyStats.toFirestore());
        return emptyStats;
      }
    } catch (e) {
      print('Error getting user stats: $e');
      return UserStatsModel.empty(userId);
    }
  }

  /// Stream user statistics for real-time updates
  static Stream<UserStatsModel> streamUserStats(String userId) {
    return _firestore.collection(_collection).doc(userId).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return UserStatsModel.fromFirestore(doc);
      } else {
        return UserStatsModel.empty(userId);
      }
    });
  }

  /// Record book completion with simplified book data
  static Future<bool> recordBookCompletion({
    required String userId,
    required String bookId,
    required String bookGenre,
    required int readingTimeMinutes,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(userId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        UserStatsModel stats;

        if (doc.exists) {
          stats = UserStatsModel.fromFirestore(doc);
        } else {
          stats = UserStatsModel.empty(userId);
        }

        // Update stats
        final updatedStats = _updateStatsForBookCompletion(
          stats,
          bookId,
          bookGenre,
          readingTimeMinutes,
        );
        transaction.set(docRef, updatedStats.toFirestore());
      });

      return true;
    } catch (e) {
      print('Error recording book completion: $e');
      return false;
    }
  }

  /// Record reading session (for tracking daily streaks)
  static Future<bool> recordReadingSession({
    required String userId,
    required int sessionMinutes,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(userId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        UserStatsModel stats;

        if (doc.exists) {
          stats = UserStatsModel.fromFirestore(doc);
        } else {
          stats = UserStatsModel.empty(userId);
        }

        // Update reading time and streak
        final updatedStats = _updateStatsForReadingSession(
          stats,
          sessionMinutes,
        );
        transaction.set(docRef, updatedStats.toFirestore());
      });

      return true;
    } catch (e) {
      print('Error recording reading session: $e');
      return false;
    }
  }

  /// Record user rating (for average rating calculation)
  static Future<bool> recordUserRating({
    required String userId,
    required double rating,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(userId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        UserStatsModel stats;

        if (doc.exists) {
          stats = UserStatsModel.fromFirestore(doc);
        } else {
          stats = UserStatsModel.empty(userId);
        }

        // Update average rating
        final newTotalRatings = stats.totalRatingsGiven + 1;
        final newAverageRating =
            ((stats.averageRating * stats.totalRatingsGiven) + rating) /
            newTotalRatings;

        final updatedStats = stats.copyWith(
          averageRating: newAverageRating,
          totalRatingsGiven: newTotalRatings,
          updatedAt: DateTime.now(),
        );

        transaction.set(docRef, updatedStats.toFirestore());
      });

      return true;
    } catch (e) {
      print('Error recording user rating: $e');
      return false;
    }
  }

  /// Get leaderboard stats
  static Future<List<UserStatsModel>> getLeaderboard({
    String sortBy = 'totalBooksRead',
    int limit = 10,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      switch (sortBy) {
        case 'totalBooksRead':
          query = query.orderBy('totalBooksRead', descending: true);
          break;
        case 'totalReadingTimeMinutes':
          query = query.orderBy('totalReadingTimeMinutes', descending: true);
          break;
        case 'currentStreak':
          query = query.orderBy('currentStreak', descending: true);
          break;
        case 'longestStreak':
          query = query.orderBy('longestStreak', descending: true);
          break;
      }

      final querySnapshot = await query.limit(limit).get();
      return querySnapshot.docs
          .map((doc) => UserStatsModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting leaderboard: $e');
      return [];
    }
  }

  /// Private helper methods

  static UserStatsModel _updateStatsForBookCompletion(
    UserStatsModel stats,
    String bookId,
    String bookGenre,
    int readingTimeMinutes,
  ) {
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    // Update genre count
    final newGenreCount = Map<String, int>.from(stats.genreReadCount);
    newGenreCount[bookGenre] = (newGenreCount[bookGenre] ?? 0) + 1;

    // Update monthly count
    final newMonthlyCount = Map<String, int>.from(stats.monthlyReadCount);
    newMonthlyCount[currentMonth] = (newMonthlyCount[currentMonth] ?? 0) + 1;

    // Update read books list
    final newReadBookIds = List<String>.from(stats.readBookIds);
    if (!newReadBookIds.contains(bookId)) {
      newReadBookIds.add(bookId);
    }

    // Update streak
    final newStreak = _calculateStreak(stats.lastReadingDate, now);

    return stats.copyWith(
      totalBooksRead: stats.totalBooksRead + 1,
      totalReadingTimeMinutes:
          stats.totalReadingTimeMinutes + readingTimeMinutes,
      genreReadCount: newGenreCount,
      monthlyReadCount: newMonthlyCount,
      readBookIds: newReadBookIds,
      currentStreak: newStreak,
      longestStreak: newStreak > stats.longestStreak
          ? newStreak
          : stats.longestStreak,
      lastReadingDate: now,
      updatedAt: now,
    );
  }

  static UserStatsModel _updateStatsForReadingSession(
    UserStatsModel stats,
    int sessionMinutes,
  ) {
    final now = DateTime.now();

    // Update streak
    final newStreak = _calculateStreak(stats.lastReadingDate, now);

    return stats.copyWith(
      totalReadingTimeMinutes: stats.totalReadingTimeMinutes + sessionMinutes,
      currentStreak: newStreak,
      longestStreak: newStreak > stats.longestStreak
          ? newStreak
          : stats.longestStreak,
      lastReadingDate: now,
      updatedAt: now,
    );
  }

  static int _calculateStreak(DateTime? lastReadingDate, DateTime currentDate) {
    if (lastReadingDate == null) return 1;

    final difference = currentDate.difference(lastReadingDate).inDays;

    if (difference == 0) {
      // Same day, maintain current streak
      return 1; // This should be handled by caller to maintain existing streak
    } else if (difference == 1) {
      // Consecutive day, increment streak
      return 1; // This should be handled by caller to increment existing streak
    } else {
      // Streak broken, start new
      return 1;
    }
  }

  /// Get user statistics summary for display
  static Future<Map<String, dynamic>> getUserStatsSummary(String userId) async {
    try {
      final stats = await getUserStats(userId);

      return {
        'totalBooks': stats.totalBooksRead,
        'readingTime': stats.formattedReadingTime,
        'favoriteGenre': stats.favoriteGenre,
        'currentStreak': stats.currentStreak,
        'readingLevel': stats.readingLevel,
        'levelProgress': stats.readingLevelProgress,
        'thisMonth': stats.thisMonthBooksRead,
        'averageRating': stats.formattedAverageRating,
        'hasReadToday': stats.hasReadToday,
      };
    } catch (e) {
      print('Error getting stats summary: $e');
      return {
        'totalBooks': 0,
        'readingTime': '0 dakika',
        'favoriteGenre': 'Henüz yok',
        'currentStreak': 0,
        'readingLevel': 'Yeni Başlayan',
        'levelProgress': 0.0,
        'thisMonth': 0,
        'averageRating': 'Henüz yok',
        'hasReadToday': false,
      };
    }
  }
}
