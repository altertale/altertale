import 'package:flutter/material.dart';

/// Icon Text Button Widget - Altertale Uygulaması için Icon + Text Horizontal Button
///
/// Bu widget, profil ekranı ve navigasyon menüleri için icon ve text içeren
/// yatay düzenli button'ları oluşturur. Theme'a uyumlu ve özelleştirilebilir.
/// Material 3 design principles'a uygun olarak tasarlanmıştır.
class IconTextButton extends StatelessWidget {
  /// Button'da gösterilecek ikon
  final IconData icon;

  /// Button'da gösterilecek metin
  final String text;

  /// Button'a tıklandığında çalışacak fonksiyon
  final VoidCallback? onPressed;

  /// Icon boyutu
  final double? iconSize;

  /// Icon rengi (null ise theme'dan alınır)
  final Color? iconColor;

  /// Text rengi (null ise theme'dan alınır)
  final Color? textColor;

  /// Button arkaplan rengi
  final Color? backgroundColor;

  /// Button stili
  final IconTextButtonStyle style;

  /// Icon ve text arasındaki boşluk
  final double spacing;

  /// Button padding
  final EdgeInsetsGeometry? padding;

  /// Button margin
  final EdgeInsetsGeometry? margin;

  /// Button genişliği
  final double? width;

  /// Button yüksekliği
  final double? height;

  /// Kenar yarıçapı
  final double? borderRadius;

  /// Loading durumu
  final bool isLoading;

  /// Badge/notification count
  final int? badgeCount;

  /// Badge rengi
  final Color? badgeColor;

  /// Trailing widget (arrow, switch, etc.)
  final Widget? trailing;

  /// Text overflow davranışı
  final TextOverflow? overflow;

  /// Maksimum satır sayısı
  final int? maxLines;

  const IconTextButton({
    super.key,
    required this.icon,
    required this.text,
    this.onPressed,
    this.iconSize,
    this.iconColor,
    this.textColor,
    this.backgroundColor,
    this.style = IconTextButtonStyle.flat,
    this.spacing = 12.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.badgeCount,
    this.badgeColor,
    this.trailing,
    this.overflow,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Varsayılan değerler
    final double buttonIconSize = iconSize ?? 24.0;
    final double buttonBorderRadius = borderRadius ?? 12.0;
    final EdgeInsetsGeometry buttonPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: _buildButton(
        context,
        theme,
        colorScheme,
        buttonIconSize,
        buttonBorderRadius,
        buttonPadding,
      ),
    );
  }

  /// Button'ı stile göre oluşturur
  Widget _buildButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    double buttonIconSize,
    double buttonBorderRadius,
    EdgeInsetsGeometry buttonPadding,
  ) {
    final bool isEnabled = !isLoading && onPressed != null;

    switch (style) {
      case IconTextButtonStyle.flat:
        return _buildFlatButton(
          context,
          theme,
          colorScheme,
          isEnabled,
          buttonIconSize,
          buttonBorderRadius,
          buttonPadding,
        );
      case IconTextButtonStyle.outlined:
        return _buildOutlinedButton(
          context,
          theme,
          colorScheme,
          isEnabled,
          buttonIconSize,
          buttonBorderRadius,
          buttonPadding,
        );
      case IconTextButtonStyle.filled:
        return _buildFilledButton(
          context,
          theme,
          colorScheme,
          isEnabled,
          buttonIconSize,
          buttonBorderRadius,
          buttonPadding,
        );
      case IconTextButtonStyle.elevated:
        return _buildElevatedButton(
          context,
          theme,
          colorScheme,
          isEnabled,
          buttonIconSize,
          buttonBorderRadius,
          buttonPadding,
        );
    }
  }

  /// Flat (düz) button oluşturur
  Widget _buildFlatButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isEnabled,
    double buttonIconSize,
    double buttonBorderRadius,
    EdgeInsetsGeometry buttonPadding,
  ) {
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? colorScheme.onSurface,
        backgroundColor: backgroundColor ?? Colors.transparent,
        padding: buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
        alignment: Alignment.centerLeft,
      ),
      child: _buildButtonContent(theme, colorScheme, isEnabled, buttonIconSize),
    );
  }

  /// Outlined (çerçeveli) button oluşturur
  Widget _buildOutlinedButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isEnabled,
    double buttonIconSize,
    double buttonBorderRadius,
    EdgeInsetsGeometry buttonPadding,
  ) {
    return OutlinedButton(
      onPressed: isEnabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? colorScheme.primary,
        backgroundColor: backgroundColor ?? Colors.transparent,
        side: BorderSide(color: colorScheme.outline),
        padding: buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
        alignment: Alignment.centerLeft,
      ),
      child: _buildButtonContent(theme, colorScheme, isEnabled, buttonIconSize),
    );
  }

  /// Filled (dolu) button oluşturur
  Widget _buildFilledButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isEnabled,
    double buttonIconSize,
    double buttonBorderRadius,
    EdgeInsetsGeometry buttonPadding,
  ) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor ?? colorScheme.onPrimary,
        backgroundColor: backgroundColor ?? colorScheme.primary,
        elevation: 0,
        padding: buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
        alignment: Alignment.centerLeft,
      ),
      child: _buildButtonContent(theme, colorScheme, isEnabled, buttonIconSize),
    );
  }

  /// Elevated (yükseltilmiş) button oluşturur
  Widget _buildElevatedButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isEnabled,
    double buttonIconSize,
    double buttonBorderRadius,
    EdgeInsetsGeometry buttonPadding,
  ) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor ?? colorScheme.onSurface,
        backgroundColor: backgroundColor ?? colorScheme.surface,
        elevation: 2,
        shadowColor: colorScheme.shadow,
        padding: buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
        alignment: Alignment.centerLeft,
      ),
      child: _buildButtonContent(theme, colorScheme, isEnabled, buttonIconSize),
    );
  }

  /// Button içeriğini oluşturur
  Widget _buildButtonContent(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isEnabled,
    double buttonIconSize,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Loading indicator veya icon
        if (isLoading)
          SizedBox(
            width: buttonIconSize,
            height: buttonIconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                iconColor ?? colorScheme.primary,
              ),
            ),
          )
        else
          _buildIconWithBadge(colorScheme, buttonIconSize),

        SizedBox(width: spacing),

        // Text
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isEnabled
                  ? (textColor ??
                        (style == IconTextButtonStyle.filled
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface))
                  : colorScheme.onSurface.withOpacity(0.38),
              fontWeight: FontWeight.w500,
            ),
            overflow: overflow ?? TextOverflow.ellipsis,
            maxLines: maxLines,
          ),
        ),

        // Trailing widget
        if (trailing != null) ...[SizedBox(width: spacing / 2), trailing!],
      ],
    );
  }

  /// Icon'u badge ile birlikte oluşturur
  Widget _buildIconWithBadge(ColorScheme colorScheme, double buttonIconSize) {
    Widget iconWidget = Icon(
      icon,
      size: buttonIconSize,
      color: iconColor ?? colorScheme.onSurfaceVariant,
    );

    // Badge ekle
    if (badgeCount != null && badgeCount! > 0) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor ?? colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                badgeCount! > 99 ? '99+' : badgeCount.toString(),
                style: TextStyle(
                  color: colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return iconWidget;
  }
}

