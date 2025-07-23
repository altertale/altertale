import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reading_progress_model.dart';
import '../../models/book_model.dart';
import '../../services/reading_progress_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

/// Okuma geçmişi ekranı
class ReadingHistoryScreen extends StatefulWidget {
  const ReadingHistoryScreen({super.key});

  @override
  State<ReadingHistoryScreen> createState() => _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends State<ReadingHistoryScreen> {
  final ReadingProgressService _readingProgressService =
      ReadingProgressService();
  List<ReadingProgressModel> _readingHistory = [];
  Map<String, BookModel> _books = {};
  bool _isLoading = true;
  String _filterStatus =
      'all'; // 'all', 'completed', 'in_progress', 'not_started'

  @override
  void initState() {
    super.initState();
    _loadReadingHistory();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Okuma Geçmişi'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: _handleFilterChange,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive),
                    SizedBox(width: 8),
                    Text('Tümü'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Tamamlanan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'in_progress',
                child: Row(
                  children: [
                    Icon(Icons.play_circle, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Devam Eden'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'not_started',
                child: Row(
                  children: [
                    Icon(Icons.radio_button_unchecked, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Başlanmayan'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _readingHistory.isEmpty
          ? _buildEmptyState(theme)
          : _buildReadingHistoryContent(theme),
    );
  }

  /// Boş durum widget'ı
  Widget _buildEmptyState(ThemeData theme) {
    return EmptyStateWidget(
      icon: Icons.history,
      title: 'Okuma Geçmişi Boş',
      subtitle:
          'Henüz hiç kitap okumadınız.\nKitaplığınızdan bir kitap seçip okumaya başlayın.',
      actionButton: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/library'),
        icon: const Icon(Icons.library_books),
        label: const Text('Kitaplığım'),
      ),
    );
  }

  /// Okuma geçmişi içeriği
  Widget _buildReadingHistoryContent(ThemeData theme) {
    final filteredHistory = _getFilteredHistory();

    return Column(
      children: [
        // Filtre bilgisi
        if (_filterStatus != 'all')
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  _getFilterStatusText(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filterStatus = 'all';
                    });
                  },
                  child: const Text('Tümünü Göster'),
                ),
              ],
            ),
          ),

        // Geçmiş listesi
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadReadingHistory,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredHistory.length,
              itemBuilder: (context, index) {
                final progress = filteredHistory[index];
                final book = _books[progress.bookId];
                return _buildHistoryCard(theme, progress, book);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Geçmiş kartı
  Widget _buildHistoryCard(
    ThemeData theme,
    ReadingProgressModel progress,
    BookModel? book,
  ) {
    if (book == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openBook(book, progress),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Kitap kapağı
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 90,
                  child: book.coverImageUrl != null
                      ? Image.network(
                          book.coverImageUrl,
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

              // Kitap bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      book.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
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

                    // İlerleme bilgileri
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // İlerleme çubuğu
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value:
                                          progress.calculatedPercentRead / 100,
                                      backgroundColor: theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getProgressColor(progress),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    progress.formattedPercentRead,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // Sayfa bilgisi
                              Text(
                                'Sayfa ${progress.currentPage ?? 0}${progress.totalPages != null ? ' / ${progress.totalPages}' : ''}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Durum badge'i
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getProgressColor(
                              progress,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            progress.statusText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getProgressColor(progress),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Zaman bilgisi
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          progress.formattedLastOpened,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        if (progress.sessionDuration != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.timer,
                            size: 12,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            progress.formattedSessionDuration,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Aksiyon butonu
              IconButton(
                onPressed: () => _continueReading(book, progress),
                icon: Icon(
                  progress.isCompleted ? Icons.refresh : Icons.play_arrow,
                  color: theme.colorScheme.primary,
                ),
                tooltip: progress.isCompleted ? 'Tekrar Oku' : 'Devam Et',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// İlerleme rengini al
  Color _getProgressColor(ReadingProgressModel progress) {
    if (progress.isCompleted) return Colors.green;
    if (progress.isInProgress) return Colors.blue;
    return Colors.grey;
  }

  /// Filtrelenmiş geçmişi al
  List<ReadingProgressModel> _getFilteredHistory() {
    switch (_filterStatus) {
      case 'completed':
        return _readingHistory
            .where((progress) => progress.isCompleted)
            .toList();
      case 'in_progress':
        return _readingHistory
            .where((progress) => progress.isInProgress)
            .toList();
      case 'not_started':
        return _readingHistory
            .where((progress) => progress.isNotStarted)
            .toList();
      default:
        return _readingHistory;
    }
  }

  /// Filtre durumu metnini al
  String _getFilterStatusText() {
    switch (_filterStatus) {
      case 'completed':
        return 'Sadece tamamlanan kitaplar gösteriliyor';
      case 'in_progress':
        return 'Sadece devam eden kitaplar gösteriliyor';
      case 'not_started':
        return 'Sadece başlanmayan kitaplar gösteriliyor';
      default:
        return '';
    }
  }

  /// Filtre değişikliğini işle
  void _handleFilterChange(String filterStatus) {
    setState(() {
      _filterStatus = filterStatus;
    });
  }

  /// Okuma geçmişini yükle
  Future<void> _loadReadingHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.userModel;

      if (user != null) {
        final history = await _readingProgressService.getReadingHistory(
          userId: user.uid,
          limit: 50,
        );

        // Kitap detaylarını al
        Map<String, BookModel> books = {};
        for (var progress in history) {
          try {
            final bookDoc = await _readingProgressService.getBookDetails(
              progress.bookId,
            );
            if (bookDoc != null) {
              books[progress.bookId] = bookDoc;
            }
          } catch (e) {
            print('Kitap detayları alınırken hata: $e');
          }
        }

        setState(() {
          _readingHistory = history;
          _books = books;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Okuma geçmişi yüklenirken hata: $e')),
      );
    }
  }

  /// Kitabı aç
  void _openBook(BookModel book, ReadingProgressModel progress) {
    Navigator.pushNamed(context, '/book/${book.id}');
  }

  /// Okumaya devam et
  void _continueReading(BookModel book, ReadingProgressModel progress) {
    final startPage = progress.isCompleted ? 1 : (progress.currentPage ?? 1);

    // Okuma oturumunu başlat
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.userModel;

    if (user != null) {
      _readingProgressService.startReadingSession(
        userId: user.uid,
        bookId: book.id,
        startPage: startPage,
      );
    }

    // Okuma sayfasına yönlendir
    Navigator.pushNamed(context, '/read/${book.id}');
  }
}
