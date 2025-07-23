import 'package:flutter/material.dart';
import '../../models/search/book_filter_model.dart';
import '../../services/search/search_service.dart';

/// Filtre modal widget'ı
class FilterModal extends StatefulWidget {
  final BookFilterModel currentFilter;
  final Function(BookFilterModel) onFilterChanged;

  const FilterModal({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final SearchService _searchService = SearchService();
  
  late BookFilterModel _filter;
  List<String> _categories = [];
  List<String> _tags = [];
  RangeValues _pointsRange = const RangeValues(0, 1000);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _loadFilterData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(theme),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(theme),
          ),
        ],
      ),
    );
  }

  /// Header widget'ı
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Filtreler',
            style: theme.textTheme.titleLarge,
          ),
          const Spacer(),
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Temizle'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _applyFilters,
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  /// İçerik widget'ı
  Widget _buildContent(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Kategori filtresi
        _buildCategoryFilter(theme),
        const SizedBox(height: 24),
        
        // Etiket filtresi
        _buildTagFilter(theme),
        const SizedBox(height: 24),
        
        // Puan ile satın alma filtresi
        _buildPurchaseFilter(theme),
        const SizedBox(height: 24),
        
        // Yayın durumu filtresi
        _buildPublishedFilter(theme),
        const SizedBox(height: 24),
        
        // Puan aralığı filtresi
        _buildPointsRangeFilter(theme),
        const SizedBox(height: 24),
        
        // Sıralama filtresi
        _buildSortFilter(theme),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Kategori filtresi
  Widget _buildCategoryFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategoriler',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        if (_categories.isEmpty)
          Text(
            'Kategori bulunamadı',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              final isSelected = _filter.categories.contains(category);
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _filter = _filter.withCategory(category);
                    } else {
                      _filter = _filter.withoutCategory(category);
                    }
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  /// Etiket filtresi
  Widget _buildTagFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etiketler',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        if (_tags.isEmpty)
          Text(
            'Etiket bulunamadı',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              final isSelected = _filter.tags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _filter = _filter.withTag(tag);
                    } else {
                      _filter = _filter.withoutTag(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  /// Puan ile satın alma filtresi
  Widget _buildPurchaseFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Puan ile Satın Alma',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        SegmentedButton<bool?>(
          segments: const [
            ButtonSegment<bool?>(
              value: null,
              label: Text('Tümü'),
            ),
            ButtonSegment<bool?>(
              value: true,
              label: Text('Evet'),
            ),
            ButtonSegment<bool?>(
              value: false,
              label: Text('Hayır'),
            ),
          ],
          selected: {_filter.canPurchaseWithPoints},
          onSelectionChanged: (Set<bool?> selection) {
            setState(() {
              final value = selection.isNotEmpty ? selection.first : null;
              _filter = _filter.withPurchaseWithPoints(value);
            });
          },
        ),
      ],
    );
  }

  /// Yayın durumu filtresi
  Widget _buildPublishedFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yayın Durumu',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        SegmentedButton<bool?>(
          segments: const [
            ButtonSegment<bool?>(
              value: null,
              label: Text('Tümü'),
            ),
            ButtonSegment<bool?>(
              value: true,
              label: Text('Yayında'),
            ),
            ButtonSegment<bool?>(
              value: false,
              label: Text('Taslak'),
            ),
          ],
          selected: {_filter.isPublished},
          onSelectionChanged: (Set<bool?> selection) {
            setState(() {
              final value = selection.isNotEmpty ? selection.first : null;
              _filter = _filter.withPublishedStatus(value);
            });
          },
        ),
      ],
    );
  }

  /// Puan aralığı filtresi
  Widget _buildPointsRangeFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Puan Aralığı',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        RangeSlider(
          values: _filter.pointsRange ?? _pointsRange,
          min: _pointsRange.start,
          max: _pointsRange.end,
          divisions: 20,
          labels: RangeLabels(
            '${_filter.pointsRange?.start.round() ?? _pointsRange.start.round()}',
            '${_filter.pointsRange?.end.round() ?? _pointsRange.end.round()}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _filter = _filter.withPointsRange(values);
            });
          },
        ),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_filter.pointsRange?.start.round() ?? _pointsRange.start.round()} puan',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              '${_filter.pointsRange?.end.round() ?? _pointsRange.end.round()} puan',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  /// Sıralama filtresi
  Widget _buildSortFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sıralama',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        DropdownButtonFormField<SortOrder>(
          value: _filter.sortOrder,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: SortOrder.values.map((order) {
            return DropdownMenuItem(
              value: order,
              child: Text(order.displayName),
            );
          }).toList(),
          onChanged: (SortOrder? value) {
            if (value != null) {
              setState(() {
                _filter = _filter.withSortOrder(value);
              });
            }
          },
        ),
      ],
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Filtre verilerini yükle
  Future<void> _loadFilterData() async {
    try {
      final results = await Future.wait([
        _searchService.getCategories(),
        _searchService.getTags(),
        _searchService.getPointsRange(),
      ]);

      setState(() {
        _categories = results[0];
        _tags = results[1];
        _pointsRange = results[2];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Tüm filtreleri temizle
  void _clearAllFilters() {
    setState(() {
      _filter = const BookFilterModel();
    });
  }

  /// Filtreleri uygula
  void _applyFilters() {
    widget.onFilterChanged(_filter);
    Navigator.pop(context);
  }
}
