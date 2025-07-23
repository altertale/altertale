import 'package:flutter/material.dart';

/// Star Rating Widget
///
/// Displays rating as stars and optionally allows user input
class StarRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool allowInput;
  final ValueChanged<int>? onRatingChanged;
  final bool showRating;
  final String? label;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.activeColor,
    this.inactiveColor,
    this.allowInput = false,
    this.onRatingChanged,
    this.showRating = true,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activeStarColor = activeColor ?? Colors.amber;
    final inactiveStarColor =
        inactiveColor ?? colorScheme.onSurfaceVariant.withValues(alpha: 0.3);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: theme.textTheme.bodyMedium),
          const SizedBox(width: 8),
        ],

        // Stars
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxRating, (index) {
            final starIndex = index + 1;
            final isFilled = starIndex <= rating;
            final isHalfFilled = !isFilled && starIndex - 0.5 <= rating;

            return GestureDetector(
              onTap: allowInput && onRatingChanged != null
                  ? () => onRatingChanged!(starIndex)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Icon(
                  isFilled
                      ? Icons.star
                      : isHalfFilled
                      ? Icons.star_half
                      : Icons.star_border,
                  size: size,
                  color: isFilled || isHalfFilled
                      ? activeStarColor
                      : inactiveStarColor,
                ),
              ),
            );
          }),
        ),

        if (showRating) ...[
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

/// Interactive Star Rating Widget
///
/// Allows user to select a rating by tapping stars
class InteractiveStarRating extends StatefulWidget {
  final int initialRating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final ValueChanged<int>? onRatingChanged;
  final String? label;
  final bool isRequired;

  const InteractiveStarRating({
    super.key,
    this.initialRating = 0,
    this.maxRating = 5,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
    this.onRatingChanged,
    this.label,
    this.isRequired = false,
  });

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late int _currentRating;
  int _hoverRating = 0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activeStarColor = widget.activeColor ?? Colors.amber;
    final inactiveStarColor =
        widget.inactiveColor ??
        colorScheme.onSurfaceVariant.withValues(alpha: 0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.isRequired)
                Text(
                  ' *',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stars
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.maxRating, (index) {
                final starIndex = index + 1;
                final displayRating = _hoverRating > 0
                    ? _hoverRating
                    : _currentRating;
                final isFilled = starIndex <= displayRating;

                return MouseRegion(
                  onEnter: (_) => setState(() => _hoverRating = starIndex),
                  onExit: (_) => setState(() => _hoverRating = 0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentRating = starIndex;
                        _hoverRating = 0;
                      });
                      widget.onRatingChanged?.call(starIndex);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        isFilled ? Icons.star : Icons.star_border,
                        size: widget.size,
                        color: isFilled ? activeStarColor : inactiveStarColor,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(width: 12),

            // Rating text
            Text(
              _getRatingText(_hoverRating > 0 ? _hoverRating : _currentRating),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: (_hoverRating > 0 ? _hoverRating : _currentRating) > 0
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 0:
        return 'Puan verin';
      case 1:
        return 'Çok kötü';
      case 2:
        return 'Kötü';
      case 3:
        return 'Orta';
      case 4:
        return 'İyi';
      case 5:
        return 'Mükemmel';
      default:
        return '$rating/5';
    }
  }
}

/// Rating Summary Widget
///
/// Shows overall rating statistics with breakdown
class RatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingCounts;
  final bool showBreakdown;

  const RatingSummary({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingCounts,
    this.showBreakdown = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall rating
        Row(
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            StarRating(rating: averageRating, size: 20, showRating: false),
            const SizedBox(width: 8),
            Text(
              '($totalReviews)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),

        if (showBreakdown && totalReviews > 0) ...[
          const SizedBox(height: 16),
          _buildRatingBreakdown(context, theme, colorScheme),
        ],
      ],
    );
  }

  Widget _buildRatingBreakdown(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: List.generate(5, (index) {
        final rating = 5 - index; // 5, 4, 3, 2, 1
        final count = ratingCounts[rating] ?? 0;
        final percentage = totalReviews > 0 ? count / totalReviews : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Text('$rating', style: theme.textTheme.bodySmall),
              const SizedBox(width: 4),
              Icon(Icons.star, size: 12, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: colorScheme.surfaceContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  '$count',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
