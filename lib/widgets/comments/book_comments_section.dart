import 'package:flutter/material.dart';
import '../../models/comment_model.dart';
import '../../models/book_model.dart';
import '../../services/comment_service.dart';
import '../../providers/auth_provider.dart';
import 'comment_card.dart';
import '../forms/comment_form.dart';

/// Kitap yorumları bölümü
class BookCommentsSection extends StatefulWidget {
  final BookModel book;
  final String currentUserId;

  const BookCommentsSection({
    super.key,
    required this.book,
    required this.currentUserId,
  });

  @override
  State<BookCommentsSection> createState() => _BookCommentsSectionState();
}

class _BookCommentsSectionState extends State<BookCommentsSection> {
  final CommentService _commentService = CommentService();

  List<CommentModel> _comments = [];
  CommentModel? _userComment;
  double _averageRating = 0.0;
  int _commentCount = 0;
  String _sortBy = 'newest';
  bool _isLoading = true;
  bool _hasPurchased = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _checkPurchaseStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık ve istatistikler
        _buildHeader(theme, isDark),

        const SizedBox(height: 16),

        // Kullanıcı yorum formu (sadece satın alanlar için)
        if (_hasPurchased) ...[
          _buildCommentForm(theme, isDark),
          const SizedBox(height: 24),
        ],

        // Yorum listesi
        _buildCommentsList(theme, isDark),
      ],
    );
  }

  /// Başlık ve istatistikler
  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Yorumlar',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (_commentCount > 0) ...[
              // Ortalama puan
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < _averageRating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                  const SizedBox(width: 4),
                  Text(
                    _averageRating.toStringAsFixed(1),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Text(
                '($_commentCount yorum)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),

        if (_commentCount > 0) ...[
          const SizedBox(height: 12),
          // Sıralama seçenekleri
          Row(
            children: [
              Text('Sırala:', style: theme.textTheme.bodyMedium),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('En Yeni'),
                selected: _sortBy == 'newest',
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _sortBy = 'newest';
                    });
                    _loadComments();
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('En Beğenilen'),
                selected: _sortBy == 'popular',
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _sortBy = 'popular';
                    });
                    _loadComments();
                  }
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Yorum formu
  Widget _buildCommentForm(ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _userComment != null ? 'Yorumunu Düzenle' : 'Yorum Yap',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            CommentForm(
              initialComment: _userComment,
              onSubmit: _handleCommentSubmit,
            ),
          ],
        ),
      ),
    );
  }

  /// Yorum listesi
  Widget _buildCommentsList(ThemeData theme, bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_comments.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Henüz yorum yapılmamış',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'İlk yorumu siz yapın!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _comments
          .map(
            (comment) => CommentCard(
              comment: comment,
              currentUserId: widget.currentUserId,
              onCommentUpdated: _loadComments,
              onCommentDeleted: _loadComments,
            ),
          )
          .toList(),
    );
  }

  /// Yorumları yükle
  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Yorumları getir
      final comments = await _commentService.getCommentsForBook(
        bookId: widget.book.id,
        sortBy: _sortBy,
      );

      // Kullanıcının yorumunu getir
      final userComment = await _commentService.getUserCommentForBook(
        userId: widget.currentUserId,
        bookId: widget.book.id,
      );

      // İstatistikleri getir
      final averageRating = await _commentService.getAverageRating(
        widget.book.id,
      );
      final commentCount = await _commentService.getCommentCount(
        widget.book.id,
      );

      setState(() {
        _comments = comments;
        _userComment = userComment;
        _averageRating = averageRating;
        _commentCount = commentCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Yorumlar yüklenirken hata: $e')));
    }
  }

  /// Satın alma durumunu kontrol et
  Future<void> _checkPurchaseStatus() async {
    try {
      final hasPurchased = await _commentService.hasUserPurchasedBook(
        userId: widget.currentUserId,
        bookId: widget.book.id,
      );

      setState(() {
        _hasPurchased = hasPurchased;
      });
    } catch (e) {
      // Hata durumunda false olarak bırak
      setState(() {
        _hasPurchased = false;
      });
    }
  }

  /// Yorum gönder/güncelle
  Future<void> _handleCommentSubmit({
    required int rating,
    required String text,
  }) async {
    try {
      final authProvider = AuthProvider.of(context);
      final user = authProvider.currentUser;

      await _commentService.addOrUpdateComment(
        userId: widget.currentUserId,
        bookId: widget.book.id,
        rating: rating,
        text: text,
        userDisplayName: user?.displayName,
        userPhotoUrl: user?.photoURL,
      );

      // Yorumları yeniden yükle
      await _loadComments();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _userComment != null ? 'Yorum güncellendi' : 'Yorum eklendi',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Yorum kaydedilirken hata: $e')));
    }
  }
}
