import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// Referans işlemleri servisi
class ReferralService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String usersCollection = 'users';
  final String referralsCollection = 'referrals';
  final int dailyReferralLimit = 5;

  /// Kullanıcıya özel referans kodu üretir ve kaydeder
  Future<String> generateReferralCode(String userId, {String? username}) async {
    final code = username != null && username.isNotEmpty
        ? _slugify(username) + userId.substring(0, 4)
        : const Uuid().v4().substring(0, 8);
    final userRef = _firestore.collection(usersCollection).doc(userId);
    await userRef.update({'referralCode': code});
    return code;
  }

  /// Referans kodunu doğrular ve referans işlemini başlatır
  Future<void> useReferralCode({
    required String invitedUid,
    required String referCode,
  }) async {
    // Kodun geçerli olup olmadığını kontrol et
    final inviterSnap = await _firestore
        .collection(usersCollection)
        .where('referralCode', isEqualTo: referCode)
        .limit(1)
        .get();
    if (inviterSnap.docs.isEmpty) throw Exception('Referans kodu geçersiz.');
    final inviterUid = inviterSnap.docs.first.id;
    if (inviterUid == invitedUid) throw Exception('Kendi kodunuzu kullanamazsınız.');

    // Aynı kullanıcıdan tekrar puan kazanımı engelle
    final existing = await _firestore
        .collection(referralsCollection)
        .where('inviterUid', isEqualTo: inviterUid)
        .where('invitedUid', isEqualTo: invitedUid)
        .get();
    if (existing.docs.isNotEmpty) throw Exception('Bu kullanıcıdan zaten puan kazandınız.');

    // Günlük limit kontrolü
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final dailyCount = await _firestore
        .collection(referralsCollection)
        .where('inviterUid', isEqualTo: inviterUid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .get();
    if (dailyCount.docs.length >= dailyReferralLimit) {
      throw Exception('Bu referans kodu ile bugün en fazla $dailyReferralLimit kişi puan kazanabilir.');
    }

    // Puanları ekle ve referral kaydı oluştur
    await _firestore.runTransaction((transaction) async {
      final inviterRef = _firestore.collection(usersCollection).doc(inviterUid);
      final invitedRef = _firestore.collection(usersCollection).doc(invitedUid);
      final referralRef = _firestore.collection(referralsCollection).doc();
      final now = DateTime.now();

      // Kodun sahibine 10 puan ve referralCount/referralPoints artır
      transaction.update(inviterRef, {
        'totalPoints': FieldValue.increment(10),
        'referralCount': FieldValue.increment(1),
        'referralPoints': FieldValue.increment(10),
        'updatedAt': now,
      });
      // Yeni kullanıcıya 5 puan hoşgeldin bonusu
      transaction.update(invitedRef, {
        'totalPoints': FieldValue.increment(5),
        'referralPoints': FieldValue.increment(5),
        'referredBy': inviterUid,
        'updatedAt': now,
      });
      // Referral kaydı
      transaction.set(referralRef, {
        'inviterUid': inviterUid,
        'invitedUid': invitedUid,
        'pointsEarned': 10,
        'timestamp': now,
      });
    });
  }

  /// Kullanıcının referans kodunu getirir (yoksa oluşturur)
  Future<String> getOrCreateReferralCode(String userId, {String? username}) async {
    final userRef = _firestore.collection(usersCollection).doc(userId);
    final userSnap = await userRef.get();
    if (!userSnap.exists) throw Exception('Kullanıcı bulunamadı');
    final data = userSnap.data() as Map<String, dynamic>;
    if (data['referralCode'] != null && data['referralCode'].toString().isNotEmpty) {
      return data['referralCode'];
    }
    return generateReferralCode(userId, username: username);
  }

  String _slugify(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
} 