import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Navigation
import 'navigation/app_router.dart';
import 'navigation/route_names.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

// Test Screens
import 'screens/test/test_screen.dart';

/// State Management Demo Application
///
/// Production-ready state management with:
/// - MultiProvider architecture
/// - Theme management with persistence
/// - Authentication state management
/// - Scalable provider structure
/// - Firebase integration ready
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization would go here
  // await Firebase.initializeApp();

  runApp(const StateManagementDemoApp());
}

class StateManagementDemoApp extends StatelessWidget {
  const StateManagementDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ==================== CORE PROVIDERS ====================

        /// Theme Provider - Must be first for theme watching
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          lazy: false, // Initialize immediately for theme
        ),

        /// Auth Provider - Core authentication management
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
          lazy: false, // Initialize immediately for auth state
        ),

        // ==================== FEATURE PROVIDERS ====================
        // Future providers will be added here:
        // - BookProvider
        // - NotificationProvider
        // - SettingsProvider
        // - etc.
      ],

      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Altertale State Management Demo',
            debugShowCheckedModeBanner: false,

            // ==================== THEME CONFIGURATION ====================
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,

            // ==================== NAVIGATION CONFIGURATION ====================
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: '/', // Start with test screen
            // 404 fallback
            onUnknownRoute: (settings) => AppRouter.generateRoute(
              RouteSettings(
                name: RouteNames.notFound,
                arguments: settings.arguments,
              ),
            ),

            // ==================== ROOT WIDGET ====================
            home: const StateManagementHomePage(),
          );
        },
      ),
    );
  }
}

/// State Management Demo Home Page
/// Ana sayfa - tüm provider özelliklerini gösterir
class StateManagementHomePage extends StatelessWidget {
  const StateManagementHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Management Demo'),
        centerTitle: true,
        actions: [
          // Quick theme toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                onPressed: themeProvider.toggleTheme,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    key: ValueKey(themeProvider.isDarkMode),
                  ),
                ),
                tooltip: 'Tema Değiştir',
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            _buildWelcomeCard(context),

            const SizedBox(height: 16),

            // Provider Status Cards
            _buildProviderStatusCard(context),

            const SizedBox(height: 16),

            // Quick Actions
            _buildQuickActionsCard(context),

            const SizedBox(height: 16),

            // Navigation to Test Screen
            _buildNavigationCard(context),

            const SizedBox(height: 16),

            // System Info
            _buildSystemInfoCard(context),
          ],
        ),
      ),
    );
  }

  /// Welcome Card
  Widget _buildWelcomeCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.apps_rounded,
                size: 40,
                color: theme.colorScheme.onPrimary,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Altertale State Management',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Production-ready state management sistemi ile '
              'scalable ve maintainable Flutter uygulaması.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Provider Status Card
  Widget _buildProviderStatusCard(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
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
                      Icons.dashboard_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Provider Durumu',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Auth Provider Status
                _buildProviderStatusRow(
                  'Auth Provider',
                  authProvider.isInitialized,
                  authProvider.isLoading,
                  theme,
                  subtitle: authProvider.isLoggedIn
                      ? 'Giriş: ${authProvider.email}'
                      : 'Giriş yapılmamış',
                ),

                const SizedBox(height: 8),

                // Theme Provider Status
                _buildProviderStatusRow(
                  'Theme Provider',
                  themeProvider.isInitialized,
                  false,
                  theme,
                  subtitle:
                      '${themeProvider.currentThemeModeDisplayName} - ${themeProvider.currentColorSchemeDisplayName}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Provider Status Row
  Widget _buildProviderStatusRow(
    String name,
    bool isInitialized,
    bool isLoading,
    ThemeData theme, {
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isInitialized
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            borderRadius: BorderRadius.circular(6),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (isLoading) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              if (subtitle != null)
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),

        Icon(
          isInitialized ? Icons.check_circle : Icons.pending,
          size: 20,
          color: isInitialized
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
      ],
    );
  }

  /// Quick Actions Card
  Widget _buildQuickActionsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Hızlı İşlemler',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Consumer2<AuthProvider, ThemeProvider>(
              builder: (context, authProvider, themeProvider, child) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Theme actions
                    _buildQuickActionChip(
                      'Açık Tema',
                      Icons.light_mode,
                      () => themeProvider.setLightTheme(),
                      theme,
                      isSelected: themeProvider.themeMode == ThemeMode.light,
                    ),
                    _buildQuickActionChip(
                      'Koyu Tema',
                      Icons.dark_mode,
                      () => themeProvider.setDarkTheme(),
                      theme,
                      isSelected: themeProvider.themeMode == ThemeMode.dark,
                    ),
                    _buildQuickActionChip(
                      'Sistem',
                      Icons.brightness_auto,
                      () => themeProvider.setSystemTheme(),
                      theme,
                      isSelected: themeProvider.themeMode == ThemeMode.system,
                    ),

                    // Auth actions
                    if (!authProvider.isLoggedIn) ...[
                      _buildQuickActionChip(
                        'Giriş Yap',
                        Icons.login,
                        () => AppRouter.navigateTo(context, RouteNames.login),
                        theme,
                      ),
                    ] else ...[
                      _buildQuickActionChip(
                        'Çıkış Yap',
                        Icons.logout,
                        () => authProvider.signOut(),
                        theme,
                        isDestructive: true,
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Quick Action Chip
  Widget _buildQuickActionChip(
    String label,
    IconData icon,
    VoidCallback onTap,
    ThemeData theme, {
    bool isSelected = false,
    bool isDestructive = false,
  }) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(
        icon,
        size: 18,
        color: isDestructive
            ? theme.colorScheme.error
            : isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
      ),
      label: Text(label),
      backgroundColor: isSelected ? theme.colorScheme.primaryContainer : null,
      labelStyle: TextStyle(
        color: isDestructive
            ? theme.colorScheme.error
            : isSelected
            ? theme.colorScheme.onPrimaryContainer
            : null,
      ),
    );
  }

  /// Navigation Card
  Widget _buildNavigationCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.explore_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Test Ekranları',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TestScreen()),
                ),
                icon: const Icon(Icons.science_rounded),
                label: const Text('Provider Test Ekranı'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Detaylı provider kullanım örnekleri ve test araçları',
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

  /// System Info Card
  Widget _buildSystemInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Sistem Bilgisi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                final brightness = MediaQuery.of(context).platformBrightness;

                return Column(
                  children: [
                    _buildSystemInfoRow(
                      'Flutter',
                      'State Management Demo',
                      theme,
                    ),
                    _buildSystemInfoRow(
                      'Provider',
                      'MultiProvider Architecture',
                      theme,
                    ),
                    _buildSystemInfoRow(
                      'Theme',
                      themeProvider.currentThemeModeDisplayName,
                      theme,
                    ),
                    _buildSystemInfoRow(
                      'Platform Theme',
                      brightness.name.toUpperCase(),
                      theme,
                    ),
                    _buildSystemInfoRow('Material', 'Material Design 3', theme),
                    _buildSystemInfoRow('Font', 'Inter Font Family', theme),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// System Info Row
  Widget _buildSystemInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
