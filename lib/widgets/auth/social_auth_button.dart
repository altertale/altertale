import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';

/// Sosyal medya ile giriş butonları için widget
/// Google, Apple gibi sosyal giriş yöntemleri için
class SocialAuthButton extends StatelessWidget {
  final String text;
  final String? icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final bool isLoading;
  final double height;
  final double borderRadius;

  const SocialAuthButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.borderColor = AppColors.border,
    this.isLoading = false,
    this.height = 50,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(
            color: borderColor,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon
            if (icon != null) ...[
              _buildIcon(),
              const SizedBox(width: 12),
            ],
            
            // Yükleme İndikatörü veya Metin
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            else
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// İkon widget'ını oluşturur
  Widget _buildIcon() {
    if (icon == null) return const SizedBox.shrink();
    
    // SVG dosyası ise
    if (icon!.endsWith('.svg')) {
      return SvgPicture.asset(
        icon!,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
      );
    }
    
    // PNG/JPG dosyası ise
    return Image.asset(
      icon!,
      width: 24,
      height: 24,
      color: textColor,
    );
  }
}

/// Google ile giriş butonu
class GoogleAuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleAuthButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SocialAuthButton(
      text: 'Google ile devam et',
      icon: 'assets/icons/google.svg',
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      borderColor: AppColors.border,
    );
  }
}

/// Apple ile giriş butonu
class AppleAuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppleAuthButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SocialAuthButton(
      text: 'Apple ile devam et',
      icon: 'assets/icons/apple.svg',
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      borderColor: Colors.black,
    );
  }
} 