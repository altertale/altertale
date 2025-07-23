import 'package:flutter/material.dart';

/// Title Text Widget - Altertale Uygulaması için Başlık Metinleri
///
/// Bu widget, uygulamanın başlık metinleri için tutarlı tipografi sağlar.
/// Theme'dan font ayarlarını alır ve farklı boyut seçenekleri sunar.
/// Material 3 typography scale'e uygun olarak tasarlanmıştır.
class TitleText extends StatelessWidget {
  /// Gösterilecek başlık metni
  final String text;

  /// Başlık boyutu/stili
  final TitleSize size;

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

  const TitleText(
    this.text, {
    super.key,
    this.size = TitleSize.medium,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
    this.letterSpacing,
    this.height,
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
      case TitleSize.small:
        baseStyle = theme.textTheme.titleSmall ?? const TextStyle();
        break;
      case TitleSize.medium:
        baseStyle = theme.textTheme.titleMedium ?? const TextStyle();
        break;
      case TitleSize.large:
        baseStyle = theme.textTheme.titleLarge ?? const TextStyle();
        break;
      case TitleSize.headline:
        baseStyle = theme.textTheme.headlineSmall ?? const TextStyle();
        break;
      case TitleSize.display:
        baseStyle = theme.textTheme.headlineMedium ?? const TextStyle();
        break;
    }

    // Özelleştirmeleri uygula
    return baseStyle.copyWith(
      color: color ?? colorScheme.onSurface,
      fontWeight: fontWeight ?? _getDefaultFontWeight(size),
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Boyuta göre varsayılan font weight döndürür
  FontWeight _getDefaultFontWeight(TitleSize size) {
    switch (size) {
      case TitleSize.small:
        return FontWeight.w500;
      case TitleSize.medium:
        return FontWeight.w600;
      case TitleSize.large:
        return FontWeight.w700;
      case TitleSize.headline:
        return FontWeight.w700;
      case TitleSize.display:
        return FontWeight.w800;
    }
  }
}

/// Başlık boyut seçenekleri
enum TitleSize {
  /// Küçük başlık (14px) - Alt başlıklar, kart başlıkları
  small,

  /// Orta başlık (16px) - Bölüm başlıkları, dialog başlıkları
  medium,

  /// Büyük başlık (22px) - Sayfa başlıkları, önemli başlıklar
  large,

  /// Ana başlık (24px) - Ekran başlıkları
  headline,

  /// Büyük ekran başlığı (28px) - Ana sayfa, öne çıkan başlıklar
  display,
}

/// Title Text için özel constructor'lar
extension TitleTextExtensions on TitleText {
  /// Küçük başlık oluşturur
  static TitleText small(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
  }) {
    return TitleText(
      text,
      key: key,
      size: TitleSize.small,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }

  /// Orta başlık oluşturur
  static TitleText medium(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
  }) {
    return TitleText(
      text,
      key: key,
      size: TitleSize.medium,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }

  /// Büyük başlık oluşturur
  static TitleText large(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
  }) {
    return TitleText(
      text,
      key: key,
      size: TitleSize.large,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }

  /// Ana başlık oluşturur
  static TitleText headline(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
  }) {
    return TitleText(
      text,
      key: key,
      size: TitleSize.headline,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }

  /// Büyük ekran başlığı oluşturur
  static TitleText display(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
  }) {
    return TitleText(
      text,
      key: key,
      size: TitleSize.display,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      fontWeight: fontWeight,
    );
  }

  /// Primary renkte başlık oluşturur
  static Widget primary(
    String text, {
    Key? key,
    TitleSize size = TitleSize.medium,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return TitleText(
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

  /// Secondary renkte başlık oluşturur
  static Widget secondary(
    String text, {
    Key? key,
    TitleSize size = TitleSize.medium,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return TitleText(
          text,
          key: key,
          size: size,
          color: colorScheme.secondary,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          fontWeight: fontWeight,
        );
      },
    );
  }

  /// Error renkte başlık oluşturur
  static Widget error(
    String text, {
    Key? key,
    TitleSize size = TitleSize.medium,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return TitleText(
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
}
