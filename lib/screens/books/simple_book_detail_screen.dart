import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../providers/auth_provider.dart';
import '../../services/favorites_service.dart';
import '../../services/purchase_service.dart';
import '../../services/share_service.dart';
import '../../services/cart_service.dart';
import '../../dialogs/purchase_confirmation_dialog.dart';
import '../../screens/books/preview_reading_screen.dart';

/// Simple Book Detail Screen
/// Shows basic book information and purchase options
class SimpleBookDetailScreen extends StatefulWidget {
  final String bookId;

  const SimpleBookDetailScreen({super.key, required this.bookId});

  @override
  State<SimpleBookDetailScreen> createState() => _SimpleBookDetailScreenState();
}

class _SimpleBookDetailScreenState extends State<SimpleBookDetailScreen> {
  final BookService _bookService = BookService();
  final FavoritesService _favoritesService = FavoritesService();
  final PurchaseService _purchaseService = PurchaseService();
  final ShareService _shareService = ShareService();
  final CartService _cartService = CartService();

  BookModel? _book;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isPurchased = false;
  bool _isPurchasing = false;
  bool _isInCart = false;
  bool _isAddingToCart = false;
  bool _isCheckingCart = false;
  String? _error;

  // Debouncing mechanism to prevent rapid button presses
  DateTime? _lastButtonPress;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  bool _canPressButton() {
    final now = DateTime.now();
    if (_lastButtonPress == null ||
        now.difference(_lastButtonPress!) > _debounceDelay) {
      _lastButtonPress = now;
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh purchase status when returning from purchase screens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPurchaseStatus();
    });
  }

  /// Refresh purchase status - called when returning from purchase flows
  Future<void> _refreshPurchaseStatus() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn || _book == null) return;

    try {
      await _checkPurchaseStatus(authProvider.userId);
    } catch (e) {
      print('📖 SimpleBookDetailScreen: Error refreshing purchase status: $e');
    }
  }

  /// Mark book as purchased immediately (called after successful purchase)
  void _markAsPurchased() {
    if (mounted) {
      setState(() {
        _isPurchased = true;
        _isInCart = false; // Remove from cart if purchased
      });
      print('📖 SimpleBookDetailScreen: Manually marked book as purchased');
    }
  }

  Future<void> _loadBook() async {
    print('📖 SimpleBookDetailScreen: Starting to load book ${widget.bookId}');

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print(
        '📖 SimpleBookDetailScreen: Calling BookService.getBookById(${widget.bookId})',
      );
      final book = await _bookService.getBookById(widget.bookId);
      print(
        '📖 SimpleBookDetailScreen: BookService returned: ${book != null ? book.title : 'null'}',
      );

      if (book != null) {
        if (mounted) {
          setState(() {
            _book = book;
          });
        }
        print('📖 SimpleBookDetailScreen: Book set in state: ${book.title}');

        // Check if book is in favorites and purchased
        final authProvider = context.read<AuthProvider>();
        if (authProvider.isLoggedIn) {
          print(
            '📖 SimpleBookDetailScreen: User logged in, checking status...',
          );
          try {
            await Future.wait([
              _checkFavoriteStatus(authProvider.userId),
              _checkPurchaseStatus(authProvider.userId),
              _checkCartStatus(authProvider.userId),
            ]).timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                print('📖 SimpleBookDetailScreen: Status checks timed out');
                return [];
              },
            );
          } catch (e) {
            print('📖 SimpleBookDetailScreen: Error in status checks: $e');
          }
        }
      } else {
        print('📖 SimpleBookDetailScreen: Book is null, showing error');
        if (mounted) {
          setState(() {
            _error = 'Kitap bulunamadı';
          });
        }
      }
    } catch (e) {
      print('📖 SimpleBookDetailScreen: Error loading book: $e');
      if (mounted) {
        setState(() {
          _error = 'Kitap yüklenirken hata oluştu: $e';
        });
      }
    } finally {
      print('📖 SimpleBookDetailScreen: Setting loading to false');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkFavoriteStatus(String userId) async {
    try {
      print('📖 SimpleBookDetailScreen: Checking favorite status for $userId');
      final isFav = await _favoritesService.isFavorite(userId, widget.bookId);
      print('📖 SimpleBookDetailScreen: Favorite status result: $isFav');
      if (mounted) {
        // Use post frame callback to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isFavorite = isFav;
            });
          }
        });
      }
    } catch (e) {
      print('❌ Error checking favorite status: $e');
    }
  }

  Future<void> _checkPurchaseStatus(String userId) async {
    try {
      print(
        '📖 SimpleBookDetailScreen: Checking purchase status for $userId, book: ${widget.bookId}',
      );

      final isPurchased = await _purchaseService
          .hasUserPurchasedBook(userId, widget.bookId)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print(
                '📖 SimpleBookDetailScreen: Purchase check timed out, assuming not purchased',
              );
              return false;
            },
          );

      print('📖 SimpleBookDetailScreen: Purchase status result: $isPurchased');

      if (mounted) {
        // Use post frame callback to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isPurchased = isPurchased;
            });
            print(
              '📖 SimpleBookDetailScreen: Updated _isPurchased to: $_isPurchased',
            );
          }
        });
      }
    } catch (e) {
      print('❌ SimpleBookDetailScreen: Error checking purchase status: $e');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isPurchased = false;
            });
          }
        });
      }
    }
  }

  Future<void> _checkCartStatus(String userId) async {
    try {
      print('📖 SimpleBookDetailScreen: Checking cart status for $userId');
      final isInCart = await _cartService.isBookInCart(widget.bookId, userId);
      print('📖 SimpleBookDetailScreen: Cart status result: $isInCart');
      if (mounted) {
        // Use post frame callback to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isInCart = isInCart;
            });
          }
        });
      }
    } catch (e) {
      print('❌ Error checking cart status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favorilere eklemek için giriş yapmalısınız'),
        ),
      );
      return;
    }

    try {
      final newState = await _favoritesService.toggleFavorite(
        authProvider.userId,
        widget.bookId,
      );

      setState(() {
        _isFavorite = newState;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Favorilere eklendi' : 'Favorilerden çıkarıldı',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handlePurchase() async {
    if (_book == null) return;

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Satın almak için giriş yapmalısınız')),
      );
      return;
    }

    // Show purchase confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => PurchaseConfirmationDialog(
        book: _book!,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isPurchasing = true;
    });

    try {
      final success = await _purchaseService.purchaseWithTL(
        userId: authProvider.userId,
        book: _book!,
      );

      if (success) {
        setState(() {
          _isPurchased = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Kitap başarıyla satın alındı!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Satın alma işlemi başarısız oldu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isPurchasing = false;
      });
    }
  }

  Future<void> _handlePreview() async {
    if (_book == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PreviewReadingScreen(book: _book!),
      ),
    );
  }

  Future<void> _handleRead() async {
    if (_book == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📖 Okuma özelliği yakında eklenecek...')),
    );
  }

  Future<void> _handleShare() async {
    if (_book == null) return;

    try {
      await _shareService.shareBook(
        bookId: _book!.id,
        title: _book!.title,
        author: _book!.author,
        description: _book!.description,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paylaşım hatası: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _handleAddToCart() async {
    if (_book == null || !_canPressButton()) return;

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sepete eklemek için giriş yapmalısınız')),
      );
      return;
    }

    // Check if already purchased - enhanced check
    try {
      final isPurchasedNow = await _purchaseService
          .hasUserPurchasedBook(authProvider.userId, _book!.id)
          .timeout(const Duration(seconds: 3));

      if (isPurchasedNow) {
        if (mounted) {
          setState(() {
            _isPurchased = true; // Update local state
            _isAddingToCart = false;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bu kitabı zaten satın aldınız. "Kitaplarım" bölümünden erişebilirsiniz.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    } catch (e) {
      print('⚠️ Could not verify purchase status: $e');
    }

    // Check if already in cart
    if (_isInCart) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu kitap zaten sepetinizde'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Prevent multiple simultaneous requests
    if (_isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      print('🛒 Adding book to cart: ${_book!.title}');

      await _cartService.addToCart(book: _book!, userId: authProvider.userId);

      // Success - update UI immediately
      if (mounted) {
        setState(() {
          _isInCart = true;
          _isAddingToCart = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Kitap sepete eklendi!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        print('✅ Successfully added to cart and updated UI');
      }
    } catch (e) {
      print('❌ Error adding to cart: $e');

      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Sepete ekleme başarısız: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_book?.title ?? 'Kitap Detayı'),
        actions: [
          if (_book != null) ...[
            IconButton(icon: const Icon(Icons.share), onPressed: _handleShare),
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
              ),
              onPressed: _toggleFavorite,
            ),
          ],
        ],
      ),
      body: _buildBody(context, theme, colorScheme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadBook,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_book == null) {
      return const Center(child: Text('Kitap bulunamadı'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover and basic info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image
              Container(
                width: 120,
                height: 180,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _book!.coverImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: _book!.coverImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.book, size: 50),
                        ),
                      )
                    : const Icon(Icons.book, size: 50),
              ),

              const SizedBox(width: 16),

              // Book info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _book!.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _book!.author,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_book!.categories.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: _book!.categories.map((category) {
                          return Chip(
                            label: Text(category),
                            backgroundColor: colorScheme.primaryContainer,
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '₺${_book!.price.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${_book!.pageCount} sayfa',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Rating display
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < _book!.averageRating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_book!.averageRating.toStringAsFixed(1)} (${_book!.ratingCount} değerlendirme)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            'Açıklama',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(_book!.description, style: theme.textTheme.bodyLarge),

          const SizedBox(height: 32),

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_book == null) return const SizedBox();

    // Free books can be read directly
    if (_book!.price <= 0) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _handleRead,
          icon: const Icon(Icons.menu_book),
          label: const Text('Ücretsiz - Okumaya Başla'),
        ),
      );
    }

    if (_isPurchased) {
      // Show read button if purchased
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _handleRead,
          icon: const Icon(Icons.menu_book),
          label: const Text('Okumaya Başla'),
        ),
      );
    }

    // Show preview and add to cart buttons if not purchased
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _handlePreview,
            child: const Text('Önizleme'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: _buildCartButton()),
      ],
    );
  }

  Widget _buildCartButton() {
    if (_isInCart) {
      // Already in cart - show "In Cart" button
      return OutlinedButton.icon(
        onPressed: () {
          // Navigate to cart
          Navigator.of(context).pushNamed('/cart');
        },
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Sepette'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.green,
          side: const BorderSide(color: Colors.green),
        ),
      );
    }

    // Not in cart - show "Add to Cart" button
    return FilledButton.icon(
      onPressed: (_isAddingToCart || _isPurchasing) ? null : _handleAddToCart,
      icon: _isAddingToCart
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.add_shopping_cart),
      label: _isAddingToCart
          ? const Text('Ekleniyor...')
          : Text('₺${_book!.price.toStringAsFixed(2)} - Sepete Ekle'),
      style: FilledButton.styleFrom(
        backgroundColor: _isAddingToCart ? Colors.grey : null,
      ),
    );
  }
}
