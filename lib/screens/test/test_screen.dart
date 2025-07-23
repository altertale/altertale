import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

// Navigation
import '../../navigation/app_router.dart';
import '../../navigation/route_names.dart';

// Tests
import '../../tests/firestore_service_test.dart';
import '../../tests/models_test_screen.dart';
import '../../tests/firebase_services_test_screen.dart';

/// Main Test Screen
///
/// Central testing hub for all Altertale features:
/// - Data Models comprehensive testing
/// - Firebase Services testing
/// - UI Components testing
/// - Performance testing
/// - Debug utilities
class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme provider'ı watch ederek tema değişikliklerini dinle
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Test Ekranı'),
        actions: [
          // Theme toggle button
          IconButton(
            onPressed: () => themeProvider.toggleTheme(),
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: 'Tema Değiştir',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Provider Demo Kartları
            _buildProviderDemoCard(context),

            const SizedBox(height: 16),

            // Auth Provider Test Section
            _buildAuthProviderSection(context),

            const SizedBox(height: 16),

            // Theme Provider Test Section
            _buildThemeProviderSection(context),

            const SizedBox(height: 16),

            // Firestore Service Test Section
            _buildFirestoreServiceSection(context),

            const SizedBox(height: 16),

            // Firebase Services Test Section
            _buildFirebaseServicesTestSection(context),

            const SizedBox(height: 16),

            // Models Test Section
            _buildModelsTestSection(context),

            const SizedBox(height: 16),

            // Provider Best Practices
            _buildBestPracticesCard(context),

            const SizedBox(height: 32),

            // Navigation Test
            _buildNavigationTestSection(context),
          ],
        ),
      ),
    );
  }

  /// Provider Demo Card
  Widget _buildProviderDemoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.science_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Provider Kullanım Demonstrasyonu',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Bu ekran AuthProvider, ThemeProvider ve FirestoreService kullanım örneklerini gösterir. '
              'Production seviyesinde state management nasıl yapılır öğrenebilirsiniz.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Auth Provider Test Section
  Widget _buildAuthProviderSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final theme = Theme.of(context);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_circle_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Auth Provider Test',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Auth Status
                _buildInfoRow(
                  'Giriş Durumu',
                  authProvider.isLoggedIn
                      ? 'Giriş Yapılmış ✅'
                      : 'Giriş Yapılmamış ❌',
                  theme,
                ),

                if (authProvider.isLoggedIn) ...[
                  _buildInfoRow('Kullanıcı Email', authProvider.email, theme),
                  _buildInfoRow(
                    'Kullanıcı Adı',
                    authProvider.displayName,
                    theme,
                  ),
                  _buildInfoRow('UID', authProvider.uid ?? 'N/A', theme),
                  _buildInfoRow(
                    'Email Doğrulandı',
                    authProvider.isEmailVerified ? 'Evet ✅' : 'Hayır ❌',
                    theme,
                  ),
                ],

                _buildInfoRow(
                  'Provider Durumu',
                  authProvider.isInitialized ? 'Hazır ✅' : 'Yükleniyor... ⏳',
                  theme,
                ),

                if (authProvider.isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'İşlem devam ediyor...',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                if (authProvider.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.onErrorContainer,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authProvider.errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: authProvider.clearError,
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onErrorContainer,
                            size: 16,
                          ),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Auth Actions
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (!authProvider.isLoggedIn) ...[
                      ElevatedButton.icon(
                        onPressed: () =>
                            AppRouter.navigateTo(context, RouteNames.login),
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text('Giriş Yap'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            AppRouter.navigateTo(context, RouteNames.register),
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('Kayıt Ol'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                await authProvider.signOut();
                              },
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Çıkış Yap'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: authProvider.reloadUser,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Yenile'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Theme Provider Test Section
  Widget _buildThemeProviderSection(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Theme Provider Test',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Theme Status
                _buildInfoRow(
                  'Tema Modu',
                  themeProvider.currentThemeModeDisplayName,
                  theme,
                ),
                _buildInfoRow(
                  'Renk Şeması',
                  themeProvider.currentColorSchemeDisplayName,
                  theme,
                ),
                _buildInfoRow(
                  'Font Ölçeği',
                  '${(themeProvider.fontScale * 100).toInt()}%',
                  theme,
                ),
                _buildInfoRow(
                  'Provider Durumu',
                  themeProvider.isInitialized ? 'Hazır ✅' : 'Yükleniyor... ⏳',
                  theme,
                ),

                const SizedBox(height: 16),

                // Theme Mode Buttons
                Text(
                  'Tema Modu:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildThemeModeButton(
                      'Açık',
                      Icons.light_mode_rounded,
                      ThemeMode.light,
                      themeProvider,
                      theme,
                    ),
                    _buildThemeModeButton(
                      'Koyu',
                      Icons.dark_mode_rounded,
                      ThemeMode.dark,
                      themeProvider,
                      theme,
                    ),
                    _buildThemeModeButton(
                      'Sistem',
                      Icons.brightness_auto_rounded,
                      ThemeMode.system,
                      themeProvider,
                      theme,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Color Scheme Selector
                Text(
                  'Renk Şeması:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: themeProvider.availableColorSchemes.map((scheme) {
                    final isSelected =
                        themeProvider.selectedColorScheme == scheme;
                    final seedColor = themeProvider.getColorSchemeSeed(scheme);

                    return GestureDetector(
                      onTap: () => themeProvider.setColorScheme(scheme),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: seedColor,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Font Scale Controls
                Text(
                  'Font Ölçeği:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: themeProvider.decreaseFontScale,
                      icon: const Icon(Icons.remove),
                      tooltip: 'Küçült',
                    ),
                    Expanded(
                      child: Slider(
                        value: themeProvider.fontScale,
                        min: 0.8,
                        max: 1.5,
                        divisions: 7,
                        label: '${(themeProvider.fontScale * 100).toInt()}%',
                        onChanged: themeProvider.setFontScale,
                      ),
                    ),
                    IconButton(
                      onPressed: themeProvider.increaseFontScale,
                      icon: const Icon(Icons.add),
                      tooltip: 'Büyüt',
                    ),
                    IconButton(
                      onPressed: themeProvider.resetFontScale,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Sıfırla',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Firestore Service Test Section
  Widget _buildFirestoreServiceSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Firestore Service Test',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Firebase Firestore CRUD işlemlerini test etmek için comprehensive test ekranı. '
              'Create, Read, Update, Delete, Batch operations, Real-time listeners ve Query operations test edilebilir.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            // Test Features List
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildFeatureChip('CRUD Operations', Icons.edit, theme),
                _buildFeatureChip(
                  'Batch Operations',
                  Icons.library_books,
                  theme,
                ),
                _buildFeatureChip('Real-time Listeners', Icons.hearing, theme),
                _buildFeatureChip('Query Operations', Icons.search, theme),
                _buildFeatureChip('Error Handling', Icons.error_outline, theme),
                _buildFeatureChip('Debug Logging', Icons.terminal, theme),
              ],
            ),

            const SizedBox(height: 16),

            // Test Screen Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FirestoreServiceTest(),
                  ),
                ),
                icon: const Icon(Icons.science_rounded),
                label: const Text('Firestore Service Test Ekranı'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Firestore operations için comprehensive test araçları',
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

  /// Firebase Services Test Section
  Widget _buildFirebaseServicesTestSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_outlined,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Firebase Services Test',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Firebase Firestore ve Authentication servislerini comprehensive test etmek için '
              'production-ready test araçları. CRUD operations, Auth flows, real-time logging ve '
              'error handling validation içeren tam test suite.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            // Service Features List
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildFeatureChip('Firestore CRUD', Icons.storage, theme),
                _buildFeatureChip('Authentication', Icons.security, theme),
                _buildFeatureChip(
                  'Batch Operations',
                  Icons.dynamic_feed,
                  theme,
                ),
                _buildFeatureChip('Real-time Logging', Icons.list_alt, theme),
                _buildFeatureChip('Error Handling', Icons.error_outline, theme),
                _buildFeatureChip('Performance Test', Icons.speed, theme),
                _buildFeatureChip('User Management', Icons.person, theme),
                _buildFeatureChip('Data Validation', Icons.verified, theme),
              ],
            ),

            const SizedBox(height: 16),

            // Test Screen Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FirebaseServicesTestScreen(),
                  ),
                ),
                icon: const Icon(Icons.cloud_sync_rounded),
                label: const Text('Firebase Services Test Ekranı'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Production-ready Firebase entegrasyonu için comprehensive test suite',
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

  /// Models Test Section
  Widget _buildModelsTestSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.data_object_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Data Models Test',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Altertale uygulamasındaki tüm data modellerini test etmek için comprehensive test ekranı. '
              'UserModel, StoryModel, PurchaseModel, CommentModel, BookmarkModel ve NotificationModel '
              'serialization, helper methods ve factory constructor testleri.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            // Model Features List
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildFeatureChip('UserModel', Icons.person, theme),
                _buildFeatureChip('StoryModel', Icons.book, theme),
                _buildFeatureChip('PurchaseModel', Icons.payment, theme),
                _buildFeatureChip('CommentModel', Icons.comment, theme),
                _buildFeatureChip('BookmarkModel', Icons.bookmark, theme),
                _buildFeatureChip(
                  'NotificationModel',
                  Icons.notifications,
                  theme,
                ),
                _buildFeatureChip(
                  'Serialization Tests',
                  Icons.data_object,
                  theme,
                ),
                _buildFeatureChip('Helper Methods', Icons.functions, theme),
              ],
            ),

            const SizedBox(height: 16),

            // Test Screen Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ModelsTestScreen()),
                ),
                icon: const Icon(Icons.science_rounded),
                label: const Text('Data Models Test Ekranı'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  foregroundColor: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Production-ready model sınıfları için comprehensive test araçları',
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

  /// Best Practices Card
  Widget _buildBestPracticesCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Provider Best Practices',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Bu ekranda kullanılan provider patterns:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            ..._buildBestPracticesList(theme),
          ],
        ),
      ),
    );
  }

  /// Best practices list
  List<Widget> _buildBestPracticesList(ThemeData theme) {
    final practices = [
      '• context.watch<Provider>() - Widget rebuild için',
      '• context.read<Provider>() - Metod çağırma için',
      '• Consumer<Provider> - Selective rebuilding',
      '• Provider.of<Provider>(context, listen: false) - Alternative read',
      '• Async operations with proper error handling',
      '• State persistence with SharedPreferences',
      '• Disposed check before operations',
      '• FirestoreService - Generic CRUD operations',
    ];

    return practices.map((practice) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          practice,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }).toList();
  }

  /// Navigation Test Section
  Widget _buildNavigationTestSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.navigation_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Navigation Test',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      AppRouter.navigateTo(context, RouteNames.home),
                  icon: const Icon(Icons.home, size: 18),
                  label: const Text('Ana Sayfa'),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      AppRouter.navigateTo(context, RouteNames.profile),
                  icon: const Icon(Icons.person, size: 18),
                  label: const Text('Profil'),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      AppRouter.navigateTo(context, '/invalid-route'),
                  icon: const Icon(Icons.error, size: 18),
                  label: const Text('404 Test'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Theme mode button helper
  Widget _buildThemeModeButton(
    String label,
    IconData icon,
    ThemeMode mode,
    ThemeProvider themeProvider,
    ThemeData theme,
  ) {
    final isSelected = themeProvider.themeMode == mode;

    return OutlinedButton.icon(
      onPressed: () {
        switch (mode) {
          case ThemeMode.light:
            themeProvider.setLightTheme();
            break;
          case ThemeMode.dark:
            themeProvider.setDarkTheme();
            break;
          case ThemeMode.system:
            themeProvider.setSystemTheme();
            break;
        }
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 36),
        backgroundColor: isSelected ? theme.colorScheme.primaryContainer : null,
        foregroundColor: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : null,
      ),
    );
  }

  /// Feature Chip helper
  Widget _buildFeatureChip(String label, IconData icon, ThemeData theme) {
    return Chip(
      avatar: Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
      label: Text(label, style: theme.textTheme.bodySmall),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
    );
  }

  /// Info row helper
  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
