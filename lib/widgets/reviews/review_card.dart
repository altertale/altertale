import 'package:flutter/material.dart';
import '../../models/review.dart';
import '../widgets.dart';
import 'star_rating.dart'; // Added import

/// Review Card Widget
///
/// Displays a single review with user info, rating, comment and actions
class ReviewCard extends StatelessWidget {
  final Review review;
  final bool isCurrentUserReview;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isCompact;

  const ReviewCard({
    super.key,
    required this.review,
    this.isCurrentUserReview = false,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RoundedCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          _buildHeader(context, theme, colorScheme),

          const SizedBox(height: 12),

          // Comment
          _buildComment(context, theme, colorScheme),

          if (review.editedText != null) ...[
            const SizedBox(height: 8),
            _buildEditedInfo(context, theme, colorScheme),
          ],

          if (showActions && isCurrentUserReview) ...[
            const SizedBox(height: 12),
            _buildActions(context, theme, colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        // User avatar
        CircleAvatar(
          radius: isCompact ? 16 : 20,
          backgroundColor: colorScheme.primary,
          child: Text(
            review.userInitial,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: isCompact ? 12 : 14,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // User info and rating
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SubtitleText(
                      review.userDisplayName,
                      fontWeight: FontWeight.w600,
                      size: isCompact
                          ? SubtitleSize.small
                          : SubtitleSize.medium,
                    ),
                  ),
                  StarRating(
                    rating: review.rating.toDouble(),
                    size: isCompact ? 14 : 16,
                    showRating: false,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              SubtitleText(
                review.formattedTimestamp,
                size: SubtitleSize.small,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComment(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SubtitleText(
      isCompact && review.isLongComment
          ? review.truncatedComment
          : review.comment,
      size: SubtitleSize.medium,
      maxLines: isCompact ? 3 : null,
    );
  }

  Widget _buildEditedInfo(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(
          Icons.edit,
          size: 12,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          review.editedText!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontStyle:
                FontStyle.italic, // Fixed: use Text widget with TextStyle
          ),
        ),
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onEdit != null)
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Düzenle'),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),

        if (onDelete != null)
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Sil'),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
      ],
    );
  }
}

/// Compact Review Card for lists
class CompactReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onTap;

  const CompactReviewCard({super.key, required this.review, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ReviewCard(review: review, showActions: false, isCompact: true),
    );
  }
}
