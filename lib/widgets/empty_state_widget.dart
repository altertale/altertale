import 'package:flutter/material.dart';

/// Empty State Widget - Altertale Uygulaması için İçerik Boş Durumu
///
/// Bu widget, liste boş olduğunda veya içerik bulunamadığında gösterilir.
/// Icon, başlık, açıklama ve action button desteği ile kullanıcı deneyimini iyileştirir.
/// Material 3 design principles'a uygun olarak tasarlanmıştır.
class EmptyStateWidget extends StatelessWidget {
  /// Gösterilecek ikon
  final IconData? icon;

  /// Ana başlık metni
  final String title;

  /// Açıklama metni (opsiyonel)
  final String? description;

  /// Action button metni
  final String? actionText;

  /// Action button fonksiyonu
  final VoidCallback? onAction;

  /// İkincil action button metni
  final String? secondaryActionText;

  /// İkincil action button fonksiyonu
  final VoidCallback? onSecondaryAction;

  /// Custom illustration widget (icon yerine)
  final Widget? illustration;

  /// Icon boyutu
  final double? iconSize;

  /// Icon rengi
  final Color? iconColor;

  /// Başlık rengi
  final Color? titleColor;

  /// Açıklama rengi
  final Color? descriptionColor;

  /// Container padding
  final EdgeInsetsGeometry? padding;

  /// Container margin
  final EdgeInsetsGeometry? margin;

  /// Maksimum genişlik
  final double? maxWidth;

  /// Bileşenler arası boşluk
  final double spacing;

  /// Empty state türü (öntanımlı stiller için)
  final EmptyStateType type;

