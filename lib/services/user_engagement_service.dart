import 'package:cloud_firestore/cloud_firestore.dart';

/// Kullanıcı etkileşim servisi - kullanıcı davranışlarını takip eder
class UserEngagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _engagementCollection = 'user_engagement';
  static const String _readingSessionsCollection = 'reading_sessions';
  static const String _userStatsCollection = 'user_stats';

  /// Uygulama açılışını kaydet
  Future<void> logAppOpen({
    required String userId,
    String? source, // 'notification', 'deep_link', 'normal'
  }) async {
    try {
      await _firestore
          .collection(_engagementCollection)
          .add({
        'userId': userId,
        'event': 'app_open',
        'source': source ?? 'normal',
        'timestamp': Timestamp.now(),
        'platform': 'flutter',
      });
    } catch (e) {
      print('Uygulama açılışı kaydedilirken hata: $e');
    }
  }

  /// Kitap okuma oturumunu başlat
  Future<void> startReadingSession({
    required String userId,
    required String bookId,
    int? startPage,
  }) async {
    try {
      final sessionId = '${userId}_${bookId}_${DateTime.now().millisecondsSinceEpoch}';
      
      await _firestore
          .collection(_readingSessionsCollection)
          .doc(sessionId)
          .set({
        'userId': userId,
        'bookId': bookId,
        'startPage': startPage ?? 1,
        'startTime': Timestamp.now(),
        'isActive': true,
        'pagesRead': 0,
        'duration': 0, // saniye cinsinden
      });
    } catch (e) {
      print('Okuma oturumu başlatılırken hata: $e');
    }
  }

  /// Kitap okuma oturumunu güncelle
  Future<void> updateReadingSession({
    required String userId,
    required String bookId,
    int? currentPage,
    int? pagesRead,
    int? duration,
  }) async {
    try {
      // Aktif oturumu bul
      final query = await _firestore
          .collection(_readingSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        
        await doc.reference.update({
          'currentPage': currentPage ?? data['currentPage'],
          'pagesRead': (data['pagesRead'] ?? 0) + (pagesRead ?? 0),
          'duration': (data['duration'] ?? 0) + (duration ?? 0),
          'lastUpdate': Timestamp.now(),
        });
      }
    } catch (e) {
      print('Okuma oturumu güncellenirken hata: $e');
    }
  }

  /// Kitap okuma oturumunu bitir
  Future<void> endReadingSession({
    required String userId,
    required String bookId,
    int? endPage,
    int? totalPagesRead,
    int? totalDuration,
  }) async {
    try {
      // Aktif oturumu bul
      final query = await _firestore
          .collection(_readingSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('bookId', isEqualTo: bookId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        
        await doc.reference.update({
          'endPage': endPage ?? data['currentPage'],
          'pagesRead': totalPagesRead ?? data['pagesRead'],
          'duration': totalDuration ?? data['duration'],
          'endTime': Timestamp.now(),
          'isActive': false,
        });

        // Kullanıcı istatistiklerini güncelle
        await _updateUserStats(
          userId: userId,
          bookId: bookId,
          pagesRead: totalPagesRead ?? data['pagesRead'],
          duration: totalDuration ?? data['duration'],
        );
      }
    } catch (e) {
      print('Okuma oturumu bitirilirken hata: $e');
    }
  }

  /// Kullanıcı istatistiklerini güncelle
  Future<void> _updateUserStats({
    required String userId,
    required String bookId,
    required int pagesRead,
    required int duration,
  }) async {
    try {
      final userStatsRef = _firestore
          .collection(_userStatsCollection)
          .doc(userId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(userStatsRef);
        
        if (doc.exists) {
          final data = doc.data()!;
          final totalPagesRead = (data['totalPagesRead'] ?? 0) + pagesRead;
          final totalReadingTime = (data['totalReadingTime'] ?? 0) + duration;
          final booksRead = data['booksRead'] ?? <String>[];
          
          if (!booksRead.contains(bookId)) {
            booksRead.add(bookId);
          }

          transaction.update(userStatsRef, {
            'totalPagesRead': totalPagesRead,
            'totalReadingTime': totalReadingTime,
            'booksRead': booksRead,
            'lastReadingSession': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });
        } else {
          transaction.set(userStatsRef, {
            'userId': userId,
            'totalPagesRead': pagesRead,
            'totalReadingTime': duration,
            'booksRead': [bookId],
            'lastReadingSession': Timestamp.now(),
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });
        }
      });
    } catch (e) {
      print('Kullanıcı istatistikleri güncellenirken hata: $e');
    }
  }

  /// Sayfa geçişini kaydet
  Future<void> logPageTurn({
    required String userId,
    required String bookId,
    required int fromPage,
    required int toPage,
  }) async {
    try {
      await _firestore
          .collection(_engagementCollection)
          .add({
        'userId': userId,
        'bookId': bookId,
        'event': 'page_turn',
        'fromPage': fromPage,
        'toPage': toPage,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Sayfa geçişi kaydedilirken hata: $e');
    }
  }

  /// Kitap satın almayı kaydet
  Future<void> logBookPurchase({
    required String userId,
    required String bookId,
    required int pointsSpent,
    String? paymentMethod,
  }) async {
    try {
      await _firestore
          .collection(_engagementCollection)
          .add({
        'userId': userId,
        'bookId': bookId,
        'event': 'book_purchase',
        'pointsSpent': pointsSpent,
        'paymentMethod': paymentMethod ?? 'points',
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Kitap satın alma kaydedilirken hata: $e');
    }
  }

  /// Yorum yapmayı kaydet
  Future<void> logComment({
    required String userId,
    required String bookId,
    required int rating,
    int commentLength = 0,
  }) async {
    try {
      await _firestore
          .collection(_engagementCollection)
          .add({
        'userId': userId,
        'bookId': bookId,
        'event': 'comment',
        'rating': rating,
        'commentLength': commentLength,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Yorum kaydedilirken hata: $e');
    }
  }

  /// Bildirime tıklamayı kaydet
  Future<void> logNotificationTap({
    required String userId,
    required String notificationId,
    String? targetScreen,
  }) async {
    try {
      await _firestore
          .collection(_engagementCollection)
          .add({
        'userId': userId,
        'notificationId': notificationId,
        'event': 'notification_tap',
        'targetScreen': targetScreen,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Bildirim tıklama kaydedilirken hata: $e');
    }
  }

  /// Kullanıcı istatistiklerini getir
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final doc = await _firestore
          .collection(_userStatsCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data()!;
      }

      return {
        'totalPagesRead': 0,
        'totalReadingTime': 0,
        'booksRead': <String>[],
        'lastReadingSession': null,
      };
    } catch (e) {
      print('Kullanıcı istatistikleri getirilirken hata: $e');
      return {};
    }
  }

  /// Kullanıcının okuma geçmişini getir
  Future<List<Map<String, dynamic>>> getReadingHistory({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_readingSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: false)
          .orderBy('endTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'sessionId': doc.id,
          'bookId': data['bookId'],
          'startTime': data['startTime'],
          'endTime': data['endTime'],
          'pagesRead': data['pagesRead'],
          'duration': data['duration'],
        };
      }).toList();
    } catch (e) {
      print('Okuma geçmişi getirilirken hata: $e');
      return [];
    }
  }

  /// Kullanıcının günlük aktivitelerini getir
  Future<List<Map<String, dynamic>>> getDailyActivities({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = Timestamp.fromDate(
        DateTime(date.year, date.month, date.day),
      );
      final endOfDay = Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, 23, 59, 59),
      );

      final snapshot = await _firestore
          .collection(_engagementCollection)
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'event': data['event'],
          'timestamp': data['timestamp'],
          'bookId': data['bookId'],
          'details': data,
        };
      }).toList();
    } catch (e) {
      print('Günlük aktiviteler getirilirken hata: $e');
      return [];
    }
  }

  /// Haftalık okuma raporu oluştur
  Future<Map<String, dynamic>> getWeeklyReadingReport({
    required String userId,
    required DateTime weekStart,
  }) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 7));
      final startTimestamp = Timestamp.fromDate(weekStart);
      final endTimestamp = Timestamp.fromDate(weekEnd);

      // Bu haftaki okuma oturumları
      final sessionsSnapshot = await _firestore
          .collection(_readingSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('startTime', isGreaterThanOrEqualTo: startTimestamp)
          .where('startTime', isLessThan: endTimestamp)
          .get();

      int totalPagesRead = 0;
      int totalReadingTime = 0;
      int sessionCount = 0;
      Set<String> booksRead = {};

      for (var doc in sessionsSnapshot.docs) {
        final data = doc.data();
        totalPagesRead += data['pagesRead'] ?? 0;
        totalReadingTime += data['duration'] ?? 0;
        sessionCount++;
        booksRead.add(data['bookId']);
      }

      return {
        'weekStart': weekStart,
        'weekEnd': weekEnd,
        'totalPagesRead': totalPagesRead,
        'totalReadingTime': totalReadingTime,
        'sessionCount': sessionCount,
        'booksRead': booksRead.length,
        'averagePagesPerSession': sessionCount > 0 ? (totalPagesRead / sessionCount).toInt() : 0,
        'averageTimePerSession': sessionCount > 0 ? (totalReadingTime / sessionCount).toInt() : 0,
      };
    } catch (e) {
      print('Haftalık rapor oluşturulurken hata: $e');
      return {};
    }
  }

  /// Kullanıcının favori kategorilerini analiz et
  Future<List<String>> getFavoriteCategories(String userId) async {
    try {
      // Son 30 günde okunan kitapları al
      final thirtyDaysAgo = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(days: 30)),
      );

      final sessionsSnapshot = await _firestore
          .collection(_readingSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('startTime', isGreaterThanOrEqualTo: thirtyDaysAgo)
          .get();

      // Kitap ID'lerini topla
      final bookIds = sessionsSnapshot.docs
          .map((doc) => doc.data()['bookId'] as String)
          .toSet()
          .toList();

      // Kitapların kategorilerini al
      final categories = <String, int>{};
      
      for (String bookId in bookIds) {
        final bookDoc = await _firestore
            .collection('books')
            .doc(bookId)
            .get();
        
        if (bookDoc.exists) {
          final bookData = bookDoc.data()!;
          final category = bookData['category'] as String?;
          
          if (category != null) {
            categories[category] = (categories[category] ?? 0) + 1;
          }
        }
      }

      // Kategorileri okuma sayısına göre sırala
      final sortedCategories = categories.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedCategories.map((e) => e.key).toList();
    } catch (e) {
      print('Favori kategoriler analiz edilirken hata: $e');
      return [];
    }
  }
} 