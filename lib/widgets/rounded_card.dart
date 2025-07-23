import 'package:flutter/material.dart';

/// Rounded Card Widget - Altertale Uygulaması için Kenarları Yuvarlatılmış Kart Container
///
/// Bu widget, içerik göstermek için kullanılan modern kart tasarımı sağlar.
/// Theme'dan renk ve shadow değerlerini alır, özelleştirilebilir padding ve elevation sunar.
/// Material 3 design principles'a uygun olarak tasarlanmıştır.
class RoundedCard extends StatelessWidget {
  /// Kart içinde gösterilecek widget
  final Widget child;

  /// Kart içi padding
  final EdgeInsetsGeometry? padding;

  /// Kart margin (dış boşluk)
  final EdgeInsetsGeometry? margin;

  /// Kart genişliği
  final double? width;

  /// Kart yüksekliği
  final double? height;

  /// Kenar yarıçapı
  final double? borderRadius;

  /// Elevation (gölge yoğunluğu)
  final double? elevation;

  /// Arkaplan rengi (null ise theme'dan alınır)
  final Color? backgroundColor;

  /// Border rengi ve kalınlığı
  final Color? borderColor;
  final double? borderWidth;

  /// Tıklanabilir olup olmadığı
  final VoidCallback? onTap;

  /// Long press callback
  final VoidCallback? onLongPress;

  /// Hover durumunda elevation artırma
  final bool enableHoverElevation;

  /// Splash efekti gösterme
  final bool enableSplash;

  /// Klip davranışı
  final Clip clipBehavior;

  const RoundedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.elevation,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.onTap,
    this.onLongPress,
    this.enableHoverElevation = true,
    this.enableSplash = true,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Varsayılan değerler
    final double cardBorderRadius = borderRadius ?? 16.0;
    final double cardElevation = elevation ?? 2.0;
    final EdgeInsetsGeometry cardPadding =
        padding ?? const EdgeInsets.all(16.0);
    final Color cardBackgroundColor = backgroundColor ?? colorScheme.surface;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: Material(
        color: cardBackgroundColor,
        elevation: cardElevation,
        shadowColor: colorScheme.shadow.withOpacity(0.15),
        borderRadius: BorderRadius.circular(cardBorderRadius),
        clipBehavior: clipBehavior,
        child: _buildCardContent(
          context,
          theme,
          colorScheme,
          cardPadding,
          cardBorderRadius,
        ),
      ),
    );
  }

  /// Kart içeriğini oluşturur (tıklanabilir veya statik)
  Widget _buildCardContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    EdgeInsetsGeometry cardPadding,
    double cardBorderRadius,
  ) {
    Widget content = Container(
      padding: cardPadding,
      decoration: _buildDecoration(colorScheme, cardBorderRadius),
      child: child,
    );

    // Eğer tıklanabilir ise InkWell ile sar
    if (onTap != null || onLongPress != null) {
      content = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        splashColor: enableSplash
            ? colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        highlightColor: colorScheme.primary.withOpacity(0.05),
        hoverColor: colorScheme.primary.withOpacity(0.03),
        child: content,
      );
    }

    // Hover elevation efekti
    if (enableHoverElevation && (onTap != null || onLongPress != null)) {
      content = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: content,
        ),
      );
    }

    return content;
  }

  /// Border decoration oluşturur
  BoxDecoration? _buildDecoration(
    ColorScheme colorScheme,
    double cardBorderRadius,
  ) {
    if (borderColor != null && borderWidth != null) {
      return BoxDecoration(
        border: Border.all(color: borderColor!, width: borderWidth!),
        borderRadius: BorderRadius.circular(cardBorderRadius),
      );
    }
    return null;
  }
}

