import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/comment_model.dart';
import '../../services/comment_service.dart';
import '../dialogs/report_comment_dialog.dart';

/// Yorum kartı widget'ı
class CommentCard extends StatefulWidget {
  final CommentModel comment;
  final String currentUserId;
  final VoidCallback? onCommentUpdated;
  final VoidCallback? onCommentDeleted;

  const CommentCard({
    super.key,
    required this.comment,
    required this.currentUserId,
    this.onCommentUpdated,
    this.onCommentDeleted,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final CommentService _commentService = CommentService();
  bool _isLiked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.comment.isLikedBy(widget.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kullanıcı bilgileri ve tarih
            Row(
              children: [
                // Profil fotoğrafı
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage: widget.comment.userPhotoUrl != null
                      ? CachedNetworkImageProvider(widget.comment.userPhotoUrl!)
                      : null,
                  child: widget.comment.userPhotoUrl == null
                      ? Icon(Icons.person, color: theme.colorScheme.primary)
                      : null,
                ),
                const SizedBox(width: 12),

                // Kullanıcı adı ve tarih
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.comment.userDisplayName ?? 'Anonim Kullanıcı',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(widget.comment.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Düzenlenmiş işareti
                if (widget.comment.isEdited) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Düzenlendi',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],

                // Menü butonu
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  onSelected: _handleMenuAction,
                  itemBuilder: (context) => [
                    if (widget.comment.userId == widget.currentUserId)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Yorumu Sil'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Şikayet Et'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Yıldız puanı
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < widget.comment.rating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${widget.comment.rating}/5',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Yorum metni
            Text(widget.comment.text, style: theme.textTheme.bodyMedium),

            const SizedBox(height: 16),

            // Beğeni butonu ve sayısı
            Row(
              children: [
                InkWell(
                  onTap: _isLoading ? null : _toggleLike,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isLiked
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isLiked
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: _isLiked
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.comment.likeCount}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _isLiked
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Tarih formatla
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  /// Beğeni durumunu değiştir
  Future<void> _toggleLike() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _commentService.toggleLike(
        userId: widget.currentUserId,
        commentId: widget.comment.id,
      );

      setState(() {
        _isLiked = !_isLiked;
      });

      if (widget.onCommentUpdated != null) {
        widget.onCommentUpdated!();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Beğeni işlemi başarısız: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Menü aksiyonlarını işle
  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'delete':
        await _deleteComment();
        break;
      case 'report':
        await _reportComment();
        break;
    }
  }

  /// Yorumu sil
  Future<void> _deleteComment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yorumu Sil'),
        content: const Text('Bu yorumu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _commentService.deleteComment(
          userId: widget.currentUserId,
          commentId: widget.comment.id,
        );

        if (widget.onCommentDeleted != null) {
          widget.onCommentDeleted!();
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Yorum silindi')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Yorum silinirken hata: $e')));
      }
    }
  }

  /// Yorumu raporla
  Future<void> _reportComment() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => ReportCommentDialog(commentId: widget.comment.id),
    );

    if (result != null) {
      try {
        await _commentService.reportComment(
          commentId: widget.comment.id,
          reporterId: widget.currentUserId,
          reason: result['reason']!,
          description: result['description'],
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rapor gönderildi. Teşekkürler.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Rapor gönderilirken hata: $e')));
      }
    }
  }
}
