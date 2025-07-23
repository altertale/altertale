import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_stats_provider.dart';

class ProfileStatsWidget extends StatefulWidget {
  final bool showDetailed;
  final EdgeInsets? padding;

  const ProfileStatsWidget({Key? key, this.showDetailed = true, this.padding})
    : super(key: key);

  @override
  State<ProfileStatsWidget> createState() => _ProfileStatsWidgetState();
}

class _ProfileStatsWidgetState extends State<ProfileStatsWidget> {
  @override
  void initState() {
    super.initState();
    // Load stats when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserStatsProvider>().loadUserStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<UserStatsProvider>(
      builder: (context, statsProvider, child) {
        if (statsProvider.isLoading) {
          return _buildLoadingState(theme);
        }

        if (statsProvider.error != null) {
          return _buildErrorState(theme, statsProvider.error!);
        }

        return Padding(
          padding: widget.padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 16),
              _buildMainStats(theme, statsProvider),
              if (widget.showDetailed) ...[
                const SizedBox(height: 20),
                _buildDetailedStats(theme, statsProvider),
                const SizedBox(height: 20),
                _buildAchievementProgress(theme, statsProvider),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.analytics_outlined,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          'Okuma İstatistiklerin',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            context.read<UserStatsProvider>().refreshStats();
          },
          icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
          tooltip: 'Yenile',
        ),
      ],
    );
  }

  Widget _buildMainStats(ThemeData theme, UserStatsProvider statsProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              theme,
              icon: Icons.menu_book,
              title: 'Okunan Kitap',
              value: '${statsProvider.totalBooksRead}',
              subtitle: 'kitap',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              theme,
              icon: Icons.schedule,
              title: 'Okuma Süresi',
              value: statsProvider.formattedReadingTime.split(' ')[0],
              subtitle: statsProvider.formattedReadingTime.split(' ').length > 1
                  ? statsProvider.formattedReadingTime.split(' ')[1]
                  : '',
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              theme,
              icon: Icons.local_fire_department,
              title: 'Streak',
              value: '${statsProvider.currentStreak}',
              subtitle: 'gün',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle.isNotEmpty) ...[
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailedStats(ThemeData theme, UserStatsProvider statsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detaylı İstatistikler',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                theme,
                icon: Icons.category,
                title: 'Favori Tür',
                value: statsProvider.favoriteGenre,
                color: Colors.purple,
              ),
              const Divider(height: 24),
              _buildDetailRow(
                theme,
                icon: Icons.star,
                title: 'Ortalama Puanın',
                value: statsProvider.formattedAverageRating,
                color: Colors.amber,
              ),
              const Divider(height: 24),
              _buildDetailRow(
                theme,
                icon: Icons.calendar_month,
                title: 'Bu Ay Okunan',
                value: '${statsProvider.thisMonthBooksRead} kitap',
                color: Colors.indigo,
              ),
              const Divider(height: 24),
              _buildDetailRow(
                theme,
                icon: Icons.emoji_events,
                title: 'Seviye',
                value: statsProvider.readingLevel,
                color: Colors.cyan,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementProgress(
    ThemeData theme,
    UserStatsProvider statsProvider,
  ) {
    final achievement = statsProvider.getAchievementProgress();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sonraki Hedef',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.secondaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      achievement['nextMilestone'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                achievement['description'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: achievement['progress'],
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${(achievement['progress'] * 100).toInt()}% tamamlandı',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'İstatistikler yükleniyor...',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 32),
          const SizedBox(height: 8),
          Text(
            'İstatistikler yüklenemedi',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              context.read<UserStatsProvider>().refreshStats();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }
}
