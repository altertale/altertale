import 'package:flutter/material.dart';
import '../../models/book_model.dart';

/// Preview Reading Screen
/// Shows a preview of the book content before purchase
class PreviewReadingScreen extends StatefulWidget {
  final BookModel book;

  const PreviewReadingScreen({super.key, required this.book});

  @override
  State<PreviewReadingScreen> createState() => _PreviewReadingScreenState();
}

class _PreviewReadingScreenState extends State<PreviewReadingScreen> {
  int _currentPage = 0;
  late List<String> _previewPages;

  @override
  void initState() {
    super.initState();
    _initializePreview();
  }

  void _initializePreview() {
    // Generate preview content
    _previewPages = _generatePreviewContent();
  }

  List<String> _generatePreviewContent() {
    // For demo purposes, generate some preview content
    return [
      '''${widget.book.title}

Yazar: ${widget.book.author}

${widget.book.description}

Bu bir önizleme sayfasıdır. Kitabın tam içeriğini görmek için satın almanız gerekmektedir.''',

      '''Bölüm 1: Başlangıç

Bu bölümde hikayemizin temelleri atılır. Karakterlerimizle tanışır, onların dünyasına adım atarız.

[Önizleme sınırına ulaştınız]

Kitabın devamını okumak için satın alın.''',

      '''Bu kitapta:

• ${widget.book.pageCount} sayfa dolu dolu içerik
• Etkileyici karakter gelişimi
• Sürükleyici olay örgüsü
• Unutulmaz anlar

Tam deneyim için satın alın!''',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.book.title),
        backgroundColor: colorScheme.surfaceVariant,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).pop();
              // Could trigger purchase dialog here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(Icons.visibility, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Önizleme Modu',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_currentPage + 1}/${_previewPages.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: PageView.builder(
              itemCount: _previewPages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _previewPages[index],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      letterSpacing: 0.3,
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: (_currentPage + 1) / _previewPages.length,
                  backgroundColor: colorScheme.outline.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Geri Dön'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Could trigger purchase flow here
                        },
                        child: Text(
                          '₺${widget.book.price.toStringAsFixed(2)} - Satın Al',
                        ),
                      ),
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
}
