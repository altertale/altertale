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
import 'providers/rating_provider.dart';
import 'utils/auth_wrapper.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/my_books/my_books_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/books/reader_screen.dart';
import 'models/book.dart';
// Temporarily removing problematic imports
// import 'screens/books/books_list_screen.dart';
// import 'screens/books/book_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling for demo mode
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed (running in demo mode): $e');
    // Continue without Firebase for demo purposes
  }

  runApp(const AlterTaleApp());
}

/// AlterTale - Ana Uygulama
///
/// Production-ready state management with:
/// - MultiProvider architecture
/// - Theme management with persistence
/// - Authentication state management
/// - Firebase integration
/// - Complete navigation system
class AlterTaleApp extends StatelessWidget {
  const AlterTaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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

        /// Book Provider - Book data management
        ChangeNotifierProvider(
          create: (context) => BookProvider(),
          lazy: false, // Initialize immediately for book data
        ),

        /// Favorites Provider - Favorites data management
        ChangeNotifierProvider(
          create: (context) => FavoritesProvider(),
          lazy: false, // Initialize immediately for favorites data
        ),

        /// Cart Provider - Cart data management
        ChangeNotifierProvider(
          create: (context) => CartProvider(),
          lazy: false, // Initialize immediately for cart data
        ),

        /// MyBooks Provider - Purchased books and reading history management
        ChangeNotifierProvider(
          create: (context) => MyBooksProvider(),
          lazy: false, // Initialize immediately for MyBooks data
        ),

        /// Rating Provider - Book rating and review management
        ChangeNotifierProvider(
          create: (context) => RatingProvider(),
          lazy: false, // Initialize immediately for rating data
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'AlterTale',
            debugShowCheckedModeBanner: false,

            // Theme Configuration
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,

            // Main entry point with authentication wrapper
            home: const AuthWrapper(),

            // Route configuration
            routes: {
              '/cart': (context) => const CartScreen(),
              '/checkout': (context) => const CheckoutScreen(),
              '/orders': (context) => const OrdersScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/library': (context) => const LibraryScreen(),
              '/explore': (context) => const ExploreScreen(),
              '/register': (context) => const RegisterScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/my-books': (context) => const MyBooksScreen(),
              '/books': (context) => const ExploreScreen(),
              '/book-detail': (context) => BookDetailScreen(
                bookId: ModalRoute.of(context)!.settings.arguments as String,
              ),
              '/reader': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments
                        as Map<String, dynamic>;
                return ReaderScreen(
                  bookId: args['bookId'] as String,
                  book: args['book'] as Book?,
                );
              },
            },

            // Handle dynamic routes
            onGenerateRoute: (settings) {
              if (settings.name?.startsWith('/book/') == true) {
                final bookId = settings.name!.split('/book/')[1];
                return MaterialPageRoute(
                  builder: (context) => BookDetailScreen(bookId: bookId),
                  settings: settings,
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
