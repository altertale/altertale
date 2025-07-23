import 'package:flutter/material.dart';
import '../../models/comment_model.dart';
import '../../services/comment_service.dart';

/// Yorum giriş widget'ı
class CommentInputWidget extends StatefulWidget {
  final String bookId;
  final CommentModel? parentComment; // Yanıt verilen yorum
  final VoidCallback? onCommentAdded;

  const CommentInputWidget({
    super.key,
    required this.bookId,
    this.parentComment,
    this.onCommentAdded,
  });

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final CommentService _commentService = CommentService();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isSubmitting = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    // Yanıt verilen yorum varsa metni hazırla
    if (widget.parentComment != null) {
      _textController.text = '@${widget.parentComment!.userDisplayName} ';
      _isExpanded = true;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yanıt göstergesi
          if (widget.parentComment != null) ...[
            _buildReplyIndicator(theme),
            const SizedBox(height: 12),
          ],
          
          // Yorum girişi
          _buildCommentInput(theme),
          
          // Karakter sayısı ve gönder butonu
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            _buildBottomRow(theme),
          ],
        ],
      ),
    );
  }

  /// Yanıt göstergesi
  Widget _buildReplyIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.reply,
            size: 16,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.parentComment!.userDisplayName} kullanıcısına yanıt',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              // Yanıtı iptal et
              Navigator.pop(context);
            },
            child: Icon(
              Icons.close,
              size: 16,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  /// Yorum girişi
  Widget _buildCommentInput(ThemeData theme) {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      maxLines: _isExpanded ? 4 : 1,
      maxLength: 500,
      decoration: InputDecoration(
        hintText: widget.parentComment != null
            ? 'Yanıtınızı yazın...'
            : 'Yorumunuzu yazın...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.all(12),
        suffixIcon: _isExpanded
            ? null
            : IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isSubmitting ? null : _submitComment,
              ),
      ),
      onTap: () {
        if (!_isExpanded) {
          setState(() {
            _isExpanded = true;
          });
          // Kısa bir gecikme ile focus ver
          Future.delayed(const Duration(milliseconds: 100), () {
            _focusNode.requestFocus();
          });
        }
      },
      onChanged: (value) {
        // Metin değiştiğinde karakter sayısını güncelle
        setState(() {});
      },
    );
  }

  /// Alt satır (karakter sayısı ve butonlar)
  Widget _buildBottomRow(ThemeData theme) {
    final characterCount = _textController.text.length;
    final isOverLimit = characterCount > 500;
    final canSubmit = characterCount > 0 && characterCount <= 500 && !_isSubmitting;

    return Row(
      children: [
        // Karakter sayısı
        Text(
          '$characterCount/500',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isOverLimit
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        
        const Spacer(),
        
        // İptal butonu
        if (_isExpanded)
          TextButton(
            onPressed: _isSubmitting ? null : _cancelComment,
            child: const Text('İptal'),
          ),
        
        const SizedBox(width: 8),
        
        // Gönder butonu
        ElevatedButton(
          onPressed: canSubmit ? _submitComment : null,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Gönder'),
        ),
      ],
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Yorum gönder
  Future<void> _submitComment() async {
    final text = _textController.text.trim();
    
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yorum metni boş olamaz'),
        ),
      );
      return;
    }

    if (text.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yorum 500 karakterden uzun olamaz'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Mention edilen kullanıcı ID'sini bul
      String? mentionedUserId;
      if (widget.parentComment != null) {
        mentionedUserId = widget.parentComment!.userId;
      }

      await _commentService.addComment(
        bookId: widget.bookId,
        text: text,
        parentCommentId: widget.parentComment?.id,
        mentionedUserId: mentionedUserId,
      );

      // Başarılı
      _textController.clear();
      setState(() {
        _isExpanded = false;
      });

      widget.onCommentAdded?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yorumunuz gönderildi'),
          backgroundColor: Colors.green,
        ),
      );

      // Yanıt modundaysa ekranı kapat
      if (widget.parentComment != null) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yorum gönderilirken hata oluştu: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// Yorumu iptal et
  void _cancelComment() {
    _textController.clear();
    setState(() {
      _isExpanded = false;
    });
    _focusNode.unfocus();
  }
}

/// Yorum düzenleme widget'ı
class CommentEditWidget extends StatefulWidget {
  final CommentModel comment;
  final VoidCallback? onCommentUpdated;

  const CommentEditWidget({
    super.key,
    required this.comment,
    this.onCommentUpdated,
  });

  @override
  State<CommentEditWidget> createState() => _CommentEditWidgetState();
}

class _CommentEditWidgetState extends State<CommentEditWidget> {
  final CommentService _commentService = CommentService();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.comment.cleanText;
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yorumu Düzenle',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Yorumunuzu düzenleyin...',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _updateComment,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Güncelle'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Yorumu güncelle
  Future<void> _updateComment() async {
    final text = _textController.text.trim();
    
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yorum metni boş olamaz'),
        ),
      );
      return;
    }

    if (text.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yorum 500 karakterden uzun olamaz'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _commentService.updateComment(
        commentId: widget.comment.id,
        text: text,
      );

      widget.onCommentUpdated?.call();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yorumunuz güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yorum güncellenirken hata oluştu: $e'),
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
