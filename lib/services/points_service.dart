import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/user_activity_model.dart';
import '../../utils/alerts.dart';

/// Puan işlemleri servisi - StateNotify ile çalışır
class PointsService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String usersCollection = 'users';

  // State değişkenleri
  int _points = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  int get points => _points;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Mevcut puanları getir
  int getPoints() {
    return _points;
  }

  /// Puan ekle (UI için basit versiyon)
  void addPoints(int amount) {
    if (amount > 0) {
      _points += amount;
      _clearError();
      notifyListeners();
    } else {
      _setError('Geçersiz puan miktarı');
    }
  }

  /// Puan kullan (UI için basit versiyon)
  void redeemPoints(int amount) {
    if (amount > 0 && _points >= amount) {
      _points -= amount;
      _clearError();
      notifyListeners();
    } else if (amount <= 0) {
      _setError('Geçersiz puan miktarı');
    } else {
      _setError('Yeterli puan yok');
    }
  }

  /// Puanları local storage'dan yükle
  Future<void> loadPointsFromStorage() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _points = prefs.getInt('user_points') ?? 0;
      _clearError();
    } catch (e) {
      _setError('Puanlar yüklenirken hata: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Puanları local storage'a kaydet
  Future<void> savePointsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_points', _points);
      _clearError();
    } catch (e) {
      _setError('Puanlar kaydedilirken hata: $e');
    }
  }

  /// Puan ekle (Firestore ile - mevcut metod)
  Future<void> addPointsToFirestore({
    required String userId,
    required int points,
    String reason = '',
  }) async {
    _setLoading(true);
    try {
      final userRef = _firestore.collection(usersCollection).doc(userId);
      await _firestore.runTransaction((transaction) async {
        final userSnap = await transaction.get(userRef);
        if (!userSnap.exists) throw Exception('Kullanıcı bulunamadı');
        final data = userSnap.data() as Map<String, dynamic>;
        final currentPoints = data['totalPoints'] ?? 0;
        transaction.update(userRef, {
          'totalPoints': currentPoints + points,
          'updatedAt': DateTime.now(),
        });
      });

      // Local state'i güncelle
      _points += points;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Puan eklenirken hata: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Puan düş (Firestore ile - mevcut metod)
  Future<void> deductPointsFromFirestore({
    required String userId,
    required int points,
    String reason = '',
  }) async {
    _setLoading(true);
    try {
      final userRef = _firestore.collection(usersCollection).doc(userId);
      await _firestore.runTransaction((transaction) async {
        final userSnap = await transaction.get(userRef);
        if (!userSnap.exists) throw Exception('Kullanıcı bulunamadı');
        final data = userSnap.data() as Map<String, dynamic>;
        final currentPoints = data['totalPoints'] ?? 0;
        if (currentPoints < points) throw Exception('Yeterli puan yok');
        transaction.update(userRef, {
          'totalPoints': currentPoints - points,
          'updatedAt': DateTime.now(),
        });
      });

      // Local state'i güncelle
      _points -= points;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Puan düşülürken hata: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Kullanıcıyı UID veya e-posta ile ara
  Future<UserModel?> getUserByQuery(String query) async {
    try {
      // Önce UID ile ara
      final userDoc = await _firestore.collection('users').doc(query).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return UserModel(
          uid: userDoc.id,
          email: userData['email'] ?? '',
          name: userData['name'] ?? userData['displayName'] ?? '',
          totalPoints: userData['totalPoints'] ?? 0,
          createdAt:
              (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt:
              (userData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }

      // E-posta ile ara
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: query)
          .limit(1)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        final userDoc = emailQuery.docs.first;
        final userData = userDoc.data() as Map<String, dynamic>;
        return UserModel(
          uid: userDoc.id,
          email: userData['email'] ?? '',
          name: userData['name'] ?? userData['displayName'] ?? '',
          totalPoints: userData['totalPoints'] ?? 0,
          createdAt:
              (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt:
              (userData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }

      return null;
    } catch (e) {
      throw Exception('Kullanıcı aranırken hata: $e');
    }
  }

  /// Kullanıcı puanlarını getir
  Future<int> getUserPoints(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) throw Exception('Kullanıcı bulunamadı');

      final data = userDoc.data() as Map<String, dynamic>;
      final firestorePoints = data['totalPoints'] ?? 0;

      // Local state'i güncelle
      _points = firestorePoints;
      notifyListeners();

      return firestorePoints;
    } catch (e) {
      throw Exception('Puanlar alınırken hata: $e');
    }
  }

  /// Puan geçmişini getir
  Future<List<Map<String, dynamic>>> getPointsHistory(String userId) async {
    try {
      final historyQuery = await _firestore
          .collection('pointTransactions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return historyQuery.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Puan geçmişi alınırken hata: $e');
    }
  }

  /// Kitap satın alma ile puan düş
  Future<void> purchaseBookWithPoints({
    required String userId,
    required int points,
    required String bookId,
  }) async {
    _setLoading(true);
    try {
      await _firestore.runTransaction((transaction) async {
        // Kullanıcı puanlarını kontrol et
        final userRef = _firestore.collection(usersCollection).doc(userId);
        final userSnap = await transaction.get(userRef);

        if (!userSnap.exists) throw Exception('Kullanıcı bulunamadı');

        final data = userSnap.data() as Map<String, dynamic>;
        final currentPoints = data['totalPoints'] ?? 0;

        if (currentPoints < points) throw Exception('Yeterli puan yok');

        // Puanları düş
        transaction.update(userRef, {
          'totalPoints': currentPoints - points,
          'updatedAt': DateTime.now(),
        });

        // Satın alma işlemini kaydet
        final purchaseRef = _firestore.collection('purchases').doc();
        transaction.set(purchaseRef, {
          'userId': userId,
          'bookId': bookId,
          'pointsSpent': points,
          'purchaseType': 'points',
          'createdAt': DateTime.now(),
        });

        // Puan işlemini kaydet
        final transactionRef = _firestore.collection('pointTransactions').doc();
        transaction.set(transactionRef, {
          'userId': userId,
          'type': 'purchase',
          'points': -points,
          'bookId': bookId,
          'createdAt': DateTime.now(),
        });
      });

      // Local state'i güncelle
      _points -= points;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Kitap satın alma hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Harcanan puanları kaydet
  Future<void> recordPointsSpent({
    required String userId,
    required int points,
    required String reason,
  }) async {
    try {
      final transactionRef = _firestore.collection('pointTransactions').doc();
      await transactionRef.set({
        'userId': userId,
        'type': 'spent',
        'points': -points,
        'reason': reason,
        'createdAt': DateTime.now(),
      });

      // Local state'i güncelle
      _points -= points;
      notifyListeners();
    } catch (e) {
      throw Exception('Puan harcama kaydedilirken hata: $e');
    }
  }

  /// Sadakat puanları kontrol et ve ekle
  Future<void> checkAndAddLoyaltyPoints(String userId) async {
    try {
      // Kullanıcının son aktivite tarihini kontrol et
      final userDoc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) return;

      final data = userDoc.data() as Map<String, dynamic>;
      final lastLoyaltyCheck = data['lastLoyaltyCheck'] as Timestamp?;

      final now = DateTime.now();

      // Günlük sadakat puanı kontrolü
      if (lastLoyaltyCheck == null ||
          now.difference(lastLoyaltyCheck.toDate()).inDays >= 1) {
        await addPointsToFirestore(
          userId: userId,
          points: 10, // Günlük sadakat puanı
          reason: 'Günlük sadakat puanı',
        );

        // Son kontrol tarihini güncelle
        await _firestore.collection(usersCollection).doc(userId).update({
          'lastLoyaltyCheck': now,
        });
      }
    } catch (e) {
      throw Exception('Sadakat puanları kontrol edilirken hata: $e');
    }
  }

  /// Puanları sıfırla (test için)
  void resetPoints() {
    _points = 0;
    _clearError();
    notifyListeners();
  }

  /// Puanları belirli bir değere ayarla (test için)
  void setPoints(int amount) {
    _points = amount;
    _clearError();
    notifyListeners();
  }

  /// Günlük uygulama girişi puanı (günde 1 kez)
  Future<void> rewardDailyLogin({
    required String userId,
    required BuildContext context,
  }) async {
    final activities = _firestore.collection('user_activities');
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final existing = await activities
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'daily_login')
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .get();
    if (existing.docs.isNotEmpty) {
      Alerts.showInfo(context, 'Bugün zaten günlük giriş puanını aldınız.');
      return;
    }
    await _firestore.runTransaction((transaction) async {
      final userRef = _firestore.collection(usersCollection).doc(userId);
      transaction.update(userRef, {'totalPoints': FieldValue.increment(5)});
      final activityRef = activities.doc();
      transaction.set(activityRef, {
        'userId': userId,
        'type': 'daily_login',
        'createdAt': DateTime.now(),
      });
    });
    Alerts.showSuccess(context, 'Günlük giriş puanı kazandınız! (+5 puan)');
  }

  /// Kitap yorumlama puanı (her kitap için yalnızca ilk yorum)
  Future<void> rewardBookComment({
    required String userId,
    required String bookId,
    required BuildContext context,
  }) async {
    final activities = _firestore.collection('user_activities');
    final existing = await activities
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'comment')
        .where('bookId', isEqualTo: bookId)
        .get();
    if (existing.docs.isNotEmpty) {
      Alerts.showInfo(context, 'Bu kitap için zaten yorum puanı aldınız.');
      return;
    }
    await _firestore.runTransaction((transaction) async {
      final userRef = _firestore.collection(usersCollection).doc(userId);
      transaction.update(userRef, {'totalPoints': FieldValue.increment(10)});
      final activityRef = activities.doc();
      transaction.set(activityRef, {
        'userId': userId,
        'type': 'comment',
        'bookId': bookId,
        'createdAt': DateTime.now(),
      });
    });
    Alerts.showSuccess(context, 'Yorum puanı kazandınız! (+10 puan)');
  }

  /// Kitabı puanlama (rate) puanı (her kitap için yalnızca 1 kez)
  Future<void> rewardBookRating({
    required String userId,
    required String bookId,
    required BuildContext context,
  }) async {
    final activities = _firestore.collection('user_activities');
    final existing = await activities
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'rate')
        .where('bookId', isEqualTo: bookId)
        .get();
    if (existing.docs.isNotEmpty) {
      Alerts.showInfo(context, 'Bu kitap için zaten puanlama puanı aldınız.');
      return;
    }
    await _firestore.runTransaction((transaction) async {
      final userRef = _firestore.collection(usersCollection).doc(userId);
      transaction.update(userRef, {'totalPoints': FieldValue.increment(5)});
      final activityRef = activities.doc();
      transaction.set(activityRef, {
        'userId': userId,
        'type': 'rate',
        'bookId': bookId,
        'createdAt': DateTime.now(),
      });
    });
    Alerts.showSuccess(context, 'Kitabı puanladınız! (+5 puan)');
  }

  /// Kitap paylaşımı puanı (günde yalnızca 1 kez)
  Future<void> rewardBookShare({
    required String userId,
    required String bookId,
    required BuildContext context,
  }) async {
    final activities = _firestore.collection('user_activities');
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final existing = await activities
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'share')
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .get();
    if (existing.docs.isNotEmpty) {
      Alerts.showInfo(context, 'Bugün zaten kitap paylaşımı puanını aldınız.');
      return;
    }
    await _firestore.runTransaction((transaction) async {
      final userRef = _firestore.collection(usersCollection).doc(userId);
      transaction.update(userRef, {'totalPoints': FieldValue.increment(7)});
      final activityRef = activities.doc();
      transaction.set(activityRef, {
        'userId': userId,
        'type': 'share',
        'bookId': bookId,
        'createdAt': DateTime.now(),
      });
    });
    Alerts.showSuccess(context, 'Kitap paylaşımı puanı kazandınız! (+7 puan)');
  }

  // Private metodlar
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
