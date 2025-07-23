import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/book_model.dart';
import '../../constants/app_colors.dart';
import '../../services/favorites_service.dart';
import '../../services/cart_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/book.dart';
import '../../providers/book_provider.dart';

/// Kitap kartı widget'ı - kitap bilgilerini kart formatında gösterir
class BookCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
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
                        book.title,
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
                        book.author,
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
                      book.formattedPrice,
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
                    if (isPurchased) ...[
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
              imageUrl: book.coverImageUrl,
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

        final isFavorite = favoritesProvider.isFavorite(book.id);

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
                final wasToggled = await favoritesProvider.toggleFavorite(
                  authProvider.userId,
                  book,
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
      book.title,
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
      book.author,
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
        if (showRating) ...[
          Icon(Icons.star, size: 14, color: Colors.amber[600]),
          const SizedBox(width: 2),
          Text(
            book.formattedRating,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (showReadCount) ...[
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
        if (showReadCount) ...[
          Icon(
            Icons.visibility,
            size: 12,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
          ),
          const SizedBox(width: 2),
          Text(
            book.formattedReadCount,
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

    if (book.price == 0) {
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
      book.formattedPrice,
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

    if (isPurchased) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onReadTap,
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

    if (book.price == 0) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onReadTap,
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
        onPressed: onBuyTap,
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
📚 ${book.title}
✍️ Yazar: ${book.author}
💰 Fiyat: ${book.formattedPrice}
⭐ Değerlendirme: ${book.averageRating.toStringAsFixed(1)}/5.0 (${book.ratingCount} değerlendirme)
📖 ${book.pageCount} sayfa
🏷️ Kategori: ${book.categories.isNotEmpty ? book.categories.first : 'Genel'}

${book.description.length > 100 ? book.description.substring(0, 100) + '...' : book.description}

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
                Share.share(shareText, subject: book.title);
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
📚 *${book.title}*
✍️ ${book.author}
⭐ ${book.averageRating.toStringAsFixed(1)}/5.0
💰 ${book.formattedPrice}

${book.description.length > 80 ? book.description.substring(0, 80) + '...' : book.description}

📱 Altertale uygulamasında oku!
''';
                Share.share(whatsappText, subject: book.title);
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
📚 ${book.title} - ${book.author}
⭐ ${book.averageRating.toStringAsFixed(1)}/5.0
💰 ${book.formattedPrice}

${book.description.length > 120 ? book.description.substring(0, 120) + '...' : book.description}

#Altertale #Kitap #Okuma #${book.author.replaceAll(' ', '')}
📱 Altertale'de keşfet!
''';
                Share.share(socialText, subject: book.title);
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
                    '''${book.title} - ${book.author}
⭐ ${book.averageRating.toStringAsFixed(1)}/5.0 | 💰 ${book.formattedPrice}
📱 Altertale uygulamasında oku!''';

                // Copy to clipboard (would need clipboard package)
                Share.share(copyText, subject: book.title);

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

  /// Comment button widget'ı (sadece satın alınan kitaplar için)
  Widget _buildCommentButton(BuildContext context) {
    return SizedBox(
      height: 24,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _openCommentModal(context),
        icon: const Icon(Icons.comment, size: 12),
        label: const Text('Yorum Yap', style: TextStyle(fontSize: 10)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          minimumSize: const Size(0, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        child: _CommentModal(book: book),
      ),
    );
  }

  /// Cart button widget'ı
  Widget _buildCartButton(BuildContext context) {
    return Consumer2<AuthProvider, CartProvider>(
      builder: (context, authProvider, cartProvider, child) {
        if (!authProvider.isLoggedIn) {
          return SizedBox(
            height: 24,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              icon: const Icon(Icons.login, size: 12),
              label: const Text('Giriş Yap', style: TextStyle(fontSize: 10)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: const Size(0, 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        }

        // Initialize cart if needed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cartProvider.initializeCart(authProvider.userId);
        });

        final isInCart = cartProvider.isBookInCart(book.id);
        final hasError =
            cartProvider.error != null &&
            cartProvider.error!.contains('zaten sepette');
        final theme = Theme.of(context);

        return SizedBox(
          height: 24,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: cartProvider.isLoading
                ? null
                : () => _addToCartWithProvider(
                    context,
                    authProvider.userId,
                    cartProvider,
                  ),
            icon: Icon(
              isInCart ? Icons.check_circle : Icons.shopping_cart,
              size: 12,
            ),
            label: Text(
              isInCart ? 'Sepete Eklendi' : 'Sepete Ekle',
              style: const TextStyle(fontSize: 10),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasError
                  ? Colors.orange
                  : isInCart
                  ? Colors.green
                  : theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              minimumSize: const Size(0, 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Add book to cart using CartProvider
  Future<void> _addToCartWithProvider(
    BuildContext context,
    String userId,
    CartProvider cartProvider,
  ) async {
    final bookForCart = Book(
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

    final success = await cartProvider.addToCart(userId, bookForCart);

    if (context.mounted) {
      if (success) {
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
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Sepete Git',
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
          ),
        );

        // Clear error after successful add
        Future.delayed(const Duration(seconds: 1), () {
          cartProvider.clearError();
        });
      } else {
        final isAlreadyInCart =
            cartProvider.error?.contains('zaten sepette') ?? false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isAlreadyInCart ? Icons.info : Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAlreadyInCart
                        ? 'Bu kitap zaten sepette!'
                        : 'Sepete eklenirken hata oluştu',
                  ),
                ),
              ],
            ),
            backgroundColor: isAlreadyInCart ? Colors.orange : Colors.red,
            action: isAlreadyInCart
                ? SnackBarAction(
                    label: 'Sepete Git',
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                  )
                : null,
          ),
        );

        // Clear error after showing message
        Future.delayed(const Duration(seconds: 2), () {
          cartProvider.clearError();
        });
      }
    }
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
