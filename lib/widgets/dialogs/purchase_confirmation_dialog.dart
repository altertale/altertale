import 'package:flutter/material.dart';
import '../../models/book_model.dart';

/// Purchase confirmation dialog that appears before completing a purchase
class PurchaseConfirmationDialog extends StatelessWidget {
  final BookModel book;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool usePoints;
  final int? userPoints;

  const PurchaseConfirmationDialog({
    super.key,
    required this.book,
    required this.onConfirm,
    required this.onCancel,
    this.usePoints = false,
    this.userPoints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.shopping_cart, color: colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Satın Alma Onayı'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Book cover placeholder
                Container(
                  width: 40,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.book, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        book.author,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Payment details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ödeme Detayları',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                if (usePoints) ...[
                  _buildPaymentRow(
                    'Ödeme Yöntemi:',
                    'Puan ile Satın Alma',
                    theme,
                  ),
                  _buildPaymentRow(
                    'Gerekli Puan:',
                    '${book.pointPrice} puan',
                    theme,
                  ),
                  if (userPoints != null)
                    _buildPaymentRow(
                      'Mevcut Puanınız:',
                      '$userPoints puan',
                      theme,
                    ),
                  if (userPoints != null)
                    _buildPaymentRow(
                      'Kalan Puan:',
                      '${userPoints! - book.pointPrice} puan',
                      theme,
                    ),
                ] else ...[
                  _buildPaymentRow(
                    'Ödeme Yöntemi:',
                    'Türk Lirası (Demo)',
                    theme,
                  ),
                  _buildPaymentRow('Tutar:', book.formattedPrice, theme),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Warning text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bu satın alma işlemi dijital bir üründür. Kitap hesabınıza eklenecek ve okumaya başlayabileceksiniz.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('İptal')),
        ElevatedButton(
          onPressed: onConfirm,
          child: Text(usePoints ? 'Puanla Satın Al' : 'Satın Al'),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
