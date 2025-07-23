import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';

/// E-posta doğrulama ekranı
/// Kullanıcının e-posta adresini doğrulamasını bekler
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _isLoading = false;
  bool _canResendEmail = true;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// E-posta doğrulama durumunu kontrol eder
  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerification();
    });
  }

  /// E-posta doğrulama durumunu kontrol eder
  Future<void> _checkEmailVerification() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.reloadEmailVerification();
    
    if (authProvider.isEmailVerified) {
      _timer?.cancel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('E-posta doğrulandı! Hoş geldiniz!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// E-posta doğrulama e-postasını yeniden gönderir
  Future<void> _resendVerificationEmail() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.sendEmailVerification();

      if (success && mounted) {
        setState(() {
          _canResendEmail = false;
          _resendCooldown = 60; // 60 saniye bekleme süresi
        });

        // Geri sayım başlat
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _resendCooldown--;
            });
            
            if (_resendCooldown <= 0) {
              setState(() {
                _canResendEmail = true;
              });
              timer.cancel();
            }
          } else {
            timer.cancel();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Doğrulama e-postası yeniden gönderildi'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Çıkış yapar
  Future<void> _signOut() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış hatası: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Hata mesajını göster
    if (authProvider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        authProvider.clearError();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // İkon ve Başlık
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.mark_email_unread,
                        size: 50,
                        color: AppColors.textInverse,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'E-posta Adresinizi Doğrulayın',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimaryColor(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hesabınızı aktifleştirmek için e-posta adresinizi doğrulamanız gerekiyor.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.getTextSecondaryColor(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // E-posta Bilgisi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.getTextTertiaryColor(isDark).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.email,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        authProvider.firebaseUser?.email ?? 'E-posta adresi bulunamadı',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimaryColor(isDark),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Adımlar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.getTextTertiaryColor(isDark).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doğrulama Adımları:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimaryColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStep(
                        number: 1,
                        text: 'E-posta kutunuzu kontrol edin',
                        isDark: isDark,
                      ),
                      _buildStep(
                        number: 2,
                        text: 'Doğrulama bağlantısına tıklayın',
                        isDark: isDark,
                      ),
                      _buildStep(
                        number: 3,
                        text: 'Bu sayfaya geri dönün',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Butonlar
                Column(
                  children: [
                    // Yeniden Gönder Butonu
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (_isLoading || !_canResendEmail) ? null : _resendVerificationEmail,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.textInverse,
                                  ),
                                ),
                              )
                            : Text(
                                _canResendEmail
                                    ? 'E-postayı Yeniden Gönder'
                                    : 'Yeniden Gönder ($_resendCooldown)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Çıkış Yap Butonu
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _signOut,
                        child: const Text(
                          'Çıkış Yap',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Bilgi Metni
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'E-posta doğrulandıktan sonra otomatik olarak ana sayfaya yönlendirileceksiniz.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.getTextSecondaryColor(isDark),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Adım widget'ını oluşturur
  Widget _buildStep({
    required int number,
    required String text,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: AppColors.textInverse,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 