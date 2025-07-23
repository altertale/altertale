import 'package:flutter/material.dart';
import '../../models/search/book_filter_model.dart';

/// Filtre etiketleri widget'ı
class FilterChipsWidget extends StatelessWidget {
  final BookFilterModel filter;
  final Function(BookFilterModel) onFilterChanged;

  const FilterChipsWidget({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!filter.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(
                Icons.filter_list,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                'Aktif Filtreler (${filter.filterCount})',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Temizle'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Filtre etiketleri
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Arama sorgusu
              if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty)
                _buildFilterChip(
                  theme,
                  'Arama: "${filter.searchQuery}"',
                  Icons.search,
                  () => _removeSearchQuery(),
                ),
              
              // Kategoriler
              ...filter.categories.map((category) => _buildFilterChip(
                theme,
                category,
                Icons.category,
                () => _removeCategory(category),
              )),
              
              // Etiketler
              ...filter.tags.map((tag) => _buildFilterChip(
                theme,
                tag,
                Icons.label,
                () => _removeTag(tag),
              )),
              
              // Puan ile satın alma
              if (filter.canPurchaseWithPoints != null)
                _buildFilterChip(
                  theme,
                  filter.canPurchaseWithPoints! ? 'Puan ile Alınabilir' : 'Sadece Para ile',
                  Icons.stars,
                  () => _removePurchaseFilter(),
                ),
              
              // Yayın durumu
              if (filter.isPublished != null)
                _buildFilterChip(
                  theme,
                  filter.isPublished! ? 'Yayında' : 'Taslak',
                  Icons.publish,
                  () => _removePublishedFilter(),
                ),
              
              // Puan aralığı
              if (filter.pointsRange != null)
                _buildFilterChip(
                  theme,
                  '${filter.pointsRange!.start.round()}-${filter.pointsRange!.end.round()} puan',
                  Icons.attach_money,
                  () => _removePointsRange(),
                ),
              
              // Sıralama
              if (filter.sortOrder != SortOrder.newest)
                _buildFilterChip(
                  theme,
                  filter.sortOrder.displayName,
                  Icons.sort,
                  () => _removeSortOrder(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Filtre etiketi oluştur
  Widget _buildFilterChip(
    ThemeData theme,
    String label,
    IconData icon,
    VoidCallback onRemove,
  ) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  // ==================== FİLTRE KALDIRMA FONKSİYONLARI ====================

  /// Tüm filtreleri temizle
  void _clearAllFilters() {
    onFilterChanged(const BookFilterModel());
  }

  /// Arama sorgusunu kaldır
  void _removeSearchQuery() {
    onFilterChanged(filter.withSearchQuery(null));
  }

  /// Kategori kaldır
  void _removeCategory(String category) {
    onFilterChanged(filter.withoutCategory(category));
  }

  /// Etiket kaldır
  void _removeTag(String tag) {
    onFilterChanged(filter.withoutTag(tag));
  }

  /// Puan ile satın alma filtresini kaldır
  void _removePurchaseFilter() {
    onFilterChanged(filter.withPurchaseWithPoints(null));
  }

  /// Yayın durumu filtresini kaldır
  void _removePublishedFilter() {
    onFilterChanged(filter.withPublishedStatus(null));
  }

  /// Puan aralığı filtresini kaldır
  void _removePointsRange() {
    onFilterChanged(filter.withPointsRange(null));
  }

  /// Sıralama filtresini kaldır
  void _removeSortOrder() {
    onFilterChanged(filter.withSortOrder(SortOrder.newest));
  }
}
