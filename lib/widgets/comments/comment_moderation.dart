import 'package:flutter/material.dart';
import '../../models/comment_model.dart';
import '../../services/comment_service.dart';

/// Yorum şikayet dialog'u
class CommentReportDialog extends StatefulWidget {
  final String commentId;

  const CommentReportDialog({super.key, required this.commentId});

  @override
  State<CommentReportDialog> createState() => _CommentReportDialogState();
}

class _CommentReportDialogState extends State<CommentReportDialog> {
  final CommentService _commentService = CommentService();

  String _selectedReason = '';
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _reportReasons = [
    'Uygunsuz içerik',
    'Spam',
    'Taciz',
    'Yanlış bilgi',
    'Telif hakkı ihlali',
    'Diğer',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Yorumu Şikayet Et'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Şikayet sebebini seçin:', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),

          // Şikayet sebepleri
          ..._reportReasons.map(
            (reason) => RadioListTile<String>(
              title: Text(reason),
              value: reason,
              groupValue: _selectedReason,
              onChanged: (value) {
                setState(() {
                  _selectedReason = value!;
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Açıklama
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            maxLength: 200,
            decoration: const InputDecoration(
              hintText: 'Açıklama (isteğe bağlı)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || _selectedReason.isEmpty
              ? null
              : _submitReport,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Şikayet Et'),
        ),
      ],
    );
  }

  /// Şikayet gönder
  Future<void> _submitReport() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _commentService.reportComment(
        commentId: widget.commentId,
        reason: _selectedReason,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şikayetiniz gönderildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Şikayet gönderilirken hata oluştu: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

/// Yorum düzenleme dialog'u
class CommentEditDialog extends StatelessWidget {
  final CommentModel comment;

  const CommentEditDialog({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: CommentEditWidget(
        comment: comment,
        onCommentUpdated: () {
          // Dialog kapatılacak
        },
      ),
    );
  }
}

/// Yorum silme dialog'u
class CommentDeleteDialog extends StatelessWidget {
  final CommentModel comment;

  const CommentDeleteDialog({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yorumu Sil'),
      content: const Text(
        'Bu yorumu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () => _deleteComment(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text('Sil'),
        ),
      ],
    );
  }

  /// Yorumu sil
  Future<void> _deleteComment(BuildContext context) async {
    try {
      final commentService = CommentService();
      await commentService.deleteComment(comment.id);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yorum silindi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yorum silinirken hata oluştu: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

/// Yorum yanıt ekranı
class CommentReplyScreen extends StatelessWidget {
  final CommentModel parentComment;
  final String bookId;

  const CommentReplyScreen({
    super.key,
    required this.parentComment,
    required this.bookId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yanıt Yaz'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          // Orijinal yorum
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yanıtlanan yorum:',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  parentComment.cleanText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '- ${parentComment.userDisplayName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Yanıt girişi
          Expanded(
            child: CommentInputWidget(
              bookId: bookId,
              parentComment: parentComment,
            ),
          ),
        ],
      ),
    );
  }
}

/// Yorum moderasyon istatistikleri widget'ı
class CommentModerationStats extends StatelessWidget {
  final String bookId;

  const CommentModerationStats({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: CommentService().getCommentStats(bookId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'İstatistikler yüklenirken hata oluştu',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          );
        }

        final stats = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yorum İstatistikleri', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),

              Row(
                children: [
                  _buildStatItem(
                    theme,
                    'Toplam',
                    stats['totalComments'].toString(),
                    Icons.comment,
                  ),
                  _buildStatItem(
                    theme,
                    'Onaylanan',
                    stats['approvedComments'].toString(),
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  _buildStatItem(
                    theme,
                    'Bekleyen',
                    stats['pendingComments'].toString(),
                    Icons.pending,
                    color: Colors.orange,
                  ),
                  _buildStatItem(
                    theme,
                    'Şikayet',
                    stats['reportedComments'].toString(),
                    Icons.flag,
                    color: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                'Ortalama Faydalılık: ${(stats['averageHelpfulness'] as double).toStringAsFixed(1)}/10',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  /// İstatistik öğesi
  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color ?? theme.colorScheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? theme.colorScheme.primary,
            ),
          ),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
