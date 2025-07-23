import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Navigation
import 'navigation/app_router.dart';
import 'navigation/route_names.dart';

// Providers
import 'providers/auth_provider.dart';

/// Navigation Demo Uygulaması
/// Route yönetim sistemini test etmek için
void main() {
  runApp(const NavigationDemoApp());
}

class NavigationDemoApp extends StatelessWidget {
  const NavigationDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Altertale Navigation Demo',
        debugShowCheckedModeBanner: false,

        // Theme Configuration
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.light,
          ),
          fontFamily: 'Inter',
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.dark,
          ),
          fontFamily: 'Inter',
        ),

        // Navigation Configuration
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: RouteNames.home,

        // 404 fallback için
        onUnknownRoute: (settings) => AppRouter.generateRoute(
          RouteSettings(
            name: RouteNames.notFound,
            arguments: settings.arguments,
          ),
        ),
      ),
    );
  }
}

/// Navigation Demo Ana Ekranı
/// Tüm route'ları test etmek için buton listesi
class NavigationDemoHome extends StatelessWidget {
  const NavigationDemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Demo'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Demo açıklama
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navigation Sistemi Demo',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bu demo uygulaması Altertale\'in navigation sistemini test etmek için oluşturulmuştur. Aşağıdaki butonları kullanarak farklı ekranlara geçiş yapabilirsiniz.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Auth Routes Section
          _buildSectionTitle('Kimlik Doğrulama', theme),
          _buildNavigationButton(
            context,
            'Giriş Yap',
            Icons.login,
            RouteNames.login,
          ),
          _buildNavigationButton(
            context,
            'Kayıt Ol',
            Icons.person_add,
            RouteNames.register,
          ),
          _buildNavigationButton(
            context,
            'Şifremi Unuttum',
            Icons.lock_reset,
            RouteNames.forgotPassword,
          ),

          const SizedBox(height: 16),

          // User Routes Section
          _buildSectionTitle('Kullanıcı', theme),
          _buildNavigationButton(
            context,
            'Profil',
            Icons.person,
            RouteNames.profile,
          ),
          _buildNavigationButton(
            context,
            'Profili Düzenle',
            Icons.edit,
            RouteNames.editProfile,
          ),
          _buildNavigationButton(
            context,
            'Ayarlar',
            Icons.settings,
            RouteNames.settings,
          ),

          const SizedBox(height: 16),

          // Book Routes Section
          _buildSectionTitle('Kitaplar', theme),
          _buildNavigationButton(
            context,
            'Arama',
            Icons.search,
            RouteNames.search,
          ),
          _buildNavigationButton(
            context,
            'Kütüphane',
            Icons.library_books,
            RouteNames.library,
          ),
          _buildNavigationButton(
            context,
            'Keşfet',
            Icons.explore,
            RouteNames.explore,
          ),

          const SizedBox(height: 16),

          // Test Routes Section
          _buildSectionTitle('Test', theme),
          _buildNavigationButton(
            context,
            '404 Testi',
            Icons.error,
            '/invalid-route',
          ),

          const SizedBox(height: 32),

          // Navigation Helper'ları test et
          _buildHelperTestButtons(context, theme),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String title,
    IconData icon,
    String routeName,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        onPressed: () => AppRouter.navigateTo(context, routeName),
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildHelperTestButtons(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Navigation Helpers', theme),

        // Push and Clear Stack
        ElevatedButton.icon(
          onPressed: () =>
              AppRouter.navigateToAndClearStack(context, RouteNames.profile),
          icon: const Icon(Icons.clear_all),
          label: const Text('Profile + Clear Stack'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
          ),
        ),

        const SizedBox(height: 8),

        // Can Go Back Test
        ElevatedButton.icon(
          onPressed: () {
            final canGoBack = AppRouter.canGoBack(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Can Go Back: $canGoBack')));
          },
          icon: const Icon(Icons.info),
          label: const Text('Can Go Back Test'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.tertiary,
          ),
        ),

        const SizedBox(height: 8),

        // Route Validation Test
        ElevatedButton.icon(
          onPressed: () {
            final isValid = AppRouter.isValidRoute('/invalid-route');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('"/invalid-route" is valid: $isValid')),
            );
          },
          icon: const Icon(Icons.check_circle),
          label: const Text('Route Validation Test'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }
}
