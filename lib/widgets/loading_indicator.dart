import 'package:flutter/material.dart';

/// Loading Indicator Widget - Altertale Uygulaması için Loading Animasyonu
///
/// Bu widget, çeşitli loading durumları için kullanılan animasyonlu gösterge sağlar.
/// Farklı boyutlar ve stiller sunar, theme'a uyumlu renk desteği içerir.
/// Material 3 design principles'a uygun olarak tasarlanmıştır.
class LoadingIndicator extends StatelessWidget {
  /// Loading indicator boyutu
  final LoadingSize size;

  /// Loading indicator stili
  final LoadingStyle style;

  /// Loading indicator rengi (null ise theme'dan alınır)
  final Color? color;

  /// Stroke kalınlığı (circular için)
  final double? strokeWidth;

  /// Loading mesajı (opsiyonel)
  final String? message;

  /// Mesaj ile indicator arasındaki boşluk
  final double spacing;

  /// Container padding
  final EdgeInsetsGeometry? padding;

  /// Container margin
  final EdgeInsetsGeometry? margin;

  /// Arkaplan rengi
  final Color? backgroundColor;

  /// Kenar yarıçapı (container için)
  final double? borderRadius;

  /// Layout yönü (vertical/horizontal)
  final Axis direction;

  const LoadingIndicator({
    super.key,
    this.size = LoadingSize.medium,
    this.style = LoadingStyle.circular,
    this.color,
    this.strokeWidth,
    this.message,
    this.spacing = 12.0,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Varsayılan değerler
    final Color indicatorColor = color ?? colorScheme.primary;
    final double indicatorStrokeWidth =
        strokeWidth ?? _getDefaultStrokeWidth(size);

    Widget indicator = _buildIndicator(indicatorColor, indicatorStrokeWidth);

    // Mesaj varsa ekle
    if (message != null) {
      indicator = _buildWithMessage(indicator, theme, colorScheme);
    }

    // Container ile sar (eğer background gerekiyorsa)
    if (backgroundColor != null || padding != null || margin != null) {
      indicator = Container(
        padding: padding,
        margin: margin,
        decoration: backgroundColor != null
            ? BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
              )
            : null,
        child: indicator,
      );
    }

    return indicator;
  }

  /// Indicator'ı oluşturur
  Widget _buildIndicator(Color indicatorColor, double indicatorStrokeWidth) {
    final double indicatorSize = _getSizeValue(size);

    switch (style) {
      case LoadingStyle.circular:
        return SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            strokeWidth: indicatorStrokeWidth,
          ),
        );

