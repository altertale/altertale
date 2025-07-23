import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../models/search/book_filter_model.dart';

/// Kitap repository - Firestore ile kitap verilerini yönetir
class BookRepository {
  static final BookRepository _instance = BookRepository._internal();
  factory BookRepository() => _instance;
  BookRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'books';

  /// Filtreli kitap sorgusu
  Future<QueryResult<BookModel>> searchBooks(BookFilterModel filter) async {
    try {
      Query query = _firestore.collection(_collection);

      // Yayın durumu filtresi (varsayılan olarak sadece yayında olanlar)
      if (filter.isPublished != null) {
        query = query.where('isPublished', isEqualTo: filter.isPublished);
      } else {
        query = query.where('isPublished', isEqualTo: true);
      }

      // Kategori filtresi
      if (filter.categories.isNotEmpty) {
        query = query.where('categories', arrayContainsAny: filter.categories);
      }

      // Etiket filtresi
      if (filter.tags.isNotEmpty) {
        query = query.where('tags', arrayContainsAny: filter.tags);
      }

      // Puan ile satın alma filtresi
      if (filter.canPurchaseWithPoints != null) {
        if (filter.canPurchaseWithPoints!) {
          query = query.where('points', isGreaterThan: 0);
        } else {
          query = query.where('points', isEqualTo: 0);
        }
      }

      // Puan aralığı filtresi
      if (filter.pointsRange != null) {
        query = query.where('points', isGreaterThanOrEqualTo: filter.pointsRange!.start.round());
        query = query.where('points', isLessThanOrEqualTo: filter.pointsRange!.end.round());
      }

      // Sıralama
      query = _applySortOrder(query, filter.sortOrder);

      // Sayfalama
      if (filter.lastDocument != null) {
        query = query.startAfterDocument(filter.lastDocument!);
      }

      // Limit
      query = query.limit(filter.limit);

      // Sorguyu çalıştır
      final querySnapshot = await query.get();
      
      // Sonuçları dönüştür
      final books = querySnapshot.docs.map((doc) {
        return BookModel.fromFirestore(doc);
      }).toList();

      // Arama sorgusu varsa client-side filtreleme yap
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final searchQuery = filter.searchQuery!.toLowerCase().trim();
        books.removeWhere((book) {
          return !book.title.toLowerCase().contains(searchQuery) &&
                 !book.author.toLowerCase().contains(searchQuery) &&
                 !book.description.toLowerCase().contains(searchQuery);
        });
      }

      return QueryResult(
        data: books,
        lastDocument: querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
        hasMore: querySnapshot.docs.length == filter.limit,
      );
    } catch (e) {
      throw Exception('Kitap arama hatası: $e');
    }
  }

  /// Sıralama düzenini uygula
  Query _applySortOrder(Query query, SortOrder sortOrder) {
    switch (sortOrder) {
      case SortOrder.newest:
        return query.orderBy('createdAt', descending: true);
      case SortOrder.oldest:
        return query.orderBy('createdAt', descending: false);
      case SortOrder.alphabetical:
        return query.orderBy('title', descending: false);
      case SortOrder.mostRead:
        return query.orderBy('readCount', descending: true);
      case SortOrder.highestRated:
        return query.orderBy('averageRating', descending: true);
      case SortOrder.lowestPrice:
        return query.orderBy('price', descending: false);
      case SortOrder.highestPrice:
        return query.orderBy('price', descending: true);
    }
  }

  /// Kategorileri getir
  Future<List<String>> getCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isPublished', isEqualTo: true)
          .get();

      final categories = <String>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final bookCategories = List<String>.from(data['categories'] ?? []);
        categories.addAll(bookCategories);
      }

      return categories.toList()..sort();
    } catch (e) {
      throw Exception('Kategoriler alınırken hata oluştu: $e');
    }
  }

  /// Etiketleri getir
  Future<List<String>> getTags() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isPublished', isEqualTo: true)
          .get();

      final tags = <String>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final bookTags = List<String>.from(data['tags'] ?? []);
        tags.addAll(bookTags);
      }

      return tags.toList()..sort();
    } catch (e) {
      throw Exception('Etiketler alınırken hata oluştu: $e');
    }
  }

  /// Puan aralığını getir
  Future<RangeValues> getPointsRange() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isPublished', isEqualTo: true)
          .orderBy('points', descending: true)
          .limit(1)
          .get();

      int maxPoints = 0;
      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        maxPoints = data['points'] ?? 0;
      }

      return RangeValues(0, maxPoints.toDouble());
    } catch (e) {
      return const RangeValues(0, 1000);
    }
  }

  /// Popüler arama terimlerini getir
  Future<List<String>> getPopularSearchTerms() async {
    try {
      // Bu özellik için ayrı bir koleksiyon kullanılabilir
      // Şimdilik sabit değerler döndürüyoruz
      return [
        'roman',
        'bilim kurgu',
        'fantastik',
        'tarih',
        'felsefe',
        'psikoloji',
        'ekonomi',
        'sanat',
      ];
    } catch (e) {
      return [];
    }
  }

  /// Kitap önerilerini getir
  Future<List<BookModel>> getBookSuggestions(String query) async {
    try {
      if (query.isEmpty) return [];

      final searchQuery = query.toLowerCase().trim();
      
      Query firestoreQuery = _firestore
          .collection(_collection)
          .where('isPublished', isEqualTo: true)
          .limit(10);

      final querySnapshot = await firestoreQuery.get();
      
      final suggestions = querySnapshot.docs.map((doc) {
        return BookModel.fromFirestore(doc);
      }).toList();

      // Client-side filtreleme
      suggestions.removeWhere((book) {
        return !book.title.toLowerCase().contains(searchQuery) &&
               !book.author.toLowerCase().contains(searchQuery);
      });

      return suggestions.take(5).toList();
    } catch (e) {
      return [];
    }
  }
}

/// Sorgu sonucu modeli
class QueryResult<T> {
  final List<T> data;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  const QueryResult({
    required this.data,
    this.lastDocument,
    required this.hasMore,
  });
}
