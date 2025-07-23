/// Production-Ready Purchase Model
///
/// Represents a purchase transaction in the Altertale application:
/// - Content purchases (stories, premium features)
/// - Point transactions and premium subscriptions
/// - Payment method and transaction details
/// - Purchase status and validation
/// - Refund and cancellation tracking
/// - Firestore-compatible serialization
class PurchaseModel {
  // ==================== CORE FIELDS ====================

  /// Unique purchase transaction ID
  final String id;

  /// User ID who made the purchase
  final String userId;

  /// User display name at time of purchase
  final String userName;

  /// Purchase type (story, subscription, points, feature)
  final String purchaseType;

  /// ID of purchased content (story ID, feature ID, etc.)
  final String? contentId;

  /// Name/title of purchased content
  final String contentTitle;

  // ==================== PRICING & PAYMENT ====================

  /// Purchase amount in the base currency
  final double amount;

  /// Currency code (USD, EUR, TRY, etc.)
  final String currency;

  /// Points used for purchase (if applicable)
  final int? pointsUsed;

  /// Points earned from this purchase
  final int pointsEarned;

  /// Original price before discounts
  final double? originalPrice;

  /// Discount amount applied
  final double? discountAmount;

  /// Discount code/coupon used
  final String? discountCode;

  // ==================== PAYMENT DETAILS ====================

  /// Payment method (card, paypal, appstore, googleplay, points)
  final String paymentMethod;

  /// Payment provider (stripe, apple, google, etc.)
  final String? paymentProvider;

  /// External transaction ID from payment provider
  final String? externalTransactionId;

  /// Payment receipt URL or data
  final String? receiptUrl;

  /// Payment gateway response data
  final Map<String, dynamic>? paymentMetadata;

  // ==================== PURCHASE STATUS ====================

  /// Purchase status (pending, completed, failed, refunded, cancelled)
  final String status;

  /// Whether purchase is verified/validated
  final bool isVerified;

  /// Whether content is currently accessible
  final bool isActive;

  /// Purchase failure reason (if failed)
  final String? failureReason;

  /// Purchase validation date
  final DateTime? verifiedAt;

  // ==================== SUBSCRIPTION DETAILS ====================

  /// Subscription duration in days (for subscription purchases)
  final int? subscriptionDurationDays;

  /// Subscription start date
  final DateTime? subscriptionStartDate;

  /// Subscription end date
  final DateTime? subscriptionEndDate;

  /// Whether subscription auto-renews
  final bool? isAutoRenewing;

  /// Next renewal date
  final DateTime? nextRenewalDate;

  // ==================== REFUND & CANCELLATION ====================

  /// Whether purchase was refunded
  final bool isRefunded;

  /// Refund amount (if different from purchase amount)
  final double? refundAmount;

  /// Refund date
  final DateTime? refundedAt;

  /// Refund reason
  final String? refundReason;

  /// Whether user cancelled (for subscriptions)
  final bool isCancelled;

  /// Cancellation date
  final DateTime? cancelledAt;

  // ==================== METADATA ====================

  /// Platform where purchase was made (ios, android, web)
  final String platform;

  /// App version at time of purchase
  final String? appVersion;

  /// User's IP address at time of purchase
  final String? ipAddress;

  /// User's country code
  final String? countryCode;

  /// Additional purchase metadata
  final Map<String, dynamic>? metadata;

  // ==================== TIMESTAMPS ====================

  /// Purchase initiation timestamp
  final DateTime createdAt;

  /// Purchase completion timestamp
  final DateTime? completedAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Purchase expiry date (for time-limited content)
  final DateTime? expiresAt;

  // ==================== CONSTRUCTOR ====================

