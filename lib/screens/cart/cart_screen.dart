import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_item.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';

/// Cart Screen - Sepet Ekranı
///
/// Kullanıcının sepetindeki kitapları görüntüler, adet yönetimi yapar
/// ve satın alma işlemi başlatır.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const TitleText('Sepetim'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (!authProvider.isLoggedIn) return const SizedBox.shrink();

              return StreamBuilder<List<CartItem>>(
                stream: _cartService.getCartItemsStream(authProvider.userId),
                builder: (context, snapshot) {
                  final cartItems = snapshot.data ?? [];
                  if (cartItems.isEmpty) return const SizedBox.shrink();

                  return PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.clear_all),
                            SizedBox(width: 8),
                            Text('Sepeti Temizle'),
                          ],
                        ),
                        onTap: () => _clearCart(authProvider.userId),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isLoggedIn) {
            return _buildLoginPrompt();
          }

          return StreamBuilder<List<CartItem>>(
            stream: _cartService.getCartItemsStream(authProvider.userId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }

              final cartItems = snapshot.data ?? [];

              if (cartItems.isEmpty) {
                return _buildEmptyCartState();
              }

              return _buildCartContent(cartItems, authProvider.userId);
            },
          );
        },
      ),
    );
  }

  Widget _buildCartContent(List<CartItem> cartItems, String userId) {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              return _buildCartItemCard(cartItem);
            },
          ),
        ),

        // Cart Summary and Checkout
        _buildCartSummary(cartItems, userId),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem cartItem) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RoundedCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: cartItem.hasValidImage
                    ? Image.network(
                        cartItem.safeImageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildImagePlaceholder();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      )
                    : _buildImagePlaceholder(),
              ),
            ),

            const SizedBox(width: 12),

            // Book Info and Controls
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Author
                  SubtitleText(
                    cartItem.title,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  SubtitleText(
                    cartItem.author,
                    size: SubtitleSize.small,
                    color: colorScheme.onSurfaceVariant,
                  ),

                  const SizedBox(height: 8),

                  // Price
                  SubtitleText(
                    cartItem.formattedUnitPrice,
                    fontWeight: FontWeight.w600,
                    color: cartItem.isFree ? Colors.green : colorScheme.primary,
                  ),

                  const SizedBox(height: 12),

                  // Digital Book Info - No quantity controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Fixed quantity display for digital books
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_stories,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                const SubtitleText(
                                  'Dijital Kitap',
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Remove Button
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: colorScheme.error,
                        ),
                        onPressed: () => _removeFromCart(cartItem),
                        tooltip: 'Sepetten Çıkar',
                      ),
                    ],
                  ),

                  // Total Price for this item
                  if (cartItem.quantity > 1) ...[
                    const SizedBox(height: 8),
                    SubtitleText(
                      'Toplam: ${cartItem.formattedTotalPrice}',
                      size: SubtitleSize.small,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool enabled,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: enabled
          ? colorScheme.surfaceContainer
          : colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: enabled ? onPressed : null,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colorScheme.surfaceContainer,
      child: Icon(
        Icons.auto_stories,
        size: 32,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildCartSummary(List<CartItem> cartItems, String userId) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalItems = cartItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final totalPrice = cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
    final formattedTotal = totalPrice == 0
        ? 'Ücretsiz'
        : '${totalPrice.toStringAsFixed(2)} ₺';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Summary Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SubtitleText(
                      '$totalItems ürün',
                      size: SubtitleSize.small,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    TitleText(
                      'Toplam: $formattedTotal',
                      size: TitleSize.medium,
                      color: totalPrice == 0
                          ? Colors.green
                          : colorScheme.primary,
                    ),
                  ],
                ),

                // Checkout Button
                SizedBox(
                  width: 140,
                  child: CustomButton(
                    text: 'Ödemeye Geç',
                    onPressed: _isLoading ? null : () => _checkout(userId),
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const TitleText('Sepetinizi Görüntüleyin', size: TitleSize.medium),
            const SizedBox(height: 8),
            SubtitleText(
              'Sepetinizi görüntülemek için giriş yapmanız gerekiyor.',
              textAlign: TextAlign.center,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Giriş Yap',
              onPressed: () => Navigator.of(context).pushNamed('/login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCartState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const TitleText('Sepetiniz Boş', size: TitleSize.medium),
            const SizedBox(height: 8),
            SubtitleText(
              'Henüz sepetinizde ürün bulunmuyor. Kitaplara göz atarak sepetinizi doldurun!',
              textAlign: TextAlign.center,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Kitaplara Gözat',
              onPressed: () => Navigator.of(context).pushNamed('/books'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          SubtitleText('Sepetiniz yükleniyor...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            TitleText('Sepet Yüklenemedi', color: colorScheme.error),
            const SizedBox(height: 8),
            SubtitleText(
              'Sepetiniz yüklenirken bir hata oluştu. Lütfen tekrar deneyin.',
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
    );
  }

  // Action Methods
  Future<void> _updateQuantity(CartItem cartItem, int newQuantity) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _cartService.updateCartItemQuantity(cartItem.id, newQuantity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newQuantity == 0
                  ? '${cartItem.title} sepetten çıkarıldı'
                  : '${cartItem.title} adedi güncellendi: $newQuantity',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
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

  Future<void> _removeFromCart(CartItem cartItem) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sepetten Çıkar'),
        content: Text(
          '${cartItem.title} kitabını sepetinizden çıkarmak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Çıkar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await _cartService.removeFromCart(cartItem.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cartItem.title} sepetten çıkarıldı'),
            backgroundColor: Colors.green,
          ),
        );
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

  Future<void> _clearCart(String userId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sepeti Temizle'),
        content: const Text(
          'Sepetinizdeki tüm kitapları çıkarmak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await _cartService.clearCart(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sepetiniz temizlendi'),
            backgroundColor: Colors.green,
          ),
        );
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

  Future<void> _checkout(String userId) async {
    // Prevent double-tap
    if (_isLoading) return;

    // Navigate to checkout screen
    Navigator.of(context).pushNamed('/checkout');
  }
}
