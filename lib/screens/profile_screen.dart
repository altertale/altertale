import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../providers/auth_provider.dart';

/// Profile Screen - Profil Ekranı
///
/// Firebase Authentication kullanarak kullanıcının profil bilgilerini
/// gösteren ve hesap yönetimi seçenekleri sunan ekran.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Demo stats (will be replaced with real data later)
  final int booksRead = 15;
  final int favoriteBooks = 8;
  final int commentsCount = 23;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const TitleText('Profil'),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil düzenleme yakında...')),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header
                _buildProfileHeader(authProvider),
                const SizedBox(height: 24),

                // Stats Section
                _buildStatsSection(),
                const SizedBox(height: 24),

                // Menu Items
                _buildMenuSection(),
                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutSection(authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RoundedCard(
      backgroundColor: colorScheme.primaryContainer,
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                authProvider.getUserInitials(),
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // User Info
          TitleText(
            authProvider.getUserDisplayText(),
            size: TitleSize.large,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(height: 4),
          SubtitleText(
            authProvider.email ?? 'Email bilgisi yok',
            color: colorScheme.onPrimaryContainer.withOpacity(0.8),
          ),
          const SizedBox(height: 8),

          // Email Verification Status
          if (!authProvider.isEmailVerified) ...[
            RoundedCard(
              backgroundColor: Colors.orange.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_outlined,
                    size: 16,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 6),
                  SubtitleText(
                    'Email Doğrulanmamış',
                    size: SubtitleSize.small,
                    color: Colors.orange.shade700,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () async {
                      final success = await authProvider
                          .sendEmailVerification();
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Email doğrulama bağlantısı gönderildi',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (mounted && authProvider.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authProvider.error!),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        );
                      }
                    },
              child: SubtitleText(
                'Email Doğrula',
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            RoundedCard(
              backgroundColor: Colors.green.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_outlined,
                    size: 16,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 6),
                  SubtitleText(
                    'Email Doğrulandı',
                    size: SubtitleSize.small,
                    color: Colors.green.shade700,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleText('İstatistikler', size: TitleSize.medium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.book_outlined,
                title: 'Okunan',
                value: booksRead.toString(),
                subtitle: 'Kitap',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.favorite_outlined,
                title: 'Favori',
                value: favoriteBooks.toString(),
                subtitle: 'Kitap',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.comment_outlined,
                title: 'Yorum',
                value: commentsCount.toString(),
                subtitle: 'Adet',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RoundedCard(
      child: Column(
        children: [
          Icon(icon, size: 32, color: colorScheme.primary),
          const SizedBox(height: 8),
          TitleText(value, size: TitleSize.medium, color: colorScheme.primary),
          SubtitleText(title, size: SubtitleSize.small),
          SubtitleText(subtitle, size: SubtitleSize.caption),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleText('Hesap', size: TitleSize.medium),
        const SizedBox(height: 12),
        RoundedCard(
          child: Column(
            children: [
              IconTextButton(
                icon: Icons.library_books_outlined,
                text: 'Kütüphanem',
                style: IconTextButtonStyle.flat,
                trailing: const Icon(Icons.chevron_right),
                onPressed: () {
                  context.go('/home');
                },
              ),
              const Divider(height: 1),
              IconTextButton(
                icon: Icons.receipt_long_outlined,
                text: 'Siparişlerim',
                style: IconTextButtonStyle.flat,
                trailing: const Icon(Icons.chevron_right),
                onPressed: () {
                  context.go('/orders');
                },
              ),
              const Divider(height: 1),
              IconTextButton(
                icon: Icons.favorite_outlined,
                text: 'Favorilerim',
                style: IconTextButtonStyle.flat,
                trailing: const Icon(Icons.chevron_right),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Favoriler yakında...')),
                  );
                },
              ),
              const Divider(height: 1),
              IconTextButton(
                icon: Icons.download_outlined,
                text: 'İndirilenler',
                style: IconTextButtonStyle.flat,
                trailing: const Icon(Icons.chevron_right),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('İndirilenler yakında...')),
                  );
                },
              ),
              const Divider(height: 1),
              IconTextButton(
                icon: Icons.history_outlined,
                text: 'Okuma Geçmişi',
                style: IconTextButtonStyle.flat,
                trailing: const Icon(Icons.chevron_right),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Okuma geçmişi yakında...')),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const TitleText('Ayarlar', size: TitleSize.medium),
        const SizedBox(height: 12),
        RoundedCard(
          child: Column(
            children: [
              IconTextButton(
                icon: Icons.notifications_outlined,
                text: 'Bildirimler',
                style: IconTextButtonStyle.flat,
                trailing: const Icon(Icons.chevron_right),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bildirim ayarları yakında...'),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              IconTextButton(
                icon: Icons.security_outlined,
                text: 'Gizlilik',
                style: IconTextButtonStyle.flat,
                trailing: const Icon(Icons.chevron_right),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gizlilik ayarları yakında...'),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              IconTextButton(
                icon: Icons.help_outline,
                text: 'Yardım',
                style: IconTextButtonStyle.flat,
                trailing: const Icon(Icons.chevron_right),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yardım sayfası yakında...')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutSection(AuthProvider authProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RoundedCard(
      child: IconTextButton(
        icon: Icons.logout_outlined,
        text: 'Çıkış Yap',
        style: IconTextButtonStyle.flat,
        iconColor: colorScheme.error,
        textColor: colorScheme.error,
        onPressed: authProvider.isLoading
            ? null
            : () => _showLogoutDialog(authProvider),
      ),
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TitleText('Çıkış Yap'),
        content: const SubtitleText(
          'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
        ),
        actions: [
          CustomButton(
            text: 'İptal',
            isPrimary: false,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return CustomButton(
                text: 'Çıkış Yap',
                isLoading: authProvider.isLoading,
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        final success = await authProvider.signOut();
                        if (success && mounted) {
                          Navigator.of(context).pop();
                          // Router will automatically redirect to login due to auth state change
                        } else if (mounted && authProvider.error != null) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authProvider.error!),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                          );
                        }
                      },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const TitleText('Yardım & Destek'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubtitleText(
              'Altertale uygulaması hakkında yardıma mı ihtiyacınız var?',
            ),
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
