import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../models/book_model.dart';
import '../../services/order_service.dart';
import '../../models/order.dart';
import '../../widgets/books/book_card.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../services/purchase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Library Screen - Kütüphane Ekranı
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _isInitialized = false;
  final PurchaseService _purchaseService = PurchaseService();
  List<BookModel> _purchasedBooks = [];
  bool _isLoadingPurchased = false;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    final bookProvider = context.read<BookProvider>();
    await bookProvider.loadBooks(limit: 10);

    // Load purchased books
    await _loadPurchasedBooks();

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _loadPurchasedBooks() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) return;

    setState(() {
      _isLoadingPurchased = true;
    });

    try {
      // Use order service to get purchased books (demo compatible)
      final orders = await _orderService.getOrdersForUser(authProvider.userId);
      final purchasedBookIds = <String>{};

      // Extract book IDs from completed orders
      for (final order in orders) {
        for (final item in order.items) {
          purchasedBookIds.add(item.bookId);
        }
      }

      // Get book details for purchased books from BookProvider
      final bookProvider = context.read<BookProvider>();
      final allBooks = bookProvider.books;

      _purchasedBooks = allBooks
          .where((book) => purchasedBookIds.contains(book.id))
          .toList();

      print(
        '📚 LibraryScreen: Loaded ${_purchasedBooks.length} purchased books from ${orders.length} orders',
      );
    } catch (e) {
      debugPrint('Error loading purchased books: $e');

      // Fallback: Create demo purchased books if orders exist
      final bookProvider = context.read<BookProvider>();
      if (bookProvider.books.isNotEmpty) {
        // Demo: First 2 books as purchased
        _purchasedBooks = bookProvider.books.take(2).toList();
        print('📚 LibraryScreen: Using demo purchased books fallback');
      } else {
        _purchasedBooks = [];
      }
    } finally {
      setState(() {
        _isLoadingPurchased = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Kütüphanem'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isLoggedIn) {
            return _buildLoginPrompt();
          }

          return _buildLibraryContent();
        },
      ),
    );
  }

  Widget _buildLoginPrompt() {
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
            'Kütüphaneni Görüntüle',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kitaplarını ve okuma geçmişini görmek için giriş yap.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<BookProvider>().refreshAll();
        await _loadPurchasedBooks();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            const SizedBox(height: 24),

            // Purchased Books Section
            _buildPurchasedBooksSection(),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Reading Statistics
            _buildReadingStats(),
            const SizedBox(height: 24),

            // Continue Reading
            _buildContinueReading(),
            const SizedBox(height: 24),

            // Recent Activity
            _buildRecentActivity(),
            const SizedBox(height: 24),

            // Recommended Books
            _buildRecommendedBooks(),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchasedBooksSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.shopping_bag,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Satın Aldığım Kitaplar',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_isLoadingPurchased)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_purchasedBooks.isEmpty)
          EmptyStateWidget(
            icon: Icons.shopping_cart_outlined,
            title: 'Henüz Kitap Almadınız',
            subtitle:
                'Keşfet sekmesinden beğendiğiniz kitapları satın alabilirsiniz.',
            buttonText: 'Kitap Keşfet',
            onButtonPressed: () {
              Navigator.of(context).pushNamed('/explore');
            },
          )
        else
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _purchasedBooks.length,
              itemBuilder: (context, index) {
                final book = _purchasedBooks[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 16),
                  child: BookCard(
                    book: book,
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed('/book-detail', arguments: book.id);
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    final theme = Theme.of(context);
    final authProvider = context.read<AuthProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.library_books,
              color: theme.colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoş geldin!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  authProvider.userEmail ?? 'Okuyucu',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İşlemler',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.shopping_bag,
                title: 'Kitaplarım',
                subtitle: 'Satın aldığın kitaplar',
                onTap: () => Navigator.of(context).pushNamed('/my-books'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.explore,
                title: 'Keşfet',
                subtitle: 'Yeni kitaplar bul',
                onTap: () => Navigator.of(context).pushNamed('/explore'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingStats() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Okuma İstatistiklerin',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                value: '12',
                label: 'Okunan Kitap',
                icon: Icons.book,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                value: '3.2k',
                label: 'Okunan Sayfa',
                icon: Icons.description,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                value: '28h',
                label: 'Okuma Süresi',
                icon: Icons.access_time,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueReading() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Okumaya Devam Et',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/my-books'),
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                child: _buildContinueReadingCard(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContinueReadingCard(int index) {
    final theme = Theme.of(context);
    final titles = ['Savaş ve Barış', 'Suç ve Ceza', '1984'];
    final authors = ['Tolstoy', 'Dostoyevski', 'George Orwell'];
    final progress = [0.6, 0.3, 0.8];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigate to reading screen
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.book, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titles[index],
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          authors[index],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress[index],
                backgroundColor: theme.colorScheme.surfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress[index] * 100).toInt()}% tamamlandı',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Aktiviteler',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(3, (index) {
          final activities = [
            'Suç ve Ceza kitabını favorilere ekledi',
            '1984 kitabının %50\'sini tamamladı',
            'Savaş ve Barış kitabını satın aldı',
          ];
          final times = ['2 saat önce', '1 gün önce', '3 gün önce'];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.history,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            title: Text(activities[index], style: theme.textTheme.bodyMedium),
            subtitle: Text(
              times[index],
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  Widget _buildRecommendedBooks() {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        final theme = Theme.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Önerilen Kitaplar',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/explore'),
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (bookProvider.isLoading && bookProvider.books.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (bookProvider.books.isEmpty)
              Container(
                height: 200,
                child: const Center(child: Text('Önerilen kitap bulunamadı')),
              )
            else
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: bookProvider.books.length.clamp(0, 5),
                  itemBuilder: (context, index) {
                    final book = bookProvider.books[index];
                    return Container(
                      width: 120,
                      margin: EdgeInsets.only(right: index < 4 ? 12 : 0),
                      child: _buildRecommendedBookCard(book),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendedBookCard(BookModel book) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed('/book/${book.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                ),
                child: book.coverImageUrl.isNotEmpty
                    ? Image.network(
                        book.coverImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.book, size: 30);
                        },
                      )
                    : const Icon(Icons.book, size: 30),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.author,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
