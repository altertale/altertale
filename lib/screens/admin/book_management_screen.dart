import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import 'book_upload_form.dart';
import 'book_edit_screen.dart';

/// Kitap yönetimi ekranı
class BookManagementScreen extends StatefulWidget {
  const BookManagementScreen({super.key});

  @override
  State<BookManagementScreen> createState() => _BookManagementScreenState();
}

class _BookManagementScreenState extends State<BookManagementScreen> {
  final BookService _bookService = BookService();
  List<BookModel> _books = [];
  bool _isLoading = true;
  String _filterStatus = 'all'; // 'all', 'published', 'draft'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve aksiyonlar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kitap Yönetimi',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_books.length} kitap bulundu',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addNewBook,
                icon: const Icon(Icons.add),
                label: const Text('Yeni Kitap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Filtreler ve arama
          Row(
            children: [
              // Durum filtresi
              DropdownButton<String>(
                value: _filterStatus,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tümü')),
                  DropdownMenuItem(value: 'published', child: Text('Yayında')),
                  DropdownMenuItem(value: 'draft', child: Text('Taslak')),
                ],
                onChanged: (value) {
                  setState(() {
                    _filterStatus = value!;
                  });
                  _loadBooks();
                },
              ),

              const SizedBox(width: 16),

              // Arama
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Kitap Ara',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _loadBooks();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Kitap listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _books.isEmpty
                ? _buildEmptyState(theme)
                : _buildBookList(theme),
          ),
        ],
      ),
    );
  }

  /// Boş durum widget'ı
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz kitap yok',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk kitabınızı ekleyerek başlayın',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addNewBook,
            icon: const Icon(Icons.add),
            label: const Text('Kitap Ekle'),
          ),
        ],
      ),
    );
  }

  /// Kitap listesi
  Widget _buildBookList(ThemeData theme) {
    return ListView.builder(
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: book.coverImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      book.coverImageUrl,
                      width: 60,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.book, color: Colors.grey),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.book, color: Colors.grey),
                  ),
            title: Text(
              book.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.author, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Durum badge'i
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: book.isPublished
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: book.isPublished
                              ? Colors.green
                              : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        book.isPublished ? 'Yayında' : 'Taslak',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: book.isPublished
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Fiyat bilgisi
                    Text(
                      '${book.price} TL',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (book.points > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${book.points} puan',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (action) => _handleBookAction(action, book),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Düzenle'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle_status',
                  child: Row(
                    children: [
                      Icon(
                        book.isPublished ? Icons.visibility_off : Icons.publish,
                        color: book.isPublished ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(book.isPublished ? 'Yayından Kaldır' : 'Yayınla'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Sil'),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _editBook(book),
          ),
        );
      },
    );
  }

  /// Kitapları yükle
  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final books = await _bookService.getAllBooks();

      // Filtreleme
      var filteredBooks = books;

      if (_filterStatus != 'all') {
        filteredBooks = books.where((book) {
          if (_filterStatus == 'published') return book.isPublished;
          if (_filterStatus == 'draft') return !book.isPublished;
          return true;
        }).toList();
      }

      // Arama
      if (_searchQuery.isNotEmpty) {
        filteredBooks = filteredBooks.where((book) {
          return book.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              book.author.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }

      setState(() {
        _books = filteredBooks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kitaplar yüklenirken hata: $e')));
    }
  }

  /// Yeni kitap ekle
  void _addNewBook() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const BookUploadForm()))
        .then((_) => _loadBooks());
  }

  /// Kitap düzenle
  void _editBook(BookModel book) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => BookEditScreen(book: book)),
        )
        .then((_) => _loadBooks());
  }

  /// Kitap aksiyonlarını işle
  Future<void> _handleBookAction(String action, BookModel book) async {
    switch (action) {
      case 'edit':
        _editBook(book);
        break;
      case 'toggle_status':
        await _toggleBookStatus(book);
        break;
      case 'delete':
        await _deleteBook(book);
        break;
    }
  }

  /// Kitap durumunu değiştir
  Future<void> _toggleBookStatus(BookModel book) async {
    try {
      await _bookService.updateBookStatus(
        bookId: book.id,
        isPublished: !book.isPublished,
      );

      await _loadBooks();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            book.isPublished
                ? 'Kitap taslak durumuna alındı'
                : 'Kitap yayınlandı',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Durum güncellenirken hata: $e')));
    }
  }

  /// Kitabı sil
  Future<void> _deleteBook(BookModel book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kitabı Sil'),
        content: Text(
          '"${book.title}" kitabını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _bookService.deleteBook(book.id);
        await _loadBooks();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kitap silindi')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kitap silinirken hata: $e')));
      }
    }
  }
}
