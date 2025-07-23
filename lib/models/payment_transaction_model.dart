import 'package:cloud_firestore/cloud_firestore.dart';

/// Ödeme işlemi modeli
class PaymentTransactionModel {
  final String id;
  final String userId;
  final String bookId;
  final String paymentType; // 'points', 'tl', 'stripe', 'iyzico'
  final double? amount;
  final String currency; // 'points', 'TL', 'USD', 'EUR'
  final String status; // 'pending', 'completed', 'failed', 'cancelled'
  final String gateway; // 'fake_payment', 'stripe', 'iyzico'
  final String platform; // 'flutter', 'web', 'ios', 'android'
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  PaymentTransactionModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.paymentType,
    this.amount,
    required this.currency,
    required this.status,
    required this.gateway,
    required this.platform,
    required this.metadata,
    required this.createdAt,
    this.completedAt,
    this.updatedAt,
  });

  /// Firestore'dan model oluştur
  factory PaymentTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PaymentTransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      paymentType: data['paymentType'] ?? '',
      amount: data['amount']?.toDouble(),
      currency: data['currency'] ?? '',
      status: data['status'] ?? '',
      gateway: data['gateway'] ?? '',
      platform: data['platform'] ?? '',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Firestore'a kaydetmek için map oluştur
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bookId': bookId,
      'paymentType': paymentType,
      'amount': amount,
      'currency': currency,
      'status': status,
      'gateway': gateway,
      'platform': platform,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Modeli kopyala ve güncelle
  PaymentTransactionModel copyWith({
    String? id,
    String? userId,
    String? bookId,
    String? paymentType,
    double? amount,
    String? currency,
    String? status,
    String? gateway,
    String? platform,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return PaymentTransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      paymentType: paymentType ?? this.paymentType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      gateway: gateway ?? this.gateway,
      platform: platform ?? this.platform,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Ödeme tipine göre icon
  String get paymentTypeIcon {
    switch (paymentType) {
      case 'points':
        return '⭐';
      case 'tl':
        return '₺';
      case 'stripe':
        return '💳';
      case 'iyzico':
        return '🏦';
      default:
        return '💰';
    }
  }

  /// Ödeme tipine göre renk
  String get paymentTypeColor {
    switch (paymentType) {
      case 'points':
        return '#FFD700'; // Altın
      case 'tl':
        return '#4CAF50'; // Yeşil
      case 'stripe':
        return '#6772E5'; // Stripe mavi
      case 'iyzico':
        return '#FF6B35'; // İyzico turuncu
      default:
        return '#607D8B'; // Gri
    }
  }

  /// Duruma göre icon
  String get statusIcon {
    switch (status) {
      case 'completed':
        return '✅';
      case 'pending':
        return '⏳';
      case 'failed':
        return '❌';
      case 'cancelled':
        return '🚫';
      default:
        return '❓';
    }
  }

  /// Duruma göre renk
  String get statusColor {
    switch (status) {
      case 'completed':
        return '#4CAF50'; // Yeşil
      case 'pending':
        return '#FF9800'; // Turuncu
      case 'failed':
        return '#F44336'; // Kırmızı
      case 'cancelled':
        return '#9E9E9E'; // Gri
      default:
        return '#607D8B'; // Gri
    }
  }

  /// Durum metni
  String get statusText {
    switch (status) {
      case 'completed':
        return 'Tamamlandı';
      case 'pending':
        return 'Beklemede';
      case 'failed':
        return 'Başarısız';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return 'Bilinmiyor';
    }
  }

  /// Ödeme tipi metni
  String get paymentTypeText {
    switch (paymentType) {
      case 'points':
        return 'Puan ile Öde';
      case 'tl':
        return 'TL ile Öde';
      case 'stripe':
        return 'Kredi Kartı (Stripe)';
      case 'iyzico':
        return 'Kredi Kartı (İyzico)';
      default:
        return 'Bilinmiyor';
    }
  }

  /// Gateway metni
  String get gatewayText {
    switch (gateway) {
      case 'fake_payment':
        return 'Test Ödeme';
      case 'stripe':
        return 'Stripe';
      case 'iyzico':
        return 'İyzico';
      default:
        return 'Bilinmiyor';
    }
  }

  /// Platform metni
  String get platformText {
    switch (platform) {
      case 'flutter':
        return 'Flutter App';
      case 'web':
        return 'Web';
      case 'ios':
        return 'iOS';
      case 'android':
        return 'Android';
      default:
        return 'Bilinmiyor';
    }
  }

  /// Tutar formatı
  String get formattedAmount {
    if (amount == null) return '0';
    
    if (currency == 'points') {
      return '${amount!.toInt()} puan';
    } else if (currency == 'TL') {
      return '${amount!.toStringAsFixed(2)} ₺';
    } else {
      return '${amount!.toStringAsFixed(2)} $currency';
    }
  }

  /// Tarih formatı
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  /// Detaylı tarih formatı
  String get detailedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Sahte ödeme mi?
  bool get isFakePayment {
    return gateway == 'fake_payment' || metadata['fakePayment'] == true;
  }

  /// Gerçek ödeme mi?
  bool get isRealPayment {
    return !isFakePayment;
  }

  /// Tamamlanmış mı?
  bool get isCompleted {
    return status == 'completed';
  }

  /// Beklemede mi?
  bool get isPending {
    return status == 'pending';
  }

  /// Başarısız mı?
  bool get isFailed {
    return status == 'failed';
  }

  /// İptal edilmiş mi?
  bool get isCancelled {
    return status == 'cancelled';
  }

  @override
  String toString() {
    return 'PaymentTransactionModel(id: $id, paymentType: $paymentType, status: $status, amount: $formattedAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentTransactionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 