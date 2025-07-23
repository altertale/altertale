import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/widgets.dart';

/// Settings Screen - Ayarlar Ekranı
///
/// Uygulamanın ayarlarını ve tercihlerini yönetmek
/// için kullanılan ekran.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoDownload = false;
  bool _offlineMode = false;
  String _language = 'Türkçe';
  String _textSize = 'Orta';
  double _brightness = 0.8;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // Load settings from storage (dummy implementation)
    final brightness = MediaQuery.of(context).platformBrightness;
    setState(() {
      _darkMode = brightness == Brightness.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const TitleText('Ayarlar'),
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildAppearanceSection(),
            const SizedBox(height: 24),

            // Reading Section
            _buildReadingSection(),
            const SizedBox(height: 24),

            // Notifications Section
            _buildNotificationsSection(),
            const SizedBox(height: 24),

            // Storage Section
            _buildStorageSection(),
            const SizedBox(height: 24),

            // Account Section
            _buildAccountSection(),
            const SizedBox(height: 24),

            // About Section
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSettingsSection(
      title: 'Görünüm',
      icon: Icons.palette_outlined,
      children: [
        _buildSwitchTile(
          title: 'Karanlık Mod',
          subtitle: 'Gece okuma için rahat görünüm',
          value: _darkMode,
          onChanged: (value) {
            setState(() {
              _darkMode = value;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Karanlık mod ${value ? 'açıldı' : 'kapatıldı'}'),
              ),
            );
          },
        ),
        _buildListTile(
          title: 'Dil',
          subtitle: _language,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguageDialog(),
        ),
        _buildSliderTile(
          title: 'Ekran Parlaklığı',
          value: _brightness,
          onChanged: (value) {
            setState(() {
              _brightness = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildReadingSection() {
    return _buildSettingsSection(
      title: 'Okuma',
      icon: Icons.menu_book_outlined,
      children: [
        _buildListTile(
          title: 'Metin Boyutu',
          subtitle: _textSize,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showTextSizeDialog(),
        ),
        _buildSwitchTile(
          title: 'Otomatik İndirme',
          subtitle: 'WiFi\'de kitapları otomatik indir',
          value: _autoDownload,
          onChanged: (value) {
            setState(() {
              _autoDownload = value;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Çevrimdışı Mod',
          subtitle: 'Sadece indirilen içerikleri göster',
          value: _offlineMode,
          onChanged: (value) {
            setState(() {
              _offlineMode = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _buildSettingsSection(
      title: 'Bildirimler',
      icon: Icons.notifications_outlined,
      children: [
        _buildSwitchTile(
          title: 'Bildirimler',
          subtitle: 'Yeni kitap ve güncellemeler',
          value: _notifications,
          onChanged: (value) {
            setState(() {
              _notifications = value;
            });
          },
        ),
        _buildListTile(
          title: 'Bildirim Ayarları',
          subtitle: 'Detaylı bildirim tercihleri',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bildirim ayarları yakında...')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStorageSection() {
    return _buildSettingsSection(
      title: 'Depolama',
      icon: Icons.storage_outlined,
      children: [
        _buildListTile(
          title: 'İndirilen Kitaplar',
          subtitle: '2.1 GB - 12 kitap',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Depolama yönetimi yakında...')),
            );
          },
        ),
        _buildListTile(
          title: 'Önbelleği Temizle',
          subtitle: 'Geçici dosyaları sil',
          trailing: const Icon(Icons.cleaning_services),
          onTap: () => _showClearCacheDialog(),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSettingsSection(
      title: 'Hesap',
      icon: Icons.account_circle_outlined,
      children: [
        _buildListTile(
          title: 'Profil',
          subtitle: 'Profil bilgilerinizi düzenleyin',
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/profile'),
        ),
        _buildListTile(
          title: 'Gizlilik',
          subtitle: 'Gizlilik ayarları ve veri kontrolü',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gizlilik ayarları yakında...')),
            );
          },
        ),
        _buildListTile(
          title: 'Güvenlik',
          subtitle: 'Şifre ve güvenlik ayarları',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Güvenlik ayarları yakında...')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSettingsSection(
      title: 'Hakkında',
      icon: Icons.info_outlined,
      children: [
        _buildListTile(
          title: 'Sürüm',
          subtitle: '1.0.0 (Beta)',
          onTap: () => _showVersionDialog(),
        ),
        _buildListTile(
          title: 'Yardım & Destek',
          subtitle: 'SSS ve destek merkezine erişim',
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showHelpDialog(),
        ),
        _buildListTile(
          title: 'Kullanım Koşulları',
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kullanım koşulları yakında...')),
            );
          },
        ),
        _buildListTile(
          title: 'Gizlilik Politikası',
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gizlilik politikası yakında...')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            TitleText(
              title,
              size: TitleSize.medium,
              color: colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        RoundedCard(child: Column(children: children)),
      ],
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: SubtitleText(title, fontWeight: FontWeight.w500),
      subtitle: subtitle != null
          ? SubtitleText(subtitle, size: SubtitleSize.small)
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: SubtitleText(title, fontWeight: FontWeight.w500),
      subtitle: subtitle != null
          ? SubtitleText(subtitle, size: SubtitleSize.small)
          : null,
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubtitleText(title, fontWeight: FontWeight.w500),
          Slider(
            value: value,
            onChanged: onChanged,
            divisions: 10,
            label: '${(value * 100).round()}%',
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['Türkçe', 'English', 'Español', 'Français'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TitleText('Dil Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: SubtitleText(language),
              value: language,
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          CustomButton(
            text: 'İptal',
            isPrimary: false,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showTextSizeDialog() {
    final sizes = ['Küçük', 'Orta', 'Büyük', 'Çok Büyük'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TitleText('Metin Boyutu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sizes.map((size) {
            return RadioListTile<String>(
              title: SubtitleText(size),
              value: size,
              groupValue: _textSize,
              onChanged: (value) {
                setState(() {
                  _textSize = value!;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          CustomButton(
            text: 'İptal',
            isPrimary: false,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TitleText('Önbelleği Temizle'),
        content: const SubtitleText(
          'Geçici dosyalar ve önbellek silinecek. Bu işlem geri alınamaz.',
        ),
        actions: [
          CustomButton(
            text: 'İptal',
            isPrimary: false,
            onPressed: () => Navigator.of(context).pop(),
          ),
          CustomButton(
            text: 'Temizle',
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Önbellek temizlendi')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.auto_stories,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const TitleText('Altertale'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubtitleText(
              'Sürüm: 1.0.0 (Beta)\n'
              'Derleme: 2024.01.001\n'
              'Flutter: 3.16.0\n\n'
              'Hikayelerinizi keşfetmenin yeni yolu.',
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'Tamam',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TitleText('Yardım & Destek'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubtitleText('Yardıma mı ihtiyacınız var? Bize ulaşın:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email_outlined),
                SizedBox(width: 8),
                SubtitleText('destek@altertale.com'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone_outlined),
                SizedBox(width: 8),
                SubtitleText('0850 123 45 67'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule_outlined),
                SizedBox(width: 8),
                SubtitleText('09:00 - 18:00 (Hafta içi)'),
              ],
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'Tamam',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
