import 'package:flutter/material.dart';
import '../../models/comment_model.dart';
import '../../services/comment_service.dart';
import 'comment_card_widget.dart';
import 'comment_sort_widget.dart';

/// Yorum listesi widget'ı
class CommentListWidget extends StatefulWidget {
  final String bookId;
  final VoidCallback? onCommentAdded;

  const CommentListWidget({
    super.key,
    required this.bookId,
    this.onCommentAdded,
  });

  @override
  State<CommentListWidget> createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  final CommentService _commentService = CommentService();
  
  CommentSortOrder _currentSortOrder = CommentSortOrder.mostHelpful;
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  String? _error;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Sıralama seçenekleri
        CommentSortWidget(
          currentSortOrder: _currentSortOrder,
          onSortChanged: _onSortChanged,
        ),
        
        // Yorum listesi
        Expanded(
          child: _buildCommentsList(theme),
        ),
      ],
    );
  }

  /// Yorum listesi widget'ı
  Widget _buildCommentsList(ThemeData theme) {
    if (_isLoading && _comments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorWidget(theme);
    }

    if (_comments.isEmpty) {
      return _buildEmptyWidget(theme);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (_hasMore && !_isLoading) {
            _loadMoreComments();
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _comments.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _comments.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final comment = _comments[index];
          return CommentCardWidget(
            comment: comment,
            onVoteChanged: _onVoteChanged,
            onReport: _onReport,
            onReply: _onReply,
            onEdit: _onEdit,
            onDelete: _onDelete,
          );
        },
      ),
    );
  }

  /// Hata widget'ı
  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Yorumlar yüklenirken hata oluştu',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadComments,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  /// Boş durum widget'ı
  Widget _buildEmptyWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz yorum yok',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'İlk yorumu siz yapın!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Yorumları yükle
  void _loadComments() {
    setState(() {
      _isLoading = true;
      _error = null;
      _lastDocument = null;
    });

    _commentService
        .getComments(
          widget.bookId,
          sortOrder: _currentSortOrder,
          limit: 20,
        )
        .listen(
      (comments) {
        setState(() {
          _comments = comments;
          _isLoading = false;
          _hasMore = comments.length == 20;
        });
      },
      onError: (error) {
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      },
    );
  }

  /// Daha fazla yorum yükle
  void _loadMoreComments() {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    // Bu özellik için CommentService'e pagination desteği eklenebilir
    // Şimdilik sadece mevcut yorumları gösteriyoruz
    setState(() {
      _isLoading = false;
      _hasMore = false;
    });
  }

  /// Sıralama değişikliği
  void _onSortChanged(CommentSortOrder sortOrder) {
    setState(() {
      _currentSortOrder = sortOrder;
    });
    _loadComments();
  }

  /// Oy değişikliği
  void _onVoteChanged(String commentId, VoteType? voteType) async {
    try {
      if (voteType == null) {
        // Oy kaldır
        await _commentService.voteComment(
          commentId: commentId,
          voteType: VoteType.like, // Bu durumda oy kaldırılacak
        );
      } else {
        // Oy ver
        await _commentService.voteComment(
          commentId: commentId,
          voteType: voteType,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oy verilirken hata oluştu: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  /// Şikayet
  void _onReport(String commentId) {
    _showReportDialog(commentId);
  }

  /// Yanıt
  void _onReply(CommentModel comment) {
    // Yanıt ekranını aç
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentReplyScreen(
          parentComment: comment,
          bookId: widget.bookId,
        ),
      ),
    ).then((_) {
      // Yanıt eklendiyse listeyi yenile
      if (mounted) {
        _loadComments();
        widget.onCommentAdded?.call();
      }
    });
  }

  /// Düzenleme
  void _onEdit(CommentModel comment) {
    _showEditDialog(comment);
  }

  /// Silme
  void _onDelete(CommentModel comment) {
    _showDeleteDialog(comment);
  }

  /// Şikayet dialog'u
  void _showReportDialog(String commentId) {
    showDialog(
      context: context,
      builder: (context) => CommentReportDialog(commentId: commentId),
    );
  }

  /// Düzenleme dialog'u
  void _showEditDialog(CommentModel comment) {
    showDialog(
      context: context,
      builder: (context) => CommentEditDialog(comment: comment),
    ).then((_) {
      if (mounted) {
        _loadComments();
      }
    });
  }

  /// Silme dialog'u
  void _showDeleteDialog(CommentModel comment) {
    showDialog(
      context: context,
      builder: (context) => CommentDeleteDialog(comment: comment),
    ).then((_) {
      if (mounted) {
        _loadComments();
        widget.onCommentAdded?.call();
      }
    });
  }
}

/// Yorum sıralama widget'ı
class CommentSortWidget extends StatelessWidget {
  final CommentSortOrder currentSortOrder;
  final Function(CommentSortOrder) onSortChanged;

  const CommentSortWidget({
    super.key,
    required this.currentSortOrder,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.sort,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            'Sırala:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CommentSortOrder>(
                value: currentSortOrder,
                isDense: true,
                items: CommentSortOrder.values.map((order) {
                  return DropdownMenuItem(
                    value: order,
                    child: Text(
                      order.displayName,
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }).toList(),
                onChanged: (CommentSortOrder? value) {
                  if (value != null) {
                    onSortChanged(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
