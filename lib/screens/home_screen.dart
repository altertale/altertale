import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import '../models/book_model.dart';
import '../widgets/widgets.dart';
import '../widgets/books/book_card.dart';

/// Home Screen - Ana Sayfa
///
/// Kullanıcının ana ekranı. Hoş geldin mesajı, hızlı işlemler,
/// öne çıkan kitaplar ve son aktiviteler gösterilir.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CartService _cartService = CartService();
  int _currentIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    final bookProvider = context.read<BookProvider>();
    await bookProvider.loadFeaturedBooks();

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          backgroundColor: colorScheme.surface,
          title: Row(
            children: [
              Icon(Icons.auto_stories, color: colorScheme.primary),
              const SizedBox(width: 8),
              TitleText(
                'Altertale',
                color: colorScheme.primary,
                size: TitleSize.large,
              ),
            ],
          ),
          actions: [
            // Cart Icon with Badge
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (!authProvider.isLoggedIn) {
                  return IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.of(context).pushNamed('/cart'),
                  );
                }

                return StreamBuilder<int>(
                  stream: _cartService
                      .getCartItemsStream(authProvider.user!.uid)
                      .map(
                        (cartItems) => cartItems.fold<int>(
                          0,
                          (sum, item) => sum + item.quantity,
                        ),
                      ),
                  builder: (context, snapshot) {
                    final cartItemCount = snapshot.data ?? 0;

                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined),
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/cart'),
                        ),
                        if (cartItemCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                cartItemCount > 99
                                    ? '99+'
                                    : cartItemCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bildirimler yakında...')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
            ),
          ],
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Welcome Section
              _buildWelcomeSection(),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActionsSection(),
              const SizedBox(height: 24),

              // Featured Books
              _buildFeaturedBooksSection(),
              const SizedBox(height: 24),

              // Recent Activity
              _buildRecentActivitySection(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final displayName = authProvider.isLoggedIn
            ? authProvider.getUserDisplayText()
            : 'Misafir';

        return RoundedCard(
          backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.waving_hand,
                    color: Colors.orange.shade400,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  TitleText('Merhaba, $displayName!', size: TitleSize.medium),
                ],
              ),
              const SizedBox(height: 8),
              SubtitleText(
                'Bugün hangi hikayeyi keşfetmek istiyorsun?',
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleText('Hızlı İşlemler', size: TitleSize.medium),
        const SizedBox(height: 12),

        // First Row - Main Actions
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.auto_stories,
                title: 'Kitaplara Gözat',
                subtitle: 'Tüm Koleksiyon',
                onTap: () => Navigator.of(context).pushNamed('/books'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.shopping_cart,
                title: 'Sepetim',
                subtitle: 'Alışveriş',
                onTap: () => Navigator.of(context).pushNamed('/cart'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Second Row - User Actions
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.receipt_long,
                title: 'Siparişlerim',
                subtitle: 'Geçmiş',
                onTap: () => Navigator.of(context).pushNamed('/orders'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.favorite,
                title: 'Favoriler',
                subtitle: 'Beğendikleriniz',
                onTap: () => Navigator.of(context).pushNamed('/my-books'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RoundedCard(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 32, color: colorScheme.primary),
          const SizedBox(height: 8),
          TitleText(title, size: TitleSize.small, textAlign: TextAlign.center),
          SubtitleText(
            subtitle,
            size: SubtitleSize.small,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedBooksSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star, color: colorScheme.primary),
            const SizedBox(width: 8),
            TitleText('Öne Çıkan Kitaplar', size: TitleSize.medium),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<BookProvider>(
          builder: (context, bookProvider, child) {
            final featuredBooks = bookProvider.featuredBooks;

            if (bookProvider.isLoading) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (featuredBooks.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(child: Text('Henüz öne çıkan kitap yok')),
              );
            }

            return SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredBooks.length,
                itemBuilder: (context, index) {
                  final book = featuredBooks[index];
                  return Container(
                    width: 160,
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedBookCard(int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
    ];
    final titles = [
      'Harika Kitap ${index + 1}',
      'Muhteşem Roman',
      'Büyülü Hikaye',
      'Epik Macera',
      'Sırlar Kitabı',
    ];

    return RoundedCard(
      onTap: () => Navigator.of(context).pushNamed('/book/${index + 1}'),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: colors[index].withValues(alpha: 0.2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Icon(Icons.menu_book, size: 48, color: colors[index]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleText(
                      titles[index],
                      size: TitleSize.small,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    SubtitleText(
                      'Yazar ${index + 1}',
                      size: SubtitleSize.small,
                      color: colorScheme.onSurfaceVariant,
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

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleText('Son Aktiviteler', size: TitleSize.medium),
        const SizedBox(height: 12),
        ...List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
            child: _buildActivityItem(index),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activities = [
      'Bugün 3 sayfa okudunuz',
      'Yeni bir kitap favorilerinize eklendi',
      'Haftalık okuma hedefinizin %60\'ını tamamladınız',
    ];
    final icons = [Icons.menu_book, Icons.favorite, Icons.emoji_events];

    return RoundedCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icons[index], color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: SubtitleText(activities[index])),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            switch (index) {
              case 0:
                // Home - already here
                break;
              case 1:
                Navigator.of(context).pushNamed('/explore');
                break;
              case 2:
                Navigator.of(context).pushNamed('/my-books');
                break;
              case 3:
                Navigator.of(context).pushNamed('/library');
                break;
              case 4:
                Navigator.of(context).pushNamed('/cart');
                break;
              case 5:
                Navigator.of(context).pushNamed('/profile');
                break;
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Keşfet',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Kitaplarım',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined),
              activeIcon: Icon(Icons.library_books),
              label: 'Kütüphane',
            ),
            BottomNavigationBarItem(
              icon: StreamBuilder<List<CartItem>>(
                stream: authProvider.isLoggedIn
                    ? _cartService.getCartItemsStream(authProvider.user!.uid)
                    : const Stream.empty(),
                builder: (context, snapshot) {
                  final cartItems = snapshot.data ?? [];
                  if (cartItems.isEmpty) {
                    return const Icon(Icons.shopping_cart_outlined);
                  }
                  return Badge(
                    label: Text('${cartItems.length}'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  );
                },
              ),
              activeIcon: const Icon(Icons.shopping_cart),
              label: 'Sepet',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        );
      },
    );
  }
}

/// Bottom Navigation Item Model
class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
