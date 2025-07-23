import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';
import '../../providers/auth_provider.dart';

/// Bildirim ayarları ekranı
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  Map<String, bool> _settings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveSettings,
              child: const Text('Kaydet'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Genel ayarlar
                  _buildSectionTitle(theme, 'Genel Bildirimler'),
                  const SizedBox(height: 16),
                  
                  _buildSettingTile(
                    theme,
                    title: 'Genel Bildirimler',
                    subtitle: 'Uygulama güncellemeleri ve önemli duyurular',
                    icon: Icons.notifications,
                    settingKey: 'general',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Kitap bildirimleri
                  _buildSectionTitle(theme, 'Kitap Bildirimleri'),
                  const SizedBox(height: 16),
                  
                  _buildSettingTile(
                    theme,
                    title: 'Yeni Kitaplar',
                    subtitle: 'Yeni eklenen kitaplar hakkında bildirim al',
                    icon: Icons.book,
                    settingKey: 'newBooks',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildSettingTile(
                    theme,
                    title: 'Haftalık Öneriler',
                    subtitle: 'Her hafta seni bekleyen kitaplar hakkında hatırlatma',
                    icon: Icons.schedule,
                    settingKey: 'weekly',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Sosyal bildirimler
                  _buildSectionTitle(theme, 'Sosyal Bildirimler'),
                  const SizedBox(height: 16),
                  
                  _buildSettingTile(
                    theme,
                    title: 'Arkadaş Aktiviteleri',
                    subtitle: 'Arkadaşlarının okuma aktiviteleri hakkında bildirim al',
                    icon: Icons.people,
                    settingKey: 'friends',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Kampanya bildirimleri
                  _buildSectionTitle(theme, 'Kampanya Bildirimleri'),
                  const SizedBox(height: 16),
                  
                  _buildSettingTile(
                    theme,
                    title: 'Kampanyalar ve İndirimler',
                    subtitle: 'Özel kampanyalar ve indirim fırsatları hakkında bildirim al',
                    icon: Icons.local_offer,
                    settingKey: 'campaigns',
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Bilgi kartı
                  _buildInfoCard(theme),
                  
                  const SizedBox(height: 24),
                  
                  // Test bildirimi butonu
                  _buildTestNotificationButton(theme),
                ],
              ),
            ),
    );
  }

  /// Bölüm başlığı
  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  /// Ayar kartı
  Widget _buildSettingTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String settingKey,
  }) {
    return Card(
      child: SwitchListTile(
        title: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        value: _settings[settingKey] ?? false,
        onChanged: (value) {
          setState(() {
            _settings[settingKey] = value;
          });
        },
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  /// Bilgi kartı
  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bildirim Ayarları Hakkında',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Bildirim ayarlarınızı istediğiniz zaman değiştirebilirsiniz\n'
              '• Değişiklikler anında uygulanır\n'
              '• Tüm bildirimler uygulama içi bildirim merkezinde görüntülenir\n'
              '• Sistem ayarlarından da bildirimleri kontrol edebilirsiniz',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Test bildirimi butonu
  Widget _buildTestNotificationButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _sendTestNotification,
        icon: const Icon(Icons.send),
        label: const Text('Test Bildirimi Gönder'),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  /// Ayarları yükle
  Future<void> _loadSettings() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.userModel;
      
      if (user != null) {
        final settings = await _notificationService.getNotificationSettings(user.uid);
        
        setState(() {
          _settings = settings;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ayarlar yüklenirken hata: $e')),
      );
    }
  }

  /// Ayarları kaydet
  Future<void> _saveSettings() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.userModel;
      
      if (user != null) {
        await _notificationService.saveNotificationSettings(
          userId: user.uid,
          settings: _settings,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bildirim ayarları kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ayarlar kaydedilirken hata: $e')),
      );
    }
  }

  /// Test bildirimi gönder
  Future<void> _sendTestNotification() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.userModel;
      
      if (user != null) {
        await _notificationService.sendNotification(
          title: 'Test Bildirimi',
          body: 'Bu bir test bildirimidir. Bildirim ayarlarınız çalışıyor!',
          targetAudience: 'all',
          data: {
            'type': 'test',
            'screen': 'notification_settings',
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test bildirimi gönderildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test bildirimi gönderilirken hata: $e')),
      );
    }
  }
} 