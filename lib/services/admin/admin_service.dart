import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth_service.dart';

/// Admin servisi - Admin yetkilerini ve işlemlerini yönetir
class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Admin e-posta adresleri
  static const List<String> _adminEmails = [
    'maya@altertale.com',
    'admin@altertale.com',
    'support@altertale.com',
  ];

  /// Mevcut kullanıcının admin olup olmadığını kontrol et
  Future<bool> isCurrentUserAdmin() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final email = currentUser.email?.toLowerCase();
      if (email == null) return false;

      return _adminEmails.contains(email);
    } catch (e) {
      return false;
    }
  }

  /// Belirli bir kullanıcının admin olup olmadığını kontrol et
  Future<bool> isUserAdmin(String email) async {
    try {
      final userEmail = email.toLowerCase();
      return _adminEmails.contains(userEmail);
    } catch (e) {
      return false;
    }
  }

  /// Admin log kaydı ekle
  Future<void> addAdminLog({
    required String action,
    required String details,
    Map<String, dynamic>? data,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      await _firestore.collection('adminLogs').add({
        'adminId': currentUser.uid,
        'adminEmail': currentUser.email,
        'action': action,
        'details': details,
        'data': data,
        'timestamp': Timestamp.now(),
        'ipAddress': 'unknown', // Gelecekte IP adresi eklenebilir
      });
    } catch (e) {
      // Log hatası kritik değil, sessizce geç
    }
  }

  /// Admin loglarını getir
  Future<List<Map<String, dynamic>>> getAdminLogs({
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('adminLogs')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'adminId': data['adminId'],
          'adminEmail': data['adminEmail'],
          'action': data['action'],
          'details': data['details'],
          'data': data['data'],
          'timestamp': (data['timestamp'] as Timestamp).toDate(),
          'ipAddress': data['ipAddress'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Admin logları alınırken hata oluştu: $e');
    }
  }

  /// İstatistikleri getir
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final stats = <String, dynamic>{};

      // Toplam kullanıcı sayısı
      final usersSnapshot = await _firestore.collection('users').get();
      stats['totalUsers'] = usersSnapshot.docs.length;

      // Toplam kitap sayısı
      final booksSnapshot = await _firestore.collection('books').get();
      stats['totalBooks'] = booksSnapshot.docs.length;

      // Toplam yorum sayısı
      final commentsSnapshot = await _firestore.collection('comments').get();
      stats['totalComments'] = commentsSnapshot.docs.length;

      // Onay bekleyen yorum sayısı
      final pendingCommentsSnapshot = await _firestore.collection('comments')
          .where('status', isEqualTo: 'pending')
          .get();
      stats['pendingComments'] = pendingCommentsSnapshot.docs.length;

      // Bugünkü aktif kullanıcılar (son 24 saat)
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final activeUsersSnapshot = await _firestore.collection('users')
          .where('lastLoginDate', isGreaterThan: Timestamp.fromDate(yesterday))
          .get();
      stats['activeUsersToday'] = activeUsersSnapshot.docs.length;

      // En çok okunan kitaplar (top 10)
      final topBooksSnapshot = await _firestore.collection('books')
          .orderBy('readCount', descending: true)
          .limit(10)
          .get();
      stats['topBooks'] = topBooksSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'],
          'author': data['author'],
          'readCount': data['readCount'] ?? 0,
        };
      }).toList();

      // En çok puan kazanan kullanıcılar (top 10)
      final topUsersSnapshot = await _firestore.collection('users')
          .orderBy('totalPoints', descending: true)
          .limit(10)
          .get();
      stats['topUsers'] = topUsersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'email': data['email'],
          'totalPoints': data['totalPoints'] ?? 0,
        };
      }).toList();

      // En çok davet eden kullanıcılar (top 10)
      final referralsSnapshot = await _firestore.collection('referrals')
          .get();
      
      final referralCounts = <String, int>{};
      for (final doc in referralsSnapshot.docs) {
        final data = doc.data();
        final referrerId = data['referrerId'] as String?;
        if (referrerId != null) {
          referralCounts[referrerId] = (referralCounts[referrerId] ?? 0) + 1;
        }
      }

      final sortedReferrers = referralCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topReferrers = <Map<String, dynamic>>[];
      for (int i = 0; i < sortedReferrers.length && i < 10; i++) {
        final entry = sortedReferrers[i];
        final userDoc = await _firestore.collection('users').doc(entry.key).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          topReferrers.add({
            'id': entry.key,
            'name': userData['name'],
            'email': userData['email'],
            'referralCount': entry.value,
          });
        }
      }
      stats['topReferrers'] = topReferrers;

      return stats;
    } catch (e) {
      throw Exception('İstatistikler alınırken hata oluştu: $e');
    }
  }

  /// Kullanıcı istatistiklerini getir
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final stats = <String, dynamic>{};

      // Kullanıcı bilgileri
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('Kullanıcı bulunamadı');
      }

      final userData = userDoc.data()!;
      stats['userInfo'] = {
        'id': userDoc.id,
        'name': userData['name'],
        'email': userData['email'],
        'totalPoints': userData['totalPoints'] ?? 0,
        'createdAt': (userData['createdAt'] as Timestamp?)?.toDate(),
        'lastLoginDate': (userData['lastLoginDate'] as Timestamp?)?.toDate(),
      };

      // Kullanıcının yorumları
      final commentsSnapshot = await _firestore.collection('comments')
          .where('userId', isEqualTo: userId)
          .get();
      stats['comments'] = commentsSnapshot.docs.length;

      // Kullanıcının satın aldığı kitaplar
      final purchasedBooks = List<String>.from(userData['purchasedBooks'] ?? []);
      stats['purchasedBooks'] = purchasedBooks.length;

      // Kullanıcının okuma ilerlemesi
      final readingProgressSnapshot = await _firestore.collection('reading_progress')
          .where('userId', isEqualTo: userId)
          .get();
      stats['readingProgress'] = readingProgressSnapshot.docs.length;

      // Kullanıcının referansları
      final referralsSnapshot = await _firestore.collection('referrals')
          .where('referrerId', isEqualTo: userId)
          .get();
      stats['referrals'] = referralsSnapshot.docs.length;

      // Kullanıcının puan geçmişi
      final pointsHistorySnapshot = await _firestore.collection('points_history')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      stats['pointsHistory'] = pointsHistorySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'points': data['points'],
          'reason': data['reason'],
          'type': data['type'],
          'createdAt': (data['createdAt'] as Timestamp).toDate(),
        };
      }).toList();

      return stats;
    } catch (e) {
      throw Exception('Kullanıcı istatistikleri alınırken hata oluştu: $e');
    }
  }

  /// Sistem durumunu kontrol et
  Future<Map<String, dynamic>> getSystemStatus() async {
    try {
      final status = <String, dynamic>{};

      // Firestore bağlantı kontrolü
      try {
        await _firestore.collection('users').limit(1).get();
        status['firestore'] = 'connected';
      } catch (e) {
        status['firestore'] = 'error';
        status['firestoreError'] = e.toString();
      }

      // Admin sayısı
      final adminCount = _adminEmails.length;
      status['adminCount'] = adminCount;

      // Son admin aktivitesi
      final lastAdminLog = await _firestore.collection('adminLogs')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      
      if (lastAdminLog.docs.isNotEmpty) {
        final lastLog = lastAdminLog.docs.first.data();
        status['lastAdminActivity'] = {
          'admin': lastLog['adminEmail'],
          'action': lastLog['action'],
          'timestamp': (lastLog['timestamp'] as Timestamp).toDate(),
        };
      }

      return status;
    } catch (e) {
      throw Exception('Sistem durumu alınırken hata oluştu: $e');
    }
  }
}
