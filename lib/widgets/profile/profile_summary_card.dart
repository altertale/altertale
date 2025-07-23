import 'package:flutter/material.dart';
import '../../models/profile_model.dart';

/// Profil özet kartı widget'ı
/// Kullanıcı profil bilgilerini kompakt şekilde gösterir
class ProfileSummaryCard extends StatelessWidget {
  final ProfileModel profile;
  final bool isDetailed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onTap;

  const ProfileSummaryCard({
    super.key,
    required this.profile,
    this.isDetailed = false,
    this.onEditPressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Üst kısım - Avatar ve temel bilgiler
              Row(
                children: [
                  // Profil fotoğrafı
                  _buildAvatar(theme),

                  const SizedBox(width: 16),

                  // Kullanıcı bilgileri
                  Expanded(child: _buildUserInfo(theme)),

                  // Düzenle butonu (detaylı görünümde)
                  if (isDetailed && onEditPressed != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onEditPressed,
                      icon: const Icon(Icons.edit),
                      tooltip: 'Profili Düzenle',
                    ),
                  ],

                  // Ok işareti (tıklanabilirse)
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),

              // Alt kısım - Ek bilgiler (detaylı görünümde)
              if (isDetailed) ...[
                const SizedBox(height: 16),
                _buildDetailedInfo(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: isDetailed ? 32 : 24,
      backgroundColor: theme.colorScheme.primary,
      backgroundImage: profile.hasProfileImage
          ? NetworkImage(profile.profileImageUrl!)
          : null,
      child: !profile.hasProfileImage
          ? Text(
              _getInitials(),
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: isDetailed ? 20 : 16,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }

  Widget _buildUserInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // İsim
        Text(
          profile.displayNameOrUsername,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // Email
        Text(
          profile.email,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Bio (varsa ve detaylı görünümde değilse)
        if (!isDetailed && profile.hasBio) ...[
          const SizedBox(height: 4),
          Text(
            profile.bio!,
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailedInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bio (detaylı görünümde)
        if (profile.hasBio) ...[
          Text(
            'Hakkımda',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(profile.bio!, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
        ],

        // İstatistik bilgileri
        Row(
          children: [
            Expanded(
              child: _buildInfoChip(
                theme,
                Icons.calendar_today,
                'Üyelik',
                '${profile.membershipDays} gün',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoChip(
                theme,
                Icons.access_time,
                'Son Aktiflik',
                '${profile.lastActiveDays} gün önce',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Premium durumu ve profil tamamlanma
        Row(
          children: [
            Expanded(
              child: _buildInfoChip(
                theme,
                profile.isPremium ? Icons.star : Icons.person,
                'Durum',
                profile.isPremium ? 'Premium' : 'Standart',
                color: profile.isPremium ? Colors.amber : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoChip(
                theme,
                Icons.analytics,
                'Tamamlanma',
                '%${profile.profileCompletionPercentage.round()}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    ThemeData theme,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    final chipColor = color ?? theme.colorScheme.primaryContainer;
    final chipTextColor = color != null
        ? Colors.white
        : theme.colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: chipTextColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: chipTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: chipTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials() {
    final name = profile.displayNameOrUsername;
    if (name.isEmpty) return '?';

    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }
}