/// Icon Text Button stil seçenekleri
enum IconTextButtonStyle {
  /// Düz button (transparent background)
  flat,

  /// Çerçeveli button
  outlined,

  /// Dolu button (filled background)
  filled,

  /// Yükseltilmiş button (elevation ile)
  elevated,
}

/// Icon Text Button için özel constructor'lar
extension IconTextButtonExtensions on IconTextButton {
  /// Profile menu item oluşturur
  static IconTextButton profileItem({
    Key? key,
    required IconData icon,
    required String text,
    VoidCallback? onPressed,
    Widget? trailing,
    int? badgeCount,
  }) {
    return IconTextButton(
      key: key,
      icon: icon,
      text: text,
      onPressed: onPressed,
      style: IconTextButtonStyle.flat,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      badgeCount: badgeCount,
    );
  }

  /// Settings menu item oluşturur
  static IconTextButton settingsItem({
    Key? key,
    required IconData icon,
    required String text,
    VoidCallback? onPressed,
    Widget? trailing,
    Color? iconColor,
  }) {
    return IconTextButton(
      key: key,
      icon: icon,
      text: text,
      onPressed: onPressed,
      style: IconTextButtonStyle.flat,
      iconColor: iconColor,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      trailing: trailing,
    );
  }

  /// Navigation drawer item oluşturur
  static Widget drawerItem({
    Key? key,
    required IconData icon,
    required String text,
    VoidCallback? onPressed,
    bool isSelected = false,
    int? badgeCount,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return IconTextButton(
          key: key,
          icon: icon,
          text: text,
          onPressed: onPressed,
          style: isSelected
              ? IconTextButtonStyle.filled
              : IconTextButtonStyle.flat,
          backgroundColor: isSelected ? colorScheme.primaryContainer : null,
          iconColor: isSelected ? colorScheme.onPrimaryContainer : null,
          textColor: isSelected ? colorScheme.onPrimaryContainer : null,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          badgeCount: badgeCount,
        );
      },
    );
  }

  /// Action button oluşturur
  static Widget action({
    Key? key,
    required IconData icon,
    required String text,
    VoidCallback? onPressed,
    bool isPrimary = false,
    bool isLoading = false,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return IconTextButton(
          key: key,
          icon: icon,
          text: text,
          onPressed: onPressed,
          style: isPrimary
              ? IconTextButtonStyle.filled
              : IconTextButtonStyle.outlined,
          backgroundColor: isPrimary ? colorScheme.primary : null,
          iconColor: isPrimary ? colorScheme.onPrimary : colorScheme.primary,
          textColor: isPrimary ? colorScheme.onPrimary : colorScheme.primary,
          isLoading: isLoading,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        );
      },
    );
  }

  /// Compact (küçük) button oluşturur
  static IconTextButton compact({
    Key? key,
    required IconData icon,
    required String text,
    VoidCallback? onPressed,
    IconTextButtonStyle style = IconTextButtonStyle.flat,
  }) {
    return IconTextButton(
      key: key,
      icon: icon,
      text: text,
      onPressed: onPressed,
      style: style,
      iconSize: 18,
      spacing: 8,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      borderRadius: 8.0,
    );
  }

  /// Large button oluşturur
  static IconTextButton large({
    Key? key,
    required IconData icon,
    required String text,
    VoidCallback? onPressed,
    IconTextButtonStyle style = IconTextButtonStyle.outlined,
    double? width,
  }) {
    return IconTextButton(
      key: key,
      icon: icon,
      text: text,
      onPressed: onPressed,
      style: style,
      width: width,
      iconSize: 28,
      spacing: 16,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
      borderRadius: 16.0,
    );
  }

  /// Destructive (silme/çıkış) action oluşturur
  static Widget destructive({
    Key? key,
    required IconData icon,
    required String text,
    VoidCallback? onPressed,
    IconTextButtonStyle style = IconTextButtonStyle.flat,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return IconTextButton(
          key: key,
          icon: icon,
          text: text,
          onPressed: onPressed,
          style: style,
          iconColor: colorScheme.error,
          textColor: colorScheme.error,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        );
      },
    );
  }
}
