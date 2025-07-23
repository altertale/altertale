import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../widgets/books/preview_reader.dart';

/// Preview Reading Screen
/// Allows users to preview a book before purchasing
class PreviewReadingScreen extends StatelessWidget {
  final Book book;

  const PreviewReadingScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${book.title} - Önizleme'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Add to cart from preview
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${book.title} sepete eklendi'),
                  action: SnackBarAction(
                    label: 'Sepete Git',
                    onPressed: () {
                      Navigator.of(context).pushNamed('/cart');
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview Info
          Container(
            width: double.infinity,
            color: theme.colorScheme.primaryContainer,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.preview,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bu kitabın önizlemesini okuyorsunuz. Tam sürümü için satın alın.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Preview Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Önizleme İçeriği',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(book.description, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Devamını okumak için kitabı satın alın...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Purchase Prompt
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Devamını okumak için kitabı satın alın',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${book.price.toStringAsFixed(2)} ₺',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(
                        context,
                      ).pushNamed('/book-detail', arguments: book.id);
                    },
                    child: const Text('Satın Al'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generatePreviewPages(Book book) {
    // Generate sample preview pages based on book description
    final previewText = book.description;
    final words = previewText.split(' ');
    final pages = <String>[];

    // Create pages with approximately 100 words each
    for (int i = 0; i < words.length; i += 100) {
      final endIndex = (i + 100).clamp(0, words.length);
      final pageText = words.sublist(i, endIndex).join(' ');
      pages.add(pageText);

      // Limit to preview pages only
      if (pages.length >= 5) {
        // Default preview limit
        break;
      }
    }

    // Add some locked pages to show the preview limitation
    pages.addAll(List.generate(5, (index) => 'Kilitli Sayfa ${index + 1}'));

    return pages;
  }
}