/// Rounded Card için özel constructor'lar
extension RoundedCardExtensions on RoundedCard {
  /// Compact (küçük) kart oluşturur
  static RoundedCard compact({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    Color? backgroundColor,
    double? elevation,
  }) {
    return RoundedCard(
      key: key,
      child: child,
      padding: const EdgeInsets.all(12.0),
      borderRadius: 12.0,
      elevation: elevation ?? 1.0,
      backgroundColor: backgroundColor,
      onTap: onTap,
    );
  }

  /// Medium (orta) boyutlu kart oluşturur
  static RoundedCard medium({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    Color? backgroundColor,
    double? elevation,
    EdgeInsetsGeometry? margin,
  }) {
    return RoundedCard(
      key: key,
      child: child,
      padding: const EdgeInsets.all(16.0),
      margin: margin,
      borderRadius: 16.0,
      elevation: elevation ?? 2.0,
      backgroundColor: backgroundColor,
      onTap: onTap,
    );
  }

  /// Large (büyük) kart oluşturur
  static RoundedCard large({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    Color? backgroundColor,
    double? elevation,
    EdgeInsetsGeometry? margin,
  }) {
    return RoundedCard(
      key: key,
      child: child,
      padding: const EdgeInsets.all(24.0),
      margin: margin,
      borderRadius: 20.0,
      elevation: elevation ?? 4.0,
      backgroundColor: backgroundColor,
      onTap: onTap,
    );
  }

  /// Outlined (çerçeveli) kart oluşturur
  static Widget outlined({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    Color? borderColor,
    double? borderWidth,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return RoundedCard(
          key: key,
          child: child,
          padding: padding,
          margin: margin,
          elevation: 0,
          backgroundColor: Colors.transparent,
          borderColor: borderColor ?? colorScheme.outline,
          borderWidth: borderWidth ?? 1.0,
          onTap: onTap,
        );
      },
    );
  }

  /// Primary renkte kart oluşturur
  static Widget primary({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? elevation,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return RoundedCard(
          key: key,
          child: child,
          padding: padding,
          margin: margin,
          elevation: elevation,
          backgroundColor: colorScheme.primaryContainer,
          onTap: onTap,
        );
      },
    );
  }

  /// Secondary renkte kart oluşturur
  static Widget secondary({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? elevation,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return RoundedCard(
          key: key,
          child: child,
          padding: padding,
          margin: margin,
          elevation: elevation,
          backgroundColor: colorScheme.secondaryContainer,
          onTap: onTap,
        );
      },
    );
  }

  /// Error renkte kart oluşturur
  static Widget error({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? elevation,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return RoundedCard(
          key: key,
          child: child,
          padding: padding,
          margin: margin,
          elevation: elevation,
          backgroundColor: colorScheme.errorContainer,
          onTap: onTap,
        );
      },
    );
  }

  /// Success renkte kart oluşturur
  static Widget success({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? elevation,
  }) {
    return RoundedCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      elevation: elevation,
      backgroundColor: Colors.green.shade50,
      borderColor: Colors.green.shade200,
      borderWidth: 1.0,
      onTap: onTap,
    );
  }

  /// Warning renkte kart oluşturur
  static Widget warning({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? elevation,
  }) {
    return RoundedCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      elevation: elevation,
      backgroundColor: Colors.orange.shade50,
      borderColor: Colors.orange.shade200,
      borderWidth: 1.0,
      onTap: onTap,
    );
  }

  /// Info renkte kart oluşturur
  static Widget info({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? elevation,
  }) {
    return RoundedCard(
      key: key,
      child: child,
      padding: padding,
      margin: margin,
      elevation: elevation,
      backgroundColor: Colors.blue.shade50,
      borderColor: Colors.blue.shade200,
      borderWidth: 1.0,
      onTap: onTap,
    );
  }

  /// Gradient arkaplan ile kart oluşturur
  static Widget gradient({
    Key? key,
    required Widget child,
    required Gradient gradient,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    double? elevation,
  }) {
    final double cardBorderRadius = borderRadius ?? 16.0;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: elevation != null && elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(cardBorderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
