import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/widgets.dart';

/// Feed Screen - Topluluk Akışı Ekranı
///
/// Kullanıcıların yorumlarını, değerlendirmelerini ve
/// etkileşimlerini görebileceği topluluk akışı ekranı.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<FeedItem> _feedItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFeedData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadFeedData() {
    // Dummy feed data
    _feedItems.addAll([
      FeedItem(
        id: '1',
        type: FeedItemType.review,
        userName: 'Ahmet Yılmaz',
        userAvatar: 'A',
        bookTitle: 'Gizemli Orman',
        content:
            'Harika bir kitap! Başından sonuna kadar sürükleyici. '
            'Karakterlerin gelişimi çok etkileyici.',
        rating: 5.0,
        likeCount: 24,
        commentCount: 8,
        timeAgo: '2 saat önce',
        isLiked: false,
      ),
      FeedItem(
        id: '2',
        type: FeedItemType.comment,
        userName: 'Elif Demir',
        userAvatar: 'E',
        bookTitle: 'Zaman Yolcusu',
        content:
            'Bu kitabın 3. bölümü gerçekten çok heyecan vericiydi! '
            'Yazarın hayal gücü muhteşem.',
        likeCount: 12,
        commentCount: 3,
        timeAgo: '4 saat önce',
        isLiked: true,
      ),
      FeedItem(
        id: '3',
        type: FeedItemType.recommendation,
        userName: 'Mehmet Kaya',
        userAvatar: 'M',
        bookTitle: 'Bilim ve Felsefe',
        content:
            'Bilim meraklıları için harika bir kaynak. '
            'Karmaşık konuları çok anlaşılır şekilde anlatıyor.',
        rating: 4.5,
        likeCount: 18,
        commentCount: 5,
        timeAgo: '6 saat önce',
        isLiked: false,
      ),
      FeedItem(
        id: '4',
        type: FeedItemType.discussion,
        userName: 'Ayşe Özkan',
        userAvatar: 'A',
        content:
            'Hangi tür kitapları okumayı tercih ediyorsunuz? '
            'Ben son zamanlarda bilim kurgu kitaplarına takıldım.',
        likeCount: 31,
        commentCount: 15,
        timeAgo: '8 saat önce',
        isLiked: false,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const TitleText('Topluluk'),
        backgroundColor: colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Akış'),
            Tab(text: 'Değerlendirmeler'),
            Tab(text: 'Tartışmalar'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePostDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFeedTab(), _buildReviewsTab(), _buildDiscussionsTab()],
      ),
    );
  }

  Widget _buildFeedTab() {
    if (_feedItems.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          icon: Icons.forum_outlined,
          title: 'Henüz İçerik Yok',
          description:
              'Topluluk akışında henüz paylaşım bulunmuyor. '
              'İlk paylaşımı siz yapın!',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          // Refresh feed data
        });
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _feedItems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildFeedItem(_feedItems[index]),
          );
        },
      ),
    );
  }

  Widget _buildReviewsTab() {
    final reviews = _feedItems
        .where(
          (item) =>
              item.type == FeedItemType.review ||
              item.type == FeedItemType.recommendation,
        )
        .toList();

    if (reviews.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          icon: Icons.star_outline,
          title: 'Henüz Değerlendirme Yok',
          description: 'Kitaplar hakkında ilk değerlendirmeyi siz yapın!',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildFeedItem(reviews[index]),
        );
      },
    );
  }

  Widget _buildDiscussionsTab() {
    final discussions = _feedItems
        .where(
          (item) =>
              item.type == FeedItemType.discussion ||
              item.type == FeedItemType.comment,
        )
        .toList();

    if (discussions.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          icon: Icons.chat_bubble_outline,
          title: 'Henüz Tartışma Yok',
          description:
              'İlk tartışmayı başlatın ve diğer okuyucularla etkileşim kurun!',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: discussions.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildFeedItem(discussions[index]),
        );
      },
    );
  }

  Widget _buildFeedItem(FeedItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primary,
                child: SubtitleText(
                  item.userAvatar,
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleText(item.userName, size: TitleSize.small),
                    SubtitleText(item.timeAgo, size: SubtitleSize.small),
                  ],
                ),
              ),
              _buildFeedTypeIcon(item.type),
            ],
          ),

          const SizedBox(height: 12),

          // Book Title (if exists)
          if (item.bookTitle != null) ...[
            RoundedCard(
              backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  SubtitleText(
                    item.bookTitle!,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Rating (if exists)
          if (item.rating != null) ...[
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < item.rating!.floor()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.orange.shade600,
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                SubtitleText(
                  item.rating!.toStringAsFixed(1),
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Content
          SubtitleText(item.content, size: SubtitleSize.medium),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              _buildActionButton(
                icon: item.isLiked ? Icons.favorite : Icons.favorite_border,
                label: item.likeCount.toString(),
                color: item.isLiked ? Colors.red : colorScheme.onSurfaceVariant,
                onPressed: () {
                  setState(() {
                    item.isLiked = !item.isLiked;
                    item.likeCount += item.isLiked ? 1 : -1;
                  });
                },
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.comment_outlined,
                label: item.commentCount.toString(),
                color: colorScheme.onSurfaceVariant,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yorumlar yakında...')),
                  );
                },
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.share_outlined,
                label: 'Paylaş',
                color: colorScheme.onSurfaceVariant,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paylaşım yakında...')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedTypeIcon(FeedItemType type) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData icon;
    Color color;

    switch (type) {
      case FeedItemType.review:
        icon = Icons.star;
        color = Colors.orange.shade600;
        break;
      case FeedItemType.comment:
        icon = Icons.comment;
        color = colorScheme.primary;
        break;
      case FeedItemType.recommendation:
        icon = Icons.thumb_up;
        color = Colors.green.shade600;
        break;
      case FeedItemType.discussion:
        icon = Icons.forum;
        color = Colors.purple.shade600;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          SubtitleText(label, color: color, size: SubtitleSize.small),
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TitleText('Yeni Paylaşım'),
        content: const SubtitleText(
          'Paylaşım oluşturma özelliği yakında eklenecek!',
        ),
        actions: [
          CustomButton(
            text: 'Tamam',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Feed Item Model
class FeedItem {
  final String id;
  final FeedItemType type;
  final String userName;
  final String userAvatar;
  final String? bookTitle;
  final String content;
  final double? rating;
  int likeCount;
  final int commentCount;
  final String timeAgo;
  bool isLiked;

  FeedItem({
    required this.id,
    required this.type,
    required this.userName,
    required this.userAvatar,
    this.bookTitle,
    required this.content,
    this.rating,
    required this.likeCount,
    required this.commentCount,
    required this.timeAgo,
    required this.isLiked,
  });
}

/// Feed Item Types
enum FeedItemType { review, comment, recommendation, discussion }
