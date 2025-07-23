import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/search/book_filter_model.dart';
import '../../models/book_model.dart';
import '../../services/search/search_service.dart';
import '../../widgets/search/search_bar_widget.dart';
import '../../widgets/search/filter_chips_widget.dart';
import '../../widgets/search/filter_modal.dart';
import '../../widgets/offline/connection_status_bar.dart';
import '../book/book_detail_screen.dart';

/// Arama ekranı
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _searchService = SearchService();

  BookFilterModel _currentFilter = const BookFilterModel();
  List<BookModel> _searchResults = [];
  bool _isLoading = false;
  bool _hasMore = false;
  DocumentSnapshot? _lastDocument;
  String? _error;

  @override
  void initState() {
    super.initState();
    _performInitialSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitap Ara'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Bağlantı durumu çubuğu
          ConnectionStatusBar(),

          // Arama çubuğu
          SearchBarWidget(
            currentFilter: _currentFilter,
            onFilterChanged: _onFilterChanged,
            onFilterTap: _showFilterModal,
          ),

          // Filtre etiketleri
          FilterChipsWidget(
            filter: _currentFilter,
            onFilterChanged: _onFilterChanged,
          ),

          // Sonuçlar
          Expanded(child: _buildResultsContent(theme)),
        ],
      ),
    );
  }

  /// Sonuçlar içeriği
  Widget _buildResultsContent(ThemeData theme) {
    if (_isLoading && _searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorWidget(theme);
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyWidget(theme);
    }

    return _buildResultsList(theme);
  }

  /// Hata widget'ı
  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Arama sırasında hata oluştu',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _performSearch,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  /// Boş durum widget'ı
  Widget _buildEmptyWidget(ThemeData theme) {
    String message;
    String subtitle;

    if (_currentFilter.hasActiveFilters) {
      message = 'Arama sonucu bulunamadı';
      subtitle = 'Filtrelerinizi değiştirmeyi deneyin';
    } else {
      message = 'Henüz kitap yok';
      subtitle = 'Yakında yeni kitaplar eklenecek';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (_currentFilter.hasActiveFilters) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearFilters,
              child: const Text('Filtreleri Temizle'),
            ),
          ],
        ],
      ),
    );
  }

  /// Sonuçlar listesi
  Widget _buildResultsList(ThemeData theme) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (_hasMore && !_isLoading) {
            _loadMoreResults();
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _searchResults.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _searchResults.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final book = _searchResults[index];
          return _buildBookCard(theme, book);
        },
      ),
    );
  }

  /// Kitap kartı
  Widget _buildBookCard(ThemeData theme, BookModel book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToBookDetail(book),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kapak resmi
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: book.coverImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          book.coverImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.book,
                              color: theme.colorScheme.onSurfaceVariant,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.book,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
              ),

              const SizedBox(width: 16),

              // Kitap bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      book.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Yazar
                    Text(
                      book.author,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Fiyat ve puan
                    Row(
                      children: [
                        if (book.price > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '₺${book.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        if (book.price > 0 && book.points > 0)
                          const SizedBox(width: 8),

                        if (book.points > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.stars,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${book.points}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Kategoriler
                    if (book.categories.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: book.categories.take(3).map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// İlk aramayı gerçekleştir
  void _performInitialSearch() {
    _performSearch();
  }

  /// Arama gerçekleştir
  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _lastDocument = null;
    });

    try {
      // Filtreleri sanitize et
      final sanitizedFilter = _searchService.sanitizeFilter(_currentFilter);

      // Arama yap
      await _searchService.searchBooks(sanitizedFilter);

      // Sonuçları dinle
      _searchService.searchResults.listen((results) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
          _hasMore = results.length == sanitizedFilter.limit;
        });
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Daha fazla sonuç yükle
  Future<void> _loadMoreResults() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextFilter = _currentFilter.withLastDocument(_lastDocument);
      final results = await _searchService.searchBooks(nextFilter);

      setState(() {
        _searchResults.addAll(results.data);
        _lastDocument = results.lastDocument;
        _hasMore = results.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Filtre değişikliği
  void _onFilterChanged(BookFilterModel newFilter) {
    setState(() {
      _currentFilter = newFilter;
    });
    _performSearch();
  }

  /// Filtre modal'ını göster
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        currentFilter: _currentFilter,
        onFilterChanged: _onFilterChanged,
      ),
    );
  }

  /// Filtreleri temizle
  void _clearFilters() {
    setState(() {
      _currentFilter = const BookFilterModel();
    });
    _performSearch();
  }

  /// Kitap detayına git
  void _navigateToBookDetail(BookModel book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
    );
  }
}
