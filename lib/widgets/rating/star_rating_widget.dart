import 'package:flutter/material.dart';

class StarRatingWidget extends StatefulWidget {
  final double initialRating;
  final Function(double)? onRatingChanged;
  final bool isInteractive;
  final double size;
  final Color filledColor;
  final Color unfilledColor;
  final int maxRating;
  final bool allowHalfRating;

  const StarRatingWidget({
    Key? key,
    this.initialRating = 0.0,
    this.onRatingChanged,
    this.isInteractive = true,
    this.size = 24.0,
    this.filledColor = Colors.amber,
    this.unfilledColor = Colors.grey,
    this.maxRating = 5,
    this.allowHalfRating = false,
  }) : super(key: key);

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  void didUpdateWidget(StarRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating) {
      _currentRating = widget.initialRating;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        return GestureDetector(
          onTap: widget.isInteractive ? () => _onStarTapped(index + 1.0) : null,
          onPanUpdate: widget.isInteractive
              ? (details) => _onPanUpdate(details, index)
              : null,
          child: Icon(
            _getStarIcon(index + 1),
            size: widget.size,
            color: _getStarColor(index + 1),
          ),
        );
      }),
    );
  }

  IconData _getStarIcon(int starNumber) {
    if (_currentRating >= starNumber) {
      return Icons.star;
    } else if (widget.allowHalfRating && _currentRating >= starNumber - 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }

  Color _getStarColor(int starNumber) {
    if (_currentRating >= starNumber) {
      return widget.filledColor;
    } else if (widget.allowHalfRating && _currentRating >= starNumber - 0.5) {
      return widget.filledColor;
    } else {
      return widget.unfilledColor;
    }
  }

  void _onStarTapped(double rating) {
    if (!widget.isInteractive) return;

    setState(() {
      _currentRating = rating;
    });

    widget.onRatingChanged?.call(rating);
  }

  void _onPanUpdate(DragUpdateDetails details, int starIndex) {
    if (!widget.isInteractive || !widget.allowHalfRating) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final double starWidth = widget.size;
    final double relativePosition = localPosition.dx / starWidth;

    double newRating;
    if (relativePosition < 0.5) {
      newRating = starIndex + 0.5;
    } else {
      newRating = starIndex + 1.0;
    }

    newRating = newRating.clamp(0.0, widget.maxRating.toDouble());

    if (newRating != _currentRating) {
      setState(() {
        _currentRating = newRating;
      });
      widget.onRatingChanged?.call(newRating);
    }
  }
}

// Display-only rating widget with text
class RatingDisplayWidget extends StatelessWidget {
  final double rating;
  final int totalRatings;
  final double starSize;
  final double fontSize;
  final Color starColor;
  final Color textColor;
  final bool showRatingText;
  final bool showTotalRatings;

  const RatingDisplayWidget({
    Key? key,
    required this.rating,
    this.totalRatings = 0,
    this.starSize = 16.0,
    this.fontSize = 14.0,
    this.starColor = Colors.amber,
    this.textColor = Colors.grey,
    this.showRatingText = true,
    this.showTotalRatings = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StarRatingWidget(
          initialRating: rating,
          isInteractive: false,
          size: starSize,
          filledColor: starColor,
          allowHalfRating: true,
        ),
        if (showRatingText || showTotalRatings) ...[
          const SizedBox(width: 4),
          Text(
            _buildRatingText(),
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  String _buildRatingText() {
    String text = '';

    if (showRatingText) {
      text += rating.toStringAsFixed(1);
    }

    if (showTotalRatings && totalRatings > 0) {
      if (text.isNotEmpty) text += ' ';
      text += '($totalRatings)';
    }

    return text;
  }
}

// Rating dialog for book detail screen
class RatingDialog extends StatefulWidget {
  final String bookTitle;
  final double? currentRating;
  final Function(double) onRatingSubmitted;

  const RatingDialog({
    Key? key,
    required this.bookTitle,
    this.currentRating,
    required this.onRatingSubmitted,
  }) : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _selectedRating = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.currentRating ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Kitabı Puanla',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.bookTitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          StarRatingWidget(
            initialRating: _selectedRating,
            onRatingChanged: (rating) {
              setState(() {
                _selectedRating = rating;
              });
            },
            size: 40.0,
            filledColor: Colors.amber,
            unfilledColor: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            _getRatingText(_selectedRating),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _selectedRating > 0
              ? () {
                  widget.onRatingSubmitted(_selectedRating);
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Puanla'),
        ),
      ],
    );
  }

  String _getRatingText(double rating) {
    if (rating == 0) return 'Bir puan seçin';

    switch (rating.round()) {
      case 1:
        return 'Beğenmedim';
      case 2:
        return 'Fena değil';
      case 3:
        return 'İyi';
      case 4:
        return 'Çok iyi';
      case 5:
        return 'Mükemmel!';
      default:
        return '';
    }
  }
}
