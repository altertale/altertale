import 'package:flutter/material.dart';

/// Subtitle Text Widget - Altertale Uygulaması için Açıklayıcı Metinler
///
/// Bu widget, başlıkların altında veya açıklayıcı metinler için kullanılır.
/// Theme'dan secondary text stillerini alır ve farklı boyut seçenekleri sunar.
/// Material 3 typography scale'e uygun olarak tasarlanmıştır.
class SubtitleText extends StatelessWidget {
  /// Gösterilecek açıklayıcı metin
  final String text;

  /// Subtitle boyutu/stili
  final SubtitleSize size;

  /// Metin rengi (null ise theme'dan alınır)
  final Color? color;

  /// Metin hizalaması
  final TextAlign? textAlign;

  /// Maksimum satır sayısı
  final int? maxLines;

  /// Metin taşması durumunda davranış
  final TextOverflow? overflow;

  /// Font weight override
  final FontWeight? fontWeight;

  /// Harfler arası boşluk
  final double? letterSpacing;

  /// Satırlar arası yükseklik
  final double? height;

  /// Metin solukluğu (opacity)
  final double? opacity;

  const SubtitleText(
    this.text, {
    super.key,
    this.size = SubtitleSize.medium,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
    this.letterSpacing,
    this.height,
    this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      text,
      style: _getTextStyle(theme, colorScheme),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Theme'a uygun text style'ı döndürür
  TextStyle _getTextStyle(ThemeData theme, ColorScheme colorScheme) {
    late TextStyle baseStyle;

    // Boyuta göre theme'dan base style al
    switch (size) {
      case SubtitleSize.small:
        baseStyle = theme.textTheme.bodySmall ?? const TextStyle();
        break;
      case SubtitleSize.medium:
        baseStyle = theme.textTheme.bodyMedium ?? const TextStyle();
        break;
      case SubtitleSize.large:
        baseStyle = theme.textTheme.bodyLarge ?? const TextStyle();
        break;
      case SubtitleSize.caption:
        baseStyle = theme.textTheme.labelSmall ?? const TextStyle();
        break;
    }

    // Varsayılan renk ayarla (secondary color)
    Color textColor = color ?? _getDefaultColor(colorScheme, size);

    // Opacity uygula
    if (opacity != null) {
      textColor = textColor.withOpacity(opacity!);
    }

    // Özelleştirmeleri uygula
    return baseStyle.copyWith(
      color: textColor,
      fontWeight: fontWeight ?? _getDefaultFontWeight(size),
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Boyuta göre varsayılan renk döndürür
  Color _getDefaultColor(ColorScheme colorScheme, SubtitleSize size) {
    switch (size) {
      case SubtitleSize.small:
        return colorScheme.onSurfaceVariant.withOpacity(0.8);
      case SubtitleSize.medium:
        return colorScheme.onSurfaceVariant;
      case SubtitleSize.large:
        return colorScheme.onSurface.withOpacity(0.9);
      case SubtitleSize.caption:
        return colorScheme.onSurfaceVariant.withOpacity(0.7);
    }
  }

  /// Boyuta göre varsayılan font weight döndürür
  FontWeight _getDefaultFontWeight(SubtitleSize size) {
    switch (size) {
      case SubtitleSize.small:
        return FontWeight.w400;
      case SubtitleSize.medium:
        return FontWeight.w400;
      case SubtitleSize.large:
        return FontWeight.w500;
      case SubtitleSize.caption:
        return FontWeight.w400;
    }
  }
}

/// Subtitle boyut seçenekleri
enum SubtitleSize {
  /// Küçük subtitle (12px) - Meta bilgiler, timestamp
  small,

  /// Orta subtitle (14px) - Açıklama metinleri, description
  medium,

  /// Büyük subtitle (16px) - Önemli açıklamalar, introductory text
  large,

  /// Caption (11px) - Çok küçük bilgi metinleri, labels
  caption,
}

/// Subtitle Text için özel constructor'lar
extension SubtitleTextExtensions on SubtitleText {
  /// Küçük subtitle oluşturur
  static SubtitleText small(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? opacity,
  }) {
    return SubtitleText(
      text,
      key: key,
      size: SubtitleSize.small,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
      opacity: opacity,
    );
  }

  /// Orta subtitle oluşturur
  static SubtitleText medium(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? opacity,
  }) {
    return SubtitleText(
      text,
      key: key,
      size: SubtitleSize.medium,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
      opacity: opacity,
    );
  }

  /// Büyük subtitle oluşturur
  static SubtitleText large(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? opacity,
  }) {
    return SubtitleText(
      text,
      key: key,
      size: SubtitleSize.large,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
      opacity: opacity,
    );
  }

  /// Caption (çok küçük) oluşturur
  static SubtitleText caption(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    double? opacity,
  }) {
    return SubtitleText(
      text,
      key: key,
      size: SubtitleSize.caption,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
      opacity: opacity,
    );
  }

  /// Muted (soluk) renkte subtitle oluşturur
  static SubtitleText muted(
    String text, {
    Key? key,
    SubtitleSize size = SubtitleSize.medium,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
  }) {
    return SubtitleText(
      text,
      key: key,
      size: size,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
      opacity: 0.6,
    );
  }

  /// Success renkte subtitle oluşturur
  static Widget success(
    String text, {
    Key? key,
    SubtitleSize size = SubtitleSize.medium,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
  }) {
    return Builder(
      builder: (context) {
        return SubtitleText(
          text,
          key: key,
          size: size,
          color: Colors.green.shade600,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          fontWeight: fontWeight,
        );
      },
    );
  }

  /// Warning renkte subtitle oluşturur
  static Widget warning(
    String text, {
    Key? key,
    SubtitleSize size = SubtitleSize.medium,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
  }) {
    return Builder(
      builder: (context) {
        return SubtitleText(
          text,
          key: key,
          size: size,
          color: Colors.orange.shade600,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          fontWeight: fontWeight,
        );
      },
    );
  }

  /// Error renkte subtitle oluşturur
  static Widget error(
    String text, {
    Key? key,
    SubtitleSize size = SubtitleSize.medium,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return SubtitleText(
          text,
          key: key,
          size: size,
          color: colorScheme.error,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          fontWeight: fontWeight,
        );
      },
    );
  }

  /// Primary renkte subtitle oluşturur
  static Widget primary(
    String text, {
    Key? key,
    SubtitleSize size = SubtitleSize.medium,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return SubtitleText(
          text,
          key: key,
          size: size,
          color: colorScheme.primary,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          fontWeight: fontWeight,
        );
      },
    );
  }

  /// Timestamp formatında küçük metin oluşturur
  static SubtitleText timestamp(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) {
    return SubtitleText(
      text,
      key: key,
      size: SubtitleSize.caption,
      color: color,
      textAlign: textAlign,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    );
  }

  /// Badge formatında küçük label oluşturur
  static SubtitleText badge(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) {
    return SubtitleText(
      text,
      key: key,
      size: SubtitleSize.caption,
      color: color,
      textAlign: textAlign,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
