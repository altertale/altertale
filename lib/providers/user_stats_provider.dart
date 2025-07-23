import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user_stats_model.dart';
import '../services/user_stats_service.dart';
import '../services/auth_service.dart';

class UserStatsProvider with ChangeNotifier {
  UserStatsModel? _userStats;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserStatsModel? get userStats => _userStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasStats => _userStats != null;

  // Quick access getters for UI
  int get totalBooksRead => _userStats?.totalBooksRead ?? 0;
  String get formattedReadingTime =>
      _userStats?.formattedReadingTime ?? '0 dakika';
  String get favoriteGenre => _userStats?.favoriteGenre ?? 'Henüz yok';
  int get currentStreak => _userStats?.currentStreak ?? 0;
  String get readingLevel => _userStats?.readingLevel ?? 'Yeni Başlayan';
  double get readingLevelProgress => _userStats?.readingLevelProgress ?? 0.0;
  int get thisMonthBooksRead => _userStats?.thisMonthBooksRead ?? 0;
  String get formattedAverageRating =>
      _userStats?.formattedAverageRating ?? 'Henüz yok';
  bool get hasReadToday => _userStats?.hasReadToday ?? false;
  String get streakStatusText => _userStats?.streakStatusText ?? 'Streak yok';

  /// Load user statistics
  Future<void> loadUserStats() async {
    final userId = AuthService().currentUser?.uid;
    if (userId == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userStats = await UserStatsService.getUserStats(userId);
    } catch (e) {
      _error = 'Error loading user stats: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stream user statistics for real-time updates
  Stream<UserStatsModel>? streamUserStats() {
    final userId = AuthService().currentUser?.uid;
    if (userId == null) return null;

    return UserStatsService.streamUserStats(userId).map((stats) {
      _userStats = stats;
      _error = null;

      // Notify listeners on next frame to avoid build issues
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      return stats;
    });
  }

  /// Record book completion
  Future<bool> recordBookCompletion({
    required String bookId,
    required String bookGenre,
    required int readingTimeMinutes,
  }) async {
    final userId = AuthService().currentUser?.uid;
    if (userId == null) return false;

    try {
      final success = await UserStatsService.recordBookCompletion(
        userId: userId,
        bookId: bookId,
        bookGenre: bookGenre,
        readingTimeMinutes: readingTimeMinutes,
      );

      if (success) {
        // Refresh stats
        await loadUserStats();
      }

      return success;
    } catch (e) {
      _error = 'Error recording book completion: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  /// Record reading session
  Future<bool> recordReadingSession(int sessionMinutes) async {
    final userId = AuthService().currentUser?.uid;
    if (userId == null) return false;

    try {
      final success = await UserStatsService.recordReadingSession(
        userId: userId,
        sessionMinutes: sessionMinutes,
      );

      if (success) {
        // Update local stats without full reload for better UX
        if (_userStats != null) {
          _userStats = _userStats!.copyWith(
            totalReadingTimeMinutes:
                _userStats!.totalReadingTimeMinutes + sessionMinutes,
            lastReadingDate: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      _error = 'Error recording reading session: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  /// Record user rating
  Future<bool> recordUserRating(double rating) async {
    final userId = AuthService().currentUser?.uid;
    if (userId == null) return false;

    try {
      final success = await UserStatsService.recordUserRating(
        userId: userId,
        rating: rating,
      );

      if (success) {
        // Update local stats
        if (_userStats != null) {
          final newTotalRatings = _userStats!.totalRatingsGiven + 1;
          final newAverageRating =
              ((_userStats!.averageRating * _userStats!.totalRatingsGiven) +
                  rating) /
              newTotalRatings;

          _userStats = _userStats!.copyWith(
            averageRating: newAverageRating,
            totalRatingsGiven: newTotalRatings,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      _error = 'Error recording user rating: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  /// Get statistics summary for quick display
  Future<Map<String, dynamic>> getStatsSummary() async {
    final userId = AuthService().currentUser?.uid;
    if (userId == null) {
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

    return await UserStatsService.getUserStatsSummary(userId);
  }

  /// Get achievement progress
  Map<String, dynamic> getAchievementProgress() {
    if (_userStats == null) {
      return {
        'nextMilestone': 'İlk kitabını oku',
        'progress': 0.0,
        'description': 'Okuma yolculuğuna başla!',
      };
    }

    final totalBooks = _userStats!.totalBooksRead;

    if (totalBooks < 5) {
      return {
        'nextMilestone': 'Okuyucu ol (5 kitap)',
        'progress': totalBooks / 5.0,
        'description': '${5 - totalBooks} kitap daha!',
      };
    } else if (totalBooks < 15) {
      return {
        'nextMilestone': 'Kitap Kurdu ol (15 kitap)',
        'progress': (totalBooks - 5) / 10.0,
        'description': '${15 - totalBooks} kitap daha!',
      };
    } else if (totalBooks < 30) {
      return {
        'nextMilestone': 'Kitap Aşığı ol (30 kitap)',
        'progress': (totalBooks - 15) / 15.0,
        'description': '${30 - totalBooks} kitap daha!',
      };
    } else if (totalBooks < 50) {
      return {
        'nextMilestone': 'Okuma Uzmanı ol (50 kitap)',
        'progress': (totalBooks - 30) / 20.0,
        'description': '${50 - totalBooks} kitap daha!',
      };
    } else if (totalBooks < 100) {
      return {
        'nextMilestone': 'Kitap Efendisi ol (100 kitap)',
        'progress': (totalBooks - 50) / 50.0,
        'description': '${100 - totalBooks} kitap daha!',
      };
    } else {
      return {
        'nextMilestone': 'Okuma Efsanesi!',
        'progress': 1.0,
        'description': 'Tebrikler! En üst seviyeye ulaştın! 🏆',
      };
    }
  }

  /// Clear stats (for logout)
  void clearStats() {
    _userStats = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Refresh stats
  Future<void> refreshStats() async {
    await loadUserStats();
  }

  /// Helper method to create minimal book model
  dynamic _createMinimalBookModel(String bookId, String genre) {
    // This is a placeholder - in real implementation you'd use the actual BookModel
    return {'id': bookId, 'genre': genre};
  }
}
