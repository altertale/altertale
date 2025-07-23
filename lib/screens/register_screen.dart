import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../providers/auth_provider.dart';

/// Register Screen - Kayıt Ekranı
///
/// Firebase Authentication kullanarak yeni kullanıcıların
/// hesap oluşturabileceği ekran.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanım koşullarını kabul etmelisiniz')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.registerWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );

    if (success && mounted) {
      // Show success dialog
      _showSuccessDialog();
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const TitleText('Başarılı!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SubtitleText('Hesabınız başarıyla oluşturuldu!'),
            const SizedBox(height: 12),
            RoundedCard(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      SubtitleText(
                        'Email Doğrulama',
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SubtitleText(
                    'Email adresinize doğrulama bağlantısı gönderildi. '
                    'Hesabınızı aktifleştirmek için emailinizdeki bağlantıya tıklayın.',
                    size: SubtitleSize.small,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          CustomButton(
            text: 'Giriş Yap',
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  void _goToLogin() {
    context.go('/login');
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad soyad gerekli';
    }
    if (value.length < 2) {
      return 'Ad soyad en az 2 karakter olmalı';
    }
    return null;
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

    // Use AuthProvider validation
    if (!AuthProvider.isValidPassword(value)) {
      return AuthProvider.getPasswordStrengthMessage(value);
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }
    if (value != _passwordController.text) {
      return 'Şifreler eşleşmiyor';
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
              const SizedBox(height: 20),

              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add,
                        size: 40,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TitleText(
                      'Hesap Oluştur',
                      size: TitleSize.headline,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    const SubtitleText(
                      'Altertale\'e katılın ve hikayeler dünyasını keşfedin',
                      size: SubtitleSize.medium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Register Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Ad Soyad',
                      hintText: 'Adınızı ve soyadınızı girin',
                      prefixIcon: Icons.person_outlined,
                      validator: _validateName,
                    ),

                    const SizedBox(height: 16),

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
                      hintText: 'Güçlü bir şifre oluşturun',
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
                      helperText:
                          'En az 6 karakter, 1 büyük harf, 1 küçük harf, 1 rakam',
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password Field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Şifre Tekrar',
                      hintText: 'Şifrenizi tekrar girin',
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixIconPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      validator: _validateConfirmPassword,
                    ),

                    const SizedBox(height: 24),

                    // Terms and Conditions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return Checkbox(
                              value: _acceptTerms,
                              onChanged: authProvider.isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _acceptTerms = value ?? false;
                                      });
                                    },
                            );
                          },
                        ),
                        Expanded(
                          child: Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return GestureDetector(
                                onTap: authProvider.isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _acceptTerms = !_acceptTerms;
                                        });
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: RichText(
                                    text: TextSpan(
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                      children: [
                                        const TextSpan(
                                          text: 'Kabul ediyorum: ',
                                        ),
                                        TextSpan(
                                          text: 'Kullanım Koşulları',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                        const TextSpan(text: ' ve '),
                                        TextSpan(
                                          text: 'Gizlilik Politikası',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Register Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return CustomButton(
                          text: 'Hesap Oluştur',
                          onPressed: authProvider.isLoading
                              ? null
                              : _handleRegister,
                          isLoading: authProvider.isLoading,
                          width: double.infinity,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SubtitleText(
                    'Zaten hesabınız var mı? ',
                    color: colorScheme.onSurfaceVariant,
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return GestureDetector(
                        onTap: authProvider.isLoading ? null : _goToLogin,
                        child: SubtitleText(
                          'Giriş Yap',
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Back to Onboarding
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return TextButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () {
                            context.go('/onboarding');
                          },
                    child: SubtitleText(
                      'Geri Dön',
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Firebase Info Card
              RoundedCard(
                backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security_outlined,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        SubtitleText(
                          'Güvenli Kayıt',
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SubtitleText(
                      'Hesabınız Firebase Authentication ile güvenli şekilde oluşturulur. '
                      'Email doğrulama ile hesabınızı aktifleştirin.',
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
