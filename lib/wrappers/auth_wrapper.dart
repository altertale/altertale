import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Services
import '../services/auth_service.dart';

// Providers
import '../providers/auth_provider.dart' as app_provider;

// Screens
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';

/// Authentication Wrapper
/// Kullanıcının giriş durumuna göre otomatik yönlendirme yapar
/// StreamBuilder ile Firebase Auth durumunu dinler
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      // Firebase Auth state stream'ini dinle
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Connection durumuna göre widget döndür
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            // Stream aktif, kullanıcı durumunu kontrol et
            final user = snapshot.data;

            if (user == null) {
              // Kullanıcı giriş yapmamış
              return const LoginScreen();
            } else {
              // Kullanıcı giriş yapmış, Provider'ı güncelle
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final authProvider = context.read<app_provider.AuthProvider>();
                // Provider'a mevcut kullanıcıyı bildir
                if (authProvider.currentUser?.uid != user.uid) {
                  authProvider.refreshUserModel();
                }
              });

              return const HomeScreen();
            }

          case ConnectionState.waiting:
            // Stream henüz başlamadı
            return const AuthLoadingScreen();

          case ConnectionState.none:
            // Stream bağlantısı yok
            return const AuthErrorScreen(error: 'Bağlantı hatası oluştu');

          case ConnectionState.done:
            // Stream tamamlandı (bu durum normal değil)
            return const AuthErrorScreen(
              error: 'Kimlik doğrulama servisi beklenmedik şekilde kapandı',
            );
        }
      },
    );
  }
}

/// Auth Loading Screen
/// StreamBuilder beklerken gösterilir
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
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.book_rounded,
                size: 50,
                color: theme.colorScheme.onPrimary,
              ),
            ),

            const SizedBox(height: 32),

            // Uygulama adı
            Text(
              'Altertale',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            // Loading indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Loading mesajı
            Text(
              'Kimlik doğrulama kontrol ediliyor...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Auth Error Screen
/// Stream bağlantı hatası durumunda gösterilir
class AuthErrorScreen extends StatelessWidget {
  final String error;

  const AuthErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error ikonu
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),

              const SizedBox(height: 32),

              // Başlık
              Text(
                'Bağlantı Hatası',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Hata mesajı
              Text(
                error,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Tekrar dene butonu
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _restartApp(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Tekrar Dene',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Manuel giriş butonu
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _goToLogin(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text(
                    'Manuel Giriş',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Uygulamayı yeniden başlat
  void _restartApp(BuildContext context) {
    // Phoenix veya restart_app package kullanılabilir
    // Şimdilik login sayfasına yönlendiriyoruz
    _goToLogin(context);
  }

  /// Login sayfasına git
  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