      case LoadingStyle.linear:
        return SizedBox(
          width: indicatorSize,
          height: 4.0,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            backgroundColor: indicatorColor.withOpacity(0.2),
          ),
        );

      case LoadingStyle.dots:
        return _buildDotsIndicator(indicatorColor, indicatorSize);

      case LoadingStyle.spinner:
        return _buildSpinnerIndicator(indicatorColor, indicatorSize);

      case LoadingStyle.pulse:
        return _buildPulseIndicator(indicatorColor, indicatorSize);
    }
  }

  /// Dots (nokta) indicator'ı oluşturur
  Widget _buildDotsIndicator(Color color, double size) {
    return SizedBox(
      width: size,
      height: size / 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 600 + (index * 200)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: (0.5 + (0.5 * value)),
                child: Container(
                  width: size / 8,
                  height: size / 8,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.5 + (0.5 * value)),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  /// Spinner indicator'ı oluşturur
  Widget _buildSpinnerIndicator(Color color, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: List.generate(8, (index) {
          return Transform.rotate(
            angle: (index * 45) * 3.14159 / 180,
            child: Align(
              alignment: Alignment.topCenter,
              child: TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 1200),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: (0.2 + (0.8 * ((value + index / 8) % 1))),
                    child: Container(
                      width: size / 12,
                      height: size / 4,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(size / 24),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Pulse indicator'ı oluşturur
  Widget _buildPulseIndicator(Color color, double size) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          width: size * (0.5 + (0.5 * value)),
          height: size * (0.5 + (0.5 * value)),
          decoration: BoxDecoration(
            color: color.withOpacity(1.0 - value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  /// Mesaj ile birlikte indicator oluşturur
  Widget _buildWithMessage(
    Widget indicator,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final List<Widget> children = direction == Axis.vertical
        ? [
            indicator,
            SizedBox(height: spacing),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ]
        : [
            indicator,
            SizedBox(width: spacing),
            Flexible(
              child: Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ];

    return direction == Axis.vertical
        ? Column(mainAxisSize: MainAxisSize.min, children: children)
        : Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  /// Boyuta göre size değeri döndürür
  double _getSizeValue(LoadingSize size) {
    switch (size) {
      case LoadingSize.small:
        return 16.0;
      case LoadingSize.medium:
        return 24.0;
      case LoadingSize.large:
        return 32.0;
      case LoadingSize.extraLarge:
        return 48.0;
    }
  }

  /// Boyuta göre varsayılan stroke width döndürür
  double _getDefaultStrokeWidth(LoadingSize size) {
    switch (size) {
      case LoadingSize.small:
        return 2.0;
      case LoadingSize.medium:
        return 3.0;
      case LoadingSize.large:
        return 4.0;
      case LoadingSize.extraLarge:
        return 5.0;
    }
  }
}

/// Loading indicator boyut seçenekleri
enum LoadingSize {
  /// Küçük (16px) - Inline loading
  small,

  /// Orta (24px) - Button loading
  medium,

  /// Büyük (32px) - Content loading
  large,

  /// Çok büyük (48px) - Page loading
  extraLarge,
}

/// Loading indicator stil seçenekleri
enum LoadingStyle {
  /// Circular progress indicator
  circular,

  /// Linear progress indicator
  linear,

  /// Dots animation
  dots,

  /// Spinner animation
  spinner,

  /// Pulse animation
  pulse,
}

/// Loading Indicator için özel constructor'lar
extension LoadingIndicatorExtensions on LoadingIndicator {
  /// Küçük inline loading oluşturur
  static LoadingIndicator small({
    Key? key,
    LoadingStyle style = LoadingStyle.circular,
    Color? color,
  }) {
    return LoadingIndicator(
      key: key,
      size: LoadingSize.small,
      style: style,
      color: color,
    );
  }

  /// Orta boyutlu loading oluşturur
  static LoadingIndicator medium({
    Key? key,
    LoadingStyle style = LoadingStyle.circular,
    Color? color,
    String? message,
  }) {
    return LoadingIndicator(
      key: key,
      size: LoadingSize.medium,
      style: style,
      color: color,
      message: message,
    );
  }

  /// Büyük loading oluşturur
  static LoadingIndicator large({
    Key? key,
    LoadingStyle style = LoadingStyle.circular,
    Color? color,
    String? message,
  }) {
    return LoadingIndicator(
      key: key,
      size: LoadingSize.large,
      style: style,
      color: color,
      message: message,
    );
  }

  /// Overlay loading (sayfa üstü) oluşturur
  static Widget overlay({
    Key? key,
    LoadingStyle style = LoadingStyle.circular,
    String? message,
    Color? backgroundColor,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          color: backgroundColor ?? Colors.black.withOpacity(0.5),
          child: Center(
            child: LoadingIndicator(
              key: key,
              size: LoadingSize.large,
              style: style,
              message: message ?? 'Yükleniyor...',
              padding: const EdgeInsets.all(24.0),
              backgroundColor: colorScheme.surface,
              borderRadius: 16.0,
            ),
          ),
        );
      },
    );
  }

  /// Button loading oluşturur
  static LoadingIndicator button({Key? key, Color? color}) {
    return LoadingIndicator(
      key: key,
      size: LoadingSize.small,
      style: LoadingStyle.circular,
      color: color,
      strokeWidth: 2.0,
    );
  }

  /// Card loading oluşturur
  static Widget card({
    Key? key,
    String? message,
    LoadingStyle style = LoadingStyle.dots,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          ),
          child: LoadingIndicator(
            key: key,
            size: LoadingSize.medium,
            style: style,
            message: message ?? 'İçerik yükleniyor...',
          ),
        );
      },
    );
  }

  /// Success loading (tamamlandı) oluşturur
  static Widget success({Key? key, String? message, VoidCallback? onComplete}) {
    return Builder(
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.green.shade700, size: 24),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.green.shade700),
                textAlign: TextAlign.center,
              ),
            ],
            if (onComplete != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onComplete, child: const Text('Tamam')),
            ],
          ],
        );
      },
    );
  }

  /// Error loading (hata) oluşturur
  static Widget error({Key? key, String? message, VoidCallback? onRetry}) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: colorScheme.onErrorContainer,
                size: 24,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Horizontal (yatay) loading oluşturur
  static LoadingIndicator horizontal({
    Key? key,
    LoadingStyle style = LoadingStyle.dots,
    String? message,
    Color? color,
  }) {
    return LoadingIndicator(
      key: key,
      size: LoadingSize.medium,
      style: style,
      message: message,
      color: color,
      direction: Axis.horizontal,
    );
  }
}
