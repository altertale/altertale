import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../models/order.dart';
import '../../widgets/widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Siparişlerim')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 64),
              SizedBox(height: 16),
              TitleText('Giriş Yapınız'),
              SubtitleText('Siparişlerinizi görmek için giriş yapmalısınız'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const TitleText('Siparişlerim', size: TitleSize.large),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: StreamBuilder<List<Order>>(
        stream: _orderService.getOrdersForUserStream(authProvider.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(theme, '${snapshot.error}');
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return _buildEmptyState(theme);
          }

          return _buildOrdersList(theme, orders);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/cart'),
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }

  Widget _buildOrdersList(ThemeData theme, List<Order> orders) {
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(theme, order);
        },
      ),
    );
  }

  Widget _buildOrderCard(ThemeData theme, Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleText(order.orderNumber, size: TitleSize.medium),
                    const SizedBox(height: 4),
                    SubtitleText(
                      order.formattedOrderDate,
                      size: SubtitleSize.small,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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

            // Order summary
            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 16),
                const SizedBox(width: 8),
                SubtitleText('${order.totalItemsCount} ürün'),
                const Spacer(),
                TitleText(
                  order.formattedFinalTotal,
                  size: TitleSize.small,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Detayları Gör',
                    onPressed: () => _showOrderDetails(order),
                    type: ButtonType.secondary,
                  ),
                ),
                if (order.canBeCancelled) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'İptal Et',
                      onPressed: () => _cancelOrder(order),
                      type: ButtonType.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const TitleText('Henüz Siparişiniz Yok', size: TitleSize.medium),
            const SizedBox(height: 8),
            SubtitleText(
              'Henüz hiç siparişiniz bulunmamaktadır.\nİlk siparişinizi vermek için alışverişe başlayın!',
              textAlign: TextAlign.center,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Alışverişe Başla',
              onPressed: () => Navigator.of(context).pushNamed('/home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            TitleText('Hata Oluştu', color: theme.colorScheme.error),
            const SizedBox(height: 8),
            SubtitleText(
              'Siparişler yüklenirken bir hata oluştu:\n$error',
              textAlign: TextAlign.center,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            CustomButton(text: 'Tekrar Dene', onPressed: () => setState(() {})),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TitleText('Sipariş Detayları - ${order.orderNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Tarih', order.detailedOrderDate),
              _buildDetailRow('Durum', order.status.displayName),
              _buildDetailRow('Ödeme', order.paymentStatus.displayName),
              _buildDetailRow('Ürün Sayısı', '${order.totalItemsCount} adet'),
              _buildDetailRow('Toplam', order.formattedFinalTotal),
              if (order.notes?.isNotEmpty == true)
                _buildDetailRow('Notlar', order.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: SubtitleText(label, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(child: SubtitleText(value)),
        ],
      ),
    );
  }

  void _cancelOrder(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TitleText('Siparişi İptal Et'),
        content: SubtitleText(
          'Bu siparişi iptal etmek istediğinizden emin misiniz?\n\n${order.orderNumber}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hayır'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                await _orderService.cancelOrder(order.id, 'Kullanıcı talebi');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sipariş başarıyla iptal edildi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('İptal işlemi başarısız: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Evet, İptal Et',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
