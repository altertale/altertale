import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Kitap filtreleme modeli
class BookFilterModel {
  final String? searchQuery;
  final List<String> categories;
  final List<String> tags;
  final bool? canPurchaseWithPoints;
  final bool? isPublished;
  final RangeValues? pointsRange;
  final SortOrder sortOrder;
  final int limit;
  final DocumentSnapshot? lastDocument;

  const BookFilterModel({
    this.searchQuery,
    this.categories = const [],
    this.tags = const [],
    this.canPurchaseWithPoints,
    this.isPublished,
    this.pointsRange,
    this.sortOrder = SortOrder.newest,
    this.limit = 20,
    this.lastDocument,
  });

  /// Filtreleri temizle
  BookFilterModel clear() {
    return const BookFilterModel();
  }

  /// Arama sorgusu ekle
  BookFilterModel withSearchQuery(String? query) {
    return BookFilterModel(
      searchQuery: query,
      categories: categories,
      tags: tags,
      canPurchaseWithPoints: canPurchaseWithPoints,
      isPublished: isPublished,
      pointsRange: pointsRange,
      sortOrder: sortOrder,
      limit: limit,
      lastDocument: lastDocument,
    );
  }

  /// Kategori ekle
  BookFilterModel withCategory(String category) {
    final newCategories = List<String>.from(categories);
    if (!newCategories.contains(category)) {
      newCategories.add(category);
    }
    return BookFilterModel(
      searchQuery: searchQuery,
      categories: newCategories,
      tags: tags,
      canPurchaseWithPoints: canPurchaseWithPoints,
      isPublished: isPublished,
      pointsRange: pointsRange,
      sortOrder: sortOrder,
      limit: limit,
      lastDocument: lastDocument,
    );
  }

  /// Kategori kaldır
  BookFilterModel withoutCategory(String category) {
    final newCategories = List<String>.from(categories);
    newCategories.remove(category);
    return BookFilterModel(
      searchQuery: searchQuery,
      categories: newCategories,
      tags: tags,
      canPurchaseWithPoints: canPurchaseWithPoints,
      isPublished: isPublished,
      pointsRange: pointsRange,
      sortOrder: sortOrder,
      limit: limit,
      lastDocument: lastDocument,
    );
  }

  /// Etiket ekle
  BookFilterModel withTag(String tag) {
    final newTags = List<String>.from(tags);
    if (!newTags.contains(tag)) {
      newTags.add(tag);
    }
    return BookFilterModel(
      searchQuery: searchQuery,
      categories: categories,
      tags: newTags,
      canPurchaseWithPoints: canPurchaseWithPoints,
      isPublished: isPublished,
      pointsRange: pointsRange,
      sortOrder: sortOrder,
      limit: limit,
      lastDocument: lastDocument,
    );
  }

  /// Etiket kaldır
  BookFilterModel withoutTag(String tag) {
    final newTags = List<String>.from(tags);
    newTags.remove(tag);
    return BookFilterModel(
      searchQuery: searchQuery,
      categories: categories,
      tags: newTags,
      canPurchaseWithPoints: canPurchaseWithPoints,
      isPublished: isPublished,
      pointsRange: pointsRange,
      sortOrder: sortOrder,
      limit: limit,
      lastDocument: lastDocument,
    );
  }

  /// Puan ile satın alma filtresi
  BookFilterModel withPurchaseWithPoints(bool? canPurchase) {
    return BookFilterModel(
      searchQuery: searchQuery,
      categories: categories,
      tags: tags,
      canPurchaseWithPoints: canPurchase,
      isPublished: isPublished,
      pointsRange: pointsRange,
      sortOrder: sortOrder,
      limit: limit,
      lastDocument: lastDocument,
    );
  }

  /// Yayın durumu filtresi
  BookFilterModel withPublishedStatus(bool? isPublished) {
    return BookFilterModel(
      searchQuery: searchQuery,
      categories: categories,
      tags: tags,
      canPurchaseWithPoints: canPurchaseWithPoints,
      isPublished: isPublished,
      pointsRange: pointsRange,
      sortOrder: sortOrder,
      limit: limit,
      lastDocument: lastDocument,
    );
  }

