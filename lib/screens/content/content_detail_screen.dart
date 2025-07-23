import 'package:flutter/material.dart';

/// Content Detail Screen
///
/// Content detail view with:
/// - Content information display
/// - Reading options
/// - User interactions
/// - Temporary placeholder UI
/// - Navigation controls
class ContentDetailScreen extends StatefulWidget {
  final String contentId;

  const ContentDetailScreen({super.key, required this.contentId});

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  // ==================== STATE ====================
  bool _isLiked = false;
  bool _isBookmarked = false;

  // ==================== DUMMY DATA ====================
  late final ContentDetailData _contentData;

  @override
  void initState() {
    super.initState();
    _contentData = ContentDetailData(
      id: widget.contentId,
      title: 'Örnek Hikaye ${widget.contentId}',
      author: 'Yazar Adı',
      description:
          'Bu örnek bir hikaye açıklamasıdır. Gerçek içerik burada görünecek. '
          'Hikaye hakkında detaylı bilgiler, karakterler ve özet burada yer alacak.',
      fullDescription:
          'Uzun açıklama metni buraya gelecek. Bu kısımda hikayenin '
          'detaylı özeti, karakterler hakkında bilgiler ve daha fazla detay bulunacak. '
          'Okuyucuların hikaye hakkında kapsamlı bilgi edinebileceği alan.',
      coverUrl: null,
      category: 'Roman',
      tags: ['macera', 'gençlik', 'aşk'],
      rating: 4.5,
      ratingCount: 234,
      readCount: 1250,
      chapterCount: 15,
      wordCount: 45000,
      publishDate: DateTime.now().subtract(const Duration(days: 30)),
      lastUpdateDate: DateTime.now().subtract(const Duration(days: 5)),
      isCompleted: false,
      isPremium: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          _buildSliverAppBar(theme),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Author
                  _buildTitleSection(theme),

                  const SizedBox(height: 16),

                  // Stats Row
                  _buildStatsRow(theme),

                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(theme),

                  const SizedBox(height: 24),

                  // Description
                  _buildDescriptionSection(theme),

                  const SizedBox(height: 24),

                  // Tags
                  _buildTagsSection(theme),

                  const SizedBox(height: 24),

                  // Info Cards
                  _buildInfoCards(theme),

                  const SizedBox(height: 24),

                  // Comments Preview
                  _buildCommentsPreview(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: theme.colorScheme.primaryContainer,
      foregroundColor: theme.colorScheme.onPrimaryContainer,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.primaryContainer.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.auto_stories,
              size: 80,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
          onPressed: () {
            setState(() {
              _isBookmarked = !_isBookmarked;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isBookmarked
                      ? 'Yer imine eklendi'
                      : 'Yer iminden kaldırıldı',
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Paylaşım özelliği yakında!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTitleSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _contentData.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Text(
              'Yazar: ',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              _contentData.author,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      children: [
        _buildStatItem(
          Icons.star,
          '${_contentData.rating}',
          '(${_contentData.ratingCount})',
          Colors.amber,
          theme,
        ),

        const SizedBox(width: 24),

        _buildStatItem(
          Icons.visibility,
          '${_contentData.readCount}',
          'okuma',
          theme.colorScheme.primary,
          theme,
        ),

        const SizedBox(width: 24),

        _buildStatItem(
          Icons.menu_book,
          '${_contentData.chapterCount}',
          'bölüm',
          theme.colorScheme.secondary,
          theme,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Okuma özelliği yakında!')),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Okumaya Başla'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _isLiked = !_isLiked;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isLiked ? 'Beğenildi!' : 'Beğeni kaldırıldı'),
                ),
              );
            },
            icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
            label: const Text('Beğen'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: _isLiked ? Colors.red : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Açıklama',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          _contentData.fullDescription,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      ],
    );
  }

  Widget _buildTagsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etiketler',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _contentData.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '#$tag',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoCards(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detaylar',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Kelime Sayısı',
                '${_contentData.wordCount}',
                Icons.text_fields,
                theme,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildInfoCard(
                'Kategori',
                _contentData.category,
                Icons.category,
                theme,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Durum',
                _contentData.isCompleted ? 'Tamamlandı' : 'Devam Ediyor',
                _contentData.isCompleted ? Icons.check_circle : Icons.schedule,
                theme,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildInfoCard(
                'Tür',
                _contentData.isPremium ? 'Premium' : 'Ücretsiz',
                _contentData.isPremium ? Icons.star : Icons.lock_open,
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),

            const SizedBox(height: 8),

            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsPreview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Yorumlar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tüm yorumlar yakında!')),
                );
              },
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.comment,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),

                const SizedBox(height: 16),

                Text(
                  'Henüz Yorum Yok',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Bu hikayanin ilk yorumunu siz yapın!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Yorum yazma özelliği yakında!'),
                      ),
                    );
                  },
                  child: const Text('Yorum Yaz'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Content Detail Data Model for UI
class ContentDetailData {
  final String id;
  final String title;
  final String author;
  final String description;
  final String fullDescription;
  final String? coverUrl;
  final String category;
  final List<String> tags;
  final double rating;
  final int ratingCount;
  final int readCount;
  final int chapterCount;
  final int wordCount;
  final DateTime publishDate;
  final DateTime lastUpdateDate;
  final bool isCompleted;
  final bool isPremium;

  const ContentDetailData({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.fullDescription,
    this.coverUrl,
    required this.category,
    required this.tags,
    required this.rating,
    required this.ratingCount,
    required this.readCount,
    required this.chapterCount,
    required this.wordCount,
    required this.publishDate,
    required this.lastUpdateDate,
    required this.isCompleted,
    required this.isPremium,
  });
}
