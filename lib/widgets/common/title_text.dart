import 'package:flutter/material.dart';

/// Enum for title text sizes
enum TitleSize { small, medium, large }

/// Custom Title Text Widget with consistent styling
class TitleText extends StatelessWidget {
  final String text;
  final TitleSize size;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TitleText(
    this.text, {
    super.key,
    this.size = TitleSize.medium,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get base style based on size
    TextStyle baseStyle;
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
    }

    // Apply custom styling
    final style = baseStyle.copyWith(
      color: color ?? theme.colorScheme.onSurface,
      fontWeight: fontWeight ?? FontWeight.w600,
    );

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
