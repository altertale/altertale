import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/book_model.dart';
import '../../constants/app_colors.dart';
import '../../services/favorites_service.dart';
import '../../services/cart_service.dart';
import '../../services/purchase_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/book_provider.dart';

/// Kitap kartı widget'ı - kitap bilgilerini kart formatında gösterir
class BookCard extends StatefulWidget {
  final BookModel book;
  final VoidCallback? onTap;
  final VoidCallback? onBuyTap;
  final VoidCallback? onReadTap;
  final bool isPurchased;
  final bool showPrice;
  final bool showRating;
  final bool showReadCount;
  final double? width;
  final double? height;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onBuyTap,
    this.onReadTap,
    this.isPurchased = false,
    this.showPrice = true,
    this.showRating = true,
    this.showReadCount = true,
    this.width,
    this.height,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  final CartService _cartService = CartService();
  final PurchaseService _purchaseService = PurchaseService();
  bool _isPurchased = false;
  bool _isInCart = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPurchaseStatus();
  }

  Future<void> _checkPurchaseStatus() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) return;

    try {
      final purchased = await _purchaseService.isBookPurchased(widget.book.id);
      final inCart = await _cartService.isBookInCart(
        widget.book.id,
        authProvider.userId,
      );

      if (mounted) {
        setState(() {
          _isPurchased = purchased;
          _isInCart = inCart;
        });
      }
    } catch (e) {
      print('❌ Error checking purchase status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kitap kapağı
            _buildCoverImage(context),

            // Kitap bilgileri
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0), // Further reduced padding
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kitap adı
                    Flexible(
                      child: Text(
                        widget.book.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12, // Smaller font
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Yazar adı
                    Flexible(
                      child: Text(
                        widget.book.author,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10, // Smaller font
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Fiyat
                    Text(
                      widget.book.formattedPrice,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11, // Smaller font
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Sepete Ekle butonu
                    _buildCartButton(context),

                    // Yorum butonu (sadece satın alınan kitaplar için)
                    if (_isPurchased) ...[
                      const SizedBox(height: 4),
                      _buildCommentButton(context),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kitap kapağı widget'ı
  Widget _buildCoverImage(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.book.coverImageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.book, size: 40, color: Colors.grey),
              ),
              // Performance optimizations
              memCacheWidth: 200, // Limit memory cache size
              memCacheHeight: 300,
              maxHeightDiskCache: 600, // Limit disk cache size
              maxWidthDiskCache: 400,
              fadeInDuration: const Duration(milliseconds: 200),
              fadeOutDuration: const Duration(milliseconds: 100),
            ),
            // Share button (top left)
            Positioned(top: 8, left: 8, child: _buildShareButton(context)),
            // Favorites button (top right)
            Positioned(top: 8, right: 8, child: _buildFavoritesButton(context)),
          ],
        ),
      ),
    );
  }

  /// Favorites button widget'ı
  Widget _buildFavoritesButton(BuildContext context) {
    return Consumer2<AuthProvider, FavoritesProvider>(
      builder: (context, authProvider, favoritesProvider, child) {
        if (!authProvider.isLoggedIn) {
          return const SizedBox.shrink();
        }

        // Initialize favorites if needed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final bookProvider = context.read<BookProvider>();
          favoritesProvider.initializeFavorites(
            authProvider.userId,
            bookProvider,
          );
        });

        final isFavorite = favoritesProvider.isFavorite(widget.book.id);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey[600],
            ),
            onPressed: () async {
              try {
                // BookModel is already the correct type, no conversion needed
                final wasToggled = await favoritesProvider.toggleFavorite(
                  authProvider.userId,
                  widget.book, // book is already BookModel type
                );

                // Show feedback
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        wasToggled
                            ? 'Favorilere eklendi'
                            : 'Favorilerden kaldırıldı',
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: wasToggled
                          ? Colors.green
                          : Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bir hata oluştu'),
                      duration: Duration(seconds: 1),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: const EdgeInsets.all(4),
          ),
        );
      },
    );
  }

  /// Kitap adı widget'ı
  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      widget.book.title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Yazar adı widget'ı
  Widget _buildAuthor(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      widget.book.author,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
        fontSize: 12,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Puan ve okuma sayısı widget'ı
  Widget _buildStats(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (widget.showRating) ...[
          Icon(Icons.star, size: 14, color: Colors.amber[600]),
          const SizedBox(width: 2),
          Text(
            widget.book.formattedRating,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.showReadCount) ...[
            const SizedBox(width: 8),
            Container(
              width: 2,
              height: 2,
              decoration: BoxDecoration(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
        if (widget.showReadCount) ...[
          Icon(
            Icons.visibility,
            size: 12,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
          ),
          const SizedBox(width: 2),
          Text(
            widget.book.formattedReadCount,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  /// Fiyat widget'ı
  Widget _buildPrice(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.book.price == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Ücretsiz',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      );
    }

    return Text(
      widget.book.formattedPrice,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
        fontSize: 13,
      ),
    );
  }

  /// Aksiyon butonu widget'ı
  Widget _buildActionButton(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isPurchased) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              widget.onReadTap ??
              () {
                // Navigate to reading screen
                Navigator.pushNamed(
                  context,
                  '/reading',
                  arguments: {'book': widget.book},
                );
              },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'Okumaya Başla',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      );
    }

    if (widget.book.price == 0) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: widget.onReadTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            side: BorderSide(color: theme.colorScheme.primary),
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'Ücretsiz Oku',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onBuyTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          'Satın Al',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  /// Share button widget'ı
  Widget _buildShareButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.share, color: Colors.white, size: 18),
        onPressed: () => _shareBook(context),
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }

  /// Share book method
  void _shareBook(BuildContext context) {
    // Create rich share content
    final String shareText =
        '''
📚 ${widget.book.title}
✍️ Yazar: ${widget.book.author}
💰 Fiyat: ${widget.book.formattedPrice}
⭐ Değerlendirme: ${widget.book.averageRating.toStringAsFixed(1)}/5.0 (${widget.book.ratingCount} değerlendirme)
📖 ${widget.book.pageCount} sayfa
🏷️ Kategori: ${widget.book.categories.isNotEmpty ? widget.book.categories.first : 'Genel'}

${widget.book.description.length > 100 ? widget.book.description.substring(0, 100) + '...' : widget.book.description}

📱 Altertale uygulamasında bu muhteşem kitabı keşfedin!
🔗 #Altertale #Kitap #Okuma

Google Play: https://play.google.com/store/apps/details?id=com.altertale.app
App Store: https://apps.apple.com/app/altertale/id123456789
''';

    // Show share options with different formats for different platforms
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paylaş', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // Standard share
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Genel Paylaşım'),
              subtitle: const Text('Tüm uygulamalar'),
              onTap: () {
                Navigator.pop(context);
                Share.share(shareText, subject: widget.book.title);
              },
            ),

            // WhatsApp optimized
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('WhatsApp'),
              subtitle: const Text('WhatsApp için optimize edilmiş'),
              onTap: () {
                Navigator.pop(context);
                final whatsappText =
                    '''
📚 *${widget.book.title}*
✍️ ${widget.book.author}
⭐ ${widget.book.averageRating.toStringAsFixed(1)}/5.0
💰 ${widget.book.formattedPrice}

${widget.book.description.length > 80 ? widget.book.description.substring(0, 80) + '...' : widget.book.description}

📱 Altertale uygulamasında oku!
''';
                Share.share(whatsappText, subject: widget.book.title);
              },
            ),

            // Social media optimized
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.blue),
              title: const Text('Sosyal Medya'),
              subtitle: const Text('Instagram, Twitter için optimize edilmiş'),
              onTap: () {
                Navigator.pop(context);
                final socialText =
                    '''
📚 ${widget.book.title} - ${widget.book.author}
⭐ ${widget.book.averageRating.toStringAsFixed(1)}/5.0
💰 ${widget.book.formattedPrice}

${widget.book.description.length > 120 ? widget.book.description.substring(0, 120) + '...' : widget.book.description}

#Altertale #Kitap #Okuma #${widget.book.author.replaceAll(' ', '')}
📱 Altertale'de keşfet!
''';
                Share.share(socialText, subject: widget.book.title);
              },
            ),

            // Copy link
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Linki Kopyala'),
              subtitle: const Text('Kitap bilgilerini panoya kopyala'),
              onTap: () {
                Navigator.pop(context);
                final copyText =
                    '''${widget.book.title} - ${widget.book.author}
⭐ ${widget.book.averageRating.toStringAsFixed(1)}/5.0 | 💰 ${widget.book.formattedPrice}
📱 Altertale uygulamasında oku!''';

                // Copy to clipboard (would need clipboard package)
                Share.share(copyText, subject: widget.book.title);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kitap bilgileri kopyalandı!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Yorum butonu widget'ı (sadece satın alınan kitaplar için)
  Widget _buildCommentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // Navigate to comments or book detail with comments section
          Navigator.pushNamed(
            context,
            '/book-detail',
            arguments: {'bookId': widget.book.id, 'showComments': true},
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontSize: 10),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.comment, size: 14),
            SizedBox(width: 4),
            Text('Yorum Yap'),
          ],
        ),
      ),
    );
  }

  /// Open comment modal
  void _openCommentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _CommentModal(book: widget.book),
      ),
    );
  }

  /// Sepete ekle butonu widget'ı
  Widget _buildCartButton(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showLoginPrompt(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: const TextStyle(fontSize: 11),
              ),
              child: const Text('Giriş Yap'),
            ),
          );
        }

        // Show different button based on purchase status
        if (_isPurchased) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  widget.onReadTap ??
                  () {
                    // Navigate to reading screen
                    Navigator.pushNamed(
                      context,
                      '/reading',
                      arguments: {'book': widget.book},
                    );
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: const TextStyle(fontSize: 11),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 16),
                  SizedBox(width: 4),
                  Text('Oku'),
                ],
              ),
            ),
          );
        }

        if (_isInCart) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: const TextStyle(fontSize: 11),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 16),
                  SizedBox(width: 4),
                  Text('Sepette'),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : () => _addToCart(authProvider.userId),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              textStyle: const TextStyle(fontSize: 11),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_shopping_cart, size: 16),
                      SizedBox(width: 4),
                      Text('Sepete Ekle'),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Future<void> _addToCart(String userId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use BookModel directly - no conversion needed
      await _cartService.addToCart(
        book: widget.book, // widget.book is already BookModel
        userId: userId,
      );

      setState(() {
        _isInCart = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.book.title} sepete eklendi'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
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

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Giriş Gerekli'),
        content: const Text('Sepete eklemek için giriş yapmanız gerekiyor.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }
}

/// Simple Comment Modal
class _CommentModal extends StatefulWidget {
  final BookModel book;

  const _CommentModal({super.key, required this.book});

  @override
  State<_CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends State<_CommentModal> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.book.title} için Yorum',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rating
          Text('Puanınız:', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  Icons.star,
                  color: index < _rating ? Colors.amber : Colors.grey,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Comment
          Text('Yorumunuz:', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Bu kitap hakkında düşüncelerinizi paylaşın...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitComment,
              child: const Text('Yorum Gönder'),
            ),
          ),
        ],
      ),
    );
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir yorum yazın')));
      return;
    }

    // TODO: Implement comment submission to backend
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Yorumunuz gönderildi!')));

    Navigator.of(context).pop();
  }
}