  const EmptyStateWidget({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.illustration,
    this.iconSize,
    this.iconColor,
    this.titleColor,
    this.descriptionColor,
    this.padding,
    this.margin,
    this.maxWidth,
    this.spacing = 16.0,
    this.type = EmptyStateType.general,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Varsayılan değerler
    final double emptyIconSize = iconSize ?? 64.0;
    final Color emptyIconColor =
        iconColor ?? colorScheme.onSurfaceVariant.withOpacity(0.6);

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(32.0),
      margin: margin,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth ?? 400.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Illustration veya Icon
              _buildIllustration(emptyIconSize, emptyIconColor),

              SizedBox(height: spacing),

              // Başlık
              _buildTitle(theme, colorScheme),

              // Açıklama (varsa)
              if (description != null) ...[
                SizedBox(height: spacing / 2),
                _buildDescription(theme, colorScheme),
              ],

              // Action buttons (varsa)
              if (actionText != null || secondaryActionText != null) ...[
                SizedBox(height: spacing * 1.5),
                _buildActions(theme, colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Illustration veya icon oluşturur
  Widget _buildIllustration(double emptyIconSize, Color emptyIconColor) {
    if (illustration != null) {
      return illustration!;
    }

    if (icon != null) {
      return Icon(icon, size: emptyIconSize, color: emptyIconColor);
    }

    // Type'a göre varsayılan icon
    return Icon(
      _getDefaultIcon(type),
      size: emptyIconSize,
      color: emptyIconColor,
    );
  }

  /// Başlık oluşturur
  Widget _buildTitle(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      title,
      style: theme.textTheme.headlineSmall?.copyWith(
        color: titleColor ?? colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Açıklama oluşturur
  Widget _buildDescription(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      description!,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: descriptionColor ?? colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Action button'ları oluşturur
  Widget _buildActions(ThemeData theme, ColorScheme colorScheme) {
    final List<Widget> actions = [];

    // Primary action
    if (actionText != null && onAction != null) {
      actions.add(
        ElevatedButton(
          onPressed: onAction,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
          ),
          child: Text(actionText!),
        ),
      );
    }

    // Secondary action
    if (secondaryActionText != null && onSecondaryAction != null) {
      if (actions.isNotEmpty) {
        actions.add(const SizedBox(width: 12.0));
      }
      actions.add(
        OutlinedButton(
          onPressed: onSecondaryAction,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
          ),
          child: Text(secondaryActionText!),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12.0,
      runSpacing: 8.0,
      children: actions,
    );
  }

  /// Type'a göre varsayılan icon döndürür
  IconData _getDefaultIcon(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.general:
        return Icons.inbox_outlined;
      case EmptyStateType.search:
        return Icons.search_off_outlined;
      case EmptyStateType.noData:
        return Icons.data_array_outlined;
      case EmptyStateType.noContent:
        return Icons.library_books_outlined;
      case EmptyStateType.noFavorites:
        return Icons.favorite_border_outlined;
      case EmptyStateType.noNotifications:
        return Icons.notifications_none_outlined;
      case EmptyStateType.offline:
        return Icons.cloud_off_outlined;
      case EmptyStateType.error:
        return Icons.error_outline;
      case EmptyStateType.noResults:
        return Icons.find_in_page_outlined;
      case EmptyStateType.noBookmarks:
        return Icons.bookmark_border_outlined;
    }
  }
}

/// Empty state türleri
enum EmptyStateType {
  /// Genel boş durum
  general,

  /// Arama sonucu bulunamadı
  search,

  /// Veri bulunamadı
  noData,

  /// İçerik bulunamadı
  noContent,

  /// Favori bulunamadı
  noFavorites,

  /// Bildirim bulunamadı
  noNotifications,

  /// Çevrimdışı durum
  offline,

  /// Hata durumu
  error,

  /// Sonuç bulunamadı
  noResults,

  /// Bookmark bulunamadı
  noBookmarks,
}

/// Empty State Widget için özel constructor'lar
extension EmptyStateWidgetExtensions on EmptyStateWidget {
  /// Genel boş liste oluşturur
  static EmptyStateWidget emptyList({
    Key? key,
    required String title,
    String? description,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: Icons.inbox_outlined,
      title: title,
      description: description,
      actionText: actionText,
      onAction: onAction,
      type: EmptyStateType.general,
    );
  }

  /// Arama sonucu bulunamadı oluşturur
  static EmptyStateWidget noSearchResults({
    Key? key,
    String? query,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: Icons.search_off_outlined,
      title: 'Sonuç Bulunamadı',
      description: query != null
          ? '"$query" için sonuç bulunamadı. Farklı arama terimleri deneyin.'
          : 'Arama kriterlerinize uygun sonuç bulunamadı.',
      actionText: actionText ?? 'Aramayı Temizle',
      onAction: onAction,
      type: EmptyStateType.search,
    );
  }

  /// Favori bulunamadı oluşturur
  static EmptyStateWidget noFavorites({
    Key? key,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: Icons.favorite_border_outlined,
      title: 'Henüz Favori Yok',
      description:
          'Beğendiğiniz içerikleri favorilerinize ekleyerek '
          'daha sonra kolayca bulabilirsiniz.',
      actionText: actionText ?? 'İçerikleri Keşfet',
      onAction: onAction,
      type: EmptyStateType.noFavorites,
    );
  }

  /// Bildirim bulunamadı oluşturur
  static EmptyStateWidget noNotifications({
    Key? key,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: Icons.notifications_none_outlined,
      title: 'Bildirim Yok',
      description:
          'Henüz hiç bildiriminiz bulunmuyor. '
          'Yeni bildirimler geldiğinde burada görünecek.',
      actionText: actionText,
      onAction: onAction,
      type: EmptyStateType.noNotifications,
    );
  }

  /// Çevrimdışı durum oluşturur
  static EmptyStateWidget offline({
    Key? key,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: Icons.cloud_off_outlined,
      title: 'İnternet Bağlantısı Yok',
      description:
          'Bu içerik için internet bağlantısı gerekiyor. '
          'Bağlantınızı kontrol edip tekrar deneyin.',
      actionText: actionText ?? 'Tekrar Dene',
      onAction: onAction,
      type: EmptyStateType.offline,
    );
  }

  /// Hata durumu oluşturur
  static EmptyStateWidget error({
    Key? key,
    required String title,
    String? description,
    String? actionText,
    VoidCallback? onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: Icons.error_outline,
      title: title,
      description:
          description ??
          'Beklenmeyen bir hata oluştu. '
              'Lütfen daha sonra tekrar deneyin.',
      actionText: actionText ?? 'Tekrar Dene',
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      type: EmptyStateType.error,
      iconColor: Colors.red.shade400,
    );
  }

  /// Kitap bulunamadı oluşturur
  static EmptyStateWidget noBooks({
    Key? key,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: Icons.library_books_outlined,
      title: 'Henüz Kitap Yok',
      description:
          'Okumak için henüz kitap eklememişsiniz. '
          'Kütüphanedeki kitapları keşfedin.',
      actionText: actionText ?? 'Kitapları Keşfet',
      onAction: onAction,
      type: EmptyStateType.noContent,
    );
  }

  /// Bookmark bulunamadı oluşturur
  static EmptyStateWidget noBookmarks({
    Key? key,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: Icons.bookmark_border_outlined,
      title: 'Henüz Bookmark Yok',
      description:
          'Önemli sayfaları bookmark\'layarak '
          'daha sonra kolayca erişebilirsiniz.',
      actionText: actionText,
      onAction: onAction,
      type: EmptyStateType.noBookmarks,
    );
  }

  /// Reading history boş oluşturur
  static EmptyStateWidget noReadingHistory({
    Key? key,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: Icons.history_outlined,
      title: 'Okuma Geçmişi Boş',
      description:
          'Henüz hiç kitap okumamışsınız. '
          'Okumaya başlayın ve geçmişiniz burada görünsün.',
      actionText: actionText ?? 'Okumaya Başla',
      onAction: onAction,
      type: EmptyStateType.noContent,
    );
  }

  /// Custom illustration ile oluşturur
  static EmptyStateWidget withIllustration({
    Key? key,
    required Widget illustration,
    required String title,
    String? description,
    String? actionText,
    VoidCallback? onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
  }) {
    return EmptyStateWidget(
      key: key,
      illustration: illustration,
      title: title,
      description: description,
      actionText: actionText,
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
    );
  }

  /// Compact (küçük) empty state oluşturur
  static EmptyStateWidget compact({
    Key? key,
    required String title,
    String? description,
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: icon ?? Icons.inbox_outlined,
      title: title,
      description: description,
      actionText: actionText,
      onAction: onAction,
      padding: const EdgeInsets.all(20.0),
      iconSize: 48.0,
      spacing: 12.0,
      maxWidth: 300.0,
    );
  }

  /// Large (büyük) empty state oluşturur
  static EmptyStateWidget large({
    Key? key,
    required String title,
    String? description,
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
  }) {
    return EmptyStateWidget(
      key: key,
      icon: icon ?? Icons.inbox_outlined,
      title: title,
      description: description,
      actionText: actionText,
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      padding: const EdgeInsets.all(48.0),
      iconSize: 80.0,
      spacing: 24.0,
      maxWidth: 500.0,
    );
  }
}
