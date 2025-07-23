import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/order.dart' as OrderModel;
import '../../models/order_item.dart';
import '../../services/order_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';

/// Order Screen - Sipariş Geçmişi Ekranı
///
/// Kullanıcının sipariş geçmişini görüntüler ve sipariş detaylarını gösterir.
class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const TitleText('Sipariş Geçmişim'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isLoggedIn) {
            return _buildLoginPrompt();
          }

          return StreamBuilder<List<OrderModel.Order>>(
            stream: _orderService.getOrdersForUserStream(authProvider.userId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }

              final orders = snapshot.data ?? [];

              if (orders.isEmpty) {
                return _buildEmptyOrdersState();
              }

              return _buildOrdersList(orders);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel.Order> orders) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOrderCard(order),
        );
      },
    );
  }

  Widget _buildOrderCard(OrderModel.Order order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleText(order.orderNumber, size: TitleSize.medium),
                  const SizedBox(height: 4),
                  SubtitleText(
                    order.detailedOrderDate,
                    size: SubtitleSize.small,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SubtitleText(
                  order.status.displayName,
                  size: SubtitleSize.small,
                  color: order.statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Order Items Preview
          _buildOrderItemsPreview(order),

          const SizedBox(height: 16),

          // Order Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubtitleText(
                    '${order.totalItems} ürün',
                    size: SubtitleSize.small,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  TitleText(
                    order.formattedTotalAmount,
                    size: TitleSize.medium,
                    color: colorScheme.primary,
                  ),
                ],
              ),

              // Action Button
              CustomButton(
                text: 'Detayları Gör',
                isPrimary: false,
                onPressed: () => _showOrderDetails(order),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsPreview(OrderModel.Order order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (order.items.isEmpty) {
      return const SubtitleText('Ürün bulunmuyor');
    }

    // Show first 2 items
    final previewItems = order.items.take(2).toList();
    final remainingCount = order.items.length - previewItems.length;

    return Column(
      children: [
        ...previewItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildOrderItemPreview(item),
          ),
        ),

        if (remainingCount > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SubtitleText(
              '+ $remainingCount diğer kitap',
              textAlign: TextAlign.center,
              size: SubtitleSize.small,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildOrderItemPreview(OrderItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // Book Cover Thumbnail
        Container(
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: item.hasValidImage
                ? Image.network(
                    item.safeImageUrl,
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

        // Book Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubtitleText(
                item.title,
                fontWeight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  SubtitleText(
                    item.author,
                    size: SubtitleSize.small,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SubtitleText(' • ', size: SubtitleSize.small),
                  SubtitleText(
                    'x${item.quantity}',
                    size: SubtitleSize.small,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Price
        SubtitleText(
          item.formattedTotalPrice,
          fontWeight: FontWeight.w600,
          color: item.isFree ? Colors.green : colorScheme.primary,
        ),
      ],
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
        size: 16,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
              Icons.receipt_long_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const TitleText(
              'Sipariş Geçmişinizi Görüntüleyin',
              size: TitleSize.medium,
            ),
            const SizedBox(height: 8),
            SubtitleText(
              'Sipariş geçmişinizi görüntülemek için giriş yapmanız gerekiyor.',
              textAlign: TextAlign.center,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Giriş Yap',
              onPressed: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const TitleText('Henüz Siparişiniz Yok', size: TitleSize.medium),
            const SizedBox(height: 8),
            SubtitleText(
              'Henüz hiç siparişiniz bulunmamaktadır. İlk siparişinizi vermek için kitaplara göz atın!',
              textAlign: TextAlign.center,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Kitaplara Gözat',
              onPressed: () => context.go('/books'),
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
          SubtitleText('Siparişleriniz yükleniyor...'),
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
            TitleText('Hata Oluştu', color: colorScheme.error),
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
    );
  }

  void _showOrderDetails(OrderModel.Order order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TitleText('Sipariş Detayı', size: TitleSize.medium),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Order Details Content
            Expanded(child: _buildOrderDetailsContent(order)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsContent(OrderModel.Order order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Info
          _buildOrderInfoSection(order),

          const SizedBox(height: 24),

          // Order Items
          _buildOrderItemsSection(order),

          const SizedBox(height: 24),

          // Order Summary
          _buildOrderSummarySection(order),

          if (order.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 24),
            _buildOrderNotesSection(order),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderInfoSection(OrderModel.Order order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleText('Sipariş Bilgileri', size: TitleSize.medium),
        const SizedBox(height: 12),

        _buildDetailRow('Sipariş No', order.orderNumber),
        _buildDetailRow('Tarih', order.formattedOrderDateTime),
        _buildDetailRow(
          'Durum',
          order.status.displayName,
          valueColor: order.statusColor,
        ),
        _buildDetailRow('Toplam Ürün', '${order.totalItems} adet'),
      ],
    );
  }

  Widget _buildOrderItemsSection(OrderModel.Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleText('Sipariş Ürünleri', size: TitleSize.medium),
        const SizedBox(height: 12),

        ...order.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDetailOrderItem(item),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailOrderItem(OrderItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RoundedCard(
      backgroundColor: colorScheme.surfaceContainer.withValues(alpha: 0.3),
      child: Row(
        children: [
          // Book Cover
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.hasValidImage
                  ? Image.network(
                      item.safeImageUrl,
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

          // Book Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SubtitleText(
                  item.title,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                SubtitleText(
                  item.author,
                  size: SubtitleSize.small,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SubtitleText(
                      '${item.formattedUnitPrice} x ${item.quantity}',
                      size: SubtitleSize.small,
                    ),
                    SubtitleText(
                      item.formattedTotalPrice,
                      fontWeight: FontWeight.w600,
                      color: item.isFree ? Colors.green : colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection(OrderModel.Order order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RoundedCard(
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('Sipariş Özeti', size: TitleSize.medium),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SubtitleText('Toplam Ürün:'),
              SubtitleText('${order.totalItems} adet'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SubtitleText('Farklı Kitap:'),
              SubtitleText('${order.uniqueItemsCount} kitap'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TitleText('Toplam Tutar:', size: TitleSize.medium),
              TitleText(
                order.formattedTotalAmount,
                size: TitleSize.medium,
                color: order.totalAmount == 0
                    ? Colors.green
                    : colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderNotesSection(OrderModel.Order order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleText('Sipariş Notları', size: TitleSize.medium),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SubtitleText(order.notes!, size: SubtitleSize.medium),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: SubtitleText(
              label,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(child: SubtitleText(value, color: valueColor)),
        ],
      ),
    );
  }
}
