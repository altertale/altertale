import 'package:flutter/material.dart';
import '../../services/likes_service.dart';
import '../../services/book_service.dart';
import '../../models/book_model.dart';

/// Beğeni analitik ekranı
class LikeAnalyticsScreen extends StatefulWidget {
  const LikeAnalyticsScreen({super.key});

  @override
  State<LikeAnalyticsScreen> createState() => _LikeAnalyticsScreenState();
}

class _LikeAnalyticsScreenState extends State<LikeAnalyticsScreen> {
  final LikesService _likesService = LikesService();
  final BookService _bookService = BookService();

  Map<String, int> _mostLikedBooks = {};
  Map<String, dynamic> _statistics = {};
  final List<Map<String, dynamic>> _recentLikes = [];
  bool _isLoading = true;
  String _selectedPeriod = 'all'; // 'all', 'today', 'week', 'month'

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Text(
            'Beğeni Analitikleri',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // İstatistik kartları
          if (!_isLoading) _buildStatisticsCards(theme),

          const SizedBox(height: 24),

          // Filtre
          _buildFilterSection(theme),

          const SizedBox(height: 24),

          // En çok beğenilen kitaplar
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMostLikedBooksList(theme),
          ),
        ],
      ),
    );
  }

  /// İstatistik kartlarını oluştur
  Widget _buildStatisticsCards(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            'Toplam Beğeni',
            '${_statistics['totalLikes'] ?? 0}',
            Icons.favorite,
            Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            theme,
            'Bugünkü Beğeni',
            '${_statistics['todayLikes'] ?? 0}',
            Icons.favorite_border,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  /// İstatistik kartı oluştur
  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Filtre bölümünü oluştur
  Widget _buildFilterSection(ThemeData theme) {
    return Row(
      children: [
        Text('Dönem:', style: theme.textTheme.titleMedium),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: _selectedPeriod,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('Tümü')),
            DropdownMenuItem(value: 'today', child: Text('Bugün')),
            DropdownMenuItem(value: 'week', child: Text('Bu Hafta')),
            DropdownMenuItem(value: 'month', child: Text('Bu Ay')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedPeriod = value!;
            });
            _loadAnalytics();
          },
        ),
      ],
    );
  }

  /// En çok beğenilen kitaplar listesini oluştur
  Widget _buildMostLikedBooksList(ThemeData theme) {
    if (_mostLikedBooks.isEmpty) {
      return Center(
        child: Text(
          'Henüz beğeni bulunmuyor',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _mostLikedBooks.length,
      itemBuilder: (context, index) {
        final bookId = _mostLikedBooks.keys.elementAt(index);
        final likeCount = _mostLikedBooks.values.elementAt(index);

        return FutureBuilder<BookModel?>(
          future: _bookService.getBookById(bookId),
          builder: (context, snapshot) {
            final book = snapshot.data;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  child: Icon(Icons.favorite, color: Colors.red, size: 20),
                ),
                title: Text(
                  book?.title ?? 'Bilinmeyen Kitap',
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Text(
                  book?.author ?? 'Bilinmeyen Yazar',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$likeCount beğeni',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Analitikleri yükle
  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // İstatistikleri yükle
      final stats = await _likesService.getLikeStatistics();

      // En çok beğenilen kitapları yükle
      final mostLiked = await _likesService.getMostLikedBooks(limit: 20);

      setState(() {
        _statistics = stats;
        _mostLikedBooks = mostLiked;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analitikler yüklenirken hata: $e')),
        );
      }
    }
  }
}
