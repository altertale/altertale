import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const TitleText('Altertale', size: TitleSize.large),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => context.go('/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showProfileDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                return RoundedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleText(
                        'Hoş Geldiniz${user?.displayName != null ? ', ${user!.displayName}' : ''}!',
                        size: TitleSize.medium,
                      ),
                      const SizedBox(height: 8),
                      const SubtitleText(
                        'Kitap dünyanızı keşfetmeye hazır mısınız?',
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Navigation Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildNavigationCard(
                    context,
                    title: 'Kitapları Keşfet',
                    subtitle: 'Tüm kitapları inceleyin',
                    icon: Icons.library_books,
                    onTap: () => context.go('/books'),
                  ),
                  _buildNavigationCard(
                    context,
                    title: 'Sepetim',
                    subtitle: 'Alışveriş sepetinizi görün',
                    icon: Icons.shopping_cart,
                    onTap: () => context.go('/cart'),
                  ),
                  _buildNavigationCard(
                    context,
                    title: 'Siparişlerim',
                    subtitle: 'Geçmiş siparişleriniz',
                    icon: Icons.receipt_long,
                    onTap: () => context.go('/orders'),
                  ),
                  _buildNavigationCard(
                    context,
                    title: 'Çıkış Yap',
                    subtitle: 'Hesabınızdan çıkış yapın',
                    icon: Icons.logout,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return RoundedCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          TitleText(title, size: TitleSize.small, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          SubtitleText(
            subtitle,
            size: SubtitleSize.small,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TitleText('Profil'),
        content: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user?.displayName != null)
                  SubtitleText('Ad: ${user!.displayName}'),
                if (user?.email != null)
                  SubtitleText('E-posta: ${user!.email}'),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Çıkış Yap',
                  type: ButtonType.secondary,
                  onPressed: () {
                    Navigator.of(context).pop();
                    _logout(context);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signOut();
    if (context.mounted) {
      context.go('/login');
    }
  }
}
