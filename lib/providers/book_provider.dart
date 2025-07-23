import 'package:flutter/foundation.dart';
import '../models/book_model.dart';
import '../services/book_service.dart';

class BookProvider with ChangeNotifier {
  final BookService _bookService = BookService();

  List<BookModel> _books = [];
  List<BookModel> _featuredBooks = [];
  List<BookModel> _popularBooks = [];
  List<BookModel> _newBooks = [];
  List<BookModel> _searchResults = [];

  bool _isLoading = false;
  bool _isLoadingFeatured = false;
  bool _isLoadingPopular = false;
  bool _isLoadingNew = false;
  bool _isSearching = false;

  String? _error;
  String? _featuredError;
  String? _popularError;
  String? _newError;
  String? _searchError;

  // Getters
  List<BookModel> get books => _books;
  List<BookModel> get featuredBooks => _featuredBooks;
  List<BookModel> get popularBooks => _popularBooks;
  List<BookModel> get newBooks => _newBooks;
  List<BookModel> get searchResults => _searchResults;

  bool get isLoading => _isLoading;
  bool get isLoadingFeatured => _isLoadingFeatured;
  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingNew => _isLoadingNew;
  bool get isSearching => _isSearching;

  String? get error => _error;
  String? get featuredError => _featuredError;
  String? get popularError => _popularError;
  String? get newError => _newError;
  String? get searchError => _searchError;

  /// Load all books
  Future<void> loadBooks({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final books = await _bookService.getBooks(
        page: page,
        limit: limit,
        category: category,
        search: search,
      );

      if (page == 1) {
        _books = books;
      } else {
        _books.addAll(books);
      }

      if (kDebugMode) {
        print('📚 BookProvider: Loaded ${books.length} books');
      }
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

  /// Load featured books
  Future<void> loadFeaturedBooks({int limit = 10}) async {
    _isLoadingFeatured = true;
    _featuredError = null;
    notifyListeners();

    try {
      _featuredBooks = await _bookService.getFeaturedBooks(limit: limit);
      if (kDebugMode) {
        print(
          '📚 BookProvider: Loaded ${_featuredBooks.length} featured books',
        );
      }
    } catch (e) {
      _featuredError = e.toString();
      if (kDebugMode) {
        print('❌ BookProvider: Error loading featured books: $e');
      }
    } finally {
      _isLoadingFeatured = false;
      notifyListeners();
    }
  }

  /// Load popular books
  Future<void> loadPopularBooks() async {
    _isLoadingPopular = true;
    _popularError = null;
    notifyListeners();

    try {
      _popularBooks = await _bookService.getPopularBooks();
      if (kDebugMode) {
        print('📚 BookProvider: Loaded ${_popularBooks.length} popular books');
      }
    } catch (e) {
      _popularError = e.toString();
      if (kDebugMode) {
        print('❌ BookProvider: Error loading popular books: $e');
      }
    } finally {
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  /// Load new books
  Future<void> loadNewBooks() async {
    _isLoadingNew = true;
    _newError = null;
    notifyListeners();

    try {
      _newBooks = await _bookService.getNewBooks();
      if (kDebugMode) {
        print('📚 BookProvider: Loaded ${_newBooks.length} new books');
      }
    } catch (e) {
      _newError = e.toString();
      if (kDebugMode) {
        print('❌ BookProvider: Error loading new books: $e');
      }
    } finally {
      _isLoadingNew = false;
      notifyListeners();
    }
  }

  /// Search books by query with optional debounce
  Future<void> searchBooks(String query, {int? debounceMs}) async {
    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      // If debounceMs is provided and greater than 0, add debounce
      if (debounceMs != null && debounceMs > 0) {
        await Future.delayed(Duration(milliseconds: debounceMs));
      }

      _searchResults = await _bookService.searchBooks(query);
      if (kDebugMode) {
        print(
          '📚 BookProvider: Found ${_searchResults.length} books for "$query"',
        );
      }
    } catch (e) {
      _searchError = e.toString();
      if (kDebugMode) {
        print('❌ BookProvider: Error searching books: $e');
      }
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Clear search results
  void clearSearchResults() {
    _searchResults = [];
    _searchError = null;
    notifyListeners();
  }

  /// Clear search results (alternative name for backward compatibility)
  void clearSearch() {
    clearSearchResults();
  }

  /// Get categories from loaded books
  List<String> get categories {
    final allCategories = <String>{};
    for (final bookList in [_books, _featuredBooks, _popularBooks, _newBooks]) {
      for (final book in bookList) {
        allCategories.addAll(book.categories);
      }
    }
    return allCategories.toList()..sort();
  }

  /// Get book by ID
  Future<BookModel?> getBookById(String bookId) async {
    try {
      // First check if book is already in loaded books
      for (final bookList in [
        _books,
        _featuredBooks,
        _popularBooks,
        _newBooks,
        _searchResults,
      ]) {
        final existingBook = bookList.firstWhereOrNull(
          (book) => book.id == bookId,
        );
        if (existingBook != null) {
          if (kDebugMode) {
            print(
              '📚 BookProvider: Found book in cache: ${existingBook.title}',
            );
          }
          return existingBook;
        }
      }

      // If not found in cache, fetch from service
      final book = await _bookService.getBookById(bookId);
      if (kDebugMode) {
        print(
          '📚 BookProvider: Fetched book from service: ${book?.title ?? 'Not found'}',
        );
      }
      return book;
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookProvider: Error getting book by ID: $e');
      }
      return null;
    }
  }

  /// Get books by category
  Future<List<BookModel>> getBooksByCategory(String category) async {
    try {
      return await _bookService.getBooksByCategory(category);
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookProvider: Error getting books by category: $e');
      }
      return [];
    }
  }

  /// Get books by author
  Future<List<BookModel>> getBooksByAuthor(String author) async {
    try {
      return await _bookService.getBooksByAuthor(author);
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookProvider: Error getting books by author: $e');
      }
      return [];
    }
  }

  /// Get similar books
  Future<List<BookModel>> getSimilarBooks(String bookId) async {
    try {
      return await _bookService.getSimilarBooks(bookId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookProvider: Error getting similar books: $e');
      }
      return [];
    }
  }

  /// Get free books
  Future<List<BookModel>> getFreeBooks() async {
    try {
      return await _bookService.getFreeBooks();
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookProvider: Error getting free books: $e');
      }
      return [];
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadBooks(),
      loadFeaturedBooks(),
      loadPopularBooks(),
      loadNewBooks(),
    ]);
  }

  /// Reset all data
  void reset() {
    _books = [];
    _featuredBooks = [];
    _popularBooks = [];
    _newBooks = [];
    _searchResults = [];

    _isLoading = false;
    _isLoadingFeatured = false;
    _isLoadingPopular = false;
    _isLoadingNew = false;
    _isSearching = false;

    _error = null;
    _featuredError = null;
    _popularError = null;
    _newError = null;
    _searchError = null;

    notifyListeners();
  }
}

// Extension to add firstWhereOrNull method if not already available
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
