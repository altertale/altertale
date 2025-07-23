import 'package:flutter/material.dart';
import '../../models/profile/user_books_model.dart';
import '../../services/profile/profile_service.dart';

/// Kullanıcı kitapları widget'ı
class UserBooksWidget extends StatefulWidget {
  final String userId;
  final VoidCallback? onRefresh;

  const UserBooksWidget({
    super.key,
    required this.userId,
    this.onRefresh,
  });

  @override
  State<UserBooksWidget> createState() => _UserBooksWidgetState();
}

class _UserBooksWidgetState extends State<UserBooksWidget>
    with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  
  late TabController _tabController;
  List<UserBook> _allBooks = [];
  List<UserBook> _favoriteBooks = [];
  List<UserBook> _completedBooks = [];
  List<UserBook> _readingBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBooks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Tab bar
        Container(
          color: theme.colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            tabs: const [
              Tab(text: 'Tümü'),
              Tab(text: 'Okunuyor'),
              Tab(text: 'Favoriler'),
              Tab(text: 'Tamamlanan'),
            ],
          ),
        ),
        
        // Tab içerikleri
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBooksList(_allBooks, 'Tüm Kitaplar'),
              _buildBooksList(_readingBooks, 'Okunan Kitaplar'),
              _buildBooksList(_favoriteBooks, 'Favori Kitaplar'),
              _buildBooksList(_completedBooks, 'Tamamlanan Kitaplar'),
            ],
          ),
        ),
      ],
    );
  }

  /// Kitaplar listesi oluştur
  Widget _buildBooksList(List<UserBook> books, String title) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: books.isEmpty
          ? _buildEmptyState(title)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return _BookCard(
                  book: book,
                  onTap: () => _showBookDetails(book),
                  onFavoriteToggle: () => _toggleFavorite(book),
                );
              },
            ),
    );
  }

  /// Boş durum widget'ı
  Widget _buildEmptyState(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz kitap yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$title listesi boş',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Kitapları yükle
  Future<void> _loadBooks() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Tüm kitapları al
      await for (final books in _profileService.getUserBooks(widget.userId)) {
        setState(() {
          _allBooks = books;
          _readingBooks = books.where((b) => b.isReading).toList();
          _favoriteBooks = books.where((b) => b.isFavorite).toList();
          _completedBooks = books.where((b) => b.isCompleted).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Verileri yenile
  Future<void> _refreshData() async {
    await _loadBooks();
    widget.onRefresh?.call();
  }

  /// Kitap detaylarını göster
  void _showBookDetails(UserBook book) {
    showDialog(
      context: context,
      builder: (context) => _BookDetailsDialog(book: book),
    );
  }

  /// Favori durumunu değiştir
  Future<void> _toggleFavorite(UserBook book) async {
    try {
      final updatedBook = book.copyWith(isFavorite: !book.isFavorite);
      await _profileService.saveUserBook(updatedBook);
      
      // Listeleri güncelle
      setState(() {
        final index = _allBooks.indexWhere((b) => b.id == book.id);
        if (index != -1) {
          _allBooks[index] = updatedBook;
        }
        
        if (updatedBook.isFavorite) {
          _favoriteBooks.add(updatedBook);
        } else {
          _favoriteBooks.removeWhere((b) => b.id == book.id);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Favori durumu güncellenirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Kitap kartı widget'ı
class _BookCard extends StatelessWidget {
  final UserBook book;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const _BookCard({
    required this.book,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Kitap kapağı
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: book.bookCoverUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          book.bookCoverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.book,
                              color: theme.colorScheme.primary,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.book,
                        color: theme.colorScheme.primary,
                      ),
              ),
              
              const SizedBox(width: 16),
              
              // Kitap bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.bookTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.bookAuthor,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Durum ve ilerleme
                    Row(
                      children: [
                        _buildStatusChip(theme),
                        const SizedBox(width: 8),
                        if (book.totalPages > 0)
                          Text(
                            '${book.currentPage}/${book.totalPages}',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // İlerleme çubuğu
                    if (book.totalPages > 0)
                      LinearProgressIndicator(
                        value: book.readingProgress / 100,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Alt bilgiler
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${book.readingTimeInHours.toStringAsFixed(1)} saat',
                          style: theme.textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(book.lastReadDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Favori butonu
              IconButton(
                onPressed: onFavoriteToggle,
                icon: Icon(
                  book.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: book.isFavorite ? Colors.red : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Durum chip'i oluştur
  Widget _buildStatusChip(ThemeData theme) {
    Color color;
    String text;

    switch (book.status) {
      case BookStatus.reading:
        color = Colors.blue;
        text = 'Okunuyor';
        break;
      case BookStatus.completed:
        color = Colors.green;
        text = 'Tamamlandı';
        break;
      case BookStatus.paused:
        color = Colors.orange;
        text = 'Duraklatıldı';
        break;
      case BookStatus.abandoned:
        color = Colors.red;
        text = 'Bırakıldı';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Tarih formatla
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Kitap detayları dialog'u
class _BookDetailsDialog extends StatelessWidget {
  final UserBook book;

  const _BookDetailsDialog({
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Expanded(
                  child: Text(
                    book.bookTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Kitap kapağı ve temel bilgiler
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: book.bookCoverUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            book.bookCoverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.book,
                                color: theme.colorScheme.primary,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.book,
                          color: theme.colorScheme.primary,
                        ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yazar: ${book.bookAuthor}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Satın Alma: ${book.purchaseType.displayName}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (book.pointsSpent != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Harcanan Puan: ${book.pointsSpent}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Satın Alma Tarihi: ${_formatDate(book.purchaseDate)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Detaylı istatistikler
            _buildDetailRow('Durum', book.status.displayName),
            if (book.totalPages > 0) ...[
              _buildDetailRow('Sayfa', '${book.currentPage}/${book.totalPages}'),
              _buildDetailRow('İlerleme', '%${book.readingProgress.toStringAsFixed(1)}'),
            ],
            _buildDetailRow('Okuma Süresi', '${book.readingTimeInHours.toStringAsFixed(1)} saat'),
            if (book.rating != null)
              _buildDetailRow('Puan', '${book.rating}/5'),
            if (book.startReadingDate != null)
              _buildDetailRow('Okumaya Başlama', _formatDate(book.startReadingDate!)),
            if (book.completedDate != null)
              _buildDetailRow('Tamamlama Tarihi', _formatDate(book.completedDate!)),
            if (book.completionTimeInDays != null)
              _buildDetailRow('Tamamlama Süresi', '${book.completionTimeInDays} gün'),
            if (book.dailyAverageReadingTime != null)
              _buildDetailRow('Günlük Ortalama', '${book.dailyAverageReadingTime!.toStringAsFixed(1)} dakika'),
            
            const SizedBox(height: 20),
            
            // Butonlar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Okumaya devam et
                    },
                    child: const Text('Okumaya Devam Et'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kapat'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Detay satırı oluştur
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Tarih formatla
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
