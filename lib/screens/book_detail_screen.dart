import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/auth/auth_wrapper.dart';
import '../widgets/books/preview_reader.dart';
import '../widgets/widgets.dart'; // Import all custom widgets
import '../services/book_service.dart';
import '../services/cart_service.dart';
import '../services/favorites_service.dart';
import '../services/share_service.dart';
import '../services/purchase_service.dart';
import '../models/book_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_themes.dart';
import '../screens/books/reading_screen.dart';
import '../screens/books/preview_reading_screen.dart';
import '../dialogs/purchase_confirmation_dialog.dart';

class BookDetailScreen extends StatefulWidget {
  final BookModel? book;
  final String? bookId;

  const BookDetailScreen({super.key, this.book, this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen>
    with TickerProviderStateMixin {
  final BookService _bookService = BookService();
  final CartService _cartService = CartService();
  final FavoritesService _favoritesService = FavoritesService();
  final ShareService _shareService = ShareService();

  BookModel? _book;
  bool _isLoading = true;
  bool _isAddingToCart = false;
  bool _isTogglingFavorite = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookData();
  }

  /// Load book data
  Future<void> _loadBookData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      BookModel? book;

      // Use provided book if available, otherwise fetch by ID
      if (widget.book != null) {
        book = widget.book;
      } else if (widget.bookId != null) {
        book = await _bookService.getBookById(widget.bookId!);
      }

      if (book != null) {
        setState(() {
          _book = book;
        });
      } else {
        setState(() {
          _error = 'Kitap bulunamadı';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Kitap yüklenirken hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_error != null) {
      return _buildErrorState(_error!);
    }

    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_book == null) {
      return _buildNotFoundState();
    }

    return _buildBookDetail(_book!);
  }

  Widget _buildBookDetail(BookModel book) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        // App Bar with Book Cover
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          backgroundColor: colorScheme.surface,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () {
              // Fixed navigation - use AppRouter.pop instead of context.pop
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isTogglingFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isTogglingFavorite ? Colors.red : colorScheme.onSurface,
              ),
              onPressed: () => _toggleFavorite(book),
            ),
            IconButton(
              icon: Icon(Icons.share, color: colorScheme.onSurface),
              onPressed: () => _shareBook(book),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(background: _buildBookCover(book)),
        ),

        // Book Information
        SliverToBoxAdapter(child: _buildBookInfo(book)),

        // Comments Section (temporarily disabled)
        // SliverToBoxAdapter(child: _buildCommentsSection(book)),
      ],
    );
  }

  Widget _buildBookCover(BookModel book) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: book.coverImageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: book.coverImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.book,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : Container(
                color: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.book,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colorScheme.surfaceContainer,
      child: Icon(
        Icons.auto_stories,
        size: 64,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildBookInfo(BookModel book) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Author
          TitleText(
            book.title,
            size: TitleSize.large,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Center(
            child: SubtitleText(
              book.author,
              size: SubtitleSize.large,
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          // Category and Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SubtitleText(
                  book.category,
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TitleText(
                book.formattedPrice,
                size: TitleSize.medium,
                color: book.price == 0 ? Colors.green : colorScheme.primary,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Description
          const TitleText('Kitap Hakkında', size: TitleSize.medium),
          const SizedBox(height: 12),

          SubtitleText(book.description, size: SubtitleSize.medium),

          const SizedBox(height: 32),

          // Book Details
          _buildBookDetails(book),

          const SizedBox(height: 32),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Favorite Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isTogglingFavorite = !_isTogglingFavorite;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isTogglingFavorite
                                ? 'Favorilere eklendi'
                                : 'Favorilerden çıkarıldı',
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      _isTogglingFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                    label: Text(
                      _isTogglingFavorite
                          ? 'Favorilerden Çıkar'
                          : 'Favorilere Ekle',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Add to Cart Button - Dynamic
                SizedBox(
                  width: double.infinity,
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (!authProvider.isLoggedIn) {
                        return OutlinedButton.icon(
                          onPressed: () => _addToCart(book),
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: const Text('Sepete Ekle'),
                        );
                      }

                      return FutureBuilder<bool>(
                        future: _isBookInCart(book, authProvider.userId),
                        builder: (context, snapshot) {
                          final isInCart = snapshot.data ?? false;

                          if (isInCart) {
                            // Book is already in cart - show green check button
                            return ElevatedButton.icon(
                              onPressed: () => _addToCart(
                                book,
                              ), // This will show the "already in cart" message
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Sepete Eklendi',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            );
                          } else {
                            // Book not in cart - show normal button
                            return OutlinedButton.icon(
                              onPressed: () => _addToCart(book),
                              icon: const Icon(Icons.shopping_cart_outlined),
                              label: const Text('Sepete Ekle'),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Preview Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _previewBook(book),
                    child: const Text('Önizleme'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Reviews Section
          // ReviewsSection(bookId: book.id, bookTitle: book.title),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBookDetails(BookModel book) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RoundedCard(
      backgroundColor: colorScheme.surfaceContainer.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('Kitap Bilgileri', size: TitleSize.medium),
          const SizedBox(height: 16),

          _buildDetailRow('Yazar', book.author),
          _buildDetailRow('Kategori', book.category),
          _buildDetailRow('Fiyat', book.formattedPrice),

          if (book.createdAt != null)
            _buildDetailRow('Eklenme Tarihi', _formatDate(book.createdAt!)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: SubtitleText(
              label,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(child: SubtitleText(value)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BookModel book) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          return _buildLoginPrompt();
        }

        return Column(
          children: [
            // Favorite Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isTogglingFavorite = !_isTogglingFavorite;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isTogglingFavorite
                            ? 'Favorilere eklendi'
                            : 'Favorilerden çıkarıldı',
                      ),
                    ),
                  );
                },
                icon: Icon(
                  _isTogglingFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                label: Text(
                  _isTogglingFavorite
                      ? 'Favorilerden Çıkar'
                      : 'Favorilere Ekle',
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Preview Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _previewBook(book),
                child: const Text('Önizle'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoginPrompt() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RoundedCard(
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Column(
        children: [
          Icon(Icons.login, size: 48, color: colorScheme.primary),
          const SizedBox(height: 12),
          const TitleText('Giriş Yapın', size: TitleSize.medium),
          const SizedBox(height: 8),
          SubtitleText(
            'Kitabı satın almak için giriş yapmanız gerekiyor.',
            textAlign: TextAlign.center,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Giriş Yap',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            SubtitleText('Kitap yükleniyor...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const TitleText('Hata'),
        backgroundColor: colorScheme.surface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              TitleText('Kitap Yüklenemedi', color: colorScheme.error),
              const SizedBox(height: 8),
              SubtitleText(
                error,
                textAlign: TextAlign.center,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Tekrar Dene',
                onPressed: () {
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const TitleText('Kitap Bulunamadı'),
        backgroundColor: colorScheme.surface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.book_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const TitleText('Kitap Bulunamadı'),
              const SizedBox(height: 8),
              SubtitleText(
                'Aradığınız kitap mevcut değil veya kaldırılmış olabilir.',
                textAlign: TextAlign.center,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Kitaplara Dön',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/books'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Action Methods
  void _toggleFavorite(BookModel book) {
    setState(() {
      _isTogglingFavorite = !_isTogglingFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isTogglingFavorite ? 'Favorilere eklendi' : 'Favorilerden çıkarıldı',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleCart(
    BookModel book,
    String userId,
    bool isCurrentlyInCart,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (isCurrentlyInCart) {
        // Remove from cart - find cart item and remove it
        final cartItems = await _cartService.getCartItems(userId);
        final cartItem = cartItems.firstWhere((item) => item.bookId == book.id);
        await _cartService.removeFromCart(cartItem.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${book.title} sepetten çıkarıldı'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Add to cart
        await _cartService.addToCart(book: book, userId: userId, quantity: 1);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${book.title} sepete eklendi'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Sepete Git',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/cart'),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handlePrimaryAction(BookModel book) {
    if (book.price == 0) {
      // Free book - start reading
      _startReading(book);
    } else {
      // Paid book - purchase
      _purchaseBook(book);
    }
  }

  void _startReading(BookModel book) async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen önce giriş yapın')));
      return;
    }

    // Check if book is purchased (for paid books)
    if (book.price > 0) {
      try {
        final purchaseService = PurchaseService();
        final isPurchased = await purchaseService.hasUserPurchasedBook(
          authProvider.currentUser!.uid,
          book.id,
        );

        if (!isPurchased) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu kitabı okumak için önce satın almalısınız'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kontrol edilirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Convert Book to BookModel for reading screen
    final bookModel = BookModel(
      id: book.id,
      title: book.title,
      author: book.author,
      description: book.description,
      coverImageUrl: book.coverImageUrl,
      categories: [book.category],
      tags: [], // Book model doesn't have tags, use empty list
      price: book.price,
      points: (book.price * 10).round(),
      averageRating: 0.0,
      ratingCount: 0,
      readCount: 0,
      pageCount: 100,
      language: 'tr',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPublished: true,
      isFeatured: false,
      isPopular: false,
      previewStart: 0,
      previewEnd: 5,
      pointPrice: (book.price * 10).round(),
    );

    // Generate sample pages for demo
    final pages = List.generate(50, (index) {
      return '''Bu ${book.title} kitabının ${index + 1}. sayfasıdır.

${book.description}

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Sayfa ${index + 1} sonu.
''';
    });

    // Navigate to reading screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReadingScreen(book: bookModel, pages: pages),
      ),
    );
  }

  void _purchaseBook(BookModel book) async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen önce giriş yapın')));
      return;
    }

    // Convert Book to BookModel for purchase service
    final bookModel = BookModel(
      id: book.id,
      title: book.title,
      author: book.author,
      description: book.description,
      coverImageUrl: book.coverImageUrl,
      categories: [book.category],
      tags: [], // Book model doesn't have tags, use empty list
      price: book.price,
      points: (book.price * 10).round(),
      averageRating: 0.0,
      ratingCount: 0,
      readCount: 0,
      pageCount: 100,
      language: 'tr',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPublished: true,
      isFeatured: false,
      isPopular: false,
      previewStart: 0,
      previewEnd: 5,
      pointPrice: (book.price * 10).round(),
    );

    // Show purchase confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => PurchaseConfirmationDialog(
        book: bookModel,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Perform actual purchase using PurchaseService
      final purchaseService = PurchaseService();
      final success = await purchaseService.purchaseWithTL(
        userId: authProvider.currentUser!.uid,
        book: bookModel,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${book.title} başarıyla satın alındı!'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Oku',
                onPressed: () => _startReading(book),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Satın alma başarısız: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addToCart(BookModel book) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      Navigator.of(context).pushNamed('/login');
      return;
    }

    try {
      await _cartService.addToCart(
        book: book,
        userId: authProvider.userId,
        quantity: 1,
      );

      if (mounted) {
        // Show success message and update button appearance
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Sepete eklendi!'),
              ],
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Sepete Git',
              onPressed: () => Navigator.of(context).pushNamed('/cart'),
            ),
          ),
        );

        // Trigger a rebuild to update button state
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        // Check if it's a duplicate error
        if (e.toString().contains('zaten sepette')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.info, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Bu kitap zaten sepette!'),
                ],
              ),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Sepete Git',
                onPressed: () => Navigator.of(context).pushNamed('/cart'),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sepete eklenirken hata oluştu: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  /// Check if book is already in cart
  Future<bool> _isBookInCart(BookModel book, String userId) async {
    try {
      final cartItems = await _cartService.getCartItems(userId);
      return cartItems.any((item) => item.bookId == book.id);
    } catch (e) {
      return false;
    }
  }

  void _previewBook(BookModel book) {
    // Navigate to preview reading screen
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PreviewReadingScreen(book: book)),
    );
  }

  void _shareBook(BookModel book) {
    // Import share_plus at the top if not already imported
    final String shareText =
        '''
📚 ${book.title}
✍️ Yazar: ${book.author}
💰 Fiyat: ${book.price.toStringAsFixed(2)} ₺
📖 ${book.category}

${book.description.length > 150 ? book.description.substring(0, 150) + '...' : book.description}

📱 Altertale uygulamasında bu harika kitabı keşfedin!
🔗 #Altertale #Kitap #Okuma #${book.author.replaceAll(' ', '')}

Google Play: https://play.google.com/store/apps/details?id=com.altertale.app
App Store: https://apps.apple.com/app/altertale/id123456789
''';

    try {
      // Use share_plus for sharing
      Share.share(shareText, subject: book.title);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paylaşırken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
