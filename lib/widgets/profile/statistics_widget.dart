import 'package:flutter/material.dart';
import '../../models/profile/user_stats_model.dart';
import '../../models/profile/user_books_model.dart';
import '../../services/profile/profile_service.dart';

/// İstatistikler widget'ı
class StatisticsWidget extends StatefulWidget {
  final UserStats? userStats;
  final UserProfile userProfile;
  final VoidCallback? onRefresh;

  const StatisticsWidget({
    super.key,
    this.userStats,
    required this.userProfile,
    this.onRefresh,
  });

  @override
  State<StatisticsWidget> createState() => _StatisticsWidgetState();
}

class _StatisticsWidgetState extends State<StatisticsWidget> {
  final ProfileService _profileService = ProfileService();
  
  List<DailyActivity> _weeklyActivity = [];
  List<MonthlyReadingTime> _yearlyReading = [];
  bool _isLoadingActivity = true;

  @override
  void initState() {
    super.initState();
    _loadActivityData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profil özeti
          _buildProfileSummary(theme),
          
          const SizedBox(height: 24),
          
          // Genel istatistikler
          if (widget.userStats != null) _buildGeneralStats(theme),
          
          const SizedBox(height: 24),
          
          // Haftalık aktivite
          if (!_isLoadingActivity) _buildWeeklyActivity(theme),
          
          const SizedBox(height: 24),
          
          // Yıllık okuma süresi
          if (!_isLoadingActivity) _buildYearlyReading(theme),
        ],
      ),
    );
  }

  /// Profil özeti widget'ı
  Widget _buildProfileSummary(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profil fotoğrafı ve bilgiler
            Row(
              children: [
                UserAvatarWidget(
                  profilePhotoUrl: widget.userProfile.profilePhotoUrl,
                  displayName: widget.userProfile.displayNameOrUsername,
                  size: 80,
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userProfile.displayNameOrUsername,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.userProfile.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.userProfile.membershipDays} gündür üye',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Premium badge
                if (widget.userProfile.isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Premium',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            // Bio
            if (widget.userProfile.hasBio) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.userProfile.bio!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Genel istatistikler widget'ı
  Widget _buildGeneralStats(ThemeData theme) {
    final stats = widget.userStats!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genel İstatistikler',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            
            // İstatistik grid'i
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  theme,
                  'Toplam Kitap',
                  stats.totalBooksRead.toString(),
                  Icons.book,
                  Colors.blue,
                ),
                _buildStatCard(
                  theme,
                  'Okuma Süresi',
                  '${stats.totalReadingTimeInHours.toStringAsFixed(1)} saat',
                  Icons.timer,
                  Colors.green,
                ),
                _buildStatCard(
                  theme,
                  'Satın Alınan',
                  stats.totalBooksPurchased.toString(),
                  Icons.shopping_cart,
                  Colors.orange,
                ),
                _buildStatCard(
                  theme,
                  'Favoriler',
                  stats.totalBooksFavorited.toString(),
                  Icons.favorite,
                  Colors.red,
                ),
                _buildStatCard(
                  theme,
                  'Kazanılan Puan',
                  stats.totalPointsEarned.toString(),
                  Icons.stars,
                  Colors.amber,
                ),
                _buildStatCard(
                  theme,
                  'Harcanan Puan',
                  stats.totalPointsSpent.toString(),
                  Icons.payment,
                  Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Detaylı bilgiler
            _buildDetailedStats(theme, stats),
          ],
        ),
      ),
    );
  }

  /// Detaylı istatistikler
  Widget _buildDetailedStats(ThemeData theme, UserStats stats) {
    return Column(
      children: [
        _buildDetailRow(
          theme,
          'Ortalama Kitap Tamamlama Süresi',
          '${stats.averageBookCompletionTime.toStringAsFixed(1)} saat',
          Icons.schedule,
        ),
        _buildDetailRow(
          theme,
          'En Çok Okunan Kategori',
          stats.mostReadCategory.isNotEmpty ? stats.mostReadCategory : 'Belirtilmemiş',
          Icons.category,
        ),
        _buildDetailRow(
          theme,
          'Günlük Ortalama Okuma',
          '${stats.dailyAverageReadingTime.toStringAsFixed(1)} dakika',
          Icons.trending_up,
        ),
        _buildDetailRow(
          theme,
          'Mevcut Puan Bakiyesi',
          stats.currentPointsBalance.toString(),
          Icons.account_balance_wallet,
        ),
      ],
    );
  }

  /// Haftalık aktivite widget'ı
  Widget _buildWeeklyActivity(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son 7 Gün Aktivite',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            
            // Aktivite çubukları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _weeklyActivity.map((activity) {
                final dayName = _getDayName(activity.date);
                final maxTime = _weeklyActivity.fold<int>(
                  0, (max, a) => a.readingTime > max ? a.readingTime : max);
                final height = maxTime > 0 ? (activity.readingTime / maxTime) * 100 : 0;
                
                return Column(
                  children: [
                    Container(
                      width: 30,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 30,
                            height: height.toDouble(),
                            decoration: BoxDecoration(
                              color: activity.isActive 
                                  ? theme.colorScheme.primary 
                                  : theme.colorScheme.outline.withValues(alpha: 0.3),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dayName,
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${activity.readingTime}dk',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Yıllık okuma süresi widget'ı
  Widget _buildYearlyReading(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son 12 Ay Okuma Süresi',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            
            // Basit çizgi grafik
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _yearlyReading.map((reading) {
                  final maxTime = _yearlyReading.fold<int>(
                    0, (max, r) => r.totalReadingTime > max ? r.totalReadingTime : max);
                  final height = maxTime > 0 ? (reading.totalReadingTime / maxTime) * 150 : 0;
                  
                  return Column(
                    children: [
                      Container(
                        width: 20,
                        height: 150,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 20,
                              height: height.toDouble(),
                              decoration: BoxDecoration(
                                color: reading.totalReadingTime > 0 
                                    ? theme.colorScheme.secondary 
                                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reading.monthName.substring(0, 3),
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '${reading.totalReadingTimeInHours.toStringAsFixed(0)}s',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Detay satırı oluştur
  Widget _buildDetailRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Gün adını al
  String _getDayName(DateTime date) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[date.weekday - 1];
  }

  /// Aktivite verilerini yükle
  Future<void> _loadActivityData() async {
    try {
      final results = await Future.wait([
        _profileService.getLastWeekActivity(widget.userProfile.userId),
        _profileService.getLastYearReadingTime(widget.userProfile.userId),
      ]);

      setState(() {
        _weeklyActivity = results[0] as List<DailyActivity>;
        _yearlyReading = results[1] as List<MonthlyReadingTime>;
        _isLoadingActivity = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingActivity = false;
      });
    }
  }

  /// Verileri yenile
  Future<void> _refreshData() async {
    await _loadActivityData();
    widget.onRefresh?.call();
  }
}
