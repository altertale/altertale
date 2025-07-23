import 'package:flutter/material.dart';

/// Enum for subtitle text sizes
enum SubtitleSize { small, medium, large }

/// Custom Subtitle Text Widget with consistent styling
class SubtitleText extends StatelessWidget {
  final String text;
  final SubtitleSize size;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const SubtitleText(
    this.text, {
    super.key,
    this.size = SubtitleSize.medium,
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
      case SubtitleSize.small:
        baseStyle = theme.textTheme.bodySmall ?? const TextStyle();
        break;
      case SubtitleSize.medium:
        baseStyle = theme.textTheme.bodyMedium ?? const TextStyle();
        break;
      case SubtitleSize.large:
        baseStyle = theme.textTheme.bodyLarge ?? const TextStyle();
        break;
    }

    // Apply custom styling
    final style = baseStyle.copyWith(
      color: color ?? theme.colorScheme.onSurfaceVariant,
      fontWeight: fontWeight ?? FontWeight.w400,
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
