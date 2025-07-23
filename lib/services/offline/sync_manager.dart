import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../points_service.dart';
import '../notification_service.dart';
import '../reading_progress_service.dart';
import 'local_storage_service.dart';
import 'connectivity_service.dart';

/// Veri senkronizasyon yöneticisi
class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final LocalStorageService _localStorage = LocalStorageService();
  final ConnectivityService _connectivity = ConnectivityService();
  final PointsService _pointsService = PointsService();
  final NotificationService _notificationService = NotificationService();
  final ReadingProgressService _readingProgressService =
      ReadingProgressService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timer? _syncTimer;
  bool _isSyncing = false;
  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();

  /// Senkronizasyon durumu stream'i
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  /// Senkronizasyon durumu
  bool get isSyncing => _isSyncing;

  /// Senkronizasyon yöneticisini başlat
  Future<void> initialize() async {
    // Bağlantı değişikliklerini dinle
    _connectivity.connectionStatus.listen((isConnected) {
      if (isConnected) {
        _scheduleSync();
      }
    });

    // İlk senkronizasyonu planla
    _scheduleSync();
  }

  /// Senkronizasyonu planla
  void _scheduleSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 5), () {
      _performSync();
    });
  }

  /// Manuel senkronizasyon
  Future<void> performManualSync() async {
    await _performSync();
  }

  /// Senkronizasyon işlemini gerçekleştir
  Future<void> _performSync() async {
    if (_isSyncing || !_connectivity.isConnected) return;

    _isSyncing = true;
    _syncStatusController.add(
      SyncStatus(
        isSyncing: true,
        message: 'Senkronizasyon başlatılıyor...',
        progress: 0.0,
      ),
    );

    try {
      // 1. Bekleyen işlemleri senkronize et
      await _syncPendingActions();

      // 2. Okuma ilerlemelerini senkronize et
      await _syncReadingProgress();

      // 3. Kullanıcı verilerini senkronize et
      await _syncUserData();

      // 4. Kitap verilerini güncelle
      await _syncBookData();

      _syncStatusController.add(
        SyncStatus(
          isSyncing: false,
          message: 'Senkronizasyon tamamlandı',
          progress: 1.0,
          lastSyncTime: DateTime.now(),
        ),
      );
    } catch (e) {
      _syncStatusController.add(
        SyncStatus(
          isSyncing: false,
          message: 'Senkronizasyon hatası: $e',
          progress: 0.0,
          hasError: true,
        ),
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Bekleyen işlemleri senkronize et
  Future<void> _syncPendingActions() async {
    final pendingActions = _localStorage.getPendingActions();
    if (pendingActions.isEmpty) return;

    _syncStatusController.add(
      SyncStatus(
        isSyncing: true,
        message: 'Bekleyen işlemler senkronize ediliyor...',
        progress: 0.1,
      ),
    );

    int processed = 0;
    final total = pendingActions.length;

    for (final action in pendingActions) {
      try {
        final success = await _processPendingAction(action);
        if (success) {
          await _localStorage.removePendingAction(action['id'] as String);
        } else {
          // Başarısız işlemi işaretle
          await _localStorage.updatePendingAction(action['id'] as String, {
            'retryCount': (action['retryCount'] ?? 0) + 1,
            'lastError': 'İşlem başarısız',
            'status': 'failed',
          });
        }

        processed++;
        _syncStatusController.add(
          SyncStatus(
            isSyncing: true,
            message: 'İşlem $processed/$total işleniyor...',
            progress: 0.1 + (0.3 * processed / total),
          ),
        );
      } catch (e) {
        // Hata durumunda işlemi işaretle
        await _localStorage.updatePendingAction(action['id'] as String, {
          'retryCount': (action['retryCount'] ?? 0) + 1,
          'lastError': e.toString(),
          'status': 'error',
        });
      }
    }
  }

  /// Bekleyen işlemi işle
  Future<bool> _processPendingAction(Map<String, dynamic> action) async {
    final type = action['type'] as String;
    final userId = action['userId'] as String;

    switch (type) {
      case 'purchase_book':
        return await _processPurchaseAction(action);

      case 'add_points':
        return await _processAddPointsAction(action);

      case 'reading_progress':
        return await _processReadingProgressAction(action);

      case 'book_like':
        return await _processBookLikeAction(action);

      case 'add_comment':
        return await _processCommentAction(action);

      default:
        return false;
    }
  }

  /// Kitap satın alma işlemini işle
  Future<bool> _processPurchaseAction(Map<String, dynamic> action) async {
    try {
      final userId = action['userId'] as String;
      final bookId = action['bookId'] as String;
      final points = action['points'] as int;

      // Firestore'da satın alma işlemini gerçekleştir
      final success = await _pointsService.purchaseBookWithPoints(
        userId: userId,
        bookId: bookId,
        requiredPoints: points,
      );

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Puan ekleme işlemini işle
  Future<bool> _processAddPointsAction(Map<String, dynamic> action) async {
    try {
      final userId = action['userId'] as String;
      final points = action['points'] as int;
      final reason = action['reason'] as String;

      _pointsService.addPoints(userId: userId, points: points, reason: reason);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Okuma ilerlemesi işlemini işle
  Future<bool> _processReadingProgressAction(
    Map<String, dynamic> action,
  ) async {
    try {
      final userId = action['userId'] as String;
      final bookId = action['bookId'] as String;
      final progress = Map<String, dynamic>.from(action['progress'] as Map);

      await _readingProgressService.saveReadingProgress(
        userId: userId,
        bookId: bookId,
        progress: progress,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Kitap beğenisi işlemini işle
  Future<bool> _processBookLikeAction(Map<String, dynamic> action) async {
    try {
      final userId = action['userId'] as String;
      final bookId = action['bookId'] as String;
      final isLiked = action['isLiked'] as bool;

      // Firestore'da beğeni işlemini gerçekleştir
      final bookRef = _firestore.collection('books').doc(bookId);

      if (isLiked) {
        await bookRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        });
      } else {
        await bookRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Yorum işlemini işle
  Future<bool> _processCommentAction(Map<String, dynamic> action) async {
    try {
      final userId = action['userId'] as String;
      final bookId = action['bookId'] as String;
      final comment = action['comment'] as String;

      // Firestore'a yorum ekle
      await _firestore.collection('comments').add({
        'userId': userId,
        'bookId': bookId,
        'comment': comment,
        'status': 'pending', // Admin onayı bekliyor
        'createdAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Okuma ilerlemelerini senkronize et
  Future<void> _syncReadingProgress() async {
    _syncStatusController.add(
      SyncStatus(
        isSyncing: true,
        message: 'Okuma ilerlemeleri senkronize ediliyor...',
        progress: 0.4,
      ),
    );

    final localProgress = _localStorage.getAllReadingProgress();

    for (final progress in localProgress) {
      try {
        final userId = progress['userId'] as String?;
        final bookId = progress['bookId'] as String?;

        if (userId != null && bookId != null) {
          await _readingProgressService.saveReadingProgress(
            userId: userId,
            bookId: bookId,
            progress: progress,
          );
        }
      } catch (e) {
        // Hata durumunda sessizce geç
      }
    }
  }

  /// Kullanıcı verilerini senkronize et
  Future<void> _syncUserData() async {
    _syncStatusController.add(
      SyncStatus(
        isSyncing: true,
        message: 'Kullanıcı verileri senkronize ediliyor...',
        progress: 0.7,
      ),
    );

    final userData = _localStorage.getUserData();
    if (userData != null) {
      try {
        final userId = userData['uid'] as String?;
        if (userId != null) {
          // Firestore'dan güncel kullanıcı verilerini al
          final userDoc = await _firestore
              .collection('users')
              .doc(userId)
              .get();
          if (userDoc.exists) {
            final firestoreData = userDoc.data()!;

            // Yerel verileri güncelle
            userData.addAll(firestoreData);
            await _localStorage.saveUserData(userData);
          }
        }
      } catch (e) {
        // Hata durumunda sessizce geç
      }
    }
  }

  /// Kitap verilerini senkronize et
  Future<void> _syncBookData() async {
    _syncStatusController.add(
      SyncStatus(
        isSyncing: true,
        message: 'Kitap verileri güncelleniyor...',
        progress: 0.9,
      ),
    );

    try {
      // Satın alınan kitapları kontrol et
      final purchasedBooks = _localStorage.getPurchasedBooks();

      for (final bookId in purchasedBooks) {
        try {
          // Firestore'dan güncel kitap verilerini al
          final bookDoc = await _firestore
              .collection('books')
              .doc(bookId)
              .get();
          if (bookDoc.exists) {
            final bookData = bookDoc.data()!;
            await _localStorage.saveBook(bookData);
          }
        } catch (e) {
          // Hata durumunda sessizce geç
        }
      }
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  /// Offline işlem ekle
  Future<void> addOfflineAction(String type, Map<String, dynamic> data) async {
    final action = {
      'type': type,
      'data': data,
      'userId': _localStorage.getUserData()?['uid'],
    };

    await _localStorage.addPendingAction(action);
  }

  /// Servisi durdur
  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
  }
}

/// Senkronizasyon durumu
class SyncStatus {
  final bool isSyncing;
  final String message;
  final double progress;
  final DateTime? lastSyncTime;
  final bool hasError;

  SyncStatus({
    required this.isSyncing,
    required this.message,
    required this.progress,
    this.lastSyncTime,
    this.hasError = false,
  });
}
