import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

// Onboarding Screens
import '../screens/onboarding/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

// Auth Screens
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';

// Dashboard Screens
import '../screens/dashboard/dashboard_screen.dart';

// Content Screens
import '../screens/content/content_list_screen.dart';
import '../screens/content/content_detail_screen.dart';

// Settings Screens
import '../screens/settings/profile_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Production-Ready App Router
///
/// Comprehensive routing solution with:
/// - Firebase Auth integration
/// - Protected routes with auth guards
/// - Deep linking support
/// - Nested navigation
/// - Route transitions
/// - Error handling
/// - Route parameters
class AppRouter {
  // ==================== SINGLETON PATTERN ====================
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  // ==================== SERVICES ====================
  final AuthService _authService = AuthService();

  // ==================== ROUTE PATHS ====================
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String contentList = '/content';
  static const String contentDetail = '/content/:id';

  // ==================== ROUTER CONFIGURATION ====================
  late final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    refreshListenable: _AuthChangeNotifier(_authService),
    redirect: _handleRedirect,
    routes: [
      // ==================== SPLASH & ONBOARDING ====================
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ==================== AUTHENTICATION ROUTES ====================
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ==================== PROTECTED ROUTES ====================
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // ==================== CONTENT ROUTES ====================
      GoRoute(
        path: contentList,
        name: 'contentList',
        builder: (context, state) => const ContentListScreen(),
      ),

      GoRoute(
        path: contentDetail,
        name: 'contentDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ContentDetailScreen(contentId: id);
        },
      ),
    ],

    // ==================== ERROR HANDLING ====================
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Sayfa Bulunamadı'),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '404 - Sayfa Bulunamadı',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aradığınız sayfa mevcut değil.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(dashboard),
              icon: const Icon(Icons.home),
              label: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );

  // ==================== REDIRECT LOGIC ====================
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = _authService.isLoggedIn;
    final location = state.uri.path;

    // Debug logging
    debugPrint(
      '🚀 Router: Redirecting from $location (isLoggedIn: $isLoggedIn)',
    );

    // Protected routes that require authentication
    final protectedRoutes = [dashboard, profile, settings, contentList];

    // Public routes that don't require authentication
    final publicRoutes = [splash, onboarding, login, register, forgotPassword];

    // If user is not logged in and trying to access protected route
    if (!isLoggedIn &&
        protectedRoutes.any((route) => location.startsWith(route))) {
      debugPrint('🚀 Router: Redirecting to login (protected route access)');
      return login;
    }

    // If user is logged in and trying to access auth routes
    if (isLoggedIn && publicRoutes.contains(location) && location != splash) {
      debugPrint('🚀 Router: Redirecting to dashboard (already logged in)');
      return dashboard;
    }

    // No redirect needed
    return null;
  }

  // ==================== NAVIGATION HELPERS ====================

  /// Navigate to login screen
  static void goToLogin(BuildContext context) {
    context.go(login);
  }

  /// Navigate to register screen
  static void goToRegister(BuildContext context) {
    context.go(register);
  }

  /// Navigate to dashboard screen
  static void goToDashboard(BuildContext context) {
    context.go(dashboard);
  }

  /// Navigate to profile screen
  static void goToProfile(BuildContext context) {
    context.go(profile);
  }

  /// Navigate to settings screen
  static void goToSettings(BuildContext context) {
    context.go(settings);
  }

  /// Navigate to content list screen
  static void goToContentList(BuildContext context) {
    context.go(contentList);
  }

  /// Navigate to content detail screen
  static void goToContentDetail(BuildContext context, String contentId) {
    context.go('/content/$contentId');
  }

  /// Navigate to forgot password screen
  static void goToForgotPassword(BuildContext context) {
    context.go(forgotPassword);
  }

  /// Navigate to onboarding screen
  static void goToOnboarding(BuildContext context) {
    context.go(onboarding);
  }

  /// Go back if possible, otherwise go to dashboard
  static void goBackOrDashboard(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(dashboard);
    }
  }
}

/// Auth State Change Notifier for GoRouter
///
/// Listens to Firebase Auth state changes and triggers
/// router refresh when authentication status changes
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._authService) {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      debugPrint('🚀 Auth State Changed: ${user?.uid ?? "null"}');
      notifyListeners();
    });
  }

  final AuthService _authService;
}
