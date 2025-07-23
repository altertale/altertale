import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/book_model.dart';
import '../../services/favorites_service.dart';
import '../../widgets/books/book_card.dart';

/// Explore Screen - Keşfet Ekranı
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FavoritesService _favoritesService = FavoritesService();
  String _selectedCategory = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    final bookProvider = context.read<BookProvider>();
    await bookProvider.refreshAll();

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Keşfet'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Öne Çıkan'),
            Tab(text: 'Popüler'),
            Tab(text: 'Yeni'),
            Tab(text: 'Kategoriler'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(theme),

          // Content Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeaturedTab(),
                _buildPopularTab(),
                _buildNewTab(),
                _buildCategoriesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Kitap ara...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<BookProvider>().clearSearch();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        ),
        onSubmitted: (query) {
          if (query.isNotEmpty) {
            context.read<BookProvider>().searchBooks(
              query,
              debounceMs: 0,
            ); // No debounce on submit
          }
        },
        onChanged: (value) {
          setState(() {});
          // Use debounced search on text change
          if (value.isNotEmpty) {
            context.read<BookProvider>().searchBooks(value, debounceMs: 800);
          } else {
            context.read<BookProvider>().clearSearch();
          }
        },
      ),
    );
  }

  Widget _buildFeaturedTab() {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        if (bookProvider.isLoading && bookProvider.featuredBooks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bookProvider.searchResults.isNotEmpty) {
          return _buildBookGrid(bookProvider.searchResults, 'Arama Sonuçları');
        }

        if (bookProvider.featuredBooks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_outline, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Öne çıkan kitap bulunamadı'),
              ],
            ),
          );
        }

        return _buildBookGrid(bookProvider.featuredBooks, 'Öne Çıkan Kitaplar');
      },
    );
  }

  Widget _buildPopularTab() {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        if (bookProvider.isLoading && bookProvider.popularBooks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bookProvider.popularBooks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.trending_up, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Popüler kitap bulunamadı'),
              ],
            ),
          );
        }

        return _buildBookGrid(bookProvider.popularBooks, 'Popüler Kitaplar');
      },
    );
  }

  Widget _buildNewTab() {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        if (bookProvider.isLoading && bookProvider.newBooks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bookProvider.newBooks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.new_releases_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Yeni kitap bulunamadı'),
              ],
            ),
          );
        }

        return _buildBookGrid(bookProvider.newBooks, 'Yeni Kitaplar');
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        if (bookProvider.categories.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Kategori bulunamadı'),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Category Selection
            Container(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                children: bookProvider.categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : '';
                      });
                      if (selected) {
                        _loadBooksByCategory(category);
                      } else {
                        bookProvider.loadBooks();
                      }
                    },
                  );
                }).toList(),
              ),
            ),

            // Books by Category
            Expanded(
              child: _selectedCategory.isNotEmpty
                  ? _buildBookGrid(
                      bookProvider.books,
                      'Kategori: $_selectedCategory',
                    )
                  : const Center(child: Text('Bir kategori seçin')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookGrid(List<BookModel> books, String title) {
    return RefreshIndicator(
      onRefresh: () => context.read<BookProvider>().refreshAll(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final book = books[index];
                return _buildBookCard(book);
              }, childCount: books.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BookModel book) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToBookDetail(book),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover with Favorite Button
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: book.coverImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: book.coverImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.book, size: 50),
                          )
                        : const Icon(Icons.book, size: 50),
                  ),
                  // Favorite Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (!authProvider.isLoggedIn) return const SizedBox();

                      return Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: FutureBuilder<bool>(
                            future: _favoritesService.isFavorite(
                              authProvider.userId,
                              book.id,
                            ),
                            builder: (context, snapshot) {
                              final isFavorite = snapshot.data ?? false;

                              return IconButton(
                                onPressed: () =>
                                    _toggleFavorite(book, authProvider.userId),
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? Colors.red
                                      : Colors.grey[600],
                                  size: 20,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: const EdgeInsets.all(4),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Book Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${book.price.toStringAsFixed(0)}₺',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (book.averageRating > 0)
                          Row(
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.amber),
                              Text(
                                book.averageRating.toStringAsFixed(1),
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                      ],
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

  void _loadBooksByCategory(String category) {
    context.read<BookProvider>().loadBooks(category: category);
  }

  void _navigateToBookDetail(BookModel book) {
    Navigator.of(context).pushNamed('/book/${book.id}');
  }

  Future<void> _toggleFavorite(BookModel book, String userId) async {
    try {
      final isFavorite = await _favoritesService.toggleFavorite(
        userId,
        book.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavorite
                  ? '${book.title} favorilere eklendi'
                  : '${book.title} favorilerden çıkarıldı',
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Trigger rebuild to update favorite icon
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
