import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import '../../providers/auth_provider.dart';
import '../widgets.dart';
import 'star_rating.dart';
import 'review_card.dart';
import 'review_form.dart';

/// Reviews Section Widget
///
/// Complete reviews section for book detail screen
class ReviewsSection extends StatefulWidget {
  final String bookId;
  final String bookTitle;

  const ReviewsSection({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final ReviewService _reviewService = ReviewService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title and rating summary
            _buildSectionHeader(context, theme, colorScheme),

            const SizedBox(height: 16),

            // Rating statistics
            _buildRatingStatistics(context, theme, colorScheme),

            const SizedBox(height: 24),

            // User's review status and add review button
            _buildUserReviewSection(context, authProvider),

            const SizedBox(height: 24),

            // Reviews list
            _buildReviewsList(context, theme, colorScheme, authProvider),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return StreamBuilder<BookRatingStats>(
      stream: _reviewService.getBookRatingStatsStream(widget.bookId),
      builder: (context, snapshot) {
        final stats = snapshot.data;

        return Row(
          children: [
            Icon(Icons.rate_review, color: colorScheme.primary),
            const SizedBox(width: 8),
            TitleText('Değerlendirmeler', size: TitleSize.medium),
            const Spacer(),
            if (stats != null && stats.totalReviews > 0)
              SubtitleText(
                '${stats.totalReviews} yorum',
                color: colorScheme.onSurfaceVariant,
              ),
          ],
        );
      },
    );
  }

  Widget _buildRatingStatistics(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return StreamBuilder<BookRatingStats>(
      stream: _reviewService.getBookRatingStatsStream(widget.bookId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data;
        if (stats == null || stats.totalReviews == 0) {
          return _buildNoRatingsState(context, theme, colorScheme);
        }

        return RoundedCard(
          child: RatingSummary(
            averageRating: stats.averageRating,
            totalReviews: stats.totalReviews,
            ratingCounts: stats.ratingCounts,
            showBreakdown: stats.totalReviews > 3,
          ),
        );
      },
    );
  }

  Widget _buildNoRatingsState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return RoundedCard(
      child: Column(
        children: [
          Icon(
            Icons.star_border,
            size: 48,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          TitleText(
            'Henüz Değerlendirme Yok',
            size: TitleSize.small,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          SubtitleText(
            'Bu kitap için ilk yorumu siz yapın!',
            textAlign: TextAlign.center,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildUserReviewSection(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Handle demo mode where user might be null
    if (!authProvider.isLoggedIn) {
      return _buildAddReviewButton(context, theme, colorScheme, authProvider);
    }

    // For demo mode, we don't need real Firebase user
    if (authProvider.isDemoMode) {
      return StreamBuilder<Review?>(
        stream: _reviewService.getUserReviewForBookStream(
          widget.bookId,
          authProvider.userId, // Use userId instead of user.uid
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final userReview = snapshot.data;

          if (userReview != null) {
            return _buildExistingUserReview(
              context,
              theme,
              colorScheme,
              userReview,
            );
          } else {
            return _buildAddReviewButton(
              context,
              theme,
              colorScheme,
              authProvider,
            );
          }
        },
      );
    }

    // For Firebase mode, user should not be null
    final user = authProvider.user;
    if (user == null) {
      return _buildAddReviewButton(context, theme, colorScheme, authProvider);
    }

    return StreamBuilder<Review?>(
      stream: _reviewService.getUserReviewForBookStream(
        widget.bookId,
        user.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final userReview = snapshot.data;

        if (userReview != null) {
          return _buildExistingUserReview(
            context,
            theme,
            colorScheme,
            userReview,
          );
        } else {
          return _buildAddReviewButton(
            context,
            theme,
            colorScheme,
            authProvider,
          );
        }
      },
    );
  }

  Widget _buildExistingUserReview(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Review userReview,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            TitleText('Yorumunuz', size: TitleSize.small),
          ],
        ),
        const SizedBox(height: 12),
        ReviewCard(
          review: userReview,
          isCurrentUserReview: true,
          onEdit: () => _editReview(context, userReview),
          onDelete: () => _deleteReview(context, userReview),
        ),
      ],
    );
  }

  Widget _buildAddReviewButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AuthProvider authProvider,
  ) {
    return RoundedCard(
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Row(
        children: [
          Icon(Icons.add_comment, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText('Bu kitabı değerlendirin', size: TitleSize.small),
                SubtitleText(
                  'Deneyiminizi diğer okuyucularla paylaşın',
                  size: SubtitleSize.small,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          CustomButton(
            text: 'Yorum Yap',
            type: ButtonType.primary,
            onPressed: () => _addReview(context, authProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AuthProvider authProvider,
  ) {
    return StreamBuilder<List<Review>>(
      stream: _reviewService.getReviewsForBookStream(widget.bookId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(
            context,
            theme,
            colorScheme,
            snapshot.error.toString(),
          );
        }

        final reviews = snapshot.data ?? [];
        final otherReviews = reviews
            .where(
              (review) =>
                  !authProvider.isLoggedIn ||
                  review.userId != authProvider.user!.uid,
            )
            .toList();

        if (otherReviews.isEmpty) {
          return _buildNoReviewsState(context, theme, colorScheme);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (authProvider.isLoggedIn &&
                reviews.any((r) => r.userId == authProvider.user!.uid))
              TitleText('Diğer Yorumlar', size: TitleSize.small),

            if (authProvider.isLoggedIn &&
                reviews.any((r) => r.userId == authProvider.user!.uid))
              const SizedBox(height: 12),

            ...otherReviews.map(
              (review) => ReviewCard(
                review: review,
                isCurrentUserReview: false,
                showActions: false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoReviewsState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            TitleText(
              'Henüz Yorum Yok',
              size: TitleSize.small,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            SubtitleText(
              'Bu kitap için ilk yorumu yapan siz olun!',
              textAlign: TextAlign.center,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            TitleText('Yorumlar Yüklenemedi', color: colorScheme.error),
            const SizedBox(height: 8),
            SubtitleText(
              'Yorumlar yüklenirken bir hata oluştu.',
              textAlign: TextAlign.center,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Tekrar Dene',
              onPressed: () {
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ACTIONS ====================

  Future<void> _addReview(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    try {
      await showReviewFormDialog(
        context: context,
        bookId: widget.bookId,
        bookTitle: widget.bookTitle,
        onSubmit: (rating, comment) async {
          try {
            await _reviewService.addReview(
              bookId: widget.bookId,
              userId: authProvider
                  .userId, // Use userId for both demo and Firebase mode
              userName: authProvider.userDisplayName.isNotEmpty
                  ? authProvider.userDisplayName
                  : 'Kullanıcı',
              userEmail: authProvider.userEmail,
              rating: rating,
              comment: comment,
            );

            // Show success message after the dialog is closed
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Yorumunuz başarıyla eklendi!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3), // Added duration
                ),
              );
            }
          } catch (e) {
            // Rethrow the error so dialog can handle it
            throw Exception('Yorum eklenirken hata oluştu: $e');
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4), // Added duration
          ),
        );
      }
    }
  }

  Future<void> _editReview(BuildContext context, Review review) async {
    try {
      await showReviewFormDialog(
        context: context,
        existingReview: review,
        bookId: widget.bookId,
        bookTitle: widget.bookTitle,
        onSubmit: (rating, comment) async {
          try {
            await _reviewService.updateReview(
              reviewId: review.id,
              userId: review.userId,
              rating: rating,
              comment: comment,
            );

            // Show success message after the dialog is closed
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Yorumunuz başarıyla güncellendi!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          } catch (e) {
            // Rethrow the error so dialog can handle it
            throw Exception('Yorum güncellenirken hata oluştu: $e');
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _deleteReview(BuildContext context, Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yorumu Sil'),
        content: const Text(
          'Yorumunuzu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _reviewService.deleteReview(review.id, review.userId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yorumunuz başarıyla silindi!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
