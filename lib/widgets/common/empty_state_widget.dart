import 'package:flutter/material.dart';
import 'title_text.dart';
import 'subtitle_text.dart';
import 'custom_button.dart';

/// Empty State Widget for displaying empty content states
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final double? iconSize;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.buttonText,
    this.onButtonPressed,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize ?? 64,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
            ],
            TitleText(
              title,
              size: TitleSize.medium,
              textAlign: TextAlign.center,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              SubtitleText(
                subtitle!,
                size: SubtitleSize.medium,
                textAlign: TextAlign.center,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: buttonText!,
                onPressed: onButtonPressed,
                type: ButtonType.primary,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
