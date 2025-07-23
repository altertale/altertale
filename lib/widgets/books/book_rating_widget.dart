import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/rating_service.dart';
import '../../providers/auth_provider.dart';

class BookRatingWidget extends StatefulWidget {
  final String bookId;
  final double currentRating;
  final int ratingCount;
  final bool showUserRating;
  final bool allowRating;
  final VoidCallback? onRatingChanged;

  const BookRatingWidget({
    super.key,
    required this.bookId,
    this.currentRating = 0.0,
    this.ratingCount = 0,
    this.showUserRating = true,
    this.allowRating = true,
    this.onRatingChanged,
  });

  @override
  State<BookRatingWidget> createState() => _BookRatingWidgetState();
}

class _BookRatingWidgetState extends State<BookRatingWidget> {
  final RatingService _ratingService = RatingService();
  double? _userRating;
  bool _isLoading = false;
  bool _hasRated = false;

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  Future<void> _loadUserRating() async {
    try {
      final userRating = await _ratingService.getUserRating(widget.bookId);
      if (mounted) {
        setState(() {
          _userRating = userRating;
          _hasRated = userRating != null;
        });
      }
    } catch (e) {
      print('❌ Error loading user rating: $e');
    }
  }

  Future<void> _rateBook(double rating) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _ratingService.rateBook(widget.bookId, rating);

      setState(() {
        _userRating = rating;
        _hasRated = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kitabı ${rating.toInt()} yıldız ile puanladınız'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Callback to notify parent widget
        widget.onRatingChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Puanlama hatası: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Giriş Gerekli'),
        content: const Text('Kitap puanlamak için giriş yapmanız gerekiyor.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kitabı Puanla'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bu kitaba kaç yıldız verirsiniz?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starRating = index + 1.0;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _rateBook(starRating);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.star,
                      size: 40,
                      color: (_userRating ?? 0) >= starRating
                          ? Colors.amber
                          : Colors.grey[300],
                    ),
                  ),
                );
              }),
            ),
            if (_hasRated) ...[
              const SizedBox(height: 16),
              Text(
                'Mevcut puanınız: ${_userRating?.toInt()} yıldız',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Rating Display
            Row(
              children: [
                // Star Rating Display
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < widget.currentRating.floor()
                          ? Icons.star
                          : index < widget.currentRating
                          ? Icons.star_half
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(width: 8),

                // Rating Text
                Text(
                  '${widget.currentRating.toStringAsFixed(1)} (${widget.ratingCount} değerlendirme)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // User Rating Section
            if (widget.showUserRating && authProvider.isLoggedIn) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_hasRated) ...[
                    // Show user's rating
                    Text('Puanınız: ', style: theme.textTheme.bodySmall),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < (_userRating ?? 0).floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.orange,
                          size: 14,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_userRating?.toInt()} yıldız',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Henüz puanlamadınız',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Rate Button
                  if (widget.allowRating) ...[
                    _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton.icon(
                            onPressed: _showRatingDialog,
                            icon: Icon(
                              _hasRated ? Icons.edit : Icons.star_rate,
                              size: 16,
                            ),
                            label: Text(
                              _hasRated ? 'Değiştir' : 'Puanla',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                            ),
                          ),
                  ],
                ],
              ),
            ],

            // Login prompt for non-logged in users
            if (widget.showUserRating && !authProvider.isLoggedIn) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Puanlamak için giriş yapın',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _showLoginPrompt,
                    child: const Text(
                      'Giriş Yap',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Simple star rating display widget
class SimpleStarRating extends StatelessWidget {
  final double rating;
  final int ratingCount;
  final double size;
  final Color? color;

  const SimpleStarRating({
    super.key,
    required this.rating,
    this.ratingCount = 0,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating.floor()
                  ? Icons.star
                  : index < rating
                  ? Icons.star_half
                  : Icons.star_border,
              color: color ?? Colors.amber,
              size: size,
            );
          }),
        ),
        if (ratingCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '(${ratingCount})',
            style: TextStyle(
              fontSize: size * 0.75,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
