import 'package:flutter/foundation.dart';
import '../models/book_model.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/reading_progress_service.dart';
import '../providers/book_provider.dart';

/// MyBooks Provider - Manages purchased books and reading history with instant sync
class MyBooksProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  final ReadingProgressService _readingProgressService =
      ReadingProgressService();

  // State variables
  List<BookModel> _purchasedBooks = [];
  List<BookModel> _readingHistory = [];
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  // Getters
  List<BookModel> get purchasedBooks => _purchasedBooks;
  List<BookModel> get readingHistory => _readingHistory;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPurchasedBooks => _purchasedBooks.isNotEmpty;
  bool get hasReadingHistory => _readingHistory.isNotEmpty;

  /// Initialize MyBooks for user
  Future<void> initializeMyBooks(
    String userId,
    BookProvider bookProvider,
  ) async {
    if (_currentUserId == userId && _purchasedBooks.isNotEmpty) {
      return; // Already initialized for this user
    }

    _currentUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load orders
      _orders = await _orderService.getOrdersForUser(userId);

      // Extract purchased book IDs
      final purchasedBookIds = <String>{};
      for (final order in _orders) {
        for (final item in order.items) {
          purchasedBookIds.add(item.bookId);
        }
      }

      // Get purchased books from BookProvider
      _purchasedBooks = bookProvider.books
          .where((book) => purchasedBookIds.contains(book.id))
          .toList();

      // If no purchased books but we have orders, use demo fallback
      if (_purchasedBooks.isEmpty && _orders.isNotEmpty) {
        _purchasedBooks = bookProvider.books.take(2).toList();
      }

      // Load reading history
      await _loadReadingHistory(userId, bookProvider);

      if (kDebugMode) {
        print(
          '📚 MyBooksProvider: Initialized ${_purchasedBooks.length} purchased books, ${_readingHistory.length} history items',
        );
      }
    } catch (e) {
      _error = 'Kitaplarım yüklenirken hata oluştu: $e';
      if (kDebugMode) {
        print('❌ MyBooksProvider: Error initializing: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load reading history
  Future<void> _loadReadingHistory(
    String userId,
    BookProvider bookProvider,
  ) async {
    try {
      final recentProgress = await _readingProgressService.getRecentlyReadBooks(
        userId: userId,
        limit: 10,
      );

      _readingHistory = recentProgress.map((progress) {
        // Find the book in BookProvider
        final book = bookProvider.books.firstWhere(
          (b) => b.id == progress.bookId,
          orElse: () => BookModel(
            id: progress.bookId,
            title: 'Bilinmeyen Kitap',
            author: 'Bilinmeyen Yazar',
            description: 'Açıklama yok',
            coverImageUrl: 'https://via.placeholder.com/150x200',
            categories: ['Genel'],
            tags: [],
            price: 0.0,
            points: 0,
            averageRating: 0.0,
            ratingCount: 0,
            readCount: 0,
            pageCount: progress.totalPages,
            language: 'tr',
            createdAt: DateTime.now(),
            updatedAt: progress.lastReadAt,
            isPublished: true,
            isFeatured: false,
            isPopular: false,
            previewStart: 0,
            previewEnd: 0,
            pointPrice: 0,
          ),
        );
        return book;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ MyBooksProvider: Error loading reading history: $e');
      }
    }
  }

  /// Add a purchased book with instant feedback (after successful purchase)
  Future<void> addPurchasedBookInstant(BookModel book, Order order) async {
    try {
      // Add to local state first for instant UI
      if (!_purchasedBooks.any((b) => b.id == book.id)) {
        _purchasedBooks.add(book);
      }

      if (!_orders.any((o) => o.id == order.id)) {
        _orders.add(order);
      }

      // Instant notification
      notifyListeners();

      if (kDebugMode) {
        print(
          '📚 MyBooksProvider: Added purchased book with instant feedback: ${book.title}',
        );
      }
    } catch (e) {
      _error = 'Satın alınan kitap eklenirken hata oluştu: $e';
      if (kDebugMode) {
        print('❌ MyBooksProvider: Error adding purchased book: $e');
      }
      notifyListeners();
    }
  }

  /// Refresh purchased books from service
  Future<void> refreshPurchasedBooks(
    String userId,
    BookProvider bookProvider,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Reload orders
      _orders = await _orderService.getOrdersForUser(userId);

      // Extract purchased book IDs
      final purchasedBookIds = <String>{};
      for (final order in _orders) {
        for (final item in order.items) {
          purchasedBookIds.add(item.bookId);
        }
      }

      // Get purchased books from BookProvider
      _purchasedBooks = bookProvider.books
          .where((book) => purchasedBookIds.contains(book.id))
          .toList();

      // If no purchased books but we have orders, use demo fallback
      if (_purchasedBooks.isEmpty && _orders.isNotEmpty) {
        _purchasedBooks = bookProvider.books.take(2).toList();
      }

      if (kDebugMode) {
        print(
          '📚 MyBooksProvider: Refreshed ${_purchasedBooks.length} purchased books',
        );
      }
    } catch (e) {
      _error = 'Satın alınan kitaplar yenilenirken hata oluştu: $e';
      if (kDebugMode) {
        print('❌ MyBooksProvider: Error refreshing purchased books: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh reading history
  Future<void> refreshReadingHistory(
    String userId,
    BookProvider bookProvider,
  ) async {
    try {
      await _loadReadingHistory(userId, bookProvider);
      notifyListeners();

      if (kDebugMode) {
        print('📚 MyBooksProvider: Refreshed reading history');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ MyBooksProvider: Error refreshing reading history: $e');
      }
    }
  }

  /// Check if user has purchased a book
  bool hasUserPurchasedBook(String bookId) {
    return _purchasedBooks.any((book) => book.id == bookId);
  }

  /// Force refresh and notify all listeners
  Future<void> forceRefresh(String userId, BookProvider bookProvider) async {
    await initializeMyBooks(userId, bookProvider);

    // Double notification for stubborn UI
    notifyListeners();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   notifyListeners();
    // });
  }

  /// Clear all state (for logout)
  void clearState() {
    _purchasedBooks.clear();
    _readingHistory.clear();
    _orders.clear();
    _currentUserId = null;
    _error = null;
    _isLoading = false;
    notifyListeners();

    if (kDebugMode) {
      print('📚 MyBooksProvider: Cleared all state');
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
