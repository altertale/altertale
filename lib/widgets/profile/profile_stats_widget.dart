import 'package:flutter/material.dart';

/// Profil istatistikleri widget'ı
/// Kullanıcının okuma istatistiklerini gösterir
class ProfileStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;

  const ProfileStatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Text(
          'İstatistikler',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 16),

        // İstatistik kartları
        _buildStatsGrid(theme),
      ],
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    final statItems = [
      _StatItem(
        icon: Icons.book,
        label: 'Okunan Kitap',
        value: stats['totalBooksRead']?.toString() ?? '0',
        color: Colors.blue,
      ),
      _StatItem(
        icon: Icons.access_time,
        label: 'Okuma Süresi',
        value: _formatReadingTime(stats['totalReadingTime'] ?? 0),
        color: Colors.green,
      ),
      _StatItem(
        icon: Icons.shopping_cart,
        label: 'Satın Alınan',
        value: stats['totalBooksPurchased']?.toString() ?? '0',
        color: Colors.orange,
      ),
      _StatItem(
        icon: Icons.favorite,
        label: 'Favoriler',
        value: stats['totalBooksFavorited']?.toString() ?? '0',
        color: Colors.red,
      ),
      _StatItem(
        icon: Icons.stars,
        label: 'Kazanılan Puan',
        value: stats['totalPointsEarned']?.toString() ?? '0',
        color: Colors.purple,
      ),
      _StatItem(
        icon: Icons.payment,
        label: 'Harcanan Puan',
        value: stats['totalPointsSpent']?.toString() ?? '0',
        color: Colors.teal,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: statItems.length,
      itemBuilder: (context, index) {
        return _buildStatCard(theme, statItems[index]);
      },
    );
  }

  Widget _buildStatCard(ThemeData theme, _StatItem item) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              item.color.withValues(alpha: 0.1),
              item.color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // İkon ve label
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Değer
            Text(
              item.value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: item.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatReadingTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}dk';
    } else if (minutes < 1440) {
      // 24 saat
      final hours = (minutes / 60).round();
      return '${hours}sa';
    } else {
      final days = (minutes / 1440).round();
      return '${days}g';
    }
  }
}

/// İstatistik öğesi data class'ı
class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
