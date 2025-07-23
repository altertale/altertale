import 'dart:async';
import 'package:flutter/foundation.dart';

/// Lazy loading service for efficient data pagination and caching
class LazyLoadingService<T> {
  final Future<List<T>> Function(int page, int limit) _dataFetcher;
  final String _cacheKey;
  final int _pageSize;
  final Duration _cacheExpiry;

  // Cache management
  final Map<int, List<T>> _pageCache = {};
  final Map<int, DateTime> _cacheTimestamps = {};
  final Set<int> _loadingPages = {};

  // State
  bool _hasMoreData = true;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;

  LazyLoadingService({
    required Future<List<T>> Function(int page, int limit) dataFetcher,
    required String cacheKey,
    int pageSize = 20,
    Duration cacheExpiry = const Duration(minutes: 10),
  }) : _dataFetcher = dataFetcher,
       _cacheKey = cacheKey,
       _pageSize = pageSize,
       _cacheExpiry = cacheExpiry;

  // Getters
  bool get hasMoreData => _hasMoreData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalLoadedItems => _getAllCachedItems().length;

  /// Get all currently cached items
  List<T> _getAllCachedItems() {
    final allItems = <T>[];
    for (int i = 0; i <= _currentPage; i++) {
      if (_pageCache.containsKey(i)) {
        allItems.addAll(_pageCache[i]!);
      }
    }
    return allItems;
  }

  /// Load next page of data
  Future<List<T>> loadNextPage() async {
    if (_isLoading || !_hasMoreData) {
      return [];
    }

    final nextPage = _currentPage + 1;

    // Check cache first
    if (_isCacheValid(nextPage)) {
      _currentPage = nextPage;
      return _pageCache[nextPage]!;
    }

    // Prevent concurrent loading of same page
    if (_loadingPages.contains(nextPage)) {
      return [];
    }

    try {
      _isLoading = true;
      _loadingPages.add(nextPage);
      _error = null;

      print('📦 Loading page $nextPage (${_pageSize} items)');

      final newItems = await _dataFetcher(nextPage, _pageSize);

      // Cache the results
      _pageCache[nextPage] = List<T>.from(newItems);
      _cacheTimestamps[nextPage] = DateTime.now();

      // Update state
      _currentPage = nextPage;
      _hasMoreData = newItems.length == _pageSize;

      print('✅ Loaded ${newItems.length} items for page $nextPage');

      return newItems;
    } catch (e) {
      _error = 'Veri yüklenirken hata: $e';
      print('❌ Error loading page $nextPage: $e');
      return [];
    } finally {
      _isLoading = false;
      _loadingPages.remove(nextPage);
    }
  }

  /// Load specific page
  Future<List<T>> loadPage(int pageNumber) async {
    if (pageNumber < 0) return [];

    // Check cache first
    if (_isCacheValid(pageNumber)) {
      return _pageCache[pageNumber]!;
    }

    // Prevent concurrent loading
    if (_loadingPages.contains(pageNumber)) {
      return [];
    }

    try {
      _loadingPages.add(pageNumber);

      print('📦 Loading specific page $pageNumber');

      final items = await _dataFetcher(pageNumber, _pageSize);

      // Cache the results
      _pageCache[pageNumber] = List<T>.from(items);
      _cacheTimestamps[pageNumber] = DateTime.now();

      print('✅ Loaded ${items.length} items for page $pageNumber');

      return items;
    } catch (e) {
      _error = 'Sayfa yüklenirken hata: $e';
      print('❌ Error loading page $pageNumber: $e');
      return [];
    } finally {
      _loadingPages.remove(pageNumber);
    }
  }

  /// Preload next few pages in background
  Future<void> preloadPages({int count = 2}) async {
    if (!_hasMoreData || _isLoading) return;

    final pagesToPreload = <int>[];
    for (int i = 1; i <= count; i++) {
      final pageToPreload = _currentPage + i;
      if (!_pageCache.containsKey(pageToPreload) &&
          !_loadingPages.contains(pageToPreload)) {
        pagesToPreload.add(pageToPreload);
      }
    }

    if (pagesToPreload.isEmpty) return;

    print('🔄 Preloading ${pagesToPreload.length} pages: $pagesToPreload');

    // Load pages in parallel (but don't wait for completion)
    for (final page in pagesToPreload) {
      unawaited(loadPage(page));
    }
  }

