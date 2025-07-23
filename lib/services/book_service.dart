import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/book_model.dart';

/// Book Service for Firestore Operations
///
/// Handles all book-related database operations with BookModel
class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String booksCollection = 'books';

  // Demo mode for testing - Always true to support all users
  bool get isDemoMode => true;

  // In-memory storage for demo books - using BookModel
  static final List<BookModel> _demoBooks = [];

  /// Get books stream (real-time updates)
  Stream<List<BookModel>> getBooksStream() {
    if (isDemoMode) {
      if (kDebugMode) {
        print('📚 BookService: Using demo mode - getBooksStream');
      }
      // Initialize demo books if empty
      if (_demoBooks.isEmpty) {
        _demoBooks.addAll(_createDemoBooks());
      }
      // Return a stream that emits demo books
      return Stream.value(_demoBooks);
    }

    try {
      return _firestore
          .collection(booksCollection)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => BookModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in getBooksStream: $e');
      }
      return Stream.value(<BookModel>[]);
    }
  }

  /// Get books by category stream
  Stream<List<BookModel>> getBooksByCategoryStream(String category) {
    if (isDemoMode) {
      if (kDebugMode) {
        print(
          '📚 BookService: Using demo mode - getBooksByCategoryStream($category)',
        );
      }
      if (_demoBooks.isEmpty) {
        _demoBooks.addAll(_createDemoBooks());
      }
      final filteredBooks = _demoBooks
          .where(
            (book) => book.categories.any(
              (cat) => cat.toLowerCase() == category.toLowerCase(),
            ),
          )
          .toList();
      return Stream.value(filteredBooks);
    }

    try {
      return _firestore
          .collection(booksCollection)
          .where('isPublished', isEqualTo: true)
          .where('categories', arrayContains: category)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => BookModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in getBooksByCategoryStream: $e');
      }
      return Stream.value(<BookModel>[]);
    }
  }

  /// Get single book by ID
  Future<BookModel?> getBookById(String bookId) async {
    if (isDemoMode) {
      if (kDebugMode) {
        print('📚 BookService: Using demo mode - getBookById($bookId)');
      }
      if (_demoBooks.isEmpty) {
        _demoBooks.addAll(_createDemoBooks());
      }
      try {
        final book = _demoBooks.firstWhere((b) => b.id == bookId);
        return book;
      } catch (e) {
        if (kDebugMode) {
          print('❌ BookService: Book not found in demo: $bookId');
        }
        return null;
      }
    }

    try {
      final doc = await _firestore
          .collection(booksCollection)
          .doc(bookId)
          .get();
      if (!doc.exists) {
        if (kDebugMode) {
          print('❌ BookService: Book not found: $bookId');
        }
        return null;
      }

      final book = BookModel.fromFirestore(doc);
      if (kDebugMode) {
        print('✅ BookService: Book found: ${book.title}');
      }
      return book;
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error getting book: $e');
      }
      return null;
    }
  }

  /// Get book stream by ID (real-time updates)
  Stream<BookModel?> getBookStreamById(String bookId) {
    if (isDemoMode) {
      if (kDebugMode) {
        print('📚 BookService: Using demo mode - getBookStreamById($bookId)');
      }
      if (_demoBooks.isEmpty) {
        _demoBooks.addAll(_createDemoBooks());
      }
      final book = _demoBooks.firstWhereOrNull((b) => b.id == bookId);
      return Stream.value(book);
    }

    try {
      return _firestore.collection(booksCollection).doc(bookId).snapshots().map(
        (doc) {
          if (!doc.exists) {
            return null;
          }
          try {
            final book = BookModel.fromFirestore(doc);
            if (kDebugMode) {
              print('✅ BookService: Book stream updated: ${book.title}');
            }
            return book;
          } catch (e) {
            if (kDebugMode) {
              print('❌ BookService: Error parsing book stream: $e');
            }
            return null;
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error in getBookStreamById: $e');
      }
      return Stream.value(null);
    }
  }

  /// Get books with pagination and filtering
  Future<List<BookModel>> getBooks({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
    String orderBy = 'createdAt',
    bool descending = true,
  }) async {
    if (isDemoMode) {
      if (kDebugMode) {
        print(
          '📚 BookService: Getting books - page: $page, limit: $limit, category: $category, search: $search',
        );
      }

      if (_demoBooks.isEmpty) {
        _demoBooks.addAll(_createDemoBooks());
      }

      List<BookModel> books = List.from(_demoBooks);

      // Apply category filter
      if (category != null && category.isNotEmpty) {
        books = books
            .where(
              (book) => book.categories.any(
                (cat) => cat.toLowerCase() == category.toLowerCase(),
              ),
            )
            .toList();
      }

      // Apply search filter
      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
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
        return <BookModel>[];
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
      Query query = _firestore
          .collection(booksCollection)
          .where('isPublished', isEqualTo: true);

      // Apply category filter
      if (category != null && category.isNotEmpty) {
        query = query.where('categories', arrayContains: category);
      }

      // Apply ordering
      query = query.orderBy(orderBy, descending: descending);

      // Apply pagination
      query = query.limit(limit);
      if (page > 1) {
        // Note: For real pagination, you'd need to use startAfter with DocumentSnapshot
        // This is a simplified version for demo purposes
        final skipCount = (page - 1) * limit;
        query = query.limit(limit + skipCount);
      }

      final querySnapshot = await query.get();
      List<BookModel> books = querySnapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .toList();

      // Apply search filter (client-side for now)
      if (search != null && search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        books = books
            .where(
              (book) =>
                  book.title.toLowerCase().contains(searchLower) ||
                  book.author.toLowerCase().contains(searchLower) ||
                  book.description.toLowerCase().contains(searchLower),
            )
            .toList();
      }

      if (kDebugMode) {
        print('✅ BookService: Loaded ${books.length} books from Firestore');
      }

      return books;
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error loading books: $e');
      }
      throw 'Kitaplar yüklenirken hata oluştu: $e';
    }
  }

  /// Get featured books
  Future<List<BookModel>> getFeaturedBooks({int limit = 10}) async {
    if (isDemoMode) {
      if (kDebugMode) {
        print('📚 BookService: Getting featured books (demo mode)');
      }
      if (_demoBooks.isEmpty) {
        _demoBooks.addAll(_createDemoBooks());
      }
      final featuredBooks = _demoBooks
          .where((book) => book.isFeatured)
          .toList();
      return featuredBooks.take(limit).toList();
    }

    try {
      final querySnapshot = await _firestore
          .collection(booksCollection)
          .where('isPublished', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error loading featured books: $e');
      }
      throw 'Öne çıkan kitaplar yüklenirken hata oluştu: $e';
    }
  }

  /// Get popular books
  Future<List<BookModel>> getPopularBooks() async {
    if (isDemoMode) {
      if (_demoBooks.isEmpty) {
        _demoBooks.addAll(_createDemoBooks());
      }
      final popularBooks = _demoBooks.where((book) => book.isPopular).toList();
      return popularBooks;
    }

    final snapshot = await _firestore
        .collection(booksCollection)
        .where('isPublished', isEqualTo: true)
        .orderBy('readCount', descending: true)
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
  }

  /// Get new books
  Future<List<BookModel>> getNewBooks() async {
    if (isDemoMode) {
      if (_demoBooks.isEmpty) {
        _demoBooks.addAll(_createDemoBooks());
      }
      final sortedBooks = List<BookModel>.from(_demoBooks);
      sortedBooks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sortedBooks.take(10).toList();
    }

    final snapshot = await _firestore
        .collection(booksCollection)
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
  }

  /// Search books
  Future<List<BookModel>> searchBooks(String query) async {
    if (isDemoMode) {
      if (_demoBooks.isEmpty) {
        _demoBooks.addAll(_createDemoBooks());
      }
      final searchQuery = query.toLowerCase();
      return _demoBooks
          .where(
            (book) =>
                book.title.toLowerCase().contains(searchQuery) ||
                book.author.toLowerCase().contains(searchQuery) ||
                book.description.toLowerCase().contains(searchQuery) ||
                book.categories.any(
                  (cat) => cat.toLowerCase().contains(searchQuery),
                ),
          )
          .toList();
    }

    final snapshot = await _firestore
        .collection(booksCollection)
        .where('isPublished', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
  }

  /// Get similar books
  Future<List<BookModel>> getSimilarBooks(String bookId) async {
    try {
      if (isDemoMode) {
        if (_demoBooks.isEmpty) {
          _demoBooks.addAll(_createDemoBooks());
        }
        final currentBook = _demoBooks.firstWhereOrNull((b) => b.id == bookId);
        if (currentBook == null) return [];

        // Find books with similar categories
        return _demoBooks
            .where(
              (book) =>
                  book.id != bookId &&
                  book.categories.any(
                    (cat) => currentBook.categories.contains(cat),
                  ),
            )
            .take(5)
            .toList();
      }

      final currentBook = await getBookById(bookId);
      if (currentBook == null) return [];

      final querySnapshot = await _firestore
          .collection(booksCollection)
          .where('isPublished', isEqualTo: true)
          .where('categories', arrayContainsAny: currentBook.categories)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .where((book) => book.id != bookId)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error getting similar books: $e');
      }
      return [];
    }
  }

  /// Get books by author
  Future<List<BookModel>> getBooksByAuthor(String author) async {
    if (isDemoMode) {
      if (_demoBooks.isEmpty) {
        _demoBooks.addAll(_createDemoBooks());
      }
      return _demoBooks
          .where((book) => book.author.toLowerCase() == author.toLowerCase())
          .toList();
    }

    final snapshot = await _firestore
        .collection(booksCollection)
        .where('isPublished', isEqualTo: true)
        .where('author', isEqualTo: author)
        .get();
    return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
  }

  /// Get books by category
  Future<List<BookModel>> getBooksByCategory(String category) async {
    if (isDemoMode) {
      if (_demoBooks.isEmpty) {
        _demoBooks.addAll(_createDemoBooks());
      }
      return _demoBooks
          .where(
            (book) => book.categories.any(
              (cat) => cat.toLowerCase() == category.toLowerCase(),
            ),
          )
          .toList();
    }

    final snapshot = await _firestore
        .collection(booksCollection)
        .where('isPublished', isEqualTo: true)
        .where('categories', arrayContains: category)
        .get();
    return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
  }

  /// Get free books
  Future<List<BookModel>> getFreeBooks() async {
    if (isDemoMode) {
      if (_demoBooks.isEmpty) {
        _demoBooks.addAll(_createDemoBooks());
      }
      return _demoBooks.where((book) => book.price == 0.0).toList();
    }

    final snapshot = await _firestore
        .collection(booksCollection)
        .where('isPublished', isEqualTo: true)
        .where('price', isEqualTo: 0.0)
        .get();
    return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
  }

  /// Get books by price range
  Future<List<BookModel>> getBooksByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    if (isDemoMode) {
      if (_demoBooks.isEmpty) {
        _demoBooks.addAll(_createDemoBooks());
      }
      return _demoBooks
          .where((book) => book.price >= minPrice && book.price <= maxPrice)
          .toList();
    }

    final snapshot = await _firestore
        .collection(booksCollection)
        .where('isPublished', isEqualTo: true)
        .where('price', isGreaterThanOrEqualTo: minPrice)
        .where('price', isLessThanOrEqualTo: maxPrice)
        .get();
    return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
  }

  /// Add book (admin)
  Future<String> addBook(BookModel book) async {
    try {
      final docRef = await _firestore
          .collection(booksCollection)
          .add(book.toMap());
      if (kDebugMode) {
        print('✅ BookService: Book added: ${book.title}');
      }
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error adding book: $e');
      }
      throw 'Kitap eklenirken hata oluştu: $e';
    }
  }

  /// Update book (admin)
  Future<void> updateBook(String bookId, BookModel book) async {
    try {
      await _firestore
          .collection(booksCollection)
          .doc(bookId)
          .update(book.toMap());
      if (kDebugMode) {
        print('✅ BookService: Book updated: ${book.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ BookService: Error updating book: $e');
      }
      throw 'Kitap güncellenirken hata oluştu: $e';
    }
  }

  /// Demo kitapları oluştur (test için)
  List<BookModel> _createDemoBooks() {
    return [
      BookModel(
        id: 'ATB001', // Unique AlterTale Book ID
        title: 'Dijital Çağın Hikayesi',
        author: 'Ayşe Yazıcı',
        description:
            'Teknolojinin hayatımızı nasıl değiştirdiğini anlatan çarpıcı bir roman. Modern insanın dijital dünyayla olan ilişkisini derinlemesine inceleyen bu eser, okuyucuları düşündürürken eğlendiriyor.',
        coverImageUrl: 'https://picsum.photos/400/600?random=1',
        categories: ['Roman', 'Teknoloji'],
        tags: ['dijital', 'modern', 'teknoloji'],
        price: 29.99,
        points: 150,
        averageRating: 4.5,
        ratingCount: 128,
        readCount: 1250,
        pageCount: 320,
        language: 'tr',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        isPublished: true,
        isFeatured: true,
        isPopular: true,
        previewStart: 1,
        previewEnd: 15,
        pointPrice: 299,
        content: _getDemoBookContent('Dijital Çağın Hikayesi'),
      ),
      BookModel(
        id: 'ATB002',
        title: 'Yıldızlar Arası Yolculuk',
        author: 'Mehmet Bilimci',
        description:
            'Uzayın derinliklerinde geçen bu bilim kurgu romanı, insanlığın gelecekteki maceralarını anlatıyor. Keşif, dostluk ve cesaret temasıyla dolu bu eser, hayal gücünüzü sınırsızca genişletecek.',
        coverImageUrl: 'https://picsum.photos/400/600?random=2',
        categories: ['Bilim Kurgu', 'Macera'],
        tags: ['uzay', 'bilim kurgu', 'macera'],
        price: 34.99,
        points: 200,
        averageRating: 4.8,
        ratingCount: 89,
        readCount: 890,
        pageCount: 280,
        language: 'tr',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
        isPublished: true,
        isFeatured: true,
        isPopular: false,
        previewStart: 1,
        previewEnd: 12,
        pointPrice: 349,
        content: _getDemoBookContent('Yıldızlar Arası Yolculuk'),
      ),
      BookModel(
        id: 'ATB003',
        title: 'Aşkın Matematiği',
        author: 'Zeynep Kalp',
        description:
            'Matematik öğretmeni olan Ana ile mimar Kerem\'in hikayesi. İki farklı dünyadan gelen bu karakterlerin aşk hikayesi, hem duygusal hem de entelektüel bir okuma deneyimi sunuyor.',
        coverImageUrl: 'https://picsum.photos/400/600?random=3',
        categories: ['Romantik', 'Drama'],
        tags: ['aşk', 'matematik', 'drama'],
        price: 24.99,
        points: 120,
        averageRating: 4.2,
        ratingCount: 156,
        readCount: 2100,
        pageCount: 240,
        language: 'tr',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
        isPublished: true,
        isFeatured: false,
        isPopular: true,
        previewStart: 1,
        previewEnd: 10,
        pointPrice: 249,
        content: _getDemoBookContent('Aşkın Matematiği'),
      ),
      BookModel(
        id: 'ATB004',
        title: 'Kayıp Hazine',
        author: 'Serkan Macera',
        description:
            'Tarihçi Dr. Elif\'in Anadolu\'da kayıp hazineyi bulma macerası. Antik dönemlerden kalma ipuçlarını takip eden bu heyecan verici hikaye, tarihi gerçeklerle kurguyu ustaca harmanlıyor.',
        coverImageUrl: 'https://picsum.photos/400/600?random=4',
        categories: ['Macera', 'Tarih'],
        tags: ['hazine', 'tarih', 'macera'],
        price: 27.99,
        points: 140,
        averageRating: 4.6,
        ratingCount: 203,
        readCount: 1800,
        pageCount: 300,
        language: 'tr',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        isPublished: true,
        isFeatured: false,
        isPopular: true,
        previewStart: 1,
        previewEnd: 18,
        pointPrice: 279,
        content: _getDemoBookContent('Kayıp Hazine'),
      ),
      BookModel(
        id: 'ATB005',
        title: 'Ücretsiz Hikayeler',
        author: 'Topluluk Yazarları',
        description:
            'Farklı yazarlardan toplanan kısa hikayeler koleksiyonu. Her türden okuyucuya hitap eden bu ücretsiz kitap, yeni yazarları keşfetmenin harika bir yolu.',
        coverImageUrl: 'https://picsum.photos/400/600?random=5',
        categories: ['Hikaye', 'Koleksiyon'],
        tags: ['ücretsiz', 'kısa hikaye', 'koleksiyon'],
        price: 0.0, // Free book
        points: 0,
        averageRating: 4.0,
        ratingCount: 45,
        readCount: 3200,
        pageCount: 150,
        language: 'tr',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
        isPublished: true,
        isFeatured: false,
        isPopular: false,
        previewStart: 1,
        previewEnd: 25,
        pointPrice: 0,
        content: _getDemoBookContent('Ücretsiz Hikayeler'),
      ),
      BookModel(
        id: 'ATB006',
        title: 'Yaşamın Sırları',
        author: 'Dr. Bilge Yaşam',
        description:
            'Yaşam koçu Dr. Bilge\'nin kişisel gelişim ve mutlu yaşam üzerine pratik önerileri. Bu rehber kitap, hayatınızı daha anlamlı ve verimli kılmanız için somut adımlar sunuyor.',
        coverImageUrl: 'https://picsum.photos/400/600?random=6',
        categories: ['Kişisel Gelişim', 'Rehber'],
        tags: ['yaşam', 'gelişim', 'rehber'],
        price: 19.99,
        points: 100,
        averageRating: 4.3,
        ratingCount: 67,
        readCount: 950,
        pageCount: 180,
        language: 'tr',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now(),
        isPublished: true,
        isFeatured: false,
        isPopular: false,
        previewStart: 1,
        previewEnd: 20,
        pointPrice: 199,
        content: _getDemoBookContent('Yaşamın Sırları'),
      ),
      BookModel(
        id: 'ATB007',
        title: 'Kod Savaşçıları',
        author: 'Hakan Developer',
        description:
            'Programlama dünyasının kahramanları olan geliştiricilerin hikayesi. Teknoloji sektöründeki zorluklarla nasıl başa çıktıklarını anlatan ilham verici öyküler.',
        coverImageUrl: 'https://picsum.photos/400/600?random=7',
        categories: ['Teknoloji', 'Biyografi'],
        tags: ['programlama', 'teknoloji', 'geliştirici'],
        price: 32.99,
        points: 180,
        averageRating: 4.7,
        ratingCount: 91,
        readCount: 1100,
        pageCount: 350,
        language: 'tr',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
        isPublished: true,
        isFeatured: true,
        isPopular: false,
        previewStart: 1,
        previewEnd: 15,
        pointPrice: 329,
        content: _getDemoBookContent('Kod Savaşçıları'),
      ),
      BookModel(
        id: 'ATB008',
        title: 'Geleceğin Şehri',
        author: 'Aylin Gelecek',
        description:
            'İstanbul 2050\'de nasıl görünecek? Bu distopik roman, çevre sorunları ve teknolojik gelişmelerin şehir yaşamını nasıl etkileyeceğini hayal ediyor.',
        coverImageUrl: 'https://picsum.photos/400/600?random=8',
        categories: ['Distopya', 'Bilim Kurgu'],
        tags: ['gelecek', 'şehir', 'distopya'],
        price: 28.99,
        points: 150,
        averageRating: 4.4,
        ratingCount: 134,
        readCount: 1450,
        pageCount: 290,
        language: 'tr',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
        isPublished: true,
        isFeatured: false,
        isPopular: true,
        previewStart: 1,
        previewEnd: 12,
        pointPrice: 289,
        content: _getDemoBookContent('Geleceğin Şehri'),
      ),
      BookModel(
        id: 'ATB009',
        title: 'Sessiz Gece',
        author: 'Canan Gizem',
        description:
            'Küçük bir kasabada yaşanan gizemli olayları konu alan bu gerilim romanı. Dedektif Komiseri Metin\'in zorlu soruşturması okuyucuları son sayfaya kadar merakta bırakacak.',
        coverImageUrl: 'https://picsum.photos/400/600?random=9',
        categories: ['Gerilim', 'Polisiye'],
        tags: ['gizem', 'polisiye', 'gerilim'],
        price: 26.99,
        points: 135,
        averageRating: 4.1,
        ratingCount: 178,
        readCount: 2300,
        pageCount: 260,
        language: 'tr',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
        isPublished: true,
        isFeatured: false,
        isPopular: true,
        previewStart: 1,
        previewEnd: 14,
        pointPrice: 269,
        content: _getDemoBookContent('Sessiz Gece'),
      ),
      BookModel(
        id: 'ATB010',
        title: 'Derin Öğrenme Rehberi',
        author: 'Prof. Dr. Ali Yapay',
        description:
            'Yapay zeka ve derin öğrenme konularında kapsamlı bir rehber. Hem teorik bilgi hem de pratik uygulamalar içeren bu kitap, AI öğrenmek isteyenler için mükemmel.',
        coverImageUrl: 'https://picsum.photos/400/600?random=10',
        categories: ['Eğitim', 'Teknoloji'],
        tags: ['yapay zeka', 'öğrenme', 'teknoloji'],
        price: 39.99,
        points: 250,
        averageRating: 4.9,
        ratingCount: 56,
        readCount: 780,
        pageCount: 420,
        language: 'tr',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        isPublished: true,
        isFeatured: true,
        isPopular: false,
        previewStart: 1,
        previewEnd: 20,
        pointPrice: 399,
        content: _getDemoBookContent('Derin Öğrenme Rehberi'),
      ),
    ];
  }

  /// Demo kitap içeriği oluştur
  String _getDemoBookContent(String title) {
    return '''
$title

Bu dijital kitabın demo içeriğidir. 

Bölüm 1: Başlangıç

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Bölüm 2: Gelişim

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.

Bölüm 3: Sonuç

Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.

Bu kitabın devamı satın alma işleminden sonra görülebilir...
''';
  }
}

// Extension to add firstWhereOrNull method
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
