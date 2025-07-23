import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../providers/auth_provider.dart';

/// Bildirim merkezi ekranı
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;
  String? _error;
  String _selectedFilter = 'all';

  final List<Map<String, String>> _filterOptions = [
    {'value': 'all', 'label': 'Tümü'},
    {'value': 'unread', 'label': 'Okunmamış'},
    {'value': 'book_update', 'label': 'Kitap Güncellemeleri'},
    {'value': 'referral', 'label': 'Referanslar'},
    {'value': 'points', 'label': 'Puanlar'},
    {'value': 'comment', 'label': 'Yorumlar'},
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bildirimler')),
        body: const Center(child: Text('Giriş yapmanız gerekiyor')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Tümünü Okundu İşaretle',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget(theme)
          : Column(
              children: [
                // Filtre seçenekleri
                _buildFilterSection(theme),

                // Bildirim listesi
                Expanded(
                  child: _notifications.isEmpty
                      ? _buildEmptyWidget(theme)
                      : _buildNotificationList(theme),
                ),
              ],
            ),
    );
  }

  /// Hata widget'ı
  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Bir hata oluştu', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNotifications,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  /// Boş durum widget'ı
  Widget _buildEmptyWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text('Henüz bildiriminiz yok', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Yeni bildirimler geldiğinde burada görünecek',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Filtre bölümü
  Widget _buildFilterSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrele',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((option) {
                final isSelected = _selectedFilter == option['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(option['label']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = option['value']!;
                      });
                      _loadNotifications();
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.primary.withValues(
                      alpha: 0.2,
                    ),
                    checkmarkColor: theme.colorScheme.primary,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Bildirim listesi
  Widget _buildNotificationList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationItem(theme, notification);
      },
    );
  }

  /// Bildirim öğesi
  Widget _buildNotificationItem(
    ThemeData theme,
    NotificationModel notification,
  ) {
    final isUnread = !notification.isRead;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isUnread
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(
            notification.type,
          ).withValues(alpha: 0.1),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ),
        trailing: isUnread
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () => _handleNotificationTap(notification),
        onLongPress: () => _showNotificationOptions(notification),
      ),
    );
  }

  /// Bildirim türüne göre renk
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'book_update':
        return Colors.blue;
      case 'referral':
        return Colors.green;
      case 'points':
        return Colors.orange;
      case 'comment':
        return Colors.purple;
      case 'promotion':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Bildirim türüne göre ikon
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'book_update':
        return Icons.book;
      case 'referral':
        return Icons.people;
      case 'points':
        return Icons.stars;
      case 'comment':
        return Icons.comment;
      case 'promotion':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  /// Tarih formatla
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  /// Bildirim seçenekleri
  void _showNotificationOptions(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Bildirimi Sil'),
              onTap: () {
                Navigator.of(context).pop();
                _deleteNotification(notification);
              },
            ),
            if (!notification.isRead)
              ListTile(
                leading: const Icon(Icons.mark_email_read),
                title: const Text('Okundu İşaretle'),
                onTap: () {
                  Navigator.of(context).pop();
                  _markAsRead(notification);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Bildirimlere tıklama
  void _handleNotificationTap(NotificationModel notification) {
    // Bildirimi okundu işaretle
    if (!notification.isRead) {
      _markAsRead(notification);
    }

    // Bildirim türüne göre yönlendirme
    switch (notification.type) {
      case 'book_update':
        // Kitap detay sayfasına git
        break;
      case 'referral':
        // Referans sayfasına git
        break;
      case 'points':
        // Puan sayfasına git
        break;
      case 'comment':
        // Yorum sayfasına git
        break;
      default:
        // Genel bildirim - hiçbir şey yapma
        break;
    }
  }

  /// Bildirimleri yükle
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        setState(() {
          _error = 'Kullanıcı bilgisi bulunamadı';
          _isLoading = false;
        });
        return;
      }

      List<NotificationModel> notifications;

      if (_selectedFilter == 'all') {
        notifications = await _notificationService.getNotifications(
          currentUser.uid,
        );
      } else if (_selectedFilter == 'unread') {
        notifications = await _notificationService.getNotifications(
          currentUser.uid,
        );
        notifications = notifications.where((n) => !n.isRead).toList();
      } else {
        notifications = _notificationService.getNotificationsByType(
          userId: currentUser.uid,
          type: _selectedFilter,
        );
      }

      final stats = _notificationService.getNotificationStats(currentUser.uid);

      setState(() {
        _notifications = notifications;
        _unreadCount = stats['unreadNotifications'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Bildirimi okundu işaretle
  Future<void> _markAsRead(NotificationModel notification) async {
    try {
      _notificationService.markAsRead(notification.id);
      _loadNotifications(); // Listeyi yenile
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  /// Tümünü okundu işaretle
  Future<void> _markAllAsRead() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser == null) return;

      _notificationService.markAllAsRead(currentUser.uid);
      _loadNotifications(); // Listeyi yenile

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tüm bildirimler okundu işaretlendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  /// Bildirimi sil
  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      _notificationService.deleteNotification(notification.id);
      _loadNotifications(); // Listeyi yenile

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bildirim silindi')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }
}
