import 'package:cloud_firestore/cloud_firestore.dart';

/// Referans durumu
enum ReferralStatus {
  pending('Beklemede'),
  completed('Tamamlandı'),
  cancelled('İptal Edildi'),
  fraudulent('Sahte');

  const ReferralStatus(this.displayName);
  final String displayName;
}

/// Referans modeli
class ReferralModel {
  final String id;
  final String referrerId; // Davet eden kullanıcı ID'si
  final String referredId; // Davet edilen kullanıcı ID'si
  final String referralCode; // Kullanılan referans kodu
  final DateTime createdAt;
  final DateTime? completedAt;
  final ReferralStatus status;
  final int pointsEarned; // Kazanılan puan
  final String? deviceId; // Cihaz ID'si (sahte hesap kontrolü için)
  final String? ipAddress; // IP adresi (sahte hesap kontrolü için)

  ReferralModel({
    required this.id,
    required this.referrerId,
    required this.referredId,
    required this.referralCode,
    required this.createdAt,
    this.completedAt,
    this.status = ReferralStatus.pending,
    this.pointsEarned = 0,
    this.deviceId,
    this.ipAddress,
  });

  /// Firestore'dan model oluştur
  factory ReferralModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReferralModel(
      id: doc.id,
      referrerId: data['referrerId'] ?? '',
      referredId: data['referredId'] ?? '',
      referralCode: data['referralCode'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      status: ReferralStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => ReferralStatus.pending,
      ),
      pointsEarned: data['pointsEarned'] ?? 0,
      deviceId: data['deviceId'],
      ipAddress: data['ipAddress'],
    );
  }

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'referrerId': referrerId,
      'referredId': referredId,
      'referralCode': referralCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'status': status.name,
      'pointsEarned': pointsEarned,
      'deviceId': deviceId,
      'ipAddress': ipAddress,
    };
  }

  /// Referansı güncelle
  ReferralModel copyWith({
    DateTime? completedAt,
    ReferralStatus? status,
    int? pointsEarned,
  }) {
    return ReferralModel(
      id: id,
      referrerId: referrerId,
      referredId: referredId,
      referralCode: referralCode,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      deviceId: deviceId,
      ipAddress: ipAddress,
    );
  }

  /// Referans tamamlanmış mı?
  bool get isCompleted => status == ReferralStatus.completed;

  /// Referans iptal edilmiş mi?
  bool get isCancelled => status == ReferralStatus.cancelled;

  /// Referans sahte mi?
  bool get isFraudulent => status == ReferralStatus.fraudulent;

  /// Referans geçerli mi?
  bool get isValid => status == ReferralStatus.completed;
}

/// Kullanıcı referans bilgileri modeli
class UserReferralInfo {
  final String userId;
  final String referralCode;
  final String? referredByCode; // Bu kullanıcının kullandığı referans kodu
  final int totalReferrals; // Toplam davet edilen kişi sayısı
  final int completedReferrals; // Tamamlanan referans sayısı
  final int totalPointsEarned; // Toplam kazanılan puan
  final DateTime createdAt;
  final DateTime? lastReferralAt; // Son referans tarihi

  UserReferralInfo({
    required this.userId,
    required this.referralCode,
    this.referredByCode,
    this.totalReferrals = 0,
    this.completedReferrals = 0,
    this.totalPointsEarned = 0,
    required this.createdAt,
    this.lastReferralAt,
  });

  /// Firestore'dan model oluştur
  factory UserReferralInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserReferralInfo(
      userId: doc.id,
      referralCode: data['referralCode'] ?? '',
      referredByCode: data['referredByCode'],
      totalReferrals: data['totalReferrals'] ?? 0,
      completedReferrals: data['completedReferrals'] ?? 0,
      totalPointsEarned: data['totalPointsEarned'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastReferralAt: data['lastReferralAt'] != null 
          ? (data['lastReferralAt'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'referralCode': referralCode,
      'referredByCode': referredByCode,
      'totalReferrals': totalReferrals,
      'completedReferrals': completedReferrals,
      'totalPointsEarned': totalPointsEarned,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastReferralAt': lastReferralAt != null ? Timestamp.fromDate(lastReferralAt!) : null,
    };
  }

  /// Referans bilgilerini güncelle
  UserReferralInfo copyWith({
    String? referralCode,
    String? referredByCode,
    int? totalReferrals,
    int? completedReferrals,
    int? totalPointsEarned,
    DateTime? lastReferralAt,
  }) {
    return UserReferralInfo(
      userId: userId,
      referralCode: referralCode ?? this.referralCode,
      referredByCode: referredByCode ?? this.referredByCode,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      completedReferrals: completedReferrals ?? this.completedReferrals,
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
      createdAt: createdAt,
      lastReferralAt: lastReferralAt ?? this.lastReferralAt,
    );
  }

  /// Referans kodu var mı?
  bool get hasReferralCode => referralCode.isNotEmpty;

  /// Referans edilmiş mi?
  bool get hasBeenReferred => referredByCode != null && referredByCode!.isNotEmpty;

  /// Başarı oranı
  double get successRate {
    if (totalReferrals == 0) return 0.0;
    return completedReferrals / totalReferrals;
  }

  /// Ortalama puan (tamamlanan referans başına)
  double get averagePointsPerReferral {
    if (completedReferrals == 0) return 0.0;
    return totalPointsEarned / completedReferrals;
  }
}

/// Referans istatistikleri modeli
class ReferralStats {
  final int totalReferrals;
  final int completedReferrals;
  final int cancelledReferrals;
  final int fraudulentReferrals;
  final int totalPointsEarned;
  final double averagePointsPerReferral;
  final double successRate;
  final DateTime lastUpdated;

  const ReferralStats({
    this.totalReferrals = 0,
    this.completedReferrals = 0,
    this.cancelledReferrals = 0,
    this.fraudulentReferrals = 0,
    this.totalPointsEarned = 0,
    this.averagePointsPerReferral = 0.0,
    this.successRate = 0.0,
    required this.lastUpdated,
  });

  /// Firestore'dan model oluştur
  factory ReferralStats.fromFirestore(Map<String, dynamic> data) {
    final totalReferrals = data['totalReferrals'] ?? 0;
    final completedReferrals = data['completedReferrals'] ?? 0;
    final cancelledReferrals = data['cancelledReferrals'] ?? 0;
    final fraudulentReferrals = data['fraudulentReferrals'] ?? 0;
    final totalPointsEarned = data['totalPointsEarned'] ?? 0;

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
      lastUpdated: data['lastUpdated'] != null 
          ? (data['lastUpdated'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'totalReferrals': totalReferrals,
      'completedReferrals': completedReferrals,
      'cancelledReferrals': cancelledReferrals,
      'fraudulentReferrals': fraudulentReferrals,
      'totalPointsEarned': totalPointsEarned,
      'averagePointsPerReferral': averagePointsPerReferral,
      'successRate': successRate,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}

/// Referans kodu oluşturma yardımcı sınıfı
class ReferralCodeGenerator {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const int _codeLength = 6;

  /// Benzersiz referans kodu oluştur
  static String generateCode() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    
    for (int i = 0; i < _codeLength; i++) {
      final index = (random + i) % _chars.length;
      buffer.write(_chars[index]);
    }
    
    return buffer.toString();
  }

  /// Referans kodunu doğrula
  static bool isValidCode(String code) {
    if (code.length != _codeLength) return false;
    
    // Sadece büyük harf ve rakam içermeli
    final regex = RegExp(r'^[A-Z0-9]{6}$');
    return regex.hasMatch(code);
  }
}
