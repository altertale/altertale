import 'package:flutter/material.dart';

/// İstatistik kartı widget'ı
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? trailing;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: cardColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),

              const SizedBox(height: 12),

              // Değer
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cardColor,
                ),
              ),

              // Alt başlık
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Okuma istatistikleri widget'ı
class ReadingStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;
  final VoidCallback? onStatsTap;

  const ReadingStatsWidget({super.key, required this.stats, this.onStatsTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.analytics, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Okuma İstatistiklerim',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (onStatsTap != null)
                TextButton(
                  onPressed: onStatsTap,
                  child: const Text('Detaylar'),
                ),
            ],
          ),
        ),

        // İstatistik kartları
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // İlk satır
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Toplam Kitap',
                      value: '${stats['totalBooks'] ?? 0}',
                      icon: Icons.library_books,
                      color: Colors.blue,
                      subtitle: 'Satın alınan kitap sayısı',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Okunan Sayfa',
                      value: '${stats['totalPagesRead'] ?? 0}',
                      icon: Icons.menu_book,
                      color: Colors.green,
                      subtitle: 'Toplam okunan sayfa',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // İkinci satır
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Ortalama',
                      value: '${stats['averagePagesPerBook'] ?? 0}',
                      icon: Icons.trending_up,
                      color: Colors.orange,
                      subtitle: 'Kitap başına sayfa',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Okuma Süresi',
                      value: _formatReadingTime(stats['totalReadingTime'] ?? 0),
                      icon: Icons.timer,
                      color: Colors.purple,
                      subtitle: 'Toplam okuma süresi',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Üçüncü satır - Favori kategori
              StatsCard(
                title: 'Favori Kategori',
                value: stats['favoriteCategory'] ?? 'Yok',
                icon: Icons.favorite,
                color: Colors.red,
                subtitle: 'En çok okunan tür',
              ),

              const SizedBox(height: 12),

              // Son okunan kitap
              if (stats['lastReadBook'] != null)
                _buildLastReadBookCard(context, stats['lastReadBook']),
            ],
          ),
        ),
      ],
    );
  }

  /// Okuma süresini formatla
  String _formatReadingTime(int seconds) {
    if (seconds == 0) return '0dk';

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}s ${minutes}dk';
    } else {
      return '${minutes}dk';
    }
  }

  /// Son okunan kitap kartı
  Widget _buildLastReadBookCard(
    BuildContext context,
    Map<String, dynamic> lastReadBook,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, '/book/${lastReadBook['id']}'),
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
                  child: lastReadBook['coverImageUrl'] != null
                      ? Image.network(
                          lastReadBook['coverImageUrl'],
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
                    Text(
                      'Son Okunan Kitap',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastReadBook['title'] ?? 'Bilinmiyor',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lastReadBook['author'] ?? 'Bilinmiyor',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatLastReadTime(lastReadBook['lastOpenedAt']),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Okuma butonu
              IconButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/read/${lastReadBook['id']}'),
                icon: Icon(Icons.play_arrow, color: theme.colorScheme.primary),
                tooltip: 'Okumaya Devam Et',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Son okuma zamanını formatla
  String _formatLastReadTime(DateTime? lastOpenedAt) {
    if (lastOpenedAt == null) return 'Bilinmiyor';

    final now = DateTime.now();
    final difference = now.difference(lastOpenedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}

/// Kategori istatistikleri widget'ı
class CategoryStatsWidget extends StatelessWidget {
  final Map<String, int> categoryBreakdown;

  const CategoryStatsWidget({super.key, required this.categoryBreakdown});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (categoryBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Kategori Dağılımı',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...categoryBreakdown.entries.map((entry) {
              final percentage =
                  (entry.value /
                          categoryBreakdown.values.reduce((a, b) => a + b) *
                          100)
                      .round();
              return _buildCategoryItem(
                context,
                entry.key,
                entry.value,
                percentage,
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Kategori öğesi
  Widget _buildCategoryItem(
    BuildContext context,
    String category,
    int count,
    int percentage,
  ) {
    final theme = Theme.of(context);
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    final color = colors[category.hashCode % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(category, style: theme.textTheme.bodyMedium)),
          Text(
            '$count kitap',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$percentage%',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
