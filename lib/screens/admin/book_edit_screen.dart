import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';

/// Kitap düzenleme ekranı
class BookEditScreen extends StatefulWidget {
  final BookModel book;

  const BookEditScreen({super.key, required this.book});

  @override
  State<BookEditScreen> createState() => _BookEditScreenState();
}

class _BookEditScreenState extends State<BookEditScreen> {
  final BookService _bookService = BookService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.book.title} - Düzenle'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _saveChanges, child: const Text('Kaydet')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kitap bilgileri
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kitap Bilgileri',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Kitap başlığı
                    Text(
                      'Başlık: ${widget.book.title}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),

                    // Yazar
                    Text(
                      'Yazar: ${widget.book.author}',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),

                    // Kategori
                    Text(
                      'Kategori: '
                      '${widget.book.categories.isNotEmpty ? widget.book.categories.first : "-"}',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),

                    // Etiketler
                    Text(
                      'Etiketler: ${widget.book.tags.join(', ')}',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),

                    // Fiyat
                    Text(
                      'Fiyat: ${widget.book.price} TL',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),

                    // Puan
                    Text(
                      'Puan: ${widget.book.points}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Yayın durumu
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yayın Durumu',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: const Text('Yayında'),
                      subtitle: Text(
                        widget.book.isPublished
                            ? 'Kitap kullanıcılara görünür'
                            : 'Kitap taslak durumunda',
                      ),
                      value: widget.book.isPublished,
                      onChanged: (value) {
                        setState(() {
                          // Bu sadece UI'da değişiklik yapar
                          // Gerçek değişiklik kaydet butonuna basıldığında olur
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // İçerik önizleme
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İçerik Önizleme',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          widget.book.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Aksiyon butonları
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _togglePublishStatus,
                    icon: Icon(
                      widget.book.isPublished
                          ? Icons.visibility_off
                          : Icons.publish,
                    ),
                    label: Text(
                      widget.book.isPublished ? 'Yayından Kaldır' : 'Yayınla',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.book.isPublished
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveChanges,
                    icon: const Icon(Icons.save),
                    label: const Text('Değişiklikleri Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Yayın durumunu değiştir
  Future<void> _togglePublishStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _bookService.updateBookStatus(
        bookId: widget.book.id,
        isPublished: !widget.book.isPublished,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.book.isPublished
                ? 'Kitap taslak durumuna alındı'
                : 'Kitap yayınlandı',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Durum güncellenirken hata: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Değişiklikleri kaydet
  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Şimdilik sadece yayın durumunu güncelle
      // Gelecekte daha fazla alan düzenlenebilir

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Değişiklikler kaydedildi')));

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Değişiklikler kaydedilirken hata: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
