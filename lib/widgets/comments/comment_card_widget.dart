import 'package:flutter/material.dart';
import '../../models/comment_model.dart';
import '../../services/comment_service.dart';
import '../../utils/date_utils.dart';

/// Yorum kartı widget'ı
class CommentCardWidget extends StatefulWidget {
  final CommentModel comment;
  final Function(String, VoteType?) onVoteChanged;
  final Function(String) onReport;
  final Function(CommentModel) onReply;
  final Function(CommentModel) onEdit;
  final Function(CommentModel) onDelete;

  const CommentCardWidget({
    super.key,
    required this.comment,
    required this.onVoteChanged,
    required this.onReport,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CommentCardWidget> createState() => _CommentCardWidgetState();
}

class _CommentCardWidgetState extends State<CommentCardWidget> {
  final CommentService _commentService = CommentService();
  VoteType? _userVote;
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    _loadUserVote();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kullanıcı bilgileri
            _buildUserInfo(theme),
            
            const SizedBox(height: 12),
            
            // Yorum metni
            _buildCommentText(theme),
            
            const SizedBox(height: 12),
            
            // Etkileşim butonları
            _buildInteractionButtons(theme),
            
            // Yanıt varsa göster
            if (widget.comment.isReply) ...[
              const SizedBox(height: 8),
              _buildReplyIndicator(theme),
            ],
          ],
        ),
      ),
    );
  }

  /// Kullanıcı bilgileri
  Widget _buildUserInfo(ThemeData theme) {
    return Row(
      children: [
        // Profil fotoğrafı
        CircleAvatar(
          radius: 16,
          backgroundImage: widget.comment.userPhotoUrl != null
              ? NetworkImage(widget.comment.userPhotoUrl!)
              : null,
          child: widget.comment.userPhotoUrl == null
              ? Text(
                  widget.comment.userDisplayName?.substring(0, 1).toUpperCase() ?? 'A',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : null,
        ),
        
        const SizedBox(width: 12),
        
        // Kullanıcı adı ve tarih
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.comment.userDisplayName ?? 'Anonim',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    DateUtils.formatRelativeTime(widget.comment.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (widget.comment.wasEdited) ...[
                    const SizedBox(width: 8),
                    Text(
                      '(düzenlendi)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        
        // Menü butonu
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          onSelected: _onMenuSelected,
          itemBuilder: (context) => _buildMenuItems(theme),
        ),
      ],
    );
  }

  /// Yorum metni
  Widget _buildCommentText(ThemeData theme) {
    return Text(
      widget.comment.cleanText,
      style: theme.textTheme.bodyMedium,
    );
  }

  /// Etkileşim butonları
  Widget _buildInteractionButtons(ThemeData theme) {
    return Row(
      children: [
        // Beğeni butonu
        _buildVoteButton(
          theme,
          VoteType.like,
          Icons.thumb_up,
          widget.comment.likeCount,
          _userVote == VoteType.like,
        ),
        
        const SizedBox(width: 16),
        
        // Beğenmeme butonu
        _buildVoteButton(
          theme,
          VoteType.dislike,
          Icons.thumb_down,
          widget.comment.dislikeCount,
          _userVote == VoteType.dislike,
        ),
        
        const SizedBox(width: 16),
        
        // Yanıt butonu
        TextButton.icon(
          onPressed: () => widget.onReply(widget.comment),
          icon: const Icon(Icons.reply, size: 16),
          label: const Text('Yanıtla'),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        
        const Spacer(),
        
        // Şikayet butonu
        if (!widget.comment.isReported)
          IconButton(
            onPressed: () => widget.onReport(widget.comment.id),
            icon: const Icon(Icons.flag, size: 16),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
      ],
    );
  }

  /// Oy butonu
  Widget _buildVoteButton(
    ThemeData theme,
    VoteType voteType,
    IconData icon,
    int count,
    bool isSelected,
  ) {
    return InkWell(
      onTap: _isVoting ? null : () => _onVotePressed(voteType),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Yanıt göstergesi
  Widget _buildReplyIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Yanıt',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Menü öğeleri
  List<PopupMenuEntry<String>> _buildMenuItems(ThemeData theme) {
    final items = <PopupMenuEntry<String>>[];

    // Kullanıcı kendi yorumu ise düzenleme ve silme seçenekleri
    if (_commentService.currentUser?.uid == widget.comment.userId) {
      items.add(
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16, color: theme.colorScheme.onSurface),
              const SizedBox(width: 8),
              const Text('Düzenle'),
            ],
          ),
        ),
      );
      
      items.add(
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text('Sil', style: TextStyle(color: theme.colorScheme.error)),
            ],
          ),
        ),
      );
    }

    // Şikayet seçeneği
    if (!widget.comment.isReported) {
      items.add(
        PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.flag, size: 16, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text('Şikayet Et', style: TextStyle(color: theme.colorScheme.error)),
            ],
          ),
        ),
      );
    }

    return items;
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Kullanıcının oyunu yükle
  Future<void> _loadUserVote() async {
    try {
      final vote = await _commentService.getUserVote(widget.comment.id);
      setState(() {
        _userVote = vote;
      });
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  /// Oy butonuna basıldı
  void _onVotePressed(VoteType voteType) async {
    if (_isVoting) return;

    setState(() {
      _isVoting = true;
    });

    try {
      VoteType? newVote;
      
      if (_userVote == voteType) {
        // Aynı oy tekrar basıldıysa oyu kaldır
        newVote = null;
      } else {
        // Yeni oy ver
        newVote = voteType;
      }

      widget.onVoteChanged(widget.comment.id, newVote);
      
      setState(() {
        _userVote = newVote;
      });
    } finally {
      setState(() {
        _isVoting = false;
      });
    }
  }

  /// Menü seçimi
  void _onMenuSelected(String value) {
    switch (value) {
      case 'edit':
        widget.onEdit(widget.comment);
        break;
      case 'delete':
        widget.onDelete(widget.comment);
        break;
      case 'report':
        widget.onReport(widget.comment.id);
        break;
    }
  }
}
