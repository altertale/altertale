import 'package:flutter/material.dart';
import '../../models/book_model.dart';

/// Kitap önizleme okuyucu - sadece belirli sayfaları gösterir
class PreviewReader extends StatelessWidget {
  final BookModel book;
  final List<String> pages; // Kitabın tüm sayfa içerikleri

  const PreviewReader({
    super.key,
    required this.book,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    final previewPages = pages.sublist(
      book.previewStart.clamp(0, pages.length),
      (book.previewEnd + 1).clamp(0, pages.length),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitap Önizleme'),
      ),
      body: ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final isPreview = index >= book.previewStart && index <= book.previewEnd;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isPreview ? Theme.of(context).cardColor : Colors.grey[200],
            child: ListTile(
              title: Text(
                isPreview ? pages[index] : 'Kilitli Sayfa',
                style: TextStyle(
                  color: isPreview ? null : Colors.grey,
                  fontStyle: isPreview ? null : FontStyle.italic,
                ),
              ),
              trailing: isPreview ? null : const Icon(Icons.lock_outline, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
} 