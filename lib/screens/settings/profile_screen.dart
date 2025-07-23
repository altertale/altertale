import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../routes/router.dart';

/// Profile Screen
///
/// User profile management screen with:
/// - User information display
/// - Profile editing options
/// - Account statistics
/// - Temporary placeholder UI
/// - Navigation controls
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ==================== SERVICES ====================
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profil düzenleme özelliği yakında!'),
                ),
              );
            },
            tooltip: 'Profili Düzenle',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(theme, user),

            const SizedBox(height: 32),

            // Stats Cards
            _buildStatsCards(theme),

            const SizedBox(height: 24),

            // Profile Sections
            _buildProfileSections(theme),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Fotoğraf değiştirme özelliği yakında!',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // User Info
            Text(
              user?.displayName ?? 'Kullanıcı',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              user?.email ?? 'email@example.com',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: user?.emailVerified == true
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user?.emailVerified == true
                    ? 'Email Doğrulandı'
                    : 'Email Doğrulanmadı',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: user?.emailVerified == true
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Okunan Hikaye',
            '12',
            Icons.auto_stories,
            theme.colorScheme.primary,
            theme,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatCard(
            'Beğeniler',
            '48',
            Icons.favorite,
            Colors.red,
            theme,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatCard(
            'Yer İmleri',
            '7',
            Icons.bookmark,
            Colors.blue,
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),

            const SizedBox(height: 12),

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
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSections(ThemeData theme) {
    return Column(
      children: [
        _buildSectionCard(
          'Hesap Bilgileri',
          'Kişisel bilgilerinizi görüntüleyin ve düzenleyin',
          Icons.person,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hesap bilgileri özelliği yakında!'),
              ),
            );
          },
          theme,
        ),

        const SizedBox(height: 12),

        _buildSectionCard(
          'Okuma Geçmişi',
          'Okuduğunuz hikayeleri görüntüleyin',
          Icons.history,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Okuma geçmişi özelliği yakında!')),
            );
          },
          theme,
        ),

        const SizedBox(height: 12),

        _buildSectionCard(
          'Favoriler',
          'Beğendiğiniz hikayeleri yönetin',
          Icons.favorite,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Favoriler özelliği yakında!')),
            );
          },
          theme,
        ),

        const SizedBox(height: 12),

        _buildSectionCard(
          'Yer İmleri',
          'Yer imlerinizi görüntüleyin ve yönetin',
          Icons.bookmark,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Yer imleri özelliği yakında!')),
            );
          },
          theme,
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go(AppRouter.settings),
            icon: const Icon(Icons.settings),
            label: const Text('Ayarlar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondaryContainer,
              foregroundColor: theme.colorScheme.onSecondaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await _showSignOutDialog(context);
              if (confirmed == true) {
                try {
                  await _authService.signOut();
                  if (mounted) {
                    context.go(AppRouter.login);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Çıkış yapılırken hata oluştu: $e'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Çıkış Yap'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool?> _showSignOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