  /// Check if cached data is still valid
  bool _isCacheValid(int page) {
    if (!_pageCache.containsKey(page)) return false;

    final timestamp = _cacheTimestamps[page];
    if (timestamp == null) return false;

    final age = DateTime.now().difference(timestamp);
    return age < _cacheExpiry;
  }

  /// Refresh all cached data
  Future<void> refresh() async {
    print('🔄 Refreshing lazy loading cache');

    // Clear cache
    _pageCache.clear();
    _cacheTimestamps.clear();
    _loadingPages.clear();

    // Reset state
    _currentPage = 0;
    _hasMoreData = true;
    _error = null;

    // Load first page
    await loadNextPage();
  }

  /// Clear specific page from cache
  void clearPage(int page) {
    _pageCache.remove(page);
    _cacheTimestamps.remove(page);
    print('🗑️ Cleared page $page from cache');
  }

  /// Clear expired cache entries
  void clearExpiredCache() {
    final now = DateTime.now();
    final expiredPages = <int>[];

    for (final entry in _cacheTimestamps.entries) {
      final age = now.difference(entry.value);
      if (age >= _cacheExpiry) {
        expiredPages.add(entry.key);
      }
    }

    for (final page in expiredPages) {
      clearPage(page);
    }

    if (expiredPages.isNotEmpty) {
      print('🧹 Cleared ${expiredPages.length} expired cache entries');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cache_key': _cacheKey,
      'cached_pages': _pageCache.length,
      'total_items': totalLoadedItems,
      'current_page': _currentPage,
      'has_more_data': _hasMoreData,
      'loading_pages': _loadingPages.length,
      'page_size': _pageSize,
      'cache_expiry_minutes': _cacheExpiry.inMinutes,
    };
  }

  /// Clear all cache
  void clearCache() {
    _pageCache.clear();
    _cacheTimestamps.clear();
    _loadingPages.clear();
    _currentPage = 0;
    _hasMoreData = true;
    _error = null;
    print('🧹 Cleared all cache for $_cacheKey');
  }

  /// Dispose resources
  void dispose() {
    clearCache();
    print('🗑️ Disposed lazy loading service for $_cacheKey');
  }
}

/// Pagination helper for UI widgets
class PaginationController<T> {
  final LazyLoadingService<T> _lazyService;
  final void Function()? onDataChanged;
  final void Function(String)? onError;

  List<T> _items = [];

  PaginationController({
    required LazyLoadingService<T> lazyService,
    this.onDataChanged,
    this.onError,
  }) : _lazyService = lazyService;

  // Getters
  List<T> get items => List.unmodifiable(_items);
  bool get hasMore => _lazyService.hasMoreData;
  bool get isLoading => _lazyService.isLoading;
  String? get error => _lazyService.error;
  int get totalItems => _items.length;

  /// Load next batch of items
  Future<void> loadMore() async {
    try {
      final newItems = await _lazyService.loadNextPage();

      if (newItems.isNotEmpty) {
        _items.addAll(newItems);
        onDataChanged?.call();
      }

      // Preload next pages
      _lazyService.preloadPages();
    } catch (e) {
      onError?.call('Veri yüklenirken hata: $e');
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    try {
      await _lazyService.refresh();
      _items.clear();

      final firstPage = await _lazyService.loadNextPage();
      _items.addAll(firstPage);

      onDataChanged?.call();

      // Preload next pages
      _lazyService.preloadPages();
    } catch (e) {
      onError?.call('Veriler yenilenirken hata: $e');
    }
  }

  /// Initialize with first page
  Future<void> initialize() async {
    if (_items.isNotEmpty) return; // Already initialized

    await loadMore();
  }

  /// Clear all data
  void clear() {
    _items.clear();
    _lazyService.clearCache();
    onDataChanged?.call();
  }

  /// Insert item at specific position
  void insertItem(int index, T item) {
    if (index >= 0 && index <= _items.length) {
      _items.insert(index, item);
      onDataChanged?.call();
    }
  }

  /// Remove item at specific position
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      onDataChanged?.call();
    }
  }

  /// Update item at specific position
  void updateItem(int index, T item) {
    if (index >= 0 && index < _items.length) {
      _items[index] = item;
      onDataChanged?.call();
    }
  }

  /// Get pagination info for display
  Map<String, dynamic> getPaginationInfo() {
    return {
      'current_items': _items.length,
      'has_more': hasMore,
      'is_loading': isLoading,
      'current_page': _lazyService.currentPage,
      'cache_stats': _lazyService.getCacheStats(),
    };
  }

  /// Dispose resources
  void dispose() {
    _lazyService.dispose();
    _items.clear();
  }
}
