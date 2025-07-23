import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/mybooks_provider.dart';
import '../../models/book_model.dart';
import '../../models/book.dart';
import '../../services/favorites_service.dart';
import '../../services/order_service.dart';
import '../../services/purchase_service.dart';
import '../../services/reading_progress_service.dart';
import '../../widgets/books/book_card.dart';
import '../../widgets/common/empty_state_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../screens/books/reader_screen.dart';
import '../../screens/book_detail_screen.dart';

/// My Books Screen - Kitaplarım Ekranı
class MyBooksScreen extends StatefulWidget {
  const MyBooksScreen({super.key});

  @override
  State<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final int _selectedTabIndex = 0;
  bool _isLoading = true;
  final FavoritesService _favoritesService = FavoritesService();
  final OrderService _orderService = OrderService();
  final PurchaseService _purchaseService = PurchaseService();

  // Mock data for demonstration
  List<BookModel> _favoriteBooks = [];
  List<BookModel> _purchasedBooks = [];
  List<BookModel> _readingHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize providers after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  // Add didChangeDependencies to reload when returning to this screen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Force refresh when screen becomes active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forceRefreshProviders();
    });
  }

  /// Initialize all providers
  Future<void> _initializeProviders() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bookProvider = context.read<BookProvider>();
      final favoritesProvider = context.read<FavoritesProvider>();
      final myBooksProvider = context.read<MyBooksProvider>();

      // Initialize all providers
      await Future.wait([
        favoritesProvider.initializeFavorites(
          authProvider.userId,
          bookProvider,
        ),
        myBooksProvider.initializeMyBooks(authProvider.userId, bookProvider),
      ]);

      // Update local state from providers
      _favoriteBooks = favoritesProvider.favoriteBooks;
      _purchasedBooks = myBooksProvider.purchasedBooks;
      _readingHistory = myBooksProvider.readingHistory;

      if (kDebugMode) {
        print(
          '📚 MyBooksScreen: Initialized providers - ${_favoriteBooks.length} favorites, ${_purchasedBooks.length} purchased',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ MyBooksScreen: Error initializing providers: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Force refresh all providers
  Future<void> _forceRefreshProviders() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) return;

    try {
      final bookProvider = context.read<BookProvider>();
      final favoritesProvider = context.read<FavoritesProvider>();
      final myBooksProvider = context.read<MyBooksProvider>();

      // Force refresh all providers
      await Future.wait([
        favoritesProvider.forceRefresh(authProvider.userId, bookProvider),
        myBooksProvider.forceRefresh(authProvider.userId, bookProvider),
      ]);

      // Update local state from providers
      if (mounted) {
        setState(() {
          _favoriteBooks = favoritesProvider.favoriteBooks;
          _purchasedBooks = myBooksProvider.purchasedBooks;
          _readingHistory = myBooksProvider.readingHistory;
        });
      }

      if (kDebugMode) {
        print(
          '📚 MyBooksScreen: Force refreshed - ${_favoriteBooks.length} favorites, ${_purchasedBooks.length} purchased',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ MyBooksScreen: Error force refreshing: $e');
      }
    }
  }

  // Method to refresh only favorites without full reload
  Future<void> _refreshFavorites() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) return;

    try {
      final bookProvider = context.read<BookProvider>();
      final favoritesProvider = context.read<FavoritesProvider>();

      // Refresh favorites from provider
      await favoritesProvider.refreshFavorites(
        authProvider.userId,
        bookProvider,
      );

      // Update local favorites list
      if (mounted) {
        setState(() {
          _favoriteBooks = favoritesProvider.favoriteBooks;
        });
      }

      print('📚 MyBooksScreen: Refreshed ${_favoriteBooks.length} favorites');
    } catch (e) {
      print('Error refreshing favorites: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserBooks() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) return;

    final bookProvider = context.read<BookProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();

    // Initialize favorites provider
    await favoritesProvider.initializeFavorites(
      authProvider.userId,
      bookProvider,
    );

    // Get favorites from provider
    _favoriteBooks = favoritesProvider.favoriteBooks;

    // Load real purchased books from orders
    try {
      final orders = await _orderService.getOrdersForUser(authProvider.userId);
      final purchasedBookIds = <String>{};

      // Extract book IDs from completed orders
      for (final order in orders) {
        for (final item in order.items) {
          purchasedBookIds.add(item.bookId);
        }
      }

      final allBooks = bookProvider.books;

      _purchasedBooks = allBooks
          .where((book) => purchasedBookIds.contains(book.id))
          .toList();

      print(
        '📚 MyBooksScreen: Loaded ${_purchasedBooks.length} purchased books from ${orders.length} orders',
      );

      // If no purchased books but we have orders, use demo fallback
      if (_purchasedBooks.isEmpty && orders.isNotEmpty) {
        _purchasedBooks = allBooks.take(2).toList();
        print('📚 MyBooksScreen: Using demo purchased books fallback');
      }
    } catch (e) {
      debugPrint('Error loading purchased books: $e');
      // Fallback to demo data
      final bookProvider = context.read<BookProvider>();
      if (bookProvider.books.isNotEmpty) {
        _purchasedBooks = bookProvider.books.take(2).toList();
      } else {
        _purchasedBooks = _generateMockBooks('Purchased');
      }
    }

    // Load real reading history from progress service
    try {
      final readingProgressService = ReadingProgressService();
      final recentProgress = await readingProgressService.getRecentlyReadBooks(
        userId: authProvider.userId,
        limit: 10,
      );
      final bookProvider = context.read<BookProvider>();

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

      print(
        '📚 MyBooksScreen: Loaded ${_readingHistory.length} reading history items',
      );
    } catch (e) {
      debugPrint('Error loading reading history: $e');
      // Fallback to mock data
      _readingHistory = _generateMockBooks('History');
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<BookModel> _generateMockBooks(String type) {
    return List.generate(5, (index) {
      return BookModel(
        id: '${type.toLowerCase()}_$index',
        title: '$type Book ${index + 1}',
        author: 'Author ${index + 1}',
        description: 'Description for $type book ${index + 1}',
        coverImageUrl: 'https://via.placeholder.com/150x200',
        categories: ['Fiction'],
        tags: [],
        price: index == 0 ? 0.0 : 29.99,
        points: 0,
        averageRating: 4.0 + (index * 0.2),
        ratingCount: 10 + index,
        readCount: 100 + (index * 10),
        pageCount: 200 + (index * 50),
        language: 'tr',
        createdAt: DateTime.now().subtract(Duration(days: index)),
        updatedAt: DateTime.now(),
        isPublished: true,
        isFeatured: index == 0,
        isPopular: index < 2,
        previewStart: 0,
        previewEnd: 10,
        pointPrice: 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitaplarım'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: 'Favoriler'),
            Tab(icon: Icon(Icons.library_books), text: 'Satın Aldıklarım'),
            Tab(icon: Icon(Icons.history), text: 'Okuma Geçmişi'),
          ],
        ),
      ),
      body: Consumer3<FavoritesProvider, MyBooksProvider, AuthProvider>(
        builder:
            (context, favoritesProvider, myBooksProvider, authProvider, child) {
              if (!authProvider.isLoggedIn) {
                return _buildNotLoggedInState();
              }

              if (_isLoading &&
                  (favoritesProvider.isLoading || myBooksProvider.isLoading)) {
                return const Center(child: CircularProgressIndicator());
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  // Favorites Tab - Using provider data
                  _buildTabContent(
                    books: favoritesProvider.favoriteBooks,
                    type: 'favorites',
                    emptyIcon: Icons.favorite_border,
                    emptyTitle: 'Henüz favori kitap yok',
                    emptySubtitle:
                        'Beğendiğiniz kitapları favorilere ekleyebilirsiniz.',
                    emptyActionText: 'Kitap Keşfet',
                    onEmptyAction: () =>
                        Navigator.pushNamed(context, '/explore'),
                  ),

                  // Purchased Books Tab - Using provider data
                  _buildTabContent(
                    books: myBooksProvider.purchasedBooks,
                    type: 'purchased',
                    emptyIcon: Icons.shopping_cart_outlined,
                    emptyTitle: 'Henüz kitap almadınız',
                    emptySubtitle: 'Satın aldığınız kitaplar burada görünecek.',
                    emptyActionText: 'Kitap Satın Al',
                    onEmptyAction: () =>
                        Navigator.pushNamed(context, '/explore'),
                  ),

                  // Reading History Tab - Using provider data
                  _buildTabContent(
                    books: myBooksProvider.readingHistory,
                    type: 'history',
                    emptyIcon: Icons.history,
                    emptyTitle: 'Okuma geçmişi boş',
                    emptySubtitle: 'Okuduğunuz kitaplar burada görünecek.',
                    emptyActionText: 'Okumaya Başla',
                    onEmptyAction: () =>
                        Navigator.pushNamed(context, '/explore'),
                  ),
                ],
              );
            },
      ),
    );
  }

  Widget _buildNotLoggedInState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.library_books_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Kitaplarını Görüntüle',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Satın aldığın kitapları ve favorilerini görmek için giriş yap.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }

  /// Build tab content with proper navigation
  Widget _buildTabContent({
    required List<BookModel> books,
    required String type,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptySubtitle,
    required String emptyActionText,
    required VoidCallback onEmptyAction,
  }) {
    if (books.isEmpty) {
      return EmptyStateWidget(
        title: emptyTitle,
        subtitle: emptySubtitle,
        icon: emptyIcon,
        buttonText: emptyActionText,
        onButtonPressed: onEmptyAction,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return GestureDetector(
            onTap: () => _handleBookTap(context, book, type),
            child: BookCard(book: book),
          );
        },
      ),
    );
  }

  /// Handle book tap with different navigation for different types
  void _handleBookTap(BuildContext context, BookModel book, String type) {
    if (type == 'purchased') {
      // Purchased books → Navigate to ReaderScreen
      final bookForReader = Book(
        id: book.id,
        title: book.title,
        author: book.author,
        description: book.description,
        coverImageUrl: book.coverImageUrl,
        category: book.categories.isNotEmpty ? book.categories.first : 'Genel',
        price: book.price,
        createdAt: book.createdAt,
        updatedAt: book.updatedAt,
        content: book.content, // Include content for reading
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ReaderScreen(bookId: book.id, book: bookForReader),
        ),
      );

      if (kDebugMode) {
        print(
          '📚 MyBooksScreen: Opening purchased book in ReaderScreen: ${book.title}',
        );
      }
    } else {
      // Favorites and history → Navigate to BookDetailScreen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookDetailScreen(bookId: book.id),
        ),
      );

      if (kDebugMode) {
        print(
          '📚 MyBooksScreen: Opening ${type} book in BookDetailScreen: ${book.title}',
        );
      }
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onAction, child: Text(actionText)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookList(List<BookModel> books, String type) {
    return RefreshIndicator(
      onRefresh: _loadUserBooks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return _buildBookListItem(book, type);
        },
      ),
    );
  }

  Widget _buildBookListItem(BookModel book, String type) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: book.coverImageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    book.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.book, size: 30);
                    },
                  ),
                )
              : const Icon(Icons.book, size: 30),
        ),
        title: Text(
          book.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              book.author,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  book.averageRating.toStringAsFixed(1),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                Text(
                  '${book.pageCount} sayfa',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (type == 'history') ...[
              const SizedBox(height: 4),
              Text(
                'Son okunma: ${_formatDate(book.updatedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleBookAction(value, book),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'read',
              child: ListTile(
                leading: Icon(Icons.book_online),
                title: Text('Oku'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'details',
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Detaylar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (type == 'favorites')
              const PopupMenuItem(
                value: 'unfavorite',
                child: ListTile(
                  leading: Icon(Icons.favorite_border),
                  title: Text('Favorilerden Çıkar'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            if (type == 'purchased')
              const PopupMenuItem(
                value: 'download',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('İndir'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        onTap: () {
          if (type == 'purchased') {
            // For purchased books, go directly to reader
            Navigator.of(context).pushNamed(
              '/reader',
              arguments: {'bookId': book.id, 'book': book},
            );
          } else if (type == 'favorites') {
            // For favorites, go to book detail card instead of reading
            Navigator.of(context).pushNamed('/book-detail', arguments: book.id);
          } else {
            // For other types, use existing read logic
            _handleBookAction('read', book);
          }
        },
      ),
    );
  }

  void _handleBookAction(String action, BookModel book) {
    switch (action) {
      case 'read':
        // First check if book is purchased before allowing reading
        _checkPurchaseAndRead(book);
        break;
      case 'details':
        Navigator.of(context).pushNamed('/book-detail', arguments: book.id);
        break;
      case 'unfavorite':
        _removeFromFavorites(book);
        break;
      case 'download':
        _downloadBook(book);
        break;
    }
  }

  // New method to check purchase before reading
  Future<void> _checkPurchaseAndRead(BookModel book) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) return;

    try {
      // Check if book is purchased
      final purchaseService = PurchaseService();
      final isPurchased = await purchaseService.hasUserPurchasedBook(
        userId: authProvider.userId,
        bookId: book.id,
      );

      if (!isPurchased) {
        // Show purchase required dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Satın Alma Gerekli'),
              content: Text(
                '${book.title} kitabını okumak için öncelikle satın almanız gerekiyor.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tamam'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(
                      context,
                    ).pushNamed('/book-detail', arguments: book.id);
                  },
                  child: const Text('Satın Al'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Book is purchased, allow reading
      _startReading(book);
    } catch (e) {
      print('Error checking purchase status: $e');
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kitap durumu kontrol edilirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method to start reading
  void _startReading(BookModel book) {
    // Convert BookModel to Book for compatibility
    final bookForReader = Book(
      id: book.id,
      title: book.title,
      author: book.author,
      description: book.description,
      coverImageUrl: book.coverImageUrl,
      category: book.categories.isNotEmpty ? book.categories.first : 'Genel',
      price: book.price,
      createdAt: book.createdAt,
      updatedAt: book.updatedAt,
    );

    Navigator.of(context).pushNamed(
      '/reader',
      arguments: {'bookId': book.id, 'book': bookForReader},
    );
  }

  void _removeFromFavorites(BookModel book) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) return;

    try {
      // Remove from favorites service
      await _favoritesService.toggleFavorite(authProvider.userId, book.id);

      setState(() {
        _favoriteBooks.removeWhere((b) => b.id == book.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${book.title} favorilerden çıkarıldı'),
          action: SnackBarAction(
            label: 'Geri Al',
            onPressed: () async {
              // Add back to favorites
              await _favoritesService.toggleFavorite(
                authProvider.userId,
                book.id,
              );
              setState(() {
                _favoriteBooks.add(book);
              });
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _downloadBook(BookModel book) {
    // Mock download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${book.title} indiriliyor...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Bugün';
    } else if (difference == 1) {
      return 'Dün';
    } else if (difference < 7) {
      return '$difference gün önce';
    } else if (difference < 30) {
      return '${(difference / 7).floor()} hafta önce';
    } else {
      return '${(difference / 30).floor()} ay önce';
    }
  }
}
