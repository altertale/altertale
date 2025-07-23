import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/book_model.dart';
import '../services/book_service.dart';

/// Book Provider - Manages book data and state with performance optimizations
class BookProvider with ChangeNotifier {
  final BookService _bookService = BookService();

  // State variables
  List<BookModel> _books = [];
  List<BookModel> _featuredBooks = [];
  List<BookModel> _popularBooks = [];
  List<BookModel> _newBooks = [];
  List<BookModel> _searchResults = [];
  List<String> _categories = [];
  List<String> _authors = [];

  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreBooks = true;

  // Performance optimization variables
  DateTime? _lastFeaturedBooksLoad;
  DateTime? _lastCategoriesLoad;
  Timer? _debounceTimer;
  final Map<String, List<BookModel>> _searchCache = {};
  final Map<String, DateTime> _searchCacheTime = {};
  static const int cacheValidityMinutes = 5;

  // Getters
  List<BookModel> get books => _books;
  List<BookModel> get featuredBooks => _featuredBooks;
  List<BookModel> get popularBooks => _popularBooks;
  List<BookModel> get newBooks => _newBooks;
  List<BookModel> get searchResults => _searchResults;
  List<String> get categories => _categories;
  List<String> get authors => _authors;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasMoreBooks => _hasMoreBooks;
  bool get hasCachedFeaturedBooks =>
      _lastFeaturedBooksLoad != null &&
      DateTime.now().difference(_lastFeaturedBooksLoad!).inMinutes <
          cacheValidityMinutes;

  /// Load books with pagination
  Future<void> loadBooks({
    int page = 1,
    int limit = 20,
    String? category,
    String? searchQuery,
  }) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final books = await _bookService.getBooks(
        page: page,
        limit: limit,
        category: category,
        searchQuery: searchQuery,
      );

      final bookModels = books.map((book) => BookModel.fromBook(book)).toList();

      if (page == 1) {
        _books = bookModels;
      } else {
        _books.addAll(bookModels);
      }

      _currentPage = page;
      _hasMoreBooks = books.length == limit;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ BookProvider: Error loading books: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load featured books with caching
  Future<void> loadFeaturedBooks({bool forceRefresh = false}) async {
    // Check cache validity
    if (!forceRefresh && hasCachedFeaturedBooks && _featuredBooks.isNotEmpty) {
      if (kDebugMode) {
        print('📚 BookProvider: Using cached featured books');
      }
      return;
    }

    try {
      _isLoading = true;
      if (_featuredBooks.isEmpty) {
        notifyListeners(); // Only notify if we don't have data
      }

      final books = await _bookService.getFeaturedBooks();
      _featuredBooks = books.map((book) => BookModel.fromBook(book)).toList();
      _lastFeaturedBooksLoad = DateTime.now();

      if (kDebugMode) {
        print(
          '📚 BookProvider: Loaded ${_featuredBooks.length} featured books',
        );
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ BookProvider: Error loading featured books: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load popular books
  Future<void> loadPopularBooks() async {
    try {
      final books = await _bookService.getPopularBooks();
      _popularBooks = books.map((book) => BookModel.fromBook(book)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ BookProvider: Error loading popular books: $e');
      }
      notifyListeners();
    }
  }

  /// Load new books
  Future<void> loadNewBooks() async {
    try {
      final books = await _bookService.getNewBooks();
      _newBooks = books.map((book) => BookModel.fromBook(book)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ BookProvider: Error loading new books: $e');
      }
      notifyListeners();
    }
  }

  /// Load categories
  Future<void> loadCategories() async {
    try {
      _categories = await _bookService.getAllCategories();
      _lastCategoriesLoad = DateTime.now();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ BookProvider: Error loading categories: $e');
      }
      notifyListeners();
    }
  }

  /// Load authors
  Future<void> loadAuthors() async {
    try {
      _authors = await _bookService.getAllAuthors();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ BookProvider: Error loading authors: $e');
      }
      notifyListeners();
    }
  }

  /// Search books with debouncing and caching
  Future<void> searchBooks(String query, {int debounceMs = 500}) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Check cache first
    final cacheKey = query.toLowerCase().trim();
    if (_searchCache.containsKey(cacheKey) &&
        _searchCacheTime.containsKey(cacheKey)) {
      final cacheTime = _searchCacheTime[cacheKey]!;
      if (DateTime.now().difference(cacheTime).inMinutes <
          cacheValidityMinutes) {
        _searchResults = _searchCache[cacheKey]!;
        notifyListeners();
        if (kDebugMode) {
          print('📚 BookProvider: Using cached search results for: $query');
        }
        return;
      }
    }

    // Debounce the search
    _debounceTimer = Timer(Duration(milliseconds: debounceMs), () async {
      await _performSearch(query);
    });
  }

  /// Perform the actual search
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final books = await _bookService.getBooks(
        page: 1,
        limit: 20,
        searchQuery: query,
      );

      _searchResults = books.map((book) => BookModel.fromBook(book)).toList();

      // Cache the results
      final cacheKey = query.toLowerCase().trim();
      _searchCache[cacheKey] = _searchResults;
      _searchCacheTime[cacheKey] = DateTime.now();

      if (kDebugMode) {
        print(
          '📚 BookProvider: Found ${_searchResults.length} books for: $query',
        );
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ BookProvider: Error searching books: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadBooks(),
      loadFeaturedBooks(),
      loadPopularBooks(),
      loadNewBooks(),
      loadCategories(),
      loadAuthors(),
    ]);
  }

  /// Get book by ID
  Future<BookModel?> getBookById(String bookId) async {
    try {
      final book = await _bookService.getBookById(bookId);
      return book != null ? BookModel.fromBook(book) : null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ BookProvider: Error getting book by ID: $e');
      }
      return null;
    }
  }

  /// Get similar books
  Future<List<BookModel>> getSimilarBooks(String bookId) async {
    try {
      final books = await _bookService.getSimilarBooks(bookId);
      return books.map((book) => BookModel.fromBook(book)).toList();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ BookProvider: Error getting similar books: $e');
      }
      return [];
    }
  }

  /// Clear search results
  void clearSearch() {
    _searchResults = [];
    _error = null;
    notifyListeners();
  }

  /// Clear all caches
  void clearCaches() {
    _searchCache.clear();
    _searchCacheTime.clear();
    _lastFeaturedBooksLoad = null;
    _lastCategoriesLoad = null;
    if (kDebugMode) {
      print('📚 BookProvider: Cleared all caches');
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
