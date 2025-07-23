import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/book_model.dart';
import '../services/payment_service.dart';

/// Sahte ödeme dialog'u - Test modunda satın alma onayı
class FakePaymentDialog extends StatefulWidget {
  final BookModel book;
  final int? pointsCost;
  final double? tlCost;
  final int userPoints;
  final Function(PaymentResult) onPaymentComplete;

  const FakePaymentDialog({
    super.key,
    required this.book,
    this.pointsCost,
    this.tlCost,
    required this.userPoints,
    required this.onPaymentComplete,
  });

  @override
  State<FakePaymentDialog> createState() => _FakePaymentDialogState();
}

class _FakePaymentDialogState extends State<FakePaymentDialog> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  String _selectedPaymentType = 'points';

  @override
  void initState() {
    super.initState();
    // Varsayılan ödeme tipini belirle
    if (widget.pointsCost != null && widget.userPoints >= widget.pointsCost!) {
      _selectedPaymentType = 'points';
    } else if (widget.tlCost != null) {
      _selectedPaymentType = 'tl';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPayWithPoints =
        widget.pointsCost != null && widget.userPoints >= widget.pointsCost!;
    final canPayWithTL = widget.tlCost != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Kitap Satın Al',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isProcessing
                      ? null
                      : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: 'Kapat',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Kitap bilgileri
            _buildBookInfo(theme),

            const SizedBox(height: 20),

            // Ödeme seçenekleri
            if (canPayWithPoints || canPayWithTL) ...[
              Text(
                'Ödeme Yöntemi',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Puan ile ödeme seçeneği
              if (canPayWithPoints)
                _buildPaymentOption(
                  theme,
                  type: 'points',
                  icon: '⭐',
                  title: 'Puan ile Öde',
                  subtitle: '${widget.pointsCost} puan',
                  isSelected: _selectedPaymentType == 'points',
                  onTap: () => setState(() => _selectedPaymentType = 'points'),
                ),

              const SizedBox(height: 8),

              // TL ile ödeme seçeneği
              if (canPayWithTL)
                _buildPaymentOption(
                  theme,
                  type: 'tl',
                  icon: '₺',
                  title: 'TL ile Öde',
                  subtitle: '${widget.tlCost!.toStringAsFixed(2)} ₺',
                  isSelected: _selectedPaymentType == 'tl',
                  onTap: () => setState(() => _selectedPaymentType = 'tl'),
                ),

              const SizedBox(height: 20),
            ],

            // Test modu uyarısı
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Test Modu: Bu bir sahte ödeme işlemidir. Gerçek para çekilmeyecektir.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Aksiyon butonları
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('İptal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Satın Al'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Kitap bilgileri widget'ı
  Widget _buildBookInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Kitap kapağı
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 90,
              child: widget.book.coverImageUrl != null
                  ? Image.network(
                      widget.book.coverImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.book,
                            size: 30,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.book,
                        size: 30,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 16),

          // Kitap detayları
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.book.author,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (widget.book.categories.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.book.categories.first,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Ödeme seçeneği widget'ı
  Widget _buildPaymentOption(
    ThemeData theme, {
    required String type,
    required String icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(
                    fontSize: 20,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceContainerHighest,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// Ödeme işlemini gerçekleştir
  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Ekran görüntüsü alınmasını engelle (Android için)
      if (Theme.of(context).platform == TargetPlatform.android) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      }

      final result = await _paymentService.purchaseBook(
        book: widget.book,
        paymentType: _selectedPaymentType,
        pointsToDeduct: _selectedPaymentType == 'points'
            ? widget.pointsCost
            : null,
        amountTL: _selectedPaymentType == 'tl' ? widget.tlCost : null,
        paymentMetadata: {
          'dialogSource': 'fake_payment_dialog',
          'userPoints': widget.userPoints,
        },
      );

      // Ekran görüntüsü korumasını kaldır
      if (Theme.of(context).platform == TargetPlatform.android) {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onPaymentComplete(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödeme işlemi başarısız: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
