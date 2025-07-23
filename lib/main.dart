import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/book_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/mybooks_provider.dart';
import 'providers/user_stats_provider.dart';
import 'providers/reading_settings_provider.dart';
import 'services/sync_manager_service.dart';
import 'utils/auth_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/my_books/my_books_screen.dart';
import 'screens/books/reader_screen.dart';
import 'screens/books/reading_screen.dart';
import 'screens/books/simple_book_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling for demo mode
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization failed (running in demo mode): $e');
    // Continue without Firebase for demo purposes
  }

  // Initialize sync manager
  try {
    await SyncManagerService().init();
    print('✅ SyncManager initialized successfully');
  } catch (e) {
    print('⚠️ SyncManager initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => MyBooksProvider()),
        ChangeNotifierProvider(create: (_) => UserStatsProvider()),
        ChangeNotifierProvider(create: (_) => ReadingSettingsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'AlterTale',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/explore': (context) => const ExploreScreen(),
              '/library': (context) => const LibraryScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/cart': (context) => const CartScreen(),
              '/checkout': (context) => const CheckoutScreen(),
              '/orders': (context) => const OrdersScreen(),
              '/my-books': (context) => const MyBooksScreen(),
            },
            onGenerateRoute: (settings) {
              // Handle dynamic routes

              // Handle book detail route: /book/{bookId}
              if (settings.name?.startsWith('/book/') == true) {
                final bookId = settings.name!.split('/book/')[1];
                if (bookId.isNotEmpty) {
                  return MaterialPageRoute(
                    builder: (context) =>
                        SimpleBookDetailScreen(bookId: bookId),
                  );
                }
              }

              if (settings.name == '/book-detail') {
                final book = settings.arguments as Map<String, dynamic>?;
                if (book != null) {
                  return MaterialPageRoute(
                    builder: (context) =>
                        SimpleBookDetailScreen(bookId: book['id']),
                  );
                }
              }

              if (settings.name == '/reader') {
                final args = settings.arguments as Map<String, dynamic>?;
                if (args != null && args['bookId'] != null) {
                  return MaterialPageRoute(
                    builder: (context) => ReaderScreen(bookId: args['bookId']),
                  );
                }
              }

              if (settings.name == '/reading') {
                final args = settings.arguments as Map<String, dynamic>?;
                if (args != null && args['book'] != null) {
                  return MaterialPageRoute(
                    builder: (context) => ReadingScreen(
                      book: args['book'],
                      pages: args['pages'] ?? [],
                    ),
                  );
                }
              }

              // Default route
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Sayfa Bulunamadı')),
                  body: const Center(child: Text('Bu sayfa bulunamadı.')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
