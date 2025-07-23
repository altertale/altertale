import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/likes_service.dart';
import '../../providers/auth_provider.dart';

/// Kitap beğeni butonu
class BookLikeButton extends StatefulWidget {
  final String bookId;
  final int initialLikeCount;
  final VoidCallback? onLikeChanged;

  const BookLikeButton({
    super.key,
    required this.bookId,
    this.initialLikeCount = 0,
    this.onLikeChanged,
  });

  @override
  State<BookLikeButton> createState() => _BookLikeButtonState();
}

class _BookLikeButtonState extends State<BookLikeButton> {
  final LikesService _likesService = LikesService();
  
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.initialLikeCount;
    _checkLikeStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const SizedBox.shrink(); // Kullanıcı giriş yapmamışsa gizle
    }

    return Row(
      children: [
        // Beğeni butonu
        InkWell(
          onTap: _isLoading ? null : _toggleLike,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isLiked 
                  ? Colors.red.withValues(alpha: 0.1)
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isLiked ? Colors.red : theme.dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : theme.iconTheme.color,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Text(
                  '$_likeCount',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: _isLiked ? Colors.red : theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Beğeni metni
        Text(
          _isLiked ? 'Beğendiniz' : 'Beğen',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Beğeni durumunu kontrol et
  Future<void> _checkLikeStatus() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null) return;

    try {
      final isLiked = await _likesService.isBookLikedByUser(
        userId: currentUser.uid,
        bookId: widget.bookId,
      );

      if (mounted) {
        setState(() {
          _isLiked = isLiked;
        });
      }
    } catch (e) {
      // Hata durumunda sessizce geç
      debugPrint('Beğeni durumu kontrol edilirken hata: $e');
    }
  }

  /// Beğeniyi aç/kapat
  Future<void> _toggleLike() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newLikeStatus = await _likesService.toggleLike(
        userId: currentUser.uid,
        bookId: widget.bookId,
      );

      if (mounted) {
        setState(() {
          _isLiked = newLikeStatus;
          _likeCount += newLikeStatus ? 1 : -1;
          _isLoading = false;
        });

        // Callback çağır
        widget.onLikeChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Beğeni işlemi yapılırken hata: $e')),
        );
      }
    }
  }
}
