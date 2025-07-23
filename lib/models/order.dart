import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item.dart';

/// Order Status Enum
enum OrderStatus {
  pending('Beklemede'),
  confirmed('Onaylandı'),
  processing('İşleniyor'),
  shipped('Kargoya Verildi'),
  delivered('Teslim Edildi'),
  cancelled('İptal Edildi'),
  refunded('İade Edildi');

  const OrderStatus(this.displayName);
  final String displayName;

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'refunded':
        return OrderStatus.refunded;
      default:
        return OrderStatus.pending;
    }
  }
}

/// Payment Status Enum
enum PaymentStatus {
  pending('Ödeme Bekleniyor'),
  completed('Ödeme Tamamlandı'),
  failed('Ödeme Başarısız'),
  refunded('İade Edildi');

  const PaymentStatus(this.displayName);
  final String displayName;

  static PaymentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }
}

/// Order Model
///
/// Represents a complete order with items, status, and payment info
class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalPrice;
  final double taxAmount;
  final double shippingFee;
  final double discountAmount;
  final double finalTotal;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final DateTime orderDate;
  final DateTime? shippingDate;
  final DateTime? deliveryDate;
  final String? shippingAddress;
  final String? billingAddress;
  final String? paymentMethod;
  final String? trackingNumber;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    this.taxAmount = 0.0,
    this.shippingFee = 0.0,
    this.discountAmount = 0.0,
    required this.finalTotal,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    required this.orderDate,
    this.shippingDate,
    this.deliveryDate,
    this.shippingAddress,
    this.billingAddress,
    this.paymentMethod,
    this.trackingNumber,
    this.notes,
    this.metadata,
  });

  /// Create Order from Firestore document
  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order.fromMap(data, doc.id);
  }

  /// Create Order from Map with ID
  factory Order.fromMap(Map<String, dynamic> map, [String? id]) {
    return Order(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['taxAmount'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (map['shippingFee'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalTotal: (map['finalTotal'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.fromString(map['status'] as String? ?? 'pending'),
      paymentStatus: PaymentStatus.fromString(
        map['paymentStatus'] as String? ?? 'pending',
      ),
      orderDate: (map['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      shippingDate: (map['shippingDate'] as Timestamp?)?.toDate(),
      deliveryDate: (map['deliveryDate'] as Timestamp?)?.toDate(),
      shippingAddress: map['shippingAddress'] as String?,
      billingAddress: map['billingAddress'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
      trackingNumber: map['trackingNumber'] as String?,
      notes: map['notes'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'taxAmount': taxAmount,
      'shippingFee': shippingFee,
      'discountAmount': discountAmount,
      'finalTotal': finalTotal,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'orderDate': Timestamp.fromDate(orderDate),
      'shippingDate': shippingDate != null
          ? Timestamp.fromDate(shippingDate!)
          : null,
      'deliveryDate': deliveryDate != null
          ? Timestamp.fromDate(deliveryDate!)
          : null,
      'shippingAddress': shippingAddress,
      'billingAddress': billingAddress,
      'paymentMethod': paymentMethod,
      'trackingNumber': trackingNumber,
      'notes': notes,
      'metadata': metadata,
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  /// Copy with modifications
  Order copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? totalPrice,
    double? taxAmount,
    double? shippingFee,
    double? discountAmount,
    double? finalTotal,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? orderDate,
    DateTime? shippingDate,
    DateTime? deliveryDate,
    String? shippingAddress,
    String? billingAddress,
    String? paymentMethod,
    String? trackingNumber,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      taxAmount: taxAmount ?? this.taxAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      discountAmount: discountAmount ?? this.discountAmount,
      finalTotal: finalTotal ?? this.finalTotal,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderDate: orderDate ?? this.orderDate,
      shippingDate: shippingDate ?? this.shippingDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Order number for display (last 8 chars of ID)
  String get orderNumber =>
      id.length > 8 ? '#${id.substring(id.length - 8).toUpperCase()}' : '#$id';

  /// Total items count
  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Unique items count
  int get uniqueItemsCount => items.length;

  /// Formatted final total
  String get formattedFinalTotal => '${finalTotal.toStringAsFixed(2)} TL';

  /// Formatted order date
  String get formattedOrderDate {
    return '${orderDate.day.toString().padLeft(2, '0')}.'
        '${orderDate.month.toString().padLeft(2, '0')}.'
        '${orderDate.year}';
  }

  /// Detailed order date with time
  String get detailedOrderDate {
    return '${orderDate.day.toString().padLeft(2, '0')}.'
        '${orderDate.month.toString().padLeft(2, '0')}.'
        '${orderDate.year} '
        '${orderDate.hour.toString().padLeft(2, '0')}:'
        '${orderDate.minute.toString().padLeft(2, '0')}';
  }

  /// Check if order can be cancelled
  bool get canBeCancelled {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  /// Check if order is completed
  bool get isCompleted {
    return status == OrderStatus.delivered;
  }

  /// Check if order is active (not cancelled or delivered)
  bool get isActive {
    return status != OrderStatus.cancelled &&
        status != OrderStatus.delivered &&
        status != OrderStatus.refunded;
  }

  /// Status color for UI
  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFFF9800); // Orange
      case OrderStatus.confirmed:
        return const Color(0xFF2196F3); // Blue
      case OrderStatus.processing:
        return const Color(0xFF9C27B0); // Purple
      case OrderStatus.shipped:
        return const Color(0xFF03DAC6); // Teal
      case OrderStatus.delivered:
        return const Color(0xFF4CAF50); // Green
      case OrderStatus.cancelled:
        return const Color(0xFFF44336); // Red
      case OrderStatus.refunded:
        return const Color(0xFF795548); // Brown
    }
  }

  /// Payment status color for UI
  Color get paymentStatusColor {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return const Color(0xFFFF9800); // Orange
      case PaymentStatus.completed:
        return const Color(0xFF4CAF50); // Green
      case PaymentStatus.failed:
        return const Color(0xFFF44336); // Red
      case PaymentStatus.refunded:
        return const Color(0xFF795548); // Brown
    }
  }

  /// Sample Order for testing
  static Order sample() {
    return Order(
      id: 'sample-order-123',
      userId: 'sample-user-id',
      items: [OrderItem.sample()],
      totalPrice: 29.99,
      taxAmount: 5.40,
      shippingFee: 9.99,
      discountAmount: 0.0,
      finalTotal: 45.38,
      status: OrderStatus.confirmed,
      paymentStatus: PaymentStatus.completed,
      orderDate: DateTime.now(),
      paymentMethod: 'Kredi Kartı',
      notes: 'Örnek sipariş notları',
    );
  }

  /// Validation
  bool isValid() {
    return userId.isNotEmpty &&
        items.isNotEmpty &&
        totalPrice >= 0 &&
        finalTotal >= 0 &&
        items.every((item) => item.isValid());
  }

  /// Get validation error message
  String? getValidationError() {
    if (userId.isEmpty) return 'Kullanıcı ID boş olamaz';
    if (items.isEmpty) return 'Sipariş ürün içermeli';
    if (totalPrice < 0) return 'Toplam tutar negatif olamaz';
    if (finalTotal < 0) return 'Final toplam negatif olamaz';

    for (var item in items) {
      final itemError = item.getValidationError();
      if (itemError != null) return 'Ürün hatası: $itemError';
    }

    return null;
  }

  @override
  String toString() {
    return 'Order(id: $id, userId: $userId, totalItems: $totalItemsCount, finalTotal: $finalTotal, status: ${status.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
