import 'package:flutter/material.dart';
import '../../models/profile_model.dart';

/// Profil ayarları bölümü widget'ı
/// Tema, bildirim ve tercih ayarlarını yönetir
class ProfileSettingsSection extends StatelessWidget {
  final ProfileModel profile;
  final Function(String) onThemeChanged;
  final Function(String, bool) onNotificationChanged;
  final Function(String, dynamic) onPreferenceChanged;

  const ProfileSettingsSection({
    super.key,
    required this.profile,
    required this.onThemeChanged,
    required this.onNotificationChanged,
    required this.onPreferenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Text(
          'Ayarlar',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 16),

        // Ayar kartları
        _buildThemeSettings(theme),
        const SizedBox(height: 12),
        _buildNotificationSettings(theme),
        const SizedBox(height: 12),
        _buildPreferenceSettings(theme),
      ],
    );
  }

  Widget _buildThemeSettings(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Görünüm',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tema seçimi
            _buildSettingTile(
              theme,
              'Tema',
              'Uygulamanın görünümünü değiştirin',
              DropdownButton<String>(
                value: profile.theme,
                isExpanded: true,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('Sistem')),
                  DropdownMenuItem(value: 'light', child: Text('Açık')),
                  DropdownMenuItem(value: 'dark', child: Text('Koyu')),
                ],
                onChanged: (value) {
                  if (value != null) onThemeChanged(value);
                },
              ),
            ),

            const Divider(),

            // Font boyutu
            _buildSettingTile(
              theme,
              'Yazı Boyutu',
              'Okuma yazı boyutunu ayarlayın',
              DropdownButton<String>(
                value: profile.fontSize,
                isExpanded: true,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'small', child: Text('Küçük')),
                  DropdownMenuItem(value: 'medium', child: Text('Orta')),
                  DropdownMenuItem(value: 'large', child: Text('Büyük')),
                ],
                onChanged: (value) {
                  if (value != null) onPreferenceChanged('fontSize', value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Bildirimler',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bildirim ayarları
            _buildSwitchTile(
              theme,
              'Yeni Kitap Bildirimleri',
              'Yeni kitaplar hakkında bilgilendirilun',
              profile.newBookNotifications,
              (value) => onNotificationChanged('newBookNotifications', value),
            ),

            _buildSwitchTile(
              theme,
              'Kampanya Bildirimleri',
              'İndirim ve kampanya haberlerini alın',
              profile.campaignNotifications,
              (value) => onNotificationChanged('campaignNotifications', value),
            ),

            _buildSwitchTile(
              theme,
              'Günlük Özet',
              'Okuma istatistiklerinizi alın',
              profile.dailySummaryNotifications,
              (value) =>
                  onNotificationChanged('dailySummaryNotifications', value),
            ),

            _buildSwitchTile(
              theme,
              'Referans Bildirimleri',
              'Arkadaş davetleri hakkında bilgi alın',
              profile.referralNotifications,
              (value) => onNotificationChanged('referralNotifications', value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceSettings(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Tercihler',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tercih ayarları
            _buildSwitchTile(
              theme,
              'Ses Efektleri',
              'Uygulama seslerini açın/kapatın',
              profile.soundEffects,
              (value) => onPreferenceChanged('soundEffects', value),
            ),

            _buildSwitchTile(
              theme,
              'Haptic Feedback',
              'Dokunsal geri bildirimi açın/kapatın',
              profile.hapticFeedback,
              (value) => onPreferenceChanged('hapticFeedback', value),
            ),

            _buildSwitchTile(
              theme,
              'Otomatik Kaydetme',
              'Okuma ilerlemesini otomatik kaydet',
              profile.autoSave,
              (value) => onPreferenceChanged('autoSave', value),
            ),

            const Divider(),

            // Dil seçimi
            _buildSettingTile(
              theme,
              'Dil',
              'Uygulama dilini değiştirin',
              DropdownButton<String>(
                value: profile.language,
                isExpanded: true,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (value) {
                  if (value != null) onPreferenceChanged('language', value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    ThemeData theme,
    String title,
    String subtitle,
    Widget trailing,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(width: 120, child: trailing),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
