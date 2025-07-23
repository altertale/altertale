import 'package:flutter/material.dart';
import '../../services/admin/admin_service.dart';
import '../../widgets/offline/connection_status_bar.dart';
import 'admin_dashboard_screen.dart';
import 'book_management_screen.dart';
import 'comment_moderation_screen.dart';
import 'user_point_manager.dart';
import 'notification_sender.dart';

/// Ana admin panel ekranı
class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final AdminService _adminService = AdminService();
  
  int _selectedIndex = 0;
  bool _isAdmin = false;
  bool _isLoading = true;

  final List<AdminMenuItem> _menuItems = [
    AdminMenuItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      screen: const AdminDashboardScreen(),
    ),
    AdminMenuItem(
      title: 'Kitap Yönetimi',
      icon: Icons.book,
      screen: const BookManagementScreen(),
    ),
    AdminMenuItem(
      title: 'Yorum Moderasyonu',
      icon: Icons.comment,
      screen: const CommentModerationScreen(),
    ),
    AdminMenuItem(
      title: 'Puan Yönetimi',
      icon: Icons.stars,
      screen: const UserPointManager(),
    ),
    AdminMenuItem(
      title: 'Bildirim Gönder',
      icon: Icons.notifications,
      screen: const NotificationSender(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erişim Reddedildi',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Bu sayfaya erişim yetkiniz bulunmamaktadır.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_menuItems[_selectedIndex].title),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: Column(
        children: [
          // Bağlantı durumu çubuğu
          ConnectionStatusBar(),
          
          // Ana içerik
          Expanded(
            child: _menuItems[_selectedIndex].screen,
          ),
        ],
      ),
      drawer: _buildDrawer(theme),
      bottomNavigationBar: _buildBottomNavigationBar(theme),
    );
  }

  /// Drawer menü
  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      child: Column(
        children: [
          // Drawer header
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.onPrimary,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: theme.colorScheme.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Admin Panel',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Altertale Yönetimi',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedIndex == index;
                
                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected ? theme.colorScheme.primary : null,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    Navigator.pop(context); // Drawer'ı kapat
                  },
                );
              },
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Hakkında'),
                  onTap: _showAboutDialog,
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Çıkış Yap'),
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Alt navigasyon çubuğu
  Widget _buildBottomNavigationBar(ThemeData theme) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      items: _menuItems.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.title,
        );
      }).toList(),
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Admin durumunu kontrol et
  Future<void> _checkAdminStatus() async {
    try {
      final isAdmin = await _adminService.isCurrentUserAdmin();
      setState(() {
        _isAdmin = isAdmin;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isAdmin = false;
        _isLoading = false;
      });
    }
  }

  /// Çıkış yap
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Admin panelinden çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog'u kapat
              Navigator.pop(context); // Admin panelini kapat
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  /// Hakkında dialog'u göster
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Panel Hakkında'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Altertale Admin Panel'),
            SizedBox(height: 8),
            Text('Versiyon: 1.0.0'),
            SizedBox(height: 8),
            Text('Bu panel yalnızca yetkili admin kullanıcılar tarafından kullanılabilir.'),
            SizedBox(height: 8),
            Text('Özellikler:'),
            Text('• Kitap yönetimi'),
            Text('• Yorum moderasyonu'),
            Text('• Puan yönetimi'),
            Text('• Bildirim gönderme'),
            Text('• İstatistik ve raporlama'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

/// Admin menü öğesi modeli
class AdminMenuItem {
  final String title;
  final IconData icon;
  final Widget screen;

  AdminMenuItem({
    required this.title,
    required this.icon,
    required this.screen,
  });
}
