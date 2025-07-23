import 'package:flutter/material.dart';

/// Custom Button Widget - Altertale Uygulaması için Temaya Uyumlu Buton
///
/// Bu widget, uygulamanın tüm ekranlarında tutarlı buton deneyimi sağlar.
/// Primary ve secondary varyantları ile farklı kullanım senaryolarını destekler.
/// Loading state ve disabled durumları için özel animasyonlar içerir.
class CustomButton extends StatelessWidget {
  /// Button üzerinde gösterilecek metin
  final String text;

  /// Button'a tıklandığında çalışacak fonksiyon
  /// null olursa button disabled duruma geçer
  final VoidCallback? onPressed;

  /// Primary (ana) veya secondary (ikincil) stil seçimi
  /// true: Primary style (dolu arkaplan)
  /// false: Secondary style (çerçeveli)
  final bool isPrimary;

  /// Loading durumu gösterimi
  /// true olduğunda loading spinner gösterilir ve button disabled olur
  final bool isLoading;

  /// Button'ın genişliği
  /// null olursa içeriğe göre boyutlanır
  final double? width;

  /// Button'ın yüksekliği
  /// null olursa tema standartları kullanılır
  final double? height;

  /// Button başında gösterilecek ikon (opsiyonel)
  final IconData? icon;

  /// Button'ın padding değerleri
  /// null olursa tema standartları kullanılır
  final EdgeInsetsGeometry? padding;

  /// Button kenar yarıçapı
  /// null olursa tema standartları kullanılır
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.width,
    this.height,
    this.icon,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Loading durumunda veya onPressed null ise button disabled
    final bool isEnabled = !isLoading && onPressed != null;

    // Button boyutları
    final double buttonHeight = height ?? 48.0;
    final EdgeInsetsGeometry buttonPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);
    final double buttonBorderRadius = borderRadius ?? 12.0;

    return SizedBox(
      width: width,
      height: buttonHeight,
      child: isPrimary
          ? _buildPrimaryButton(
              context,
              theme,
              colorScheme,
              isEnabled,
              buttonPadding,
              buttonBorderRadius,
            )
          : _buildSecondaryButton(
              context,
              theme,
              colorScheme,
              isEnabled,
              buttonPadding,
              buttonBorderRadius,
            ),
    );
  }

  /// Primary Button (Dolu Arkaplan) oluşturur
  Widget _buildPrimaryButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isEnabled,
    EdgeInsetsGeometry buttonPadding,
    double buttonBorderRadius,
  ) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled
            ? colorScheme.primary
            : colorScheme.onSurface.withOpacity(0.12),
        foregroundColor: isEnabled
            ? colorScheme.onPrimary
            : colorScheme.onSurface.withOpacity(0.38),
        elevation: isEnabled ? 2 : 0,
        shadowColor: colorScheme.shadow,
        padding: buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
        animationDuration: const Duration(milliseconds: 200),
      ),
      child: _buildButtonContent(theme, colorScheme, isEnabled),
    );
  }

  /// Secondary Button (Çerçeveli) oluşturur
  Widget _buildSecondaryButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isEnabled,
    EdgeInsetsGeometry buttonPadding,
    double buttonBorderRadius,
  ) {
    return OutlinedButton(
      onPressed: isEnabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: isEnabled
            ? colorScheme.primary
            : colorScheme.onSurface.withOpacity(0.38),
        backgroundColor: Colors.transparent,
        side: BorderSide(
          color: isEnabled
              ? colorScheme.outline
              : colorScheme.onSurface.withOpacity(0.12),
          width: 1.5,
        ),
        padding: buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
        animationDuration: const Duration(milliseconds: 200),
      ),
      child: _buildButtonContent(theme, colorScheme, isEnabled),
    );
  }

  /// Button içeriği (text, icon, loading indicator) oluşturur
  Widget _buildButtonContent(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isEnabled,
  ) {
    // Loading durumunda spinner göster
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isPrimary ? colorScheme.onPrimary : colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Yükleniyor...',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    // Normal durumda icon + text göster
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    // Sadece text göster
    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      textAlign: TextAlign.center,
    );
  }
}

/// Custom Button için Factory Constructor'lar
extension CustomButtonExtensions on CustomButton {
  /// Küçük boyutlu primary button oluşturur
  static CustomButton small({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isPrimary = true,
    bool isLoading = false,
    IconData? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isPrimary: isPrimary,
      isLoading: isLoading,
      icon: icon,
      height: 36.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      borderRadius: 8.0,
    );
  }

  /// Büyük boyutlu primary button oluşturur
  static CustomButton large({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isPrimary = true,
    bool isLoading = false,
    IconData? icon,
    double? width,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isPrimary: isPrimary,
      isLoading: isLoading,
      icon: icon,
      width: width,
      height: 56.0,
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      borderRadius: 16.0,
    );
  }

  /// Tam genişlik button oluşturur
  static CustomButton fullWidth({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isPrimary = true,
    bool isLoading = false,
    IconData? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isPrimary: isPrimary,
      isLoading: isLoading,
      icon: icon,
      width: double.infinity,
    );
  }
}
