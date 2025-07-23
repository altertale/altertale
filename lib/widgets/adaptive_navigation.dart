import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';

/// Platform bazlı uyarlanabilir navigasyon widget'ı
class AdaptiveNavigation extends StatelessWidget {
  final Widget child;
  final List<NavigationItem> items;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final Widget? leading;
  final List<Widget>? actions;
  final String? title;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const AdaptiveNavigation({
    super.key,
    required this.child,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.leading,
    this.actions,
    this.title,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final breakpoint = PlatformUtils.getResponsiveBreakpoint(context);
    final isWeb = PlatformUtils.isWeb;

    if (isWeb && breakpoint != ResponsiveBreakpoint.smallMobile) {
      // Web'de masaüstü ve tablet için sol menü
      return _buildWebLayout(context, breakpoint);
    } else {
      // Mobilde drawer menü
      return _buildMobileLayout(context);
    }
  }

  /// Web layout - Sol menü ile
  Widget _buildWebLayout(
    BuildContext context,
    ResponsiveBreakpoint breakpoint,
  ) {
    final theme = Theme.of(context);
    final isDesktop = breakpoint == ResponsiveBreakpoint.desktop;
    final drawerWidth = isDesktop ? 280.0 : 240.0;

    return Scaffold(
      body: Row(
        children: [
          // Sol navigasyon menüsü
          Container(
            width: drawerWidth,
            decoration: BoxDecoration(
              color: backgroundColor ?? theme.colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Başlık alanı
                _buildWebHeader(context, theme),

                // Menü öğeleri
                Expanded(child: _buildWebNavigationItems(context, theme)),

                // Alt alan (kullanıcı bilgileri, ayarlar vs.)
                _buildWebFooter(context, theme),
              ],
            ),
          ),

          // Ana içerik alanı
          Expanded(child: _buildWebContent(context, theme)),
        ],
      ),
    );
  }

  /// Web header widget'ı
  Widget _buildWebHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo/İkon
          Icon(Icons.book, size: 32, color: theme.colorScheme.primary),
          const SizedBox(width: 12),

          // Başlık
          Expanded(
            child: Text(
              title ?? 'Altertale',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: foregroundColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Web navigation items widget'ı
  Widget _buildWebNavigationItems(BuildContext context, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedIndex == index;

        return _buildWebNavigationItem(context, theme, item, index, isSelected);
      },
    );
  }

  /// Web navigation item widget'ı
  Widget _buildWebNavigationItem(
    BuildContext context,
    ThemeData theme,
    NavigationItem item,
    int index,
    bool isSelected,
  ) {
    final breakpoint = PlatformUtils.getResponsiveBreakpoint(context);
    final isDesktop = breakpoint == ResponsiveBreakpoint.desktop;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 20.0 : 16.0,
              vertical: isDesktop ? 16.0 : 12.0,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
              border: isSelected
                  ? Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // İkon
                Icon(
                  item.icon,
                  size: isDesktop ? 24.0 : 20.0,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : foregroundColor ??
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),

                // Başlık
                Expanded(
                  child: Text(
                    item.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : foregroundColor ?? theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                // Badge (varsa)
                if (item.badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      item.badge!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Web footer widget'ı
  Widget _buildWebFooter(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Kullanıcı bilgileri (gelecekte eklenecek)
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kullanıcı',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Giriş yapıldı',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Ayarlar menüsü
                  },
                  icon: Icon(
                    Icons.settings,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Web content widget'ı
  Widget _buildWebContent(BuildContext context, ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Üst bar (mobilde app bar yerine)
          if (actions != null || title != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),

          // Ana içerik
          Expanded(child: child),
        ],
      ),
    );
  }

  /// Mobil layout - Drawer menü ile
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        actions: actions,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation,
      ),
      drawer: _buildMobileDrawer(context),
      body: child,
      bottomNavigationBar: _buildMobileBottomNavigation(context),
    );
  }

  /// Mobil drawer widget'ı
  Widget _buildMobileDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // Drawer header
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.surface),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.book, size: 48, color: theme.colorScheme.onPrimary),
                const SizedBox(height: 12),
                Text(
                  title ?? 'Altertale',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sadece Uygulama İçi Okuma',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Drawer items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedIndex == index;

                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: item.badge != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            item.badge!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
                  selected: isSelected,
                  onTap: () {
                    Navigator.pop(context); // Drawer'ı kapat
                    onItemSelected(index);
                  },
                );
              },
            ),
          ),

          // Drawer footer
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Ayarlar'),
                  onTap: () {
                    Navigator.pop(context);
                    // Ayarlar sayfasına git
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Yardım'),
                  onTap: () {
                    Navigator.pop(context);
                    // Yardım sayfasına git
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mobil bottom navigation widget'ı
  Widget _buildMobileBottomNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final maxItems = 5; // Bottom navigation maksimum 5 öğe

    // İlk 5 öğeyi al
    final bottomItems = items.take(maxItems).toList();

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex < maxItems ? selectedIndex : 0,
      onTap: (index) => onItemSelected(index),
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      items: bottomItems.map((item) {
        return BottomNavigationBarItem(
          icon: Stack(
            children: [
              Icon(item.icon),
              if (item.badge != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      item.badge!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onError,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: item.title,
        );
      }).toList(),
    );
  }
}

/// Navigation item modeli
class NavigationItem {
  final String title;
  final IconData icon;
  final String? badge;
  final String? route;

  const NavigationItem({
    required this.title,
    required this.icon,
    this.badge,
    this.route,
  });
}

/// Platform bazlı navigation builder
class PlatformNavigation extends StatelessWidget {
  final Widget child;
  final List<NavigationItem> items;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final Widget? leading;
  final List<Widget>? actions;
  final String? title;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const PlatformNavigation({
    super.key,
    required this.child,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.leading,
    this.actions,
    this.title,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      builder: (context, isWeb, isMobile) {
        return AdaptiveNavigation(
          items: items,
          selectedIndex: selectedIndex,
          onItemSelected: onItemSelected,
          leading: leading,
          actions: actions,
          title: title,
          automaticallyImplyLeading: automaticallyImplyLeading,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: elevation,
          child: child,
        );
      },
    );
  }
}
