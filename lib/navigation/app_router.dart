import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Import all screens
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/book_detail_screen.dart';
import '../screens/books/books_list_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/orders/order_screen.dart';
import '../screens/feed_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/library/library_screen.dart'; // Fixed path

// Import auth provider
import '../providers/auth_provider.dart';

/// App Router Configuration
///
/// GoRouter kullanarak uygulamanın tüm navigasyon sistemini yönetir.
/// Route'lar, parametre geçişleri ve Firebase Auth state navigation logic'i içerir.
class AppRouter {
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  // Route paths
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String books = '/books';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String book = '/book';
  static const String bookDetail = '/book/:bookId';
  static const String feed = '/feed';
  static const String settings = '/settings';
  static const String library = '/library'; // Added library route path

  /// Create GoRouter with auth state management
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: splash,
      debugLogDiagnostics: true,
      refreshListenable: authProvider,
      redirect: (context, state) =>
          _handleRedirect(context, state, authProvider),
      routes: [
        // Splash Screen - Ana başlangıç ekranı
        GoRoute(
          path: splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Onboarding Screen - Uygulama tanıtımı
        GoRoute(
          path: onboarding,
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),

        // Authentication Screens
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

        // Main App Screens (Protected)
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: books,
          name: 'books',
          builder: (context, state) {
            final category = state.uri.queryParameters['category'];
            return BooksListScreen(category: category);
          },
        ),
        GoRoute(
          path: cart,
          name: 'cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: orders,
          name: 'orders',
          builder: (context, state) => const OrderScreen(),
        ),
        GoRoute(
          path: profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/library',
          name: 'library',
          builder: (context, state) => const LibraryScreen(),
        ),
        GoRoute(
          path: feed,
          name: 'feed',
          builder: (context, state) => const FeedScreen(),
        ),
        GoRoute(
          path: settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),

        // Book Detail Screen with parameter
        GoRoute(
          path: bookDetail,
          name: 'book-detail',
          builder: (context, state) {
            final bookId = state.pathParameters['bookId'] ?? '1';
            return BookDetailScreen(bookId: bookId);
          },
        ),
      ],

      // Error handling
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Sayfa Bulunamadı',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Aradığınız sayfa mevcut değil: ${state.uri.path}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(home),
                child: const Text('Ana Sayfaya Dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle authentication-based redirects
  static String? _handleRedirect(
    BuildContext context,
    GoRouterState state,
    AuthProvider authProvider,
  ) {
    final isLoggedIn = authProvider.isLoggedIn;
    final isInitialized = authProvider.isInitialized;
    final currentLocation = state.uri.path;

    // Don't redirect while auth state is still initializing
    if (!isInitialized) {
      return null;
    }

    // Define protected and public routes
    final protectedRoutes = [
      home,
      books,
      cart,
      orders,
      profile,
      feed,
      settings,
      library, // Added library to protected routes
    ];
    final publicRoutes = [splash, onboarding, login, register];
    final authRoutes = [login, register];

    // Check if current route is protected
    final isProtectedRoute = protectedRoutes.any(
      (route) =>
          currentLocation.startsWith(route) ||
          currentLocation.startsWith('/book/'), // Book detail is also protected
    );

    // Check if current route is auth-related
    final isAuthRoute = authRoutes.contains(currentLocation);

    // Redirect logic
    if (!isLoggedIn && isProtectedRoute) {
      // User not logged in but trying to access protected route
      return login;
    }

    if (isLoggedIn && isAuthRoute) {
      // User logged in but on auth screen, redirect to home
      return home;
    }

    if (isLoggedIn && currentLocation == splash) {
      // User logged in and on splash, go to home
      return home;
    }

    if (!isLoggedIn && currentLocation == splash) {
      // User not logged in and on splash, go to onboarding
      return onboarding;
    }

    // No redirect needed
    return null;
  }

  // Navigation helper methods (kept for backward compatibility)
  static void goToSplash(BuildContext context) {
    context.go(splash);
  }

  static void goToOnboarding(BuildContext context) {
    context.go(onboarding);
  }

  static void goToLogin(BuildContext context) {
    context.go(login);
  }

  static void goToRegister(BuildContext context) {
    context.go(register);
  }

  static void goToHome(BuildContext context) {
    context.go(home);
  }

  static void goToBooks(BuildContext context, {String? category}) {
    final uri = category != null ? '$books?category=$category' : books;
    context.go(uri);
  }

  static void goToCart(BuildContext context) {
    context.go(cart);
  }

  static void goToOrders(BuildContext context) {
    context.go(orders);
  }

  static void goToProfile(BuildContext context) {
    context.go(profile);
  }

  static void goToBookDetail(BuildContext context, String bookId) {
    context.go('/book/$bookId');
  }

  static void goToFeed(BuildContext context) {
    context.go(feed);
  }

  static void goToSettings(BuildContext context) {
    context.go(settings);
  }

  static void goToLibrary(BuildContext context) {
    context.go(library);
  }

  // Navigation with replacement (no back button)
  static void replaceWithHome(BuildContext context) {
    context.pushReplacement(home);
  }

  static void replaceWithLogin(BuildContext context) {
    context.pushReplacement(login);
  }

  // Check if can pop (has back navigation)
  static bool canPop(BuildContext context) {
    return GoRouter.of(context).canPop();
  }

  // Pop current route
  static void pop(BuildContext context) {
    if (canPop(context)) {
      context.pop();
    } else {
      goToHome(context);
    }
  }

  // Get current route name
  static String getCurrentRoute(BuildContext context) {
    final RouteMatch lastMatch = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : GoRouter.of(context).routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  // Check if current route is specific path
  static bool isCurrentRoute(BuildContext context, String routePath) {
    return getCurrentRoute(context) == routePath;
  }
}

/// Navigation Extensions for easier usage
extension NavigationExtensions on BuildContext {
  /// Go to splash screen
  void goToSplash() => AppRouter.goToSplash(this);

  /// Go to onboarding screen
  void goToOnboarding() => AppRouter.goToOnboarding(this);

  /// Go to login screen
  void goToLogin() => AppRouter.goToLogin(this);

  /// Go to register screen
  void goToRegister() => AppRouter.goToRegister(this);

  /// Go to home screen
  void goToHome() => AppRouter.goToHome(this);

  /// Go to books screen
  void goToBooks({String? category}) =>
      AppRouter.goToBooks(this, category: category);

  /// Go to cart screen
  void goToCart() => AppRouter.goToCart(this);

  /// Go to orders screen
  void goToOrders() => AppRouter.goToOrders(this);

  /// Go to profile screen
  void goToProfile() => AppRouter.goToProfile(this);

  /// Go to book detail screen
  void goToBookDetail(String bookId) => AppRouter.goToBookDetail(this, bookId);

  /// Go to feed screen
  void goToFeed() => AppRouter.goToFeed(this);

  /// Go to settings screen
  void goToSettings() => AppRouter.goToSettings(this);

  /// Go to library screen
  void goToLibrary() => AppRouter.goToLibrary(this);

  /// Replace current route with home
  void replaceWithHome() => AppRouter.replaceWithHome(this);

  /// Replace current route with login
  void replaceWithLogin() => AppRouter.replaceWithLogin(this);

  /// Check if can pop
  bool canPopRoute() => AppRouter.canPop(this);

  /// Pop current route
  void popRoute() => AppRouter.pop(this);

  /// Get current route
  String getCurrentRoute() => AppRouter.getCurrentRoute(this);

  /// Check if current route matches path
  bool isCurrentRoute(String routePath) =>
      AppRouter.isCurrentRoute(this, routePath);
}
