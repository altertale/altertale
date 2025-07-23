import 'package:flutter/material.dart';
import '../models/book_model.dart';

/// Purchase Confirmation Dialog
/// Shows confirmation dialog before purchasing a book
class PurchaseConfirmationDialog extends StatelessWidget {
  final BookModel book;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const PurchaseConfirmationDialog({
    super.key,
    required this.book,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
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
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Book cover placeholder
                Container(
                  width: 50,
                  height: 70,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.book, color: colorScheme.outline),
                ),
                const SizedBox(width: 12),
                // Book details
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
                      const SizedBox(height: 4),
                      Text(
                        '₺${book.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Confirmation message
          Text(
            'Bu kitabı satın almak istediğinizden emin misiniz?',
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 8),

          // Purchase info
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Satın aldığınız kitap kütüphanenize eklenecek ve istediğiniz zaman okuyabileceksiniz.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: const Text('İptal'),
        ),

        // Confirm button
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.payment, size: 18),
              const SizedBox(width: 6),
              Text('₺${book.price.toStringAsFixed(2)} Öde'),
            ],
          ),
        ),
      ],
    );
  }

  /// Show the dialog
  static Future<bool?> show(
    BuildContext context, {
    required BookModel book,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => PurchaseConfirmationDialog(
        book: book,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}
