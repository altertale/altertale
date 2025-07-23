import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';

/// Bildirim badge widget'ı - okunmamış bildirim sayısını gösterir
class NotificationBadge extends StatefulWidget {
  final Widget child;
  final double? size;
  final Color? backgroundColor;
  final Color? textColor;

  const NotificationBadge({
    super.key,
    required this.child,
    this.size,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        widget.child,
        if (_unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: widget.size ?? 20,
              height: widget.size ?? 20,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? theme.colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                  style: TextStyle(
                    color: widget.textColor ?? Colors.white,
                    fontSize: (widget.size ?? 20) * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        if (_isLoading)
          Positioned(
            right: 0,
            top: 0,
            child: SizedBox(
              width: widget.size ?? 20,
              height: widget.size ?? 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.backgroundColor ?? theme.colorScheme.error,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Okunmamış bildirim sayısını yükle
  Future<void> _loadUnreadCount() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final stats = _notificationService.getNotificationStats(currentUser.uid);

      setState(() {
        _unreadCount = stats['unreadNotifications'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Badge'i yenile
  void refresh() {
    _loadUnreadCount();
  }
}
