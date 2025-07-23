import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart'; // Use the full-featured HomeScreen

/// Authentication Wrapper
/// Kullanıcının giriş durumuna göre otomatik yönlendirme yapar
/// Ana uygulama başlangıcında çalışır
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isCheckingRememberedLogin = true;

  @override
  void initState() {
    super.initState();
    _checkRememberedLogin();
  }

  Future<void> _checkRememberedLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (rememberMe) {
        final savedEmail = prefs.getString('saved_email');
        final savedPassword = prefs.getString('saved_password');

        if (savedEmail != null && savedPassword != null) {
          final authProvider = context.read<AuthProvider>();
          try {
            await authProvider.signInWithEmail(
              email: savedEmail,
              password: savedPassword,
            );
          } catch (e) {
            // If auto-login fails, remove saved credentials
            await prefs.remove('remember_me');
            await prefs.remove('saved_email');
            await prefs.remove('saved_password');
          }
        }
      }
    } catch (e) {
      // Handle any errors silently
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingRememberedLogin = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while checking remembered login or auth provider is initializing
        if (_isCheckingRememberedLogin || !authProvider.isInitialized) {
          return const AuthLoadingScreen();
        }

        // Kullanıcı giriş yapmışsa ana sayfa, yapmamışsa giriş sayfası
        if (authProvider.isLoggedIn) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

/// Authentication loading ekranı
/// Provider başlatılırken gösterilir
class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.auto_stories,
                size: 40,
                color: theme.colorScheme.onPrimary,
              ),
            ),

            const SizedBox(height: 24),

            // App Name
            Text(
              'AlterTale',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Alternatif Hikayeler Dünyası',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 40),

            // Loading Indicator
            CircularProgressIndicator(color: theme.colorScheme.primary),

            const SizedBox(height: 16),

            Text(
              'Yükleniyor...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
