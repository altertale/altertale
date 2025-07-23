import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/referral/referral_model.dart';

/// Referans servisi
class ReferralService {
  static final ReferralService _instance = ReferralService._internal();
  factory ReferralService() => _instance;
  ReferralService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Koleksiyon isimleri
  static const String _referralsCollection = 'referrals';
  static const String _userReferralsCollection = 'userReferrals';
  static const String _referralCodesCollection = 'referralCodes';

  // Puan değerleri
  static const int _referrerPoints = 50; // Davet eden kullanıcıya verilen puan
  static const int _referredPoints = 10; // Davet edilen kullanıcıya verilen puan

  /// Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  /// Kullanıcı için referans kodu oluştur
  Future<String> generateReferralCode(String userId) async {
    try {
      // Mevcut kodları kontrol et
      String code;
      bool isUnique = false;
      int attempts = 0;
      const maxAttempts = 10;

      do {
        code = ReferralCodeGenerator.generateCode();
        final existingCode = await _firestore
            .collection(_referralCodesCollection)
            .doc(code)
            .get();

        isUnique = !existingCode.exists;
        attempts++;
      } while (!isUnique && attempts < maxAttempts);

      if (!isUnique) {
        throw Exception('Benzersiz referans kodu oluşturulamadı');
      }

      // Kodu kaydet
      await _firestore
          .collection(_referralCodesCollection)
          .doc(code)
          .set({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return code;
    } catch (e) {
      throw Exception('Referans kodu oluşturulurken hata oluştu: $e');
    }
  }

  /// Kullanıcının referans bilgilerini getir
  Future<UserReferralInfo> getUserReferralInfo(String userId) async {
    try {
      final doc = await _firestore
          .collection(_userReferralsCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserReferralInfo.fromFirestore(doc);
      } else {
        // Kullanıcı için referans bilgileri yoksa oluştur
        final referralCode = await generateReferralCode(userId);
        final userInfo = UserReferralInfo(
          userId: userId,
          referralCode: referralCode,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(_userReferralsCollection)
            .doc(userId)
            .set(userInfo.toFirestore());

        return userInfo;
      }
    } catch (e) {
      throw Exception('Referans bilgileri alınırken hata oluştu: $e');
    }
  }

  /// Referans kodunu doğrula
  Future<String?> validateReferralCode(String code) async {
    try {
      if (!ReferralCodeGenerator.isValidCode(code)) {
        return null;
      }

      final doc = await _firestore
          .collection(_referralCodesCollection)
          .doc(code)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['userId'] as String?;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Referans işlemini başlat
  Future<void> startReferral({
    required String referralCode,
    required String referredUserId,
    String? deviceId,
    String? ipAddress,
  }) async {
    try {
      // Referans kodunu doğrula
      final referrerId = await validateReferralCode(referralCode);
      if (referrerId == null) {
        throw Exception('Geçersiz referans kodu');
      }

      // Kendini referans etmeye çalışıyor mu?
      if (referrerId == referredUserId) {
        throw Exception('Kendinizi referans edemezsiniz');
      }

      // Daha önce referans edilmiş mi?
      final existingReferral = await _firestore
          .collection(_referralsCollection)
          .where('referredId', isEqualTo: referredUserId)
          .limit(1)
          .get();

      if (existingReferral.docs.isNotEmpty) {
        throw Exception('Bu kullanıcı zaten referans edilmiş');
      }

      // Referans işlemini oluştur
      final referral = ReferralModel(
        id: '', // Firestore tarafından oluşturulacak
        referrerId: referrerId,
        referredId: referredUserId,
        referralCode: referralCode,
        createdAt: DateTime.now(),
        deviceId: deviceId,
        ipAddress: ipAddress,
      );

      await _firestore
          .collection(_referralsCollection)
          .add(referral.toFirestore());

      // Kullanıcı referans bilgilerini güncelle
      await _updateUserReferralStats(referrerId, 1, 0, 0);
    } catch (e) {
      throw Exception('Referans işlemi başlatılırken hata oluştu: $e');
    }
  }

  /// Referans işlemini tamamla
  Future<void> completeReferral(String referredUserId) async {
    try {
      // Referans işlemini bul
      final referralQuery = await _firestore
          .collection(_referralsCollection)
          .where('referredId', isEqualTo: referredUserId)
          .where('status', isEqualTo: ReferralStatus.pending.name)
          .limit(1)
          .get();

      if (referralQuery.docs.isEmpty) {
        return; // Referans işlemi bulunamadı
      }

      final referralDoc = referralQuery.docs.first;
      final referral = ReferralModel.fromFirestore(referralDoc);

      // Referans işlemini tamamla
      final updatedReferral = referral.copyWith(
        status: ReferralStatus.completed,
        completedAt: DateTime.now(),
        pointsEarned: _referrerPoints,
      );

      await _firestore
          .collection(_referralsCollection)
          .doc(referral.id)
          .update(updatedReferral.toFirestore());

      // Davet eden kullanıcıya puan ver
      await _addPointsToUser(referral.referrerId, _referrerPoints);

      // Davet edilen kullanıcıya puan ver
      await _addPointsToUser(referral.referredId, _referredPoints);

      // Kullanıcı referans istatistiklerini güncelle
      await _updateUserReferralStats(
        referral.referrerId,
        0,
        1,
        _referrerPoints,
      );
    } catch (e) {
      throw Exception('Referans işlemi tamamlanırken hata oluştu: $e');
    }
  }

  /// Kullanıcının referanslarını getir
  Stream<List<ReferralModel>> getUserReferrals(String userId) {
    return _firestore
        .collection(_referralsCollection)
        .where('referrerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReferralModel.fromFirestore(doc);
      }).toList();
    });
  }

  /// Referans istatistiklerini getir
  Future<ReferralStats> getReferralStats() async {
    try {
      final referralsSnapshot = await _firestore
          .collection(_referralsCollection)
          .get();

      int totalReferrals = 0;
      int completedReferrals = 0;
      int cancelledReferrals = 0;
      int fraudulentReferrals = 0;
      int totalPointsEarned = 0;

      for (final doc in referralsSnapshot.docs) {
        final referral = ReferralModel.fromFirestore(doc);
        totalReferrals++;

        switch (referral.status) {
          case ReferralStatus.completed:
            completedReferrals++;
            totalPointsEarned += referral.pointsEarned;
            break;
          case ReferralStatus.cancelled:
            cancelledReferrals++;
            break;
          case ReferralStatus.fraudulent:
            fraudulentReferrals++;
            break;
          case ReferralStatus.pending:
            break;
        }
      }

      final averagePointsPerReferral = completedReferrals > 0 
          ? totalPointsEarned / completedReferrals 
          : 0.0;
      
      final successRate = totalReferrals > 0 
          ? completedReferrals / totalReferrals 
          : 0.0;

      return ReferralStats(
        totalReferrals: totalReferrals,
        completedReferrals: completedReferrals,
        cancelledReferrals: cancelledReferrals,
        fraudulentReferrals: fraudulentReferrals,
        totalPointsEarned: totalPointsEarned,
        averagePointsPerReferral: averagePointsPerReferral,
        successRate: successRate,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Referans istatistikleri alınırken hata oluştu: $e');
    }
  }

  /// Sahte referansları tespit et
  Future<List<ReferralModel>> detectFraudulentReferrals() async {
    try {
      final referralsSnapshot = await _firestore
          .collection(_referralsCollection)
          .where('status', isEqualTo: ReferralStatus.completed.name)
          .get();

      final referrals = referralsSnapshot.docs.map((doc) {
        return ReferralModel.fromFirestore(doc);
      }).toList();

      final fraudulentReferrals = <ReferralModel>[];

      // Aynı cihazdan gelen referansları kontrol et
      final deviceGroups = <String, List<ReferralModel>>{};
      for (final referral in referrals) {
        if (referral.deviceId != null) {
          deviceGroups.putIfAbsent(referral.deviceId!, () => []).add(referral);
        }
      }

      for (final deviceReferrals in deviceGroups.values) {
        if (deviceReferrals.length > 3) {
          // Aynı cihazdan 3'ten fazla referans varsa sahte olabilir
          fraudulentReferrals.addAll(deviceReferrals);
        }
      }

      // Aynı IP'den gelen referansları kontrol et
      final ipGroups = <String, List<ReferralModel>>{};
      for (final referral in referrals) {
        if (referral.ipAddress != null) {
          ipGroups.putIfAbsent(referral.ipAddress!, () => []).add(referral);
        }
      }

      for (final ipReferrals in ipGroups.values) {
        if (ipReferrals.length > 5) {
          // Aynı IP'den 5'ten fazla referans varsa sahte olabilir
          fraudulentReferrals.addAll(ipReferrals);
        }
      }

      return fraudulentReferrals.toSet().toList(); // Tekrarları kaldır
    } catch (e) {
      throw Exception('Sahte referanslar tespit edilirken hata oluştu: $e');
    }
  }

  /// Referansı iptal et
  Future<void> cancelReferral(String referralId) async {
    try {
      final doc = await _firestore
          .collection(_referralsCollection)
          .doc(referralId)
          .get();

      if (!doc.exists) {
        throw Exception('Referans bulunamadı');
      }

      final referral = ReferralModel.fromFirestore(doc);

      // Referansı iptal et
      await _firestore
          .collection(_referralsCollection)
          .doc(referralId)
          .update({
        'status': ReferralStatus.cancelled.name,
      });

      // Kullanıcı istatistiklerini güncelle
      await _updateUserReferralStats(
        referral.referrerId,
        0,
        -1,
        -referral.pointsEarned,
      );
    } catch (e) {
      throw Exception('Referans iptal edilirken hata oluştu: $e');
    }
  }

  /// Referansı sahte olarak işaretle
  Future<void> markReferralAsFraudulent(String referralId) async {
    try {
      final doc = await _firestore
          .collection(_referralsCollection)
          .doc(referralId)
          .get();

      if (!doc.exists) {
        throw Exception('Referans bulunamadı');
      }

      final referral = ReferralModel.fromFirestore(doc);

      // Referansı sahte olarak işaretle
      await _firestore
          .collection(_referralsCollection)
          .doc(referralId)
          .update({
        'status': ReferralStatus.fraudulent.name,
      });

      // Kullanıcıdan puanları geri al
      await _addPointsToUser(referral.referrerId, -referral.pointsEarned);

      // Kullanıcı istatistiklerini güncelle
      await _updateUserReferralStats(
        referral.referrerId,
        0,
        -1,
        -referral.pointsEarned,
      );
    } catch (e) {
      throw Exception('Referans sahte olarak işaretlenirken hata oluştu: $e');
    }
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Kullanıcıya puan ekle
  Future<void> _addPointsToUser(String userId, int points) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'points': FieldValue.increment(points),
      });
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  /// Kullanıcı referans istatistiklerini güncelle
  Future<void> _updateUserReferralStats(
    String userId,
    int totalReferralsDelta,
    int completedReferralsDelta,
    int totalPointsEarnedDelta,
  ) async {
    try {
      await _firestore
          .collection(_userReferralsCollection)
          .doc(userId)
          .update({
        'totalReferrals': FieldValue.increment(totalReferralsDelta),
        'completedReferrals': FieldValue.increment(completedReferralsDelta),
        'totalPointsEarned': FieldValue.increment(totalPointsEarnedDelta),
        'lastReferralAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  /// Cihaz ID'sini al
  Future<String?> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('device_id');
      
      if (deviceId == null) {
        deviceId = DateTime.now().millisecondsSinceEpoch.toString();
        await prefs.setString('device_id', deviceId);
      }
      
      return deviceId;
    } catch (e) {
      return null;
    }
  }
}
