import 'package:cloud_firestore/cloud_firestore.dart';

/// OrderItem Model
///
/// Represents a single item within an order
class OrderItem {
  final String bookId;
  final String title;
  final String author;
  final String? imageUrl;
  final double price;
  final int quantity;
  final DateTime addedAt;

  const OrderItem({
    required this.bookId,
    required this.title,
    required this.author,
    this.imageUrl,
    required this.price,
    required this.quantity,
    required this.addedAt,
  });

  /// Create OrderItem from Firestore document
  factory OrderItem.fromFirestore(Map<String, dynamic> data) {
    return OrderItem(
      bookId: data['bookId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      author: data['author'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] as int? ?? 1,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create OrderItem from Map
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      bookId: map['bookId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      author: map['author'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] as int? ?? 1,
      addedAt: map['addedAt'] is DateTime
          ? map['addedAt'] as DateTime
          : DateTime.now(),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  /// Copy with modifications
  OrderItem copyWith({
    String? bookId,
    String? title,
    String? author,
    String? imageUrl,
    double? price,
    int? quantity,
    DateTime? addedAt,
  }) {
    return OrderItem(
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Total price for this item
  double get totalPrice => price * quantity;

  /// Formatted total price
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(2)} TL';

  /// Formatted unit price
  String get formattedUnitPrice => '${price.toStringAsFixed(2)} TL';

  /// Display name for UI
  String get displayName => title.isNotEmpty ? title : 'Bilinmeyen Kitap';

  /// Check if item has valid image
  bool get hasValidImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Safe image URL
  String get safeImageUrl => hasValidImage ? imageUrl! : '';

  /// Check if item is free
  bool get isFree => price == 0.0;

  /// Quantity text for display
  String get quantityText => quantity == 1 ? '1 adet' : '$quantity adet';

  /// Summary text for item
  String get summaryText =>
      '$displayName - $quantityText - $formattedTotalPrice';

  /// Sample OrderItem for testing
  static OrderItem sample() {
    return OrderItem(
      bookId: 'sample-book-id',
      title: 'Örnek Kitap',
      author: 'Örnek Yazar',
      imageUrl: 'https://via.placeholder.com/150x200/0066CC/FFFFFF?text=Book',
      price: 29.99,
      quantity: 1,
      addedAt: DateTime.now(),
    );
  }

  /// Validation
  bool isValid() {
    return bookId.isNotEmpty &&
        title.isNotEmpty &&
        author.isNotEmpty &&
        price >= 0 &&
        quantity > 0;
  }

  /// Get validation error message
  String? getValidationError() {
    if (bookId.isEmpty) return 'Kitap ID boş olamaz';
    if (title.isEmpty) return 'Kitap başlığı boş olamaz';
    if (author.isEmpty) return 'Yazar adı boş olamaz';
    if (price < 0) return 'Fiyat negatif olamaz';
    if (quantity <= 0) return 'Miktar sıfırdan büyük olmalı';
    return null;
  }

  @override
  String toString() {
    return 'OrderItem(bookId: $bookId, title: $title, author: $author, price: $price, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem && other.bookId == bookId;
  }

  @override
  int get hashCode => bookId.hashCode;
}
