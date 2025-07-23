import 'package:flutter/material.dart';
import '../../services/offline/offline_service.dart';

/// Bağlantı durumu göstergesi
class ConnectionStatusBar extends StatelessWidget {
  final bool showIcon;
  final bool showText;
  final Color? backgroundColor;
  final Color? textColor;

  const ConnectionStatusBar({
    super.key,
    this.showIcon = true,
    this.showText = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: OfflineService().connectionStatus,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        if (isConnected) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final bgColor = backgroundColor ?? Colors.red;
        final txtColor = textColor ?? Colors.white;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: bgColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showIcon) ...[
                Icon(Icons.wifi_off, color: txtColor, size: 16),
                const SizedBox(width: 8),
              ],
              if (showText)
                Text(
                  'İnternet bağlantısı yok - Çevrimdışı mod',
                  style: TextStyle(
                    color: txtColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
