import 'package:cloud_firestore/cloud_firestore.dart';

/// Cart Item Model for Shopping Cart
///
/// Represents a book item in user's shopping cart.
/// Stored in Firestore under user-specific cart collection.
class CartItem {
  final String id;
  final String bookId;
  final String title;
  final String author;
  final String imageUrl;
  final double price;
  final int quantity;
  final String userId;
  final DateTime? addedAt;
  final DateTime? updatedAt;

  const CartItem({
    required this.id,
    required this.bookId,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.userId,
    this.addedAt,
    this.updatedAt,
  });

  /// Create empty CartItem for null checking
  factory CartItem.empty() {
    return const CartItem(
      id: '',
      bookId: '',
      title: '',
      author: '',
      imageUrl: '',
      price: 0.0,
      quantity: 0,
      userId: '',
    );
  }

  /// Create CartItem from Firestore DocumentSnapshot
  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CartItem(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      userId: data['userId'] ?? '',
      addedAt: data['addedAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  /// Create CartItem from Map (for testing/manual creation)
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      bookId: map['bookId'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      userId: map['userId'] ?? '',
      addedAt: map['addedAt'] is Timestamp
          ? (map['addedAt'] as Timestamp).toDate()
          : map['addedAt'] is DateTime
          ? map['addedAt']
          : null,
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : map['updatedAt'] is DateTime
          ? map['updatedAt']
          : null,
    );
  }

  /// Convert CartItem to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'userId': userId,
      'addedAt': addedAt != null
          ? Timestamp.fromDate(addedAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert CartItem to JSON (for debugging/logging)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'userId': userId,
      'addedAt': addedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy of CartItem with updated fields
  CartItem copyWith({
    String? id,
    String? bookId,
    String? title,
    String? author,
    String? imageUrl,
    double? price,
    int? quantity,
    String? userId,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      userId: userId ?? this.userId,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get total price for this cart item (price * quantity)
  double get totalPrice {
    return price * quantity;
  }

  /// Get formatted total price string
  String get formattedTotalPrice {
    if (totalPrice == 0) {
      return 'Ücretsiz';
    }
    return '${totalPrice.toStringAsFixed(2)} ₺';
  }

  /// Get formatted unit price string
  String get formattedUnitPrice {
    if (price == 0) {
      return 'Ücretsiz';
    }
    return '${price.toStringAsFixed(2)} ₺';
  }

  /// Get book display name (title by author)
  String get displayName {
    return '$title - $author';
  }

  /// Check if cart item has valid image
  bool get hasValidImage {
    return imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http') || imageUrl.startsWith('https'));
  }

  /// Get safe image URL with fallback
  String get safeImageUrl {
    if (hasValidImage) {
      return imageUrl;
    }
    // Return a placeholder image URL
    return 'https://via.placeholder.com/150x200/E3F2FD/1976D2?text=${Uri.encodeComponent(title)}';
  }

  /// Check if this is a free book
  bool get isFree {
    return price == 0;
  }

  /// Get quantity display text
  String get quantityText {
    return 'Adet: $quantity';
  }

  /// Get summary text for cart item
  String get summaryText {
    if (quantity == 1) {
      return '$title ($formattedUnitPrice)';
    } else {
      return '$title x$quantity ($formattedTotalPrice)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CartItem &&
        other.id == id &&
        other.bookId == bookId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(id, bookId, userId);
  }

  @override
  String toString() {
    return 'CartItem(id: $id, bookId: $bookId, title: $title, quantity: $quantity, price: $price, userId: $userId)';
  }

  /// Create a sample cart item for testing
  static CartItem sample({
    String? id,
    String? bookId,
    String? title,
    String? author,
    String? imageUrl,
    double? price,
    int? quantity,
    String? userId,
  }) {
    return CartItem(
      id: id ?? 'sample_cart_item_id',
      bookId: bookId ?? 'sample_book_id',
      title: title ?? 'Örnek Kitap',
      author: author ?? 'Örnek Yazar',
      imageUrl:
          imageUrl ??
          'https://via.placeholder.com/150x200/E3F2FD/1976D2?text=Örnek+Kitap',
      price: price ?? 29.99,
      quantity: quantity ?? 1,
      userId: userId ?? 'sample_user_id',
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create CartItem from Book model
  static CartItem fromBook({
    required String bookId,
    required String title,
    required String author,
    required String imageUrl,
    required double price,
    required String userId,
    int quantity = 1,
    String? cartItemId,
  }) {
    return CartItem(
      id: cartItemId ?? '',
      bookId: bookId,
      title: title,
      author: author,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity,
      userId: userId,
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Validate cart item data
  bool isValid() {
    return bookId.isNotEmpty &&
        title.isNotEmpty &&
        author.isNotEmpty &&
        userId.isNotEmpty &&
        price >= 0 &&
        quantity > 0;
  }

  /// Get validation error message
  String? getValidationError() {
    if (bookId.isEmpty) return 'Kitap ID boş olamaz';
    if (title.isEmpty) return 'Kitap başlığı boş olamaz';
    if (author.isEmpty) return 'Yazar ismi boş olamaz';
    if (userId.isEmpty) return 'Kullanıcı ID boş olamaz';
    if (price < 0) return 'Fiyat negatif olamaz';
    if (quantity <= 0) return 'Adet 1\'den küçük olamaz';
    return null;
  }
}
