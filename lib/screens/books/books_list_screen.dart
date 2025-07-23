import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../../widgets/widgets.dart';

/// Books List Screen - Kitap Listesi Ekranı
///
/// Firestore'dan real-time kitap verilerini alır ve listeler.
/// GridView layout ile modern kitap kartları gösterir.
class BooksListScreen extends StatefulWidget {
  final String? category;

  const BooksListScreen({super.key, this.category});

  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
  final BookService _bookService = BookService();
  String _searchQuery = '';
  String _selectedCategory = 'Tümü';
  List<String> _categories = ['Tümü'];

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (widget.category != null) {
      _selectedCategory = widget.category!;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _bookService.getCategories();
      setState(() {
        _categories = ['Tümü', ...categories];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kategoriler yüklenemedi: $e')));
      }
    }
  }

  Stream<List<Book>> _getBooksStream() {
    if (_selectedCategory == 'Tümü') {
      return _bookService.getBooksStream();
    } else {
      return _bookService.getBooksByCategoryStream(_selectedCategory);
    }
  }

  List<Book> _filterBooks(List<Book> books) {
    if (_searchQuery.isEmpty) return books;

    final query = _searchQuery.toLowerCase();
    return books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _addSampleBooks() async {
    try {
      await _bookService.addSampleBooks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Örnek kitaplar eklendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: TitleText(
          widget.category != null
              ? '${widget.category} Kitapları'
              : 'Kitap Mağazası',
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          // Add sample books button (for testing)
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addSampleBooks,
            tooltip: 'Örnek Kitaplar Ekle',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilter(),

          // Books Grid
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: _getBooksStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                final books = snapshot.data ?? [];
                final filteredBooks = _filterBooks(books);

                if (filteredBooks.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildBooksGrid(filteredBooks);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          CustomTextField(
            hintText: 'Kitap veya yazar ara...',
            prefixIcon: Icons.search,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: SubtitleText(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: colorScheme.surface,
                    selectedColor: colorScheme.primaryContainer,
                    side: BorderSide(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksGrid(List<Book> books) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildBookCard(book);
      },
    );
  }

  Widget _buildBookCard(Book book) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RoundedCard(
      onTap: () {
        Navigator.pushNamed(context, '/book/${book.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: book.hasValidCoverImage
                    ? Image.network(
                        book.safeCoverImageUrl,
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
          ),

          // Book Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  SubtitleText(
                    book.title,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Author
                  SubtitleText(
                    book.author,
                    size: SubtitleSize.small,
                    color: colorScheme.onSurfaceVariant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Price and Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SubtitleText(
                        book.formattedPrice,
                        fontWeight: FontWeight.w600,
                        color: book.price == 0
                            ? Colors.green
                            : colorScheme.primary,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SubtitleText(
                          book.category,
                          size: SubtitleSize.caption,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
        size: 48,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
          SubtitleText('Kitaplar yükleniyor...'),
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

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const TitleText('Kitap Bulunamadı'),
            const SizedBox(height: 8),
            SubtitleText(
              _searchQuery.isNotEmpty
                  ? 'Arama kriterlerinize uygun kitap bulunamadı.'
                  : 'Bu kategoride henüz kitap bulunmuyor.',
              textAlign: TextAlign.center,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Örnek Kitaplar Ekle',
              onPressed: _addSampleBooks,
            ),
          ],
        ),
      ),
    );
  }
}
