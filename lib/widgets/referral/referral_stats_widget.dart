import 'package:flutter/material.dart';
import '../../models/referral/referral_model.dart';

/// Referans istatistikleri widget'ı
class ReferralStatsWidget extends StatelessWidget {
  final UserReferralInfo userReferralInfo;

  const ReferralStatsWidget({
    super.key,
    required this.userReferralInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Referans İstatistikleriniz',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // İstatistik kartları
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Toplam Davet',
                    userReferralInfo.totalReferrals.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Tamamlanan',
                    userReferralInfo.completedReferrals.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Kazanılan Puan',
                    userReferralInfo.totalPointsEarned.toString(),
                    Icons.stars,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Başarı Oranı',
                    '${(userReferralInfo.successRate * 100).toInt()}%',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Detay bilgileri
            if (userReferralInfo.hasBeenReferred) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: theme.colorScheme.onSecondaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Siz de ${userReferralInfo.referredByCode} kodunu kullanarak kayıt oldunuz',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            if (userReferralInfo.lastReferralAt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Son davet: ${_formatDate(userReferralInfo.lastReferralAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
