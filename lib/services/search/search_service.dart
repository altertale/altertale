import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../models/search/book_filter_model.dart';

/// Arama servisi
/// Kitap arama ve filtreleme işlemlerini yönetir
class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _booksCollection = 'books';
  static const String _authorsCollection = 'authors';
  static const String _categoriesCollection = 'categories';

  /// Kitap ara
  Future<List<BookModel>> searchBooks({
    required String query,
    BookFilterModel? filters,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query booksQuery = _firestore.collection(_booksCollection);

      // Eğer query boş değilse, başlık ve yazara göre ara
      if (query.isNotEmpty) {
        // Firestore'da case-insensitive arama için array-contains kullanıyoruz
        // Kitap başlığı ve yazar adı için arama kelimeleri array'i olmalı
        booksQuery = booksQuery.where(
          'searchTerms',
          arrayContainsAny: query.toLowerCase().split(' '),
        );
      }

      // Filtreler uygula
      if (filters != null) {
        if (filters.categories.isNotEmpty) {
          booksQuery = booksQuery.where(
            'categories',
            arrayContainsAny: filters.categories,
          );
        }

        if (filters.authors.isNotEmpty) {
          booksQuery = booksQuery.where('author', whereIn: filters.authors);
        }

        if (filters.minPrice != null && filters.maxPrice != null) {
          booksQuery = booksQuery
              .where('pointPrice', isGreaterThanOrEqualTo: filters.minPrice)
              .where('pointPrice', isLessThanOrEqualTo: filters.maxPrice);
        }

        if (filters.sortBy != null) {
          switch (filters.sortBy) {
            case BookSortBy.title:
              booksQuery = booksQuery.orderBy('title');
              break;
            case BookSortBy.author:
              booksQuery = booksQuery.orderBy('author');
              break;
            case BookSortBy.publishDate:
              booksQuery = booksQuery.orderBy('publishDate', descending: true);
              break;
            case BookSortBy.pointPrice:
              booksQuery = booksQuery.orderBy(
                'pointPrice',
                descending: filters.sortDescending,
              );
              break;
            case BookSortBy.popularity:
              booksQuery = booksQuery.orderBy('popularity', descending: true);
              break;
            default:
              booksQuery = booksQuery.orderBy('createdAt', descending: true);
          }
        } else {
          booksQuery = booksQuery.orderBy('createdAt', descending: true);
        }
      } else {
        booksQuery = booksQuery.orderBy('createdAt', descending: true);
      }

      // Sayfalama
      if (lastDocument != null) {
        booksQuery = booksQuery.startAfterDocument(lastDocument);
      }

      booksQuery = booksQuery.limit(limit);

      final snapshot = await booksQuery.get();
      return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Kitap arama hatası: $e');
    }
  }

  /// Popüler kitapları getir
  Future<List<BookModel>> getPopularBooks({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_booksCollection)
          .orderBy('popularity', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Popüler kitaplar alınamadı: $e');
    }
  }

  /// Yeni kitapları getir
  Future<List<BookModel>> getNewBooks({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_booksCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Yeni kitaplar alınamadı: $e');
    }
  }

  /// Kategoriye göre kitap getir
  Future<List<BookModel>> getBooksByCategory(
    String category, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_booksCollection)
          .where('categories', arrayContains: category)
          .orderBy('popularity', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Kategori kitapları alınamadı: $e');
    }
  }

  /// Yazara göre kitap getir
  Future<List<BookModel>> getBooksByAuthor(
    String author, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_booksCollection)
          .where('author', isEqualTo: author)
          .orderBy('publishDate', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Yazar kitapları alınamadı: $e');
    }
  }

  /// Arama önerileri getir
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      if (query.isEmpty) return [];

      final suggestions = <String>[];

      // Kitap başlıklarından öneriler
      final booksSnapshot = await _firestore
          .collection(_booksCollection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .limit(5)
          .get();

      for (var doc in booksSnapshot.docs) {
        final book = BookModel.fromFirestore(doc);
        suggestions.add(book.title);
      }

      // Yazar isimlerinden öneriler
      final authorsSnapshot = await _firestore
          .collection(_booksCollection)
          .where('author', isGreaterThanOrEqualTo: query)
          .where('author', isLessThan: '${query}z')
          .limit(3)
          .get();

      for (var doc in authorsSnapshot.docs) {
        final book = BookModel.fromFirestore(doc);
        if (!suggestions.contains(book.author)) {
          suggestions.add(book.author);
        }
      }

      return suggestions.take(8).toList();
    } catch (e) {
      return [];
    }
  }

  /// Puan aralığı getir
  Future<RangeValues> getPointsRange() async {
    try {
      // Basit bir range değeri döndür
      return const RangeValues(0, 1000);
    } catch (e) {
      return const RangeValues(0, 1000);
    }
  }

  /// Tüm kategorileri getir
  Future<List<String>> getAllCategories() async {
    try {
      final snapshot = await _firestore.collection(_booksCollection).get();

      final categories = <String>{};
      for (var doc in snapshot.docs) {
        final book = BookModel.fromFirestore(doc);
        if (book.categories.isNotEmpty) {
          categories.addAll(book.categories);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      return [];
    }
  }

  /// Tüm yazarları getir
  Future<List<String>> getAllAuthors() async {
    try {
      final snapshot = await _firestore.collection(_booksCollection).get();

      final authors = <String>{};
      for (var doc in snapshot.docs) {
        final book = BookModel.fromFirestore(doc);
        authors.add(book.author);
      }

      return authors.toList()..sort();
    } catch (e) {
      return [];
    }
  }
}