  /// Puan aralığı filtresi
  BookFilterModel withPointsRange(RangeValues? range) {
    return BookFilterModel(
      searchQuery: searchQuery,
      categories: categories,
      tags: tags,
      canPurchaseWithPoints: canPurchaseWithPoints,
      isPublished: isPublished,
      pointsRange: range,
      sortOrder: sortOrder,
      limit: limit,
      lastDocument: lastDocument,
    );
  }

  /// Sıralama düzeni
  BookFilterModel withSortOrder(SortOrder order) {
    return BookFilterModel(
      searchQuery: searchQuery,
      categories: categories,
      tags: tags,
      canPurchaseWithPoints: canPurchaseWithPoints,
      isPublished: isPublished,
      pointsRange: pointsRange,
      sortOrder: order,
      limit: limit,
      lastDocument: lastDocument,
    );
  }

  /// Sayfalama için sonraki sayfa
  BookFilterModel withLastDocument(DocumentSnapshot? document) {
    return BookFilterModel(
      searchQuery: searchQuery,
      categories: categories,
      tags: tags,
      canPurchaseWithPoints: canPurchaseWithPoints,
      isPublished: isPublished,
      pointsRange: pointsRange,
      sortOrder: sortOrder,
      limit: limit,
      lastDocument: document,
    );
  }

  /// Filtrelerin aktif olup olmadığını kontrol et
  bool get hasActiveFilters {
    return searchQuery != null && searchQuery!.isNotEmpty ||
           categories.isNotEmpty ||
           tags.isNotEmpty ||
           canPurchaseWithPoints != null ||
           isPublished != null ||
           pointsRange != null ||
           sortOrder != SortOrder.newest;
  }

  /// Filtre sayısını getir
  int get filterCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (categories.isNotEmpty) count += categories.length;
    if (tags.isNotEmpty) count += tags.length;
    if (canPurchaseWithPoints != null) count++;
    if (isPublished != null) count++;
    if (pointsRange != null) count++;
    if (sortOrder != SortOrder.newest) count++;
    return count;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookFilterModel &&
        other.searchQuery == searchQuery &&
        other.categories.length == categories.length &&
        other.categories.every((c) => categories.contains(c)) &&
        other.tags.length == tags.length &&
        other.tags.every((t) => tags.contains(t)) &&
        other.canPurchaseWithPoints == canPurchaseWithPoints &&
        other.isPublished == isPublished &&
        other.pointsRange == pointsRange &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return Object.hash(
      searchQuery,
      Object.hashAll(categories),
      Object.hashAll(tags),
      canPurchaseWithPoints,
      isPublished,
      pointsRange,
      sortOrder,
    );
  }

  @override
  String toString() {
    return 'BookFilterModel('
        'searchQuery: $searchQuery, '
        'categories: $categories, '
        'tags: $tags, '
        'canPurchaseWithPoints: $canPurchaseWithPoints, '
        'isPublished: $isPublished, '
        'pointsRange: $pointsRange, '
        'sortOrder: $sortOrder)';
  }
}

/// Sıralama düzeni
enum SortOrder {
  newest('En Yeni'),
  oldest('En Eski'),
  alphabetical('Alfabetik'),
  mostRead('En Çok Okunan'),
  highestRated('En Yüksek Puanlı'),
  lowestPrice('En Düşük Fiyatlı'),
  highestPrice('En Yüksek Fiyatlı');

  const SortOrder(this.displayName);
  final String displayName;
}

/// Arama geçmişi modeli
class SearchHistoryItem {
  final String query;
  final DateTime timestamp;

  const SearchHistoryItem({
    required this.query,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'query': query,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory SearchHistoryItem.fromMap(Map<String, dynamic> map) {
    return SearchHistoryItem(
      query: map['query'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchHistoryItem &&
        other.query == query &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(query, timestamp);
}
