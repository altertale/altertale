import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../providers/auth_provider.dart';

/// Login Screen - Giriş Ekranı
///
/// Firebase Authentication kullanarak kullanıcıların
/// giriş yapabileceği ekran.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Navigate to home on successful login
      Navigator.of(context).pushReplacementNamed('/');
    } else if (mounted && authProvider.error != null) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce email adresinizi girin')),
      );
      return;
    }

    if (!AuthProvider.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir email adresi girin')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.sendPasswordResetEmail(email);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Şifre sıfırlama emaili $email adresine gönderildi'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted && authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _goToRegister() {
    Navigator.of(context).pushNamed('/register');
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email adresi gerekli';
    }
    if (!AuthProvider.isValidEmail(value)) {
      return 'Geçerli bir email adresi girin';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Logo/App Name
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_stories,
                        size: 40,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TitleText(
                      'Altertale',
                      size: TitleSize.headline,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    const SubtitleText(
                      'Hesabınıza giriş yapın',
                      size: SubtitleSize.large,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Email adresinizi girin',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: _validateEmail,
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Şifre',
                      hintText: 'Şifrenizi girin',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixIconPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: _validatePassword,
                      onSubmitted: (_) => _handleLogin(),
                    ),

                    const SizedBox(height: 8),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return TextButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : _handleForgotPassword,
                            child: SubtitleText(
                              'Şifremi Unuttum',
                              color: colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return CustomButton(
                          text: 'Giriş Yap',
                          onPressed: authProvider.isLoading
                              ? null
                              : _handleLogin,
                          isLoading: authProvider.isLoading,
                          width: double.infinity,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(color: colorScheme.outline.withOpacity(0.5)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SubtitleText(
                      'veya',
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Divider(color: colorScheme.outline.withOpacity(0.5)),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Register Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return CustomButton(
                    text: 'Hesap Oluştur',
                    isPrimary: false,
                    onPressed: authProvider.isLoading ? null : _goToRegister,
                    width: double.infinity,
                  );
                },
              ),

              const SizedBox(height: 20),

              // Back to Onboarding
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return TextButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () {
                            Navigator.of(context).pushReplacementNamed('/');
                          },
                    child: SubtitleText(
                      'Geri Dön',
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Quick Test Info Card
              RoundedCard(
                backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        SubtitleText(
                          'Test İçin',
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SubtitleText(
                      'Firebase Authentication ile gerçek giriş sistemi kullanılıyor. '
                      'Yeni hesap oluşturarak veya mevcut hesabınızla giriş yapabilirsiniz.',
                      size: SubtitleSize.small,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
