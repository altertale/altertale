import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Content List Screen
///
/// Content browsing screen with:
/// - Content list display
/// - Search and filter options
/// - Content navigation
/// - Temporary placeholder UI
/// - Grid/list view toggle
class ContentListScreen extends StatefulWidget {
  const ContentListScreen({super.key});

  @override
  State<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends State<ContentListScreen> {
  // ==================== STATE ====================
  bool _isGridView = true;
  String _searchQuery = '';

  // ==================== DUMMY DATA ====================
  final List<ContentItem> _contentItems = [
    ContentItem(
      id: '1',
      title: 'Örnek Hikaye 1',
      author: 'Yazar Adı',
      description:
          'Bu örnek bir hikaye açıklamasıdır. Gerçek içerik burada görünecek.',
      coverUrl: null,
      category: 'Roman',
      rating: 4.5,
      readCount: 1250,
    ),
    ContentItem(
      id: '2',
      title: 'Örnek Hikaye 2',
      author: 'Başka Yazar',
      description: 'İkinci örnek hikaye açıklaması. UI test için kullanılıyor.',
      coverUrl: null,
      category: 'Macera',
      rating: 4.2,
      readCount: 980,
    ),
    ContentItem(
      id: '3',
      title: 'Örnek Hikaye 3',
      author: 'Üçüncü Yazar',
      description: 'Üçüncü örnek hikaye. Daha fazla içerik eklenecek.',
      coverUrl: null,
      category: 'Fantastik',
      rating: 4.8,
      readCount: 2100,
    ),
  ];

  List<ContentItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _contentItems;

    return _contentItems.where((item) {
      return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İçerikler'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'Liste Görünümü' : 'Izgara Görünümü',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(theme),

          // Content List/Grid
          Expanded(
            child: _filteredItems.isEmpty
                ? _buildEmptyState(theme)
                : _isGridView
                ? _buildGridView(theme)
                : _buildListView(theme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new content functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yeni içerik ekleme özelliği yakında!'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Hikaye, yazar veya kategori ara...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),

          const SizedBox(height: 16),

          Text(
            'Sonuç Bulunamadı',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Aradığınız kriterlere uygun içerik bulunamadı.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
            },
            child: const Text('Aramayı Temizle'),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildGridItemCard(item, theme);
      },
    );
  }

  Widget _buildListView(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildListItemCard(item, theme);
      },
    );
  }

  Widget _buildGridItemCard(ContentItem item, ThemeData theme) {
    return Card(
      child: InkWell(
        onTap: () => _navigateToDetail(item.id),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Placeholder
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Icon(
                  Icons.auto_stories,
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),

            // Content Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      item.author,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          item.rating.toString(),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItemCard(ContentItem item, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(item.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Cover Image Placeholder
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_stories,
                  size: 32,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 16),

              // Content Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      item.author,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),

                        const Spacer(),

                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          item.rating.toString(),
                          style: theme.textTheme.bodySmall,
                        ),

                        const SizedBox(width: 16),

                        Icon(
                          Icons.visibility,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.readCount}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(String contentId) {
    context.go('/content/$contentId');
  }
}

/// Content Item Model for UI
class ContentItem {
  final String id;
  final String title;
  final String author;
  final String description;
  final String? coverUrl;
  final String category;
  final double rating;
  final int readCount;

  const ContentItem({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    this.coverUrl,
    required this.category,
    required this.rating,
    required this.readCount,
  });
}
