import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Ayarlar switch öğesi widget'ı
/// Açık/kapalı durumu olan ayarlar için kullanılır
class SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const SettingsSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.getTextPrimaryColor(isDark),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.getTextSecondaryColor(isDark),
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withOpacity(0.3),
        inactiveThumbColor: AppColors.getTextTertiaryColor(isDark),
        inactiveTrackColor: AppColors.getTextTertiaryColor(isDark).withOpacity(0.3),
      ),
      onTap: enabled && onChanged != null
          ? () => onChanged!(!value)
          : null,
      enabled: enabled,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
    );
  }
} 