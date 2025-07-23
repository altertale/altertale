import 'package:cloud_firestore/cloud_firestore.dart';
import 'book.dart'; // Import the simple Book model

/// Kitap modeli - Firestore'dan gelen kitap verilerini temsil eder
class BookModel {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverImageUrl;
  final List<String> categories;
  final List<String> tags;
  final double price;
  final int points;
  final double averageRating;
  final int ratingCount;
  final int readCount;
  final int pageCount;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final bool isFeatured;
  final bool isPopular;
  final int previewStart;
  final int previewEnd;
  final int pointPrice;
  final String? content; // Book content for reading

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImageUrl,
    required this.categories,
    required this.tags,
    required this.price,
    required this.points,
    required this.averageRating,
    required this.ratingCount,
    required this.readCount,
    required this.pageCount,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
    required this.isPublished,
    required this.isFeatured,
    required this.isPopular,
    required this.previewStart,
    required this.previewEnd,
    required this.pointPrice,
    this.content, // Optional content field
  });

  /// Firestore'dan gelen veriyi BookModel'e dönüştürür
  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BookModel(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      description: data['description'] ?? '',
      coverImageUrl: data['coverImageUrl'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      price: (data['price'] ?? 0.0).toDouble(),
      points: data['points'] ?? 0,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      readCount: data['readCount'] ?? 0,
      pageCount: data['pageCount'] ?? 0,
      language: data['language'] ?? 'tr',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPublished: data['isPublished'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      isPopular: data['isPopular'] ?? false,
      previewStart: data['previewStart'] ?? 0,
      previewEnd: data['previewEnd'] ?? 0,
      pointPrice: data['pointPrice'] ?? 0,
      content: data['content'], // Add content field
    );
  }

  /// Create BookModel from simple Book model
  factory BookModel.fromBook(Book book) {
    return BookModel(
      id: book.id,
      title: book.title,
      author: book.author,
      description: book.description,
      coverImageUrl: book.coverImageUrl,
      categories: [book.category], // Convert single category to list
      tags: [], // Default empty tags
      price: book.price,
      points: 0, // Default points
      averageRating: 0.0, // Default rating
      ratingCount: 0, // Default rating count
      readCount: 0, // Default read count
      pageCount: 0, // Default page count
      language: 'tr', // Default language
      createdAt: book.createdAt ?? DateTime.now(),
      updatedAt: book.updatedAt ?? DateTime.now(),
      isPublished: true, // Default published
      isFeatured: false, // Default not featured
      isPopular: false, // Default not popular
      previewStart: 0, // Default preview start
      previewEnd: 10, // Default preview end
      pointPrice: 0, // Default point price
      content: null, // Default null content
    );
  }

  /// BookModel'i Firestore'a kaydetmek için Map'e dönüştürür
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'categories': categories,
      'tags': tags,
      'price': price,
      'points': points,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'readCount': readCount,
      'pageCount': pageCount,
      'language': language,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublished': isPublished,
      'isFeatured': isFeatured,
      'isPopular': isPopular,
      'previewStart': previewStart,
      'previewEnd': previewEnd,
      'pointPrice': pointPrice,
      'content': content, // Add content field
    };
  }

  /// Kitabın kopyasını oluşturur (immutable yapı için)
  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? coverImageUrl,
    List<String>? categories,
    List<String>? tags,
    double? price,
    int? points,
    double? averageRating,
    int? ratingCount,
    int? readCount,
    int? pageCount,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
    bool? isFeatured,
    bool? isPopular,
    int? previewStart,
    int? previewEnd,
    int? pointPrice,
    String? content, // Optional content field
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      price: price ?? this.price,
      points: points ?? this.points,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      readCount: readCount ?? this.readCount,
      pageCount: pageCount ?? this.pageCount,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      isPopular: isPopular ?? this.isPopular,
      previewStart: previewStart ?? this.previewStart,
      previewEnd: previewEnd ?? this.previewEnd,
      pointPrice: pointPrice ?? this.pointPrice,
      content: content ?? this.content, // Copy content field
    );
  }

  /// Kitap adına göre arama yapar
  bool matchesSearch(String query) {
    final lowercaseQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowercaseQuery) ||
        author.toLowerCase().contains(lowercaseQuery) ||
        tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
        categories.any(
          (category) => category.toLowerCase().contains(lowercaseQuery),
        );
  }

  /// Kategoriye göre filtreleme yapar
  bool matchesCategory(String category) {
    return categories.contains(category);
  }

  /// Puan formatını döndürür (örn: 4.5)
  String get formattedRating {
    return averageRating.toStringAsFixed(1);
  }

  /// Genre compatibility - returns first category
  String get genre {
    return categories.isNotEmpty ? categories.first : 'Genel';
  }

  /// Fiyat formatını döndürür (örn: ₺25.99)
  String get formattedPrice {
    return '₺${price.toStringAsFixed(2)}';
  }

  /// Puan formatını döndürür (örn: 150 puan)
  String get formattedPoints {
    return '$points puan';
  }

  /// Sayfa sayısı formatını döndürür (örn: 250 sayfa)
  String get formattedPageCount {
    return '$pageCount sayfa';
  }

  /// Yorum sayısı formatını döndürür (örn: 125 yorum)
  String get formattedRatingCount {
    return '$ratingCount yorum';
  }

  /// Okuma sayısı formatını döndürür (örn: 1.2K okuma)
  String get formattedReadCount {
    if (readCount >= 1000) {
      return '${(readCount / 1000).toStringAsFixed(1)}K okuma';
    }
    return '$readCount okuma';
  }

  /// Kitabın kısa açıklamasını döndürür (maksimum 150 karakter)
  String get shortDescription {
    if (description.length <= 150) {
      return description;
    }
    return '${description.substring(0, 147)}...';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BookModel(id: $id, title: $title, author: $author)';
  }
}