  const PurchaseModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.purchaseType,
    this.contentId,
    required this.contentTitle,
    required this.amount,
    this.currency = 'USD',
    this.pointsUsed,
    this.pointsEarned = 0,
    this.originalPrice,
    this.discountAmount,
    this.discountCode,
    required this.paymentMethod,
    this.paymentProvider,
    this.externalTransactionId,
    this.receiptUrl,
    this.paymentMetadata,
    this.status = 'pending',
    this.isVerified = false,
    this.isActive = false,
    this.failureReason,
    this.verifiedAt,
    this.subscriptionDurationDays,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.isAutoRenewing,
    this.nextRenewalDate,
    this.isRefunded = false,
    this.refundAmount,
    this.refundedAt,
    this.refundReason,
    this.isCancelled = false,
    this.cancelledAt,
    this.platform = 'unknown',
    this.appVersion,
    this.ipAddress,
    this.countryCode,
    this.metadata,
    required this.createdAt,
    this.completedAt,
    required this.updatedAt,
    this.expiresAt,
  });

  // ==================== FACTORY CONSTRUCTORS ====================

  /// Create a new purchase
  factory PurchaseModel.create({
    required String id,
    required String userId,
    required String userName,
    required String purchaseType,
    String? contentId,
    required String contentTitle,
    required double amount,
    required String paymentMethod,
    String currency = 'USD',
    String platform = 'unknown',
  }) {
    final now = DateTime.now();
    return PurchaseModel(
      id: id,
      userId: userId,
      userName: userName,
      purchaseType: purchaseType,
      contentId: contentId,
      contentTitle: contentTitle,
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
      platform: platform,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create an empty purchase model
  factory PurchaseModel.empty() {
    final now = DateTime.now();
    return PurchaseModel(
      id: '',
      userId: '',
      userName: '',
      purchaseType: '',
      contentTitle: '',
      amount: 0.0,
      paymentMethod: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  // ==================== SERIALIZATION ====================

  /// Convert PurchaseModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'purchaseType': purchaseType,
      'contentId': contentId,
      'contentTitle': contentTitle,
      'amount': amount,
      'currency': currency,
      'pointsUsed': pointsUsed,
      'pointsEarned': pointsEarned,
      'originalPrice': originalPrice,
      'discountAmount': discountAmount,
      'discountCode': discountCode,
      'paymentMethod': paymentMethod,
      'paymentProvider': paymentProvider,
      'externalTransactionId': externalTransactionId,
      'receiptUrl': receiptUrl,
      'paymentMetadata': paymentMetadata,
      'status': status,
      'isVerified': isVerified,
      'isActive': isActive,
      'failureReason': failureReason,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'subscriptionDurationDays': subscriptionDurationDays,
      'subscriptionStartDate': subscriptionStartDate?.toIso8601String(),
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
      'isAutoRenewing': isAutoRenewing,
      'nextRenewalDate': nextRenewalDate?.toIso8601String(),
      'isRefunded': isRefunded,
      'refundAmount': refundAmount,
      'refundedAt': refundedAt?.toIso8601String(),
      'refundReason': refundReason,
      'isCancelled': isCancelled,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'platform': platform,
      'appVersion': appVersion,
      'ipAddress': ipAddress,
      'countryCode': countryCode,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// Create PurchaseModel from Firestore Map
  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      purchaseType: map['purchaseType'] ?? '',
      contentId: map['contentId'],
      contentTitle: map['contentTitle'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'USD',
      pointsUsed: map['pointsUsed'],
      pointsEarned: map['pointsEarned'] ?? 0,
      originalPrice: map['originalPrice']?.toDouble(),
      discountAmount: map['discountAmount']?.toDouble(),
      discountCode: map['discountCode'],
      paymentMethod: map['paymentMethod'] ?? '',
      paymentProvider: map['paymentProvider'],
      externalTransactionId: map['externalTransactionId'],
      receiptUrl: map['receiptUrl'],
      paymentMetadata: map['paymentMetadata'] != null
          ? Map<String, dynamic>.from(map['paymentMetadata'])
          : null,
      status: map['status'] ?? 'pending',
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? false,
      failureReason: map['failureReason'],
      verifiedAt: map['verifiedAt'] != null
          ? DateTime.parse(map['verifiedAt'])
          : null,
      subscriptionDurationDays: map['subscriptionDurationDays'],
      subscriptionStartDate: map['subscriptionStartDate'] != null
          ? DateTime.parse(map['subscriptionStartDate'])
          : null,
      subscriptionEndDate: map['subscriptionEndDate'] != null
          ? DateTime.parse(map['subscriptionEndDate'])
          : null,
      isAutoRenewing: map['isAutoRenewing'],
      nextRenewalDate: map['nextRenewalDate'] != null
          ? DateTime.parse(map['nextRenewalDate'])
          : null,
      isRefunded: map['isRefunded'] ?? false,
      refundAmount: map['refundAmount']?.toDouble(),
      refundedAt: map['refundedAt'] != null
          ? DateTime.parse(map['refundedAt'])
          : null,
      refundReason: map['refundReason'],
      isCancelled: map['isCancelled'] ?? false,
      cancelledAt: map['cancelledAt'] != null
          ? DateTime.parse(map['cancelledAt'])
          : null,
      platform: map['platform'] ?? 'unknown',
      appVersion: map['appVersion'],
      ipAddress: map['ipAddress'],
      countryCode: map['countryCode'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'])
          : null,
    );
  }

  // ==================== COPY WITH ====================

  /// Create a copy of PurchaseModel with updated fields
  PurchaseModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? purchaseType,
    String? contentId,
    String? contentTitle,
    double? amount,
    String? currency,
    int? pointsUsed,
    int? pointsEarned,
    double? originalPrice,
    double? discountAmount,
    String? discountCode,
    String? paymentMethod,
    String? paymentProvider,
    String? externalTransactionId,
    String? receiptUrl,
    Map<String, dynamic>? paymentMetadata,
    String? status,
    bool? isVerified,
    bool? isActive,
    String? failureReason,
    DateTime? verifiedAt,
    int? subscriptionDurationDays,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    bool? isAutoRenewing,
    DateTime? nextRenewalDate,
    bool? isRefunded,
    double? refundAmount,
    DateTime? refundedAt,
    String? refundReason,
    bool? isCancelled,
    DateTime? cancelledAt,
    String? platform,
    String? appVersion,
    String? ipAddress,
    String? countryCode,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      purchaseType: purchaseType ?? this.purchaseType,
      contentId: contentId ?? this.contentId,
      contentTitle: contentTitle ?? this.contentTitle,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      pointsUsed: pointsUsed ?? this.pointsUsed,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      originalPrice: originalPrice ?? this.originalPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      discountCode: discountCode ?? this.discountCode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      externalTransactionId:
          externalTransactionId ?? this.externalTransactionId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      paymentMetadata: paymentMetadata ?? this.paymentMetadata,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      failureReason: failureReason ?? this.failureReason,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      subscriptionDurationDays:
          subscriptionDurationDays ?? this.subscriptionDurationDays,
      subscriptionStartDate:
          subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      isAutoRenewing: isAutoRenewing ?? this.isAutoRenewing,
      nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
      isRefunded: isRefunded ?? this.isRefunded,
      refundAmount: refundAmount ?? this.refundAmount,
      refundedAt: refundedAt ?? this.refundedAt,
      refundReason: refundReason ?? this.refundReason,
      isCancelled: isCancelled ?? this.isCancelled,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      ipAddress: ipAddress ?? this.ipAddress,
      countryCode: countryCode ?? this.countryCode,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  // ==================== HELPER METHODS ====================

  /// Check if purchase is completed successfully
  bool get isCompleted {
    return status == 'completed' && isVerified && !isRefunded;
  }

  /// Check if purchase is pending payment
  bool get isPending {
    return status == 'pending';
  }

  /// Check if purchase failed
  bool get isFailed {
    return status == 'failed';
  }

  /// Check if subscription is currently active
  bool get isSubscriptionActive {
    if (subscriptionEndDate == null) return false;
    return DateTime.now().isBefore(subscriptionEndDate!) &&
        !isCancelled &&
        !isRefunded;
  }

  /// Check if purchase has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get purchase type display name
  String get purchaseTypeDisplayName {
    switch (purchaseType) {
      case 'story':
        return 'Hikaye Satın Alma';
      case 'subscription':
        return 'Premium Abonelik';
      case 'points':
        return 'Puan Satın Alma';
      case 'feature':
        return 'Özellik Satın Alma';
      default:
        return 'Satın Alma';
    }
  }

  /// Get payment method display name
  String get paymentMethodDisplayName {
    switch (paymentMethod) {
      case 'card':
        return 'Kredi Kartı';
      case 'paypal':
        return 'PayPal';
      case 'appstore':
        return 'App Store';
      case 'googleplay':
        return 'Google Play';
      case 'points':
        return 'Puanlar';
      default:
        return paymentMethod;
    }
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'completed':
        return 'Tamamlandı';
      case 'failed':
        return 'Başarısız';
      case 'refunded':
        return 'İade Edildi';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return status;
    }
  }

  /// Calculate final price after discounts
  double get finalPrice {
    if (discountAmount != null) {
      return amount - discountAmount!;
    }
    return amount;
  }

  /// Calculate discount percentage
  double get discountPercentage {
    if (originalPrice == null || discountAmount == null || originalPrice == 0) {
      return 0.0;
    }
    return (discountAmount! / originalPrice!) * 100;
  }

  /// Get formatted amount with currency
  String get formattedAmount {
    switch (currency) {
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      case 'TRY':
        return '₺${amount.toStringAsFixed(2)}';
      default:
        return '${amount.toStringAsFixed(2)} $currency';
    }
  }

  /// Get days until subscription expires
  int? get daysUntilExpiry {
    if (subscriptionEndDate == null) return null;
    final difference = subscriptionEndDate!.difference(DateTime.now());
    return difference.inDays;
  }

  /// Check if purchase is eligible for refund
  bool get isRefundEligible {
    if (isRefunded || isFailed || status != 'completed') return false;

    // Example: 7 days refund policy
    final refundDeadline = createdAt.add(const Duration(days: 7));
    return DateTime.now().isBefore(refundDeadline);
  }

  // ==================== EQUALITY & HASH ====================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PurchaseModel) return false;
    return id == other.id &&
        userId == other.userId &&
        contentId == other.contentId &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, contentId, createdAt);
  }

  @override
  String toString() {
    return 'PurchaseModel(id: $id, user: $userName, type: $purchaseType, '
        'amount: $formattedAmount, status: $status, '
        'method: $paymentMethod, createdAt: $createdAt)';
  }
}
