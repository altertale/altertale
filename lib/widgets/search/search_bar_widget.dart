import 'package:flutter/material.dart';
import '../../models/search/book_filter_model.dart';
import '../../services/search/search_service.dart';

/// Arama çubuğu widget'ı
class SearchBarWidget extends StatefulWidget {
  final BookFilterModel currentFilter;
  final Function(BookFilterModel) onFilterChanged;
  final VoidCallback? onFilterTap;

  const SearchBarWidget({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    this.onFilterTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<String> _suggestions = [];
  List<SearchHistoryItem> _searchHistory = [];
  bool _showSuggestions = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.currentFilter.searchQuery ?? '';
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Arama çubuğu
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
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
              // Arama ikonu
              Icon(
                Icons.search,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),

              // Arama metin alanı
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Kitap, yazar veya konu ara...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                  onTap: _onSearchTap,
                  onSubmitted: _onSearchSubmitted,
                ),
              ),

              // Temizle butonu
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                  iconSize: 20,
                ),

              // Filtre butonu
              Container(
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: widget.currentFilter.hasActiveFilters
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: widget.currentFilter.hasActiveFilters
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: widget.onFilterTap,
                  iconSize: 20,
                ),
              ),
            ],
          ),
        ),

        // Öneriler paneli
        if (_showSuggestions &&
            (_suggestions.isNotEmpty || _searchHistory.isNotEmpty))
          _buildSuggestionsPanel(theme),
      ],
    );
  }

  /// Öneriler paneli
  Widget _buildSuggestionsPanel(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arama geçmişi
          if (_searchHistory.isNotEmpty) ...[
            _buildSectionHeader(theme, 'Son Aramalar', Icons.history),
            ..._searchHistory.map((item) => _buildHistoryItem(theme, item)),
            const Divider(height: 1),
          ],

          // Öneriler
          if (_suggestions.isNotEmpty) ...[
            _buildSectionHeader(theme, 'Öneriler', Icons.lightbulb),
            ..._suggestions.map(
              (suggestion) => _buildSuggestionItem(theme, suggestion),
            ),
          ],

          // Popüler arama terimleri
          if (_searchController.text.isEmpty) ...[
            if (_searchHistory.isNotEmpty) const Divider(height: 1),
            _buildSectionHeader(theme, 'Popüler Aramalar', Icons.trending_up),
            _buildPopularSearchTerms(theme),
          ],
        ],
      ),
    );
  }

  /// Bölüm başlığı
  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Geçmiş öğesi
  Widget _buildHistoryItem(ThemeData theme, SearchHistoryItem item) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.history, size: 16),
      title: Text(item.query, style: theme.textTheme.bodyMedium),
      onTap: () => _selectSearchQuery(item.query),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 16),
        onPressed: () => _removeFromHistory(item),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  /// Öneri öğesi
  Widget _buildSuggestionItem(ThemeData theme, String suggestion) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.search, size: 16),
      title: Text(suggestion, style: theme.textTheme.bodyMedium),
      onTap: () => _selectSearchQuery(suggestion),
    );
  }

  /// Popüler arama terimleri
  Widget _buildPopularSearchTerms(ThemeData theme) {
    return FutureBuilder<List<String>>(
      future: _searchService.getPopularSearchTerms(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Wrap(
          padding: const EdgeInsets.all(16),
          spacing: 8,
          runSpacing: 8,
          children: snapshot.data!.map((term) {
            return ActionChip(
              label: Text(term),
              onPressed: () => _selectSearchQuery(term),
            );
          }).toList(),
        );
      },
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Arama değişikliği
  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = true;
        _suggestions = [];
      });
      _loadSearchHistory();
    } else {
      _getSuggestions(query);
    }
  }

  /// Arama tıklaması
  void _onSearchTap() {
    setState(() {
      _showSuggestions = true;
    });
    _loadSearchHistory();
  }

  /// Arama gönderimi
  void _onSearchSubmitted(String query) {
    _performSearch(query);
    setState(() {
      _showSuggestions = false;
    });
  }

  /// Arama temizle
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
    _performSearch('');
  }

  /// Önerileri getir
  void _getSuggestions(String query) {
    setState(() {
      _showSuggestions = true;
      _isLoading = true;
    });

    _searchService.getSuggestions(query).listen((suggestions) {
      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    });
  }

  /// Arama geçmişini yükle
  Future<void> _loadSearchHistory() async {
    final history = await _searchService.getSearchHistory();
    setState(() {
      _searchHistory = history;
    });
  }

  /// Arama sorgusu seç
  void _selectSearchQuery(String query) {
    _searchController.text = query;
    _performSearch(query);
    setState(() {
      _showSuggestions = false;
    });
  }

  /// Geçmişten kaldır
  Future<void> _removeFromHistory(SearchHistoryItem item) async {
    // Bu özellik için SearchService'e removeFromHistory metodu eklenebilir
    // Şimdilik sadece UI'dan kaldırıyoruz
    setState(() {
      _searchHistory.remove(item);
    });
  }

  /// Arama gerçekleştir
  void _performSearch(String query) {
    final sanitizedQuery = _searchService.sanitizeSearchQuery(query);
    final newFilter = widget.currentFilter.withSearchQuery(
      sanitizedQuery.isEmpty ? null : sanitizedQuery,
    );
    widget.onFilterChanged(newFilter);
  }
}
