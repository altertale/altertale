import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/settings_service.dart';
import '../../services/profile/profile_service.dart';
import '../../models/user_profile_model.dart';
import '../../widgets/widgets.dart';
import '../../widgets/offline/connection_status_widget.dart';

/// Settings Screen - Ayarlar Ekranı
///
/// Kullanıcının uygulama ayarlarını yönetmesini sağlar
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final ProfileService _profileService = ProfileService();

  // State variables
  bool _isLoading = true;
  bool _isUpdating = false;
  UserProfile? _userProfile;
  PackageInfo? _packageInfo;

  // Settings values
  bool _notificationsEnabled = true;
  bool _autoSaveEnabled = true;
  bool _offlineModeEnabled = false;
  bool _analyticsEnabled = true;
  String _selectedLanguage = 'tr';
  double _textSizeScale = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      // Initialize services
      await _settingsService.initialize();

      // Load package info for version
      _packageInfo = await PackageInfo.fromPlatform();

      // Load user profile
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isLoggedIn) {
        _userProfile = await _profileService.getUserProfile(
          authProvider.userId,
        );
      }

      // Load settings
      await _loadSettings();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ayarlar yüklenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadSettings() async {
    try {
      final results = await Future.wait([
        _settingsService.getNotificationsEnabled(),
        _settingsService.getAutoSaveEnabled(),
        _settingsService.getOfflineModeEnabled(),
        _settingsService.getAnalyticsEnabled(),
        _settingsService.getSelectedLanguage(),
        _settingsService.getTextSizeScale(),
      ]);

      if (mounted) {
        setState(() {
          _notificationsEnabled = results[0] as bool;
          _autoSaveEnabled = results[1] as bool;
          _offlineModeEnabled = results[2] as bool;
          _analyticsEnabled = results[3] as bool;
          _selectedLanguage = results[4] as String;
          _textSizeScale = results[5] as double;
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _updateSetting<T>(
    Future<void> Function(T value) setter,
    T value,
    String settingName,
  ) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await setter(value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$settingName güncellendi'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$settingName güncellenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TitleText('Hesabı Sil'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.red, size: 48),
            SizedBox(height: 16),
            SubtitleText(
              'Bu işlem geri alınamaz!\n\nTüm verileriniz kalıcı olarak silinecek:\n• Profil bilgileri\n• Sipariş geçmişi\n• Tercihler\n• Tüm kişisel veriler',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFinalDeleteConfirmation();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation() {
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const TitleText('Son Onay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SubtitleText('Hesabınızı silmek için aşağıya "SİL" yazın:'),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                labelText: 'Onay metni',
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: confirmController,
            builder: (context, value, child) {
              final isValid = value.text.trim().toUpperCase() == 'SİL';
              return TextButton(
                onPressed: isValid ? () => _deleteAccount() : null,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  backgroundColor: isValid ? Colors.red.withOpacity(0.1) : null,
                ),
                child: const Text('HESABI SİL'),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    Navigator.of(context).pop(); // Close dialog

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            SubtitleText('Hesap siliniyor...'),
          ],
        ),
      ),
    );

    try {
      final authProvider = context.read<AuthProvider>();

      // Delete user profile
      if (authProvider.isLoggedIn) {
        await _profileService.deleteUserProfile(authProvider.userId);
      }

      // Clear all settings
      await _settingsService.clearAllSettings();

      // Sign out
      await authProvider.signOut();

      // Close loading dialog and navigate
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hesap başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hesap silinirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TitleText('Çıkış Yap'),
        content: const SubtitleText(
          'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthProvider>().signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
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
        elevation: 0,
      ),
      body: _isLoading ? _buildLoadingState() : _buildSettingsContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          SubtitleText('Ayarlar yükleniyor...'),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // User Info Section
          _buildUserInfoSection(),

          const SizedBox(height: 24),

          // Theme Settings Section
          _buildThemeSection(),

          const SizedBox(height: 16),

          // Notification Settings Section
          _buildNotificationSection(),

          const SizedBox(height: 16),

          // App Settings Section
          _buildAppSettingsSection(),

          const SizedBox(height: 16),

          // Privacy Settings Section
          _buildPrivacySection(),

          const SizedBox(height: 32),

          // Action Buttons Section
          _buildActionButtonsSection(),

          const SizedBox(height: 32),

          // App Info Section
          _buildAppInfoSection(),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      return const SizedBox.shrink();
    }

    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('Kullanıcı Bilgileri', size: TitleSize.medium),
          const SizedBox(height: 16),

          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: _userProfile?.profileImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        _userProfile!.profileImageUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            _userProfile?.initials ?? 'U',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    )
                  : Text(
                      _userProfile?.initials ?? 'U',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            title: Text(_userProfile?.displayName ?? 'Kullanıcı'),
            subtitle: Text(_userProfile?.email ?? authProvider.userId),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.of(context).pushNamed('/profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('Görünüm', size: TitleSize.medium),
          const SizedBox(height: 8),

          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: const Text('Karanlık Mod'),
                subtitle: const Text('Gece görünümü için karanlık tema kullan'),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  if (value) {
                    themeProvider.setDarkTheme();
                  } else {
                    themeProvider.setLightTheme();
                  }
                },
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              );
            },
          ),

          // Text Size Slider
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Metin Boyutu'),
            subtitle: Slider(
              value: _textSizeScale,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              label: '${(_textSizeScale * 100).round()}%',
              onChanged: (value) {
                setState(() {
                  _textSizeScale = value;
                });
              },
              onChangeEnd: (value) {
                _updateSetting(
                  _settingsService.setTextSizeScale,
                  value,
                  'Metin boyutu',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('Bildirimler', size: TitleSize.medium),
          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text('Bildirimleri Etkinleştir'),
            subtitle: const Text('Uygulama bildirimlerini al'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _updateSetting(
                _settingsService.setNotificationsEnabled,
                value,
                'Bildirimler',
              );
            },
            secondary: const Icon(Icons.notifications),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection() {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('Uygulama Ayarları', size: TitleSize.medium),
          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text('Otomatik Kaydet'),
            subtitle: const Text('Değişiklikleri otomatik olarak kaydet'),
            value: _autoSaveEnabled,
            onChanged: (value) {
              setState(() {
                _autoSaveEnabled = value;
              });
              _updateSetting(
                _settingsService.setAutoSaveEnabled,
                value,
                'Otomatik kaydetme',
              );
            },
            secondary: const Icon(Icons.save),
          ),

          SwitchListTile(
            title: const Text('Çevrimdışı Mod'),
            subtitle: const Text('İnternet olmadan kullanım'),
            value: _offlineModeEnabled,
            onChanged: (value) {
              setState(() {
                _offlineModeEnabled = value;
              });
              _updateSetting(
                _settingsService.setOfflineModeEnabled,
                value,
                'Çevrimdışı mod',
              );
            },
            secondary: const Icon(Icons.cloud_off),
          ),

          // Sync Settings Section
          const SizedBox(height: 16),
          const TitleText('Senkronizasyon', size: TitleSize.medium),
          const SizedBox(height: 8),
          ConnectionStatusWidget(),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('Gizlilik', size: TitleSize.medium),
          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text('Analitik Veriler'),
            subtitle: const Text(
              'Uygulamayı geliştirmek için anonim veri gönder',
            ),
            value: _analyticsEnabled,
            onChanged: (value) {
              setState(() {
                _analyticsEnabled = value;
              });
              _updateSetting(
                _settingsService.setAnalyticsEnabled,
                value,
                'Analitik veriler',
              );
            },
            secondary: const Icon(Icons.analytics),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsSection() {
    final authProvider = context.watch<AuthProvider>();

    return Column(
      children: [
        // Sign Out Button
        if (authProvider.isLoggedIn) ...[
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Çıkış Yap',
              onPressed: _signOut,
              type: ButtonType.secondary,
            ),
          ),

          const SizedBox(height: 16),

          // Delete Account Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _showDeleteAccountDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Hesabı Sil'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAppInfoSection() {
    final theme = Theme.of(context);

    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('Uygulama Bilgileri', size: TitleSize.medium),
          const SizedBox(height: 16),

          Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _packageInfo?.appName ?? 'AlterTale',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    SubtitleText(
                      'Sürüm ${_packageInfo?.version ?? '1.0.0'} (${_packageInfo?.buildNumber ?? '1'})',
                      size: SubtitleSize.small,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(),

          const SizedBox(height: 8),

          SubtitleText(
            '© 2024 AlterTale. Tüm hakları saklıdır.',
            size: SubtitleSize.small,
            color: theme.colorScheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
