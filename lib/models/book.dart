import 'package:cloud_firestore/cloud_firestore.dart';

/// Book Model for Firestore Integration
///
/// Represents a book document in the 'books' collection.
/// Simple structure focused on core book information.
class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverImageUrl;
  final double price;
  final String category;
  final String? content; // Demo content for reading
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImageUrl,
    required this.price,
    required this.category,
    this.content,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Book from Firestore DocumentSnapshot
  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      description: data['description'] ?? '',
      coverImageUrl: data['coverImageUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      content: data['content'],
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  /// Create Book from Map (for testing/manual creation)
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      content: map['content'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  /// Convert Book to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'price': price,
      'category': category,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Convert Book to JSON (for debugging/logging)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'price': price,
      'category': category,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? coverImageUrl,
    double? price,
    String? category,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      price: price ?? this.price,
      category: category ?? this.category,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted price string
  String get formattedPrice {
    if (price == 0) {
      return 'Ücretsiz';
    }
    return '${price.toStringAsFixed(2)} ₺';
  }

  /// Get book display name (title by author)
  String get displayName {
    return '$title - $author';
  }

  /// Check if book has valid cover image
  bool get hasValidCoverImage {
    return coverImageUrl.isNotEmpty &&
        (coverImageUrl.startsWith('http') || coverImageUrl.startsWith('https'));
  }

  /// Get fallback cover image URL
  String get safeCoverImageUrl {
    if (hasValidCoverImage) {
      return coverImageUrl;
    }
    // Return a placeholder image URL
    return 'https://via.placeholder.com/300x400/E3F2FD/1976D2?text=${Uri.encodeComponent(title)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Book && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    return 'Book(id: $id, title: $title, author: $author, price: $price, category: $category)';
  }

  /// Create a sample book for testing
  static Book sample({
    String? id,
    String? title,
    String? author,
    String? description,
    String? coverImageUrl,
    double? price,
    String? category,
  }) {
    return Book(
      id: id ?? 'sample_book_id',
      title: title ?? 'Örnek Kitap',
      author: author ?? 'Örnek Yazar',
      description:
          description ??
          'Bu bir örnek kitap açıklamasıdır. Kitabın içeriği hakkında bilgi verir.',
      coverImageUrl:
          coverImageUrl ??
          'https://via.placeholder.com/300x400/E3F2FD/1976D2?text=Örnek+Kitap',
      price: price ?? 29.99,
      category: category ?? 'Roman',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
