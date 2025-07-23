import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reading Progress Model
class ReadingProgress {
  final String id;
  final String userId;
  final String bookId;
  final int currentPage;
  final int totalPages;
  final double percentRead;
  final DateTime lastReadAt;
  final DateTime updatedAt;

  ReadingProgress({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.currentPage,
    required this.totalPages,
    required this.percentRead,
    required this.lastReadAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookId': bookId,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'percentRead': percentRead,
      'lastReadAt': lastReadAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ReadingProgress.fromMap(Map<String, dynamic> map) {
    return ReadingProgress(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      bookId: map['bookId'] ?? '',
      currentPage: map['currentPage'] ?? 0,
      totalPages: map['totalPages'] ?? 0,
      percentRead: (map['percentRead'] ?? 0.0).toDouble(),
      lastReadAt: DateTime.fromMillisecondsSinceEpoch(map['lastReadAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }
}

/// Reading Progress Service
///
/// Manages user reading progress for books including:
/// - Current page tracking
/// - Reading percentage
/// - Last read timestamp
/// - Cross-device synchronization
class ReadingProgressService {
  static final ReadingProgressService _instance =
      ReadingProgressService._internal();
  factory ReadingProgressService() => _instance;
  ReadingProgressService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _progressCollection = 'readingProgress';

  // Demo mode for testing
  bool get isDemoMode => true;

  // In-memory storage for demo progress
  static final Map<String, ReadingProgress> _demoProgress = {};

  // ==================== PROGRESS MANAGEMENT ====================

  /// Get reading progress for a specific book
  Future<ReadingProgress?> getReadingProgress({
    required String userId,
    required String bookId,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '📖 ReadingProgressService: Getting progress for user: $userId, book: $bookId',
        );
      }

      if (isDemoMode) {
        await _loadDemoProgress(userId, bookId);
        final progressKey = '${userId}_$bookId';
        final progress = _demoProgress[progressKey];

        if (kDebugMode && progress != null) {
          print(
            '📖 ReadingProgressService: Found progress - Page: ${progress.currentPage}/${progress.totalPages}',
          );
        }

        return progress;
      }

      // Firestore implementation
      final doc = await _firestore
          .collection(_progressCollection)
          .doc('${userId}_$bookId')
          .get();

      if (!doc.exists) {
        if (kDebugMode) {
          print('📖 ReadingProgressService: No progress found');
        }
        return null;
      }

      final progress = ReadingProgress.fromMap(doc.data()!);

      if (kDebugMode) {
        print('📖 ReadingProgressService: Loaded progress from Firestore');
      }

      return progress;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReadingProgressService: Error getting progress: $e');
      }
      return null;
    }
  }

  /// Update reading progress
  Future<void> updateReadingProgress({
    required String userId,
    required String bookId,
    required int currentPage,
    int? totalPages,
    double? percentRead,
  }) async {
    try {
      if (kDebugMode) {
        print(
          '📖 ReadingProgressService: Updating progress - Page: $currentPage',
        );
      }

      final now = DateTime.now();
      final progressId = '${userId}_$bookId';

      // Get existing progress to preserve total pages
      final existingProgress = await getReadingProgress(
        userId: userId,
        bookId: bookId,
      );

      final finalTotalPages = totalPages ?? existingProgress?.totalPages ?? 1;
      final finalPercentRead =
          percentRead ??
          ((currentPage + 1) / finalTotalPages * 100).clamp(0.0, 100.0);

      final progress = ReadingProgress(
        id: progressId,
        userId: userId,
        bookId: bookId,
        currentPage: currentPage,
        totalPages: finalTotalPages,
        percentRead: finalPercentRead,
        lastReadAt: now,
        updatedAt: now,
      );

      if (isDemoMode) {
        _demoProgress[progressId] = progress;
        await _saveDemoProgress(userId, bookId, progress);

        if (kDebugMode) {
          print('📖 ReadingProgressService: Demo progress saved');
        }
        return;
      }

      // Firestore implementation
      await _firestore
          .collection(_progressCollection)
          .doc(progressId)
          .set(progress.toMap(), SetOptions(merge: true));

      if (kDebugMode) {
        print('📖 ReadingProgressService: Progress saved to Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReadingProgressService: Error updating progress: $e');
      }
    }
  }

  /// Get all reading progress for a user
  Future<List<ReadingProgress>> getUserReadingProgress(String userId) async {
    try {
      if (kDebugMode) {
        print(
          '📖 ReadingProgressService: Getting all progress for user: $userId',
        );
      }

      if (isDemoMode) {
        await _loadAllDemoProgress(userId);
        return _demoProgress.values
            .where((progress) => progress.userId == userId)
            .toList()
          ..sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
      }

      // Firestore implementation
      final snapshot = await _firestore
          .collection(_progressCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('lastReadAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReadingProgress.fromMap(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReadingProgressService: Error getting user progress: $e');
      }
      return [];
    }
  }

  /// Delete reading progress
  Future<void> deleteReadingProgress({
    required String userId,
    required String bookId,
  }) async {
    try {
      if (kDebugMode) {
        print('📖 ReadingProgressService: Deleting progress for book: $bookId');
      }

      final progressId = '${userId}_$bookId';

      if (isDemoMode) {
        _demoProgress.remove(progressId);
        await _deleteDemoProgress(userId, bookId);
        return;
      }

      // Firestore implementation
      await _firestore.collection(_progressCollection).doc(progressId).delete();

      if (kDebugMode) {
        print('📖 ReadingProgressService: Progress deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReadingProgressService: Error deleting progress: $e');
      }
    }
  }

  // ==================== DEMO MODE PERSISTENCE ====================

  Future<void> _loadDemoProgress(String userId, String bookId) async {
    final progressKey = '${userId}_$bookId';
    if (_demoProgress.containsKey(progressKey)) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('reading_progress_$progressKey');

      if (progressJson != null) {
        final progressMap = <String, dynamic>{};
        final parts = progressJson.split('|');

        if (parts.length >= 6) {
          progressMap['id'] = progressKey;
          progressMap['userId'] = userId;
          progressMap['bookId'] = bookId;
          progressMap['currentPage'] = int.tryParse(parts[0]) ?? 0;
          progressMap['totalPages'] = int.tryParse(parts[1]) ?? 1;
          progressMap['percentRead'] = double.tryParse(parts[2]) ?? 0.0;
          progressMap['lastReadAt'] =
              int.tryParse(parts[3]) ?? DateTime.now().millisecondsSinceEpoch;
          progressMap['updatedAt'] =
              int.tryParse(parts[4]) ?? DateTime.now().millisecondsSinceEpoch;

          _demoProgress[progressKey] = ReadingProgress.fromMap(progressMap);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReadingProgressService: Error loading demo progress: $e');
      }
    }
  }

  Future<void> _saveDemoProgress(
    String userId,
    String bookId,
    ReadingProgress progress,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressKey = '${userId}_$bookId';

      // Simple string format: currentPage|totalPages|percentRead|lastReadAt|updatedAt
      final progressJson =
          '${progress.currentPage}|${progress.totalPages}|${progress.percentRead}|${progress.lastReadAt.millisecondsSinceEpoch}|${progress.updatedAt.millisecondsSinceEpoch}';

      await prefs.setString('reading_progress_$progressKey', progressJson);
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReadingProgressService: Error saving demo progress: $e');
      }
    }
  }

  Future<void> _loadAllDemoProgress(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where((key) => key.startsWith('reading_progress_${userId}_'))
          .toList();

      for (final key in keys) {
        final bookId = key.replaceFirst('reading_progress_${userId}_', '');
        await _loadDemoProgress(userId, bookId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReadingProgressService: Error loading all demo progress: $e');
      }
    }
  }

  Future<void> _deleteDemoProgress(String userId, String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressKey = '${userId}_$bookId';
      await prefs.remove('reading_progress_$progressKey');
    } catch (e) {
      if (kDebugMode) {
        print('❌ ReadingProgressService: Error deleting demo progress: $e');
      }
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Check if user has started reading a book
  Future<bool> hasStartedReading({
    required String userId,
    required String bookId,
  }) async {
    final progress = await getReadingProgress(userId: userId, bookId: bookId);
    return progress != null && progress.currentPage > 0;
  }

  /// Get reading completion percentage
  Future<double> getCompletionPercentage({
    required String userId,
    required String bookId,
  }) async {
    final progress = await getReadingProgress(userId: userId, bookId: bookId);
    return progress?.percentRead ?? 0.0;
  }

  /// Get recently read books
  Future<List<ReadingProgress>> getRecentlyReadBooks({
    required String userId,
    int limit = 10,
  }) async {
    final allProgress = await getUserReadingProgress(userId);
    return allProgress.take(limit).toList();
  }
}
