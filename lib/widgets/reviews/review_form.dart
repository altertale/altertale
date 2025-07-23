import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/review.dart';
import '../widgets.dart';
import 'star_rating.dart';

/// Review Form Widget
///
/// Form for adding/editing reviews with star rating and comment
class ReviewForm extends StatefulWidget {
  final Review? existingReview;
  final String bookId;
  final Function(int rating, String comment) onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;

  const ReviewForm({
    super.key,
    this.existingReview,
    required this.bookId,
    required this.onSubmit,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _commentController.text = widget.existingReview!.comment;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.existingReview != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form title
          TitleText(
            isEditing ? 'Yorumunuzu Düzenleyin' : 'Yorum Yapın',
            size: TitleSize.medium,
          ),

          const SizedBox(height: 16),

          // Star rating
          InteractiveStarRating(
            initialRating: _rating,
            label: 'Puanınız',
            isRequired: true,
            onRatingChanged: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),

          const SizedBox(height: 16),

          // Comment field
          _buildCommentField(theme, colorScheme),

          const SizedBox(height: 24),

          // Action buttons
          _buildActionButtons(theme, colorScheme, isEditing),
        ],
      ),
    );
  }

  Widget _buildCommentField(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Yorumunuz',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              ' *',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _commentController,
          maxLines: 4,
          maxLength: 500,
          enabled: !widget.isLoading,
          decoration: InputDecoration(
            hintText: 'Kitap hakkındaki düşüncelerinizi paylaşın...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Yorum boş olamaz';
            }
            if (value.trim().length < 10) {
              return 'Yorum en az 10 karakter olmalı';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isEditing,
  ) {
    return Row(
      children: [
        if (widget.onCancel != null)
          Expanded(
            child: CustomButton(
              text: 'İptal',
              type: ButtonType.secondary,
              onPressed: widget.isLoading ? null : widget.onCancel,
              isFullWidth: false,
            ),
          ),

        if (widget.onCancel != null) const SizedBox(width: 12),

        Expanded(
          child: CustomButton(
            text: isEditing ? 'Güncelle' : 'Yorum Yap',
            isLoading: widget.isLoading,
            onPressed: widget.isLoading ? null : _handleSubmit,
            isFullWidth: false,
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    // Validate rating
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir puan verin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Submit
    widget.onSubmit(_rating, _commentController.text.trim());
  }
}

/// Review Form Dialog
///
/// Modal dialog containing the review form
class ReviewFormDialog extends StatefulWidget {
  final Review? existingReview;
  final String bookId;
  final String bookTitle;
  final Function(int rating, String comment) onSubmit;

  const ReviewFormDialog({
    super.key,
    this.existingReview,
    required this.bookId,
    required this.bookTitle,
    required this.onSubmit,
  });

  @override
  State<ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends State<ReviewFormDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog header
            Row(
              children: [
                Icon(Icons.rate_review, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleText(
                        widget.existingReview != null
                            ? 'Yorumu Düzenle'
                            : 'Yorum Yap',
                        size: TitleSize.medium,
                      ),
                      SubtitleText(
                        widget.bookTitle,
                        size: SubtitleSize.small,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Review form
            ReviewForm(
              existingReview: widget.existingReview,
              bookId: widget.bookId,
              isLoading: _isLoading,
              onSubmit: _handleSubmit,
              onCancel: _isLoading ? null : () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(int rating, String comment) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Add timeout to prevent infinite loading
      await widget
          .onSubmit(rating, comment)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException(
                'İşlem zaman aşımına uğradı',
                const Duration(seconds: 10),
              );
            },
          );

      // Success - close dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Error handling
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );

        // Close dialog even on error after showing message
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// Helper function to show review form dialog
Future<void> showReviewFormDialog({
  required BuildContext context,
  Review? existingReview,
  required String bookId,
  required String bookTitle,
  required Function(int rating, String comment) onSubmit,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ReviewFormDialog(
      existingReview: existingReview,
      bookId: bookId,
      bookTitle: bookTitle,
      onSubmit: onSubmit,
    ),
  );
}
