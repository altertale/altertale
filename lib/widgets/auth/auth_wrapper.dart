import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/home_screen.dart';

/// Simple Auth Wrapper Widget
/// Can be used within other screens to wrap content that requires authentication
class AuthWrapper extends StatelessWidget {
  final Widget child;
  final Widget? loginWidget;
  final String? loginMessage;

  const AuthWrapper({
    super.key,
    required this.child,
    this.loginWidget,
    this.loginMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoggedIn) {
          return child;
        } else {
          return loginWidget ?? _buildDefaultLoginPrompt(context);
        }
      },
    );
  }

  Widget _buildDefaultLoginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              loginMessage ?? 'Bu özelliği kullanmak için giriş yapmalısınız.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full Screen Auth Wrapper
/// Redirects to full screen auth when not logged in
class FullScreenAuthWrapper extends StatelessWidget {
  final Widget child;

  const FullScreenAuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoggedIn) {
          return child;
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
