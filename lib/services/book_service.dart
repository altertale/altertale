import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/book.dart';

/// Book Service for Firestore Operations
///
/// Handles all book-related database operations including:
/// - Real-time book listing
/// - Book detail retrieval
/// - CRUD operations for future modules
class BookService {
  static final BookService _instance = BookService._internal();
  factory BookService() => _instance;
  BookService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _booksCollection = 'books';

  // ==================== REAL-TIME DATA STREAMS ====================

  /// Get real-time stream of all books
  Stream<List<Book>> getBooksStream() {
    try {
      if (kDebugMode) {
        print('📚 BookService: Starting books stream');
      }

      return _firestore
          .collection(_booksCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final books = snapshot.docs
                .map((doc) => Book.fromFirestore(doc))
                .toList();

            if (kDebugMode) {
              print(
                '📚 BookService: Loaded ${books.length} books from Firestore',
              );
            }

            return books;
          });
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in getBooksStream: $e');
      }
      throw 'Kitaplar yüklenirken hata oluştu: $e';
    }
  }

  /// Get real-time stream of books by category
  Stream<List<Book>> getBooksByCategoryStream(String category) {
    try {
      if (kDebugMode) {
        print('📚 BookService: Starting books stream for category: $category');
      }

      return _firestore
          .collection(_booksCollection)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final books = snapshot.docs
                .map((doc) => Book.fromFirestore(doc))
                .toList();

            if (kDebugMode) {
              print(
                '📚 BookService: Loaded ${books.length} books for category $category',
              );
            }

            return books;
          });
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in getBooksByCategoryStream: $e');
      }
      throw 'Kategori kitapları yüklenirken hata oluştu: $e';
    }
  }

  // ==================== SINGLE BOOK OPERATIONS ====================

  /// Get a single book by ID
  Future<Book?> getBookById(String bookId) async {
    try {
      if (kDebugMode) {
        print('📖 BookService: Getting book with ID: $bookId');
      }

      if (isDemoMode) {
        _initializeDemoBooks();

        // Find book in demo data
        try {
          final book = _demoBooks.firstWhere((b) => b.id == bookId);
          if (kDebugMode) {
            print('✅ BookService: Demo book found: ${book.title}');
          }
          return book;
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ BookService: Demo book not found: $bookId');
          }
          return null;
        }
      }

      final doc = await _firestore
          .collection(_booksCollection)
          .doc(bookId)
          .get();

      if (!doc.exists) {
        if (kDebugMode) {
          print('⚠️ BookService: Book not found: $bookId');
        }
        return null;
      }

      final book = Book.fromFirestore(doc);

      if (kDebugMode) {
        print('✅ BookService: Book loaded: ${book.title}');
      }

      return book;
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error getting book $bookId: $e');
      }
      throw 'Kitap detayları yüklenirken hata oluştu: $e';
    }
  }

  /// Get real-time stream for a single book
  Stream<Book?> getBookStreamById(String bookId) {
    try {
      if (kDebugMode) {
        print('📖 BookService: Starting book stream for ID: $bookId');
      }

      if (isDemoMode) {
        _initializeDemoBooks();

        // Find book in demo data
        final book = _demoBooks.firstWhere(
          (b) => b.id == bookId,
          orElse: () => throw StateError('Book not found'),
        );

        if (kDebugMode) {
          print('📖 BookService: Demo book found in stream: ${book.title}');
        }

        // Return a stream with the demo book
        return Stream.value(book);
      }

      return _firestore
          .collection(_booksCollection)
          .doc(bookId)
          .snapshots()
          .map((doc) {
            if (!doc.exists) {
              if (kDebugMode) {
                print('⚠️ BookService: Book not found in stream: $bookId');
              }
              return null;
            }

            final book = Book.fromFirestore(doc);

            if (kDebugMode) {
              print('📖 BookService: Book updated in stream: ${book.title}');
            }

            return book;
          });
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in book stream $bookId: $e');
      }

      if (isDemoMode) {
        // Return null stream for demo mode if book not found
        if (kDebugMode) {
          print('⚠️ BookService: Demo book not found: $bookId');
        }
        return Stream.value(null);
      }

      throw 'Kitap güncellemeleri alınırken hata oluştu: $e';
    }
  }

  // ==================== PAGINATION SUPPORT ====================

  /// Get books with optional filtering and pagination
  Future<List<Book>> getBooks({
    int page = 1,
    int limit = 20,
    String? category,
    String? searchQuery,
  }) async {
    if (kDebugMode) {
      print(
        '📚 BookService: Getting books - page: $page, limit: $limit, category: $category, search: $searchQuery',
      );
    }

    if (isDemoMode) {
      _initializeDemoBooks();

      List<Book> books = List.from(_demoBooks);

      // Apply category filter
      if (category != null && category.isNotEmpty) {
        books = books
            .where(
              (book) => book.category.toLowerCase() == category.toLowerCase(),
            )
            .toList();
      }

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        books = books
            .where(
              (book) =>
                  book.title.toLowerCase().contains(query) ||
                  book.author.toLowerCase().contains(query) ||
                  book.description.toLowerCase().contains(query),
            )
            .toList();
      }

      // Apply pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;

      if (startIndex >= books.length) {
        return [];
      }

      final paginatedBooks = books.sublist(
        startIndex,
        endIndex > books.length ? books.length : endIndex,
      );

      if (kDebugMode) {
        print('📚 BookService: Loaded ${paginatedBooks.length} demo books');
      }

      return paginatedBooks;
    }

    try {
      Query query = _firestore.collection(_booksCollection);

      // Apply category filter
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Simple search implementation - can be improved with Algolia or similar
        query = query
            .where('title', isGreaterThanOrEqualTo: searchQuery)
            .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff');
      }

      // Apply pagination
      query = query.limit(limit);
      if (page > 1) {
        // Note: Firestore offset is not recommended for large datasets
        // Consider using cursor-based pagination for production
        final skipCount = (page - 1) * limit;
        // Firestore doesn't have direct offset, so we'll implement a simple version
        query = query.limit(limit + skipCount);
      }

      final querySnapshot = await query.get();
      List<Book> books = querySnapshot.docs
          .map((doc) => Book.fromFirestore(doc))
          .toList();

      // If we used limit + skipCount, remove the first skipCount items
      if (page > 1) {
        final skipCount = (page - 1) * limit;
        books = books.skip(skipCount).toList();
      }

      if (kDebugMode) {
        print('📚 BookService: Loaded ${books.length} books');
      }

      return books;
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error getting books: $e');
      }
      rethrow;
    }
  }

  /// Get featured books
  Future<List<Book>> getFeaturedBooks({int limit = 10}) async {
    if (kDebugMode) {
      print('📚 BookService: Getting featured books');
    }

    if (isDemoMode) {
      _initializeDemoBooks();

      // Return first few books as featured
      final featuredBooks = _demoBooks.take(limit).toList();

      if (kDebugMode) {
        print(
          '📚 BookService: Loaded ${featuredBooks.length} demo featured books',
        );
      }

      return featuredBooks;
    }

    try {
      final querySnapshot = await _firestore
          .collection(_booksCollection)
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final books = querySnapshot.docs
          .map((doc) => Book.fromFirestore(doc))
          .toList();

      if (kDebugMode) {
        print('📚 BookService: Loaded ${books.length} featured books');
      }

      return books;
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error getting featured books: $e');
      }
      rethrow;
    }
  }

  /// Get popular books
  Future<List<Book>> getPopularBooks() async {
    try {
      final snapshot = await _firestore
          .collection(_booksCollection)
          .orderBy('readCount', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in getPopularBooks: $e');
      }
      return [];
    }
  }

  /// Get new books
  Future<List<Book>> getNewBooks() async {
    try {
      final snapshot = await _firestore
          .collection(_booksCollection)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in getNewBooks: $e');
      }
      return [];
    }
  }

  /// Get all categories
  Future<List<String>> getAllCategories() async {
    try {
      final snapshot = await _firestore.collection(_booksCollection).get();
      final categories = snapshot.docs
          .map((doc) => doc.data()['category'] as String?)
          .where((category) => category != null)
          .cast<String>()
          .toSet()
          .toList();

      return categories;
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in getAllCategories: $e');
      }
      return ['Roman', 'Bilim', 'Tarih', 'Felsefe']; // Default categories
    }
  }

  /// Get all authors
  Future<List<String>> getAllAuthors() async {
    try {
      final snapshot = await _firestore.collection(_booksCollection).get();
      final authors = snapshot.docs
          .map((doc) => doc.data()['author'] as String?)
          .where((author) => author != null)
          .cast<String>()
          .toSet()
          .toList();

      return authors;
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in getAllAuthors: $e');
      }
      return ['Orhan Pamuk', 'Sabahattin Ali']; // Default authors
    }
  }

  /// Search books
  Future<List<Book>> searchBooks(String query) async {
    try {
      if (query.isEmpty) return [];

      final snapshot = await _firestore
          .collection(_booksCollection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in searchBooks: $e');
      }
      return [];
    }
  }

  /// Get similar books
  Future<List<Book>> getSimilarBooks(String bookId) async {
    try {
      // Get the book first to find its category
      final bookDoc = await _firestore
          .collection(_booksCollection)
          .doc(bookId)
          .get();
      if (!bookDoc.exists) return [];

      final bookData = bookDoc.data()!;
      final category = bookData['category'] as String?;

      if (category == null) return [];

      final snapshot = await _firestore
          .collection(_booksCollection)
          .where('category', isEqualTo: category)
          .limit(10)
          .get();

      return snapshot.docs
          .where((doc) => doc.id != bookId) // Exclude the current book
          .map((doc) => Book.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in getSimilarBooks: $e');
      }
      return [];
    }
  }

  /// Get books by author
  Future<List<Book>> getBooksByAuthor(String author) async {
    try {
      final snapshot = await _firestore
          .collection(_booksCollection)
          .where('author', isEqualTo: author)
          .get();

      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in getBooksByAuthor: $e');
      }
      return [];
    }
  }

  /// Get books by category
  Future<List<Book>> getBooksByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_booksCollection)
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in getBooksByCategory: $e');
      }
      return [];
    }
  }

  /// Increment read count
  Future<void> incrementReadCount(String bookId) async {
    try {
      await _firestore.collection(_booksCollection).doc(bookId).update({
        'readCount': FieldValue.increment(1),
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in incrementReadCount: $e');
      }
    }
  }

  /// Update book rating
  Future<void> updateBookRating(String bookId, double newRating) async {
    try {
      await _firestore.collection(_booksCollection).doc(bookId).update({
        'rating': newRating,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in updateBookRating: $e');
      }
    }
  }

  /// Get free books
  Future<List<Book>> getFreeBooks() async {
    try {
      final snapshot = await _firestore
          .collection(_booksCollection)
          .where('price', isEqualTo: 0)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in getFreeBooks: $e');
      }
      return [];
    }
  }

  /// Get books by price range
  Future<List<Book>> getBooksByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_booksCollection)
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice)
          .get();

      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in getBooksByPriceRange: $e');
      }
      return [];
    }
  }

  // ==================== CRUD OPERATIONS (Future Use) ====================

  /// Add a new book (Admin function)
  Future<String> addBook(Book book) async {
    try {
      if (kDebugMode) {
        print('➕ BookService: Adding new book: ${book.title}');
      }

      final docRef = await _firestore
          .collection(_booksCollection)
          .add(book.toMap());

      if (kDebugMode) {
        print('✅ BookService: Book added with ID: ${docRef.id}');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error adding book: $e');
      }
      throw 'Kitap eklenirken hata oluştu: $e';
    }
  }

  /// Update an existing book (Admin function)
  Future<void> updateBook(String bookId, Book book) async {
    try {
      if (kDebugMode) {
        print('📝 BookService: Updating book: $bookId');
      }

      await _firestore
          .collection(_booksCollection)
          .doc(bookId)
          .update(book.toMap());

      if (kDebugMode) {
        print('✅ BookService: Book updated: $bookId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error updating book: $e');
      }
      throw 'Kitap güncellenirken hata oluştu: $e';
    }
  }

  /// Delete a book (Admin function)
  Future<void> deleteBook(String bookId) async {
    try {
      if (kDebugMode) {
        print('🗑️ BookService: Deleting book: $bookId');
      }

      await _firestore.collection(_booksCollection).doc(bookId).delete();

      if (kDebugMode) {
        print('✅ BookService: Book deleted: $bookId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error deleting book: $e');
      }
      throw 'Kitap silinirken hata oluştu: $e';
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Check if books collection exists and has data
  Future<bool> hasBooksData() async {
    try {
      final snapshot = await _firestore
          .collection(_booksCollection)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error checking books data: $e');
      }
      return false;
    }
  }

  /// Get total books count
  Future<int> getBooksCount() async {
    try {
      final snapshot = await _firestore.collection(_booksCollection).get();

      return snapshot.docs.length;
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error getting books count: $e');
      }
      return 0;
    }
  }

  // Demo mode for testing - Always true to support all users
  bool get isDemoMode => true;

  // In-memory storage for demo books
  static final List<Book> _demoBooks = [];

  /// Initialize demo books
  void _initializeDemoBooks() {
    if (_demoBooks.isEmpty) {
      _demoBooks.addAll([
        Book(
          id: '1',
          title: 'Suç ve Ceza',
          author: 'Fyodor Dostoyevski',
          description:
              'Rus edebiyatının başyapıtlarından biri olan bu roman, suç işleyen bir gencin ruhsal çözülüşünü anlatır.',
          coverImageUrl:
              'https://img.kitapyurdu.com/v1/getImage/fn:11467526/wh:true/wi:800',
          category: 'Klasik',
          price: 25.90,
          content: _getSucVeCezaContent(),
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Book(
          id: '2',
          title: 'Savaş ve Barış',
          author: 'Lev Tolstoy',
          description:
              'Napolyon savaşları dönemini konu alan bu eser, tarih ve edebiyatın buluştuğu muhteşem bir roman.',
          coverImageUrl:
              'https://img.kitapyurdu.com/v1/getImage/fn:11428765/wh:true/wi:800',
          category: 'Klasik',
          price: 45.50,
          content: _getSavasVeBarisContent(),
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Book(
          id: '3',
          title: 'Çalıkuşu',
          author: 'Reşat Nuri Güntekin',
          description:
              'Türk edebiyatının en sevilen romanlarından biri. Feride\'nin hayat hikayesi.',
          coverImageUrl:
              'https://img.kitapyurdu.com/v1/getImage/fn:11388234/wh:true/wi:800',
          category: 'Türk Edebiyatı',
          price: 18.75,
          content: _getCalikusuContent(),
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Book(
          id: '4',
          title: 'Vadideki Zambak',
          author: 'Honoré de Balzac',
          description:
              'Aşk, tutku ve toplumsal eleştirinin harmanlandığı bu roman, Fransız edebiyatının걸작작입니다.',
          coverImageUrl:
              'https://img.kitapyurdu.com/v1/getImage/fn:11398765/wh:true/wi:800',
          category: 'Klasik',
          price: 22.30,
          content: _getVadidekiZambakContent(),
          createdAt: DateTime.now().subtract(const Duration(days: 18)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Book(
          id: '5',
          title: 'Küçük Prens',
          author: 'Antoine de Saint-Exupéry',
          description:
              'Çocukların ve yetişkinlerin eşit sevgiyle okuduğu bu eser, hayatın anlamını sorgular.',
          coverImageUrl:
              'https://img.kitapyurdu.com/v1/getImage/fn:11467890/wh:true/wi:800',
          category: 'Çocuk',
          price: 15.90,
          content: _getKucukPrensContent(),
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        Book(
          id: '6',
          title: 'İnsan Ne ile Yaşar',
          author: 'Lev Tolstoy',
          description:
              'Tolstoy\'un derin felsefi düşüncelerini içeren bu kısa hikayeler kitabı.',
          coverImageUrl:
              'https://img.kitapyurdu.com/v1/getImage/fn:11445623/wh:true/wi:800',
          category: 'Felsefe',
          price: 19.45,
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        Book(
          id: '7',
          title: 'Satranç',
          author: 'Stefan Zweig',
          description:
              'Nazi Almanya\'sında geçen bu novella, insan ruhunun derinliklerini keşfeder.',
          coverImageUrl:
              'https://img.kitapyurdu.com/v1/getImage/fn:11434567/wh:true/wi:800',
          category: 'Novella',
          price: 12.60,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        Book(
          id: '8',
          title: 'Beyaz Diş',
          author: 'Jack London',
          description:
              'Vahşi doğada geçen bu macera romanı, bir kurdun evcilleşme hikayesini anlatır.',
          coverImageUrl:
              'https://img.kitapyurdu.com/v1/getImage/fn:11456789/wh:true/wi:800',
          category: 'Macera',
          price: 21.80,
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        Book(
          id: '9',
          title: 'Simyacı',
          author: 'Paulo Coelho',
          description:
              'Bir çobanın kendi efsanesini yaşama yolculuğunu anlatan bu roman, dünya çapında sevilir.',
          coverImageUrl:
              'https://img.kitapyurdu.com/v1/getImage/fn:11478923/wh:true/wi:800',
          category: 'Modern',
          price: 24.70,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        Book(
          id: '10',
          title: 'Kürk Mantolu Madonna',
          author: 'Sabahattin Ali',
          description:
              'Türk edebiyatının en güzel aşk hikayelerinden biri. Berlin\'de geçen unutulmaz bir aşk.',
          coverImageUrl:
              'https://img.kitapyurdu.com/v1/getImage/fn:11489034/wh:true/wi:800',
          category: 'Türk Edebiyatı',
          price: 16.90,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ]);

      if (kDebugMode) {
        print(
          '📚 BookService: Demo books initialized (${_demoBooks.length} books)',
        );
      }
    }
  }

  // ==================== DEMO CONTENT GENERATORS ====================

  String _getSucVeCezaContent() {
    return '''
BÖLÜM 1

Temmuz ayının son derece sıcak ve bunaltıcı bir gününde, akşama doğru, genç bir adam K--ski sokağından çıktı ve ağır ağır, kararsız adımlarla H-- köprüsüne yöneldi.

O büyük bir apartman dairesinde kiracı olarak kalıyordu, ama ev sahibesiyle karşılaşmaktan çekiniyordu. Kadına epey para borcu vardı ve onunla karşılaşmaktan korkuyordu.

Genç adamın adı Rodion Romanoviç Raskolnikov'du. Üniversitede hukuk okuyordu, ama artık derslerine gitmiyor, okumuyordu. Çok fakir düşmüş, aylardır uygun bir iş bulamamıştı.

Bu gün, tuhaf bir karar vermişti. Aklından geçen korkunç plana tekrar tekrar dönüyordu. "Ben bunu yapabilir miyim?" diye kendi kendine soruyordu. "Hayır, bu imkansız... Bu sadece aptalca bir rüya..."

Ama yine de gidiyordu. Gittiği yer belli: yaşlı tefeci kadının eviydi.

BÖLÜM 2

Alëna İvanovna'nın kapısına geldiğinde ellerini titriyordu. Yaşlı kadın oldukça zengin biriydi, ama çok cimri ve acımasızdı. Raskolnikov ona daha önce de bazı eşyalarını rehin vermişti.

"Yine mi geldin?" dedi yaşlı kadın kapıyı açarken. "Ne istiyorsun bu sefer?"

"Bir şey rehin vermek istiyorum," dedi Raskolnikov titrek bir sesle.

Kadın onu içeri aldı. Raskolnikov cebinden küçük bir gümüş saat çıkardı. Bu saati babası ona vermişti.

"Bu kadar az para... Bu saat çok değerli değil," dedi Alëna İvanovna saati incelerken.

Raskolnikov'un kafası karışıktı. Aklından korkunç düşünceler geçiyordu. "Şimdi mi yapmalıyım?" diye düşündü. "Bu kadın kötü, kimse onu sevmez... Ama hayır, ben bunu yapamam..."

BÖLÜM 3

Ertesi gün Raskolnikov çok rahatsızdı. Geceyi hiç uyumadan geçirmişti. Sürekli aynı şeyi düşünüyordu. Bir yandan vicdanı onu suçluyordu, öte yandan akla mantığa sığmayan fikirler zihnini kemiriyordu.

"Eğer ben bu işi yaparsam," diye düşünüyordu, "bu para ile üniversitemi bitirebilirim. Annemle kız kardeşime yardım edebilirim. O yaşlı kadın zaten hiç kimsenin işine yaramıyor..."

Ama sonra kendine geliyordu: "Hayır! Bu korkunç bir düşünce. Ben nasıl bir insana dönüştüm? Bu düşünce bile beni rezil ediyor."

Sokağa çıktı, aimlessly dolaştı. Nihayetinde tekrar o meşhur apartmana doğru yürümeye başladı...
''';
  }

  String _getSavasVeBarisContent() {
    return '''
BÖLÜM 1
Moskova, 1805

- "Eh, Prens, Cenova ve Lucca artık Buonaparte ailesinin mülkleri haline geldi. Ama sizi uyarıyorum, eğer bu savaş hakkında bahsetmeye devam etmezseniz... artık dostum değilsiniz," dedi Anna Pavlovna Scherer, Çar'ın maiyetinden biri olan Prens Vasily'ye.

Bu sözler 1805 yılının Temmuz ayında, Petersburg'daki zarif bir salonda söylenmişti. Anna Pavlovna prestijli bir soirée veriyordu ve Rus soylularının elit üyeleri burada toplanmıştı.

"Napolyon tehlikeli bir adam," diye devam etti Anna Pavlovna. "O sadece Fransa'yı değil, tüm Avrupa'yı ele geçirmek istiyor."

Prens Vasily gülümsedi. O yaşlı, tecrübeli bir diplomattı. "Anna Pavlovna, siz her zaman abartıyorsunuz. Napolyon elbette tehlikeli, ama..."

BÖLÜM 2
Rostov Ailesi

Aynı dönemde, Moskova'da Rostov ailesi de savaş hazırlıklarını konuşuyordu. Count İlya Rostov zengin bir soyluydu ve çok misafirperver biriydi.

"Nikolenka'yı orduya göndermemiz gerekiyor," dedi Countess Natalya Rostova, genç oğlu Nikolay'dan bahsederken. "O artık bir erkek ve vatanına hizmet etmeli."

Nikolay Rostov on sekiz yaşındaydı, genç, yakışıklı ve macera seversen. Savaş fikri onu heyecanlandırıyordu.

"Evet anne! Ben savaşmak istiyorum. Napolyon'u durdurmak için elimizden geleni yapmalıyız," dedi kararlı bir şekilde.

Küçük kız kardeşi Natasha ise endişeliydi. O henüz on üç yaşındaydı, ama çok hassas ve akıllı bir kızdı.

BÖLÜM 3
Pierre Bezukhov

Pierre Bezukhov, Count Bezukhov'un gayrimeşru oğluydu. Çok zengin olmasına rağmen, kendini mutsuz ve kayıp hissediyordu. O dönemin felsefî akımlarına ilgi duyuyordu.

"Bu savaş neyi çözecek?" diye düşünüyordu Pierre. "İnsanlar neden birbirini öldürmeye bu kadar istekli?"

O, Anna Pavlovna'nın soirée'sine katılmıştı ve oradaki sohbetleri dinliyordu. Soyluların savaş konusundaki heyecanları onu rahatsız ediyordu.

"Belki de bu savaş gerekli," dedi kendi kendine. "Ama keşke barışçıl yollarla çözülebilseydi..."

Bu gece, Pierre'nin hayatı değişecekti...
''';
  }

  String _getCalikusuContent() {
    return '''
BİRİNCİ KISIM

Feride on yedi yaşındaydı. İstanbul'da, Erenköy'deki evlerinde yaşıyordu. Babası Faiz Bey, eskiden varlıklı bir aile ferdi olmasına rağmen, artık maddi sıkıntılar çekiyordu.

Bu sabah Feride pencereden Marmara'yı seyrediyordu. Deniz çok sakindi ve güneşin altında pırıl pırıl parlıyordu.

"Ne yapacağım ben?" diye düşünüyordu. "Babam beni evlendirmek istiyor, ama ben henüz çok gencim."

Feride çok güzel bir kızdı. Uzun kumral saçları, yeşil gözleri ve narin yapısıyla İstanbul'un en güzel kızlarından biriydi. Ama güzelliği onu mutlu etmiyordu.

"Öğretmen olmak istiyorum," diye mırıldandı. "Belki böyle kendi ayaklarım üzerinde durabilirim."

BİRİNCİ BÖLÜM
Karar

Faiz Bey o akşam eve geldiğinde müjdeli haberini verdi:

"Feride, kızım! Sana çok iyi bir kısmet çıktı. Münir Bey'in oğlu Kemal senle evlenmek istiyor."

Feride'nin yüzü bembeyaz oldu. "Baba, ben henüz evlenecek yaşta değilim."

"Saçmalama kızım. Sen artık büyük bir hanımefendisin. Kemal Bey çok iyi bir aile çocuğu, hem de zengin."

"Ama baba, ben onu sevmiyorum. Hem de ben öğretmen olmak istiyorum."

Faiz Bey sinirlenmeye başladı. "Öğretmenlik! Bu ne biçim düşünce? Bir hanımefendiye yakışır mı öğretmenlik yapmak?"

İKİNCİ BÖLÜM
Kaçış

Feride o gece uzun uzun düşündü. Babası onu zorla evlendirecekti, ama o buna razı değildi. Tek çare vardı: kaçmak.

Ertesi sabah erkenden kalktı ve bavuluna birkaç eşya koydu. Annesinin eski mücevherlerinden birkaçını da aldı. Bu paralarla bir süre idare edebilirdi.

"Anadolu'da bir kasabada öğretmenlik yapacağım," diye düşündü. "Orada kimse beni tanımaz ve özgürce yaşayabilirim."

İstanbul'dan Anadolu'ya gidecek vapura binerken kalbi hızla çarpıyordu. Bu büyük bir maceraydı ve ne ile karşılaşacağını bilmiyordu.

"Allah'ım, bana yardım et," diye dua etti sessizce.

Vapur düdük çaldı ve yavaş yavaş İstanbul'dan uzaklaştı. Feride arkasına bakmadı. Artık yeni bir hayat başlıyordu...
''';
  }

  String _getVadidekiZambakContent() {
    return '''
BİRİNCİ BÖLÜM

Félix de Vandenesse yirmi iki yaşında genç, yakışıklı bir asilzadeydi. Tours yakınlarındaki Clochegourde şatosuna geldiği o bahar günü, hayatının en önemli anını yaşayacağını bilmiyordu.

Bahçede yürürken, güzel bir kadının beyaz elbisesiyle zambaklar arasında durduğunu gördü. Bu kadın Henriette de Mortsauf'tu - evli, iki çocuk annesi ve Félix'ten altı yaş büyük.

"Madame," dedi Félix, şapkasını çıkararak. "Bu güzel bahçenizde kaybolmuşum. Beni affeder misiniz?"

Henriette döndü ve ona baktı. O an, ikisinin de hayatı değişti. Gözleri buluştuğunda, tarif edilemez bir şey oldu.

"Tabii ki, Monsieur. Burası Clochegourde. Ben Madame de Mortsauf."

Félix'in kalbi çılgınca atmaya başladı. Bu kadında öyle bir güzellik, öyle bir zarafet vardı ki...

İKİNCİ BÖLÜM
Yasak Aşk

Günler geçti. Félix her gün şatoya gelmeye başladı. Henriette'in kocası Monsieur de Mortsauf yaşlı ve hastalıklı bir adamdı. Çocukları Jacques ve Madeleine ile ilgilenirken, Henriette çok yorgun düşüyordu.

"Siz buraya gelince evimiz aydınlanıyor," dedi Henriette bir gün. "Félix, siz çok iyi bir arkadaşsınız."

Ama Félix'in hisleri arkadaşlıktan çok daha derinleriyle geliyordu. O Henriette'e aşıktı, ama bu aşkını hiçbir zaman açıkça söyleyemiyordu.

"Henriette," diye mırıldandı bir gün yalnızken. "Sizi seviyorum, ama bu yasak bir aşk. Siz evlisiniz ve ben sadece genç bir adamım."

ÜÇÜNCÜ BÖLÜM
Mektuplar

Félix Paris'e dönmek zorunda kaldığında, Henriette ile mektuplamaya başladılar. Bu mektuplar iki kalbin en derin duygularını içeriyordu.

"Sevgili Félix," yazıyordu Henriette, "sizin dostluğunuz benim hayatımın en değerli hazinesi. Lütfen beni unutmayın."

Félix de ona şu satırları yazıyordu: "Henriette, siz benim ruhuma işlemiş bir zambaksınız. Sizin yanınızda olmadığım her an, sanki ölü gibiyim."

Ama bu aşk hiçbir zaman gerçekleşemeyecekti. Toplumun kuralları, ahlaki değerler ve Henriette'in evli olması... Hepsi bu aşkın önünde büyük engellerdi.

Félix bu acıyı kalbinde taşıyacak, Henriette ise vazifesini yerine getirmeye devam edecekti...
''';
  }

  String _getKucukPrensContent() {
    return '''
BÖLÜM I

Altı yaşındayken, "Yaşanmış Hikayeler" adlı virgin ormanlar hakkındaki bir kitapta muhteşem bir resim gördüm. Bir boa yılanının vahşi bir hayvanı yuttuğu resimdi.

Kitapta şöyle yazıyordu: "Boa yılanları avlarını bütün halinde yutarlar, çiğnemezler. Sonra artık hareket edemezler ve altı ay uyuyarak sindirim yaparlar."

Bu konuyu çok düşündüm ve renkli kalemimle ilk resmimi çizdim. 1 numaralı çizimim böyleydi:

Şaheserimi büyüklere gösterdim ve onlara şapkanın korkutucu olup olmadığını sordum.

Bana şu karşılığı verdiler: "Şapka neden korkutucu olsun?"

Benim resmim şapka değildi. Bir fili sindiren boa yılanıydı. Bunun üzerine büyüklerin anlayabilmesi için boa yılanının içini çizdim. Büyükler hep açıklama isterler. 2 numaralı çizimim şöyleydi:

BÖLÜM II

Böylece altı yaşında parlak bir kariyeri - ressam kariyerimi - bıraktım. 1 ve 2 numaralı çizimlerimin başarısızlığı beni cesaret kırmıştı.

Büyükler hiçbir şeyi kendileri anlayamazlar. Çocuklar için onlara durmadan açıklama yapmak çok yorucu bir iştir.

Bu nedenle başka bir meslek seçmek zorunda kaldım ve pilot olmayı öğrendim. Dünyanın her tarafında uçtum. Gerçekten de coğrafya bana çok işe yaradı.

Çin ile Arizona'yı bir bakışta ayırt edebiliyordum. Gecenin ortasında kaybolursanız, bu çok yararlıdır.

BÖLÜM III

Hayatım boyunca ciddi insanlarla çok karşılaştım. Büyükler arasında uzun zaman yaşadım. Onları çok yakından tanıdım. Bu da düşüncemi pek değiştirmedi.

Ne zaman akıllı biriyle karşılaştıysam, ona hep 1 numaralı çizimimi gösterdim. Bu çizimi hep yanımda taşırım. Gerçekten anlayışlı biri olup olmadığını öğrenmek isterdim.

Ama hep şu karşılığı alırdım: "Bu bir şapka."

O zaman ne boa yılanlarından, ne virgin ormanlardan, ne de yıldızlardan bahsederdim. Onun seviyesine inerdim. Briç, golf, politika ve kravatlardan konuşurdum. O zaman da bu büyük adamı, böylesine akıllı bir adam tanıdığı için çok memnun olurdu.

BÖLÜM IV

Sahara çölünde motor arızası nedeniyle zorunlu iniş yapmıştım. Yanımda ne bir teknisyen, ne de bir yolcu vardı. Zor bir tamiri tek başıma yapmaya girişecektim.

Bu benim için ölüm kalım meselesiydi. İçecek suyum ancak sekiz gün yetecekti.

İlk gece kum üzerinde, binlerce kilometre uzakta herhangi bir yerde, denizin ortasında sal üzerindeki gemi kazası geçirmişlerden daha yalnız uyudum.

Gün doğarken tuhaf, küçük bir sesin beni uyandırdığını düşünebilirsiniz:

"Lütfen... bana bir koyun çizer misin?"

"Hıı!"

"Bana bir koyun çizer misin..."
''';
  }
}
