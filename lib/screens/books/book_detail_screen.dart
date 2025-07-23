import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/auth/auth_wrapper.dart';
import '../../widgets/books/preview_reader.dart';
import '../../widgets/widgets.dart'; // Import all custom widgets
import '../../services/book_service.dart';
import '../../services/cart_service.dart';
import '../../services/favorites_service.dart';
import '../../services/share_service.dart';
import '../../services/purchase_service.dart';
import '../../models/book_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_themes.dart';
import '../../screens/books/reading_screen.dart';
import '../../screens/books/preview_reading_screen.dart';
import '../../dialogs/purchase_confirmation_dialog.dart';

/// Kitap detay ekranı - kitap hakkında detaylı bilgi gösterir
class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  BookModel? _book;
  List<BookModel> _similarBooks = [];
  bool _isLoading = true;
  bool _isPurchased = false;
  String? _error;
  List<String> _bookPages = [];

  // Rating related state
  BookRatingStats? _ratingStats;
  Rating? _userRating;
  bool _isLoadingRating = true;

  @override
  void initState() {
    super.initState();
    _loadBookDetails();
    _loadRatingData();
  }

  /// Load rating data for the book
  Future<void> _loadRatingData() async {
    try {
      final ratingProvider = context.read<RatingProvider>();

      // Load book rating stats and user rating in parallel
      final futures = await Future.wait([
        ratingProvider.loadBookRatingStats(widget.bookId),
        ratingProvider.loadUserRating(widget.bookId),
      ]);

      setState(() {
        _ratingStats = futures[0] as BookRatingStats;
        _userRating = futures[1] as Rating?;
        _isLoadingRating = false;
      });
    } catch (e) {
      print('Error loading rating data: $e');
      setState(() {
        _isLoadingRating = false;
      });
    }
  }

  /// Kitap detaylarını yükler
  Future<void> _loadBookDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final bookProvider = context.read<BookProvider>();
      final authProvider = context.read<AuthProvider>();

      // Kitap detaylarını yükle
      final book = await bookProvider.getBookById(widget.bookId);

      if (book != null) {
        // Check if user has purchased this book
        bool isPurchased = false;
        if (authProvider.isLoggedIn) {
          final purchaseService = PurchaseService();
          isPurchased = await purchaseService.hasUserPurchasedBook(
            userId: authProvider.userId,
            bookId: widget.bookId,
          );
        }

        // Benzer kitapları yükle
        final similarBooks = await bookProvider.getSimilarBooks(book.id);

        setState(() {
          _book = book;
          _isPurchased = isPurchased;
          _similarBooks = similarBooks;
          _isLoading = false;
        });

        // Generate demo pages for reading
        _bookPages = List.generate(
          50,
          (index) =>
              'Bu ${book.title} kitabının ${index + 1}. sayfasıdır. '
              '${book.author} tarafından yazılmış bu muhteşem eser, '
              'okuyuculara benzersiz bir deneyim sunmaktadır...',
        );
      } else {
        setState(() {
          _error = 'Kitap bulunamadı';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Kitap yüklenirken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  void _startReading(BookModel book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReadingScreen(book: book, pages: _bookPages),
      ),
    );
  }

  void _purchaseBook(BookModel book) async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen önce giriş yapın')));
      return;
    }

    // Show purchase confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => PurchaseConfirmationDialog(
        book: BookModel.fromBook(book),
        usePoints: false,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Perform actual purchase using PurchaseService
      final purchaseService = PurchaseService();
      final success = await purchaseService.purchaseWithTL(
        userId: authProvider.currentUser!.uid,
        book: BookModel.fromBook(book),
        amount: book.price,
        paymentProvider: 'demo',
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${book.title} başarıyla satın alındı!'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Oku',
                onPressed: () => _startReading(book),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Satın alma başarısız: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget(context)
          : _book == null
          ? _buildNotFoundWidget(context)
          : CustomScrollView(
              slivers: [
                // App Bar
                _buildSliverAppBar(context),

                // Ana içerik
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kitap bilgileri
                      _buildBookInfo(context),

                      // Aksiyon butonları
                      _buildActionButtons(context),

                      // Açıklama
                      _buildDescription(context),

                      // Kitap detayları
                      _buildBookDetails(context),

                      // Kategoriler ve etiketler
                      _buildCategoriesAndTags(context),

                      // Yorumlar bölümü
                      _buildCommentsSection(context),

                      // Benzer kitaplar
                      if (_similarBooks.isNotEmpty) _buildSimilarBooks(context),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /// Sliver App Bar
  Widget _buildSliverAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          onPressed: () => _showShareOptions(context),
          icon: const Icon(Icons.share),
        ),
        IconButton(
          onPressed: () {
            // TODO: Favorilere ekleme
          },
          icon: const Icon(Icons.favorite_border),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _book?.coverImageUrl != null
            ? CachedNetworkImage(
                imageUrl: _book!.coverImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.book, size: 80, color: Colors.grey),
                ),
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.book, size: 80, color: Colors.grey),
              ),
      ),
    );
  }

  /// Kitap bilgileri
  Widget _buildBookInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kitap adı
          Text(
            _book!.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Yazar adı
          Text(
            _book!.author,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 16),

          // Puan ve yorum sayısı
          _buildRatingSection(context),
        ],
      ),
    );
  }

  /// Aksiyon butonları
  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    if (_book == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (_isPurchased) ...[
            // Purchased book actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startReading(_book!),
                    icon: const Icon(Icons.auto_stories),
                    label: const Text('Kitabı Oku'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Add comment functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Yorum özelliği yakında!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.comment),
                    label: const Text('Yorum Yap'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Paylaşım özelliği yakında!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Paylaş'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PreviewReader(book: _book!, pages: _bookPages),
                        ),
                      );
                    },
                    icon: const Icon(Icons.preview),
                    label: const Text('Önizleme'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Not purchased book actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PreviewReader(book: _book!, pages: _bookPages),
                        ),
                      );
                    },
                    icon: const Icon(Icons.preview),
                    label: const Text('Önizleme'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Purchase button
                Expanded(
                  child: BookPurchaseButton(
                    book: _book!,
                    isPurchased: _isPurchased,
                    onPurchased: () {
                      setState(() => _isPurchased = true);
                      _startReading(_book!);
                    },
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Açıklama
  Widget _buildDescription(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Açıklama',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _book!.description,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  /// Kitap detayları
  Widget _buildBookDetails(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kitap Detayları',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Detay kartları
          Row(
            children: [
              Expanded(
                child: _buildDetailCard(
                  context,
                  icon: Icons.pages,
                  title: 'Sayfa Sayısı',
                  value: _book!.formattedPageCount,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailCard(
                  context,
                  icon: Icons.language,
                  title: 'Dil',
                  value: _book!.language.toUpperCase(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailCard(
                  context,
                  icon: Icons.attach_money,
                  title: 'Fiyat',
                  value: _book!.formattedPrice,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailCard(
                  context,
                  icon: Icons.stars,
                  title: 'Puan',
                  value: _book!.formattedPoints,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Detay kartı
  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Kategoriler ve etiketler
  Widget _buildCategoriesAndTags(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategoriler
          if (_book!.categories.isNotEmpty) ...[
            Text(
              'Kategoriler',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _book!.categories.map((category) {
                return Chip(
                  label: Text(category),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Etiketler
          if (_book!.tags.isNotEmpty) ...[
            Text(
              'Etiketler',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _book!.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Yorumlar bölümü
  Widget _buildCommentsSection(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: BookCommentsSection(book: _book!, currentUserId: currentUserId),
    );
  }

  /// Benzer kitaplar
  Widget _buildSimilarBooks(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benzer Kitaplar',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _similarBooks.length,
              itemBuilder: (context, index) {
                final book = _similarBooks[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _similarBooks.length - 1 ? 16 : 0,
                  ),
                  child: BookCard(
                    book: book,
                    onTap: () {
                      // Aynı sayfada yeni kitap detayını göster
                      context.pushReplacement('/book/${book.id}');
                    },
                    onBuyTap: () {
                      // TODO: Satın alma işlemi
                    },
                    onReadTap: () {
                      // TODO: Okuma işlemi
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Hata widget'ı
  Widget _buildErrorWidget(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Bir hata oluştu',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBookDetails,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  /// Bulunamadı widget'ı
  Widget _buildNotFoundWidget(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: theme.hintColor),
            const SizedBox(height: 16),
            Text(
              'Kitap bulunamadı',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Geri Dön'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build rating section with interactive rating
  Widget _buildRatingSection(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoadingRating) {
      return Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            'Puanlar yükleniyor...',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall rating display
        if (_ratingStats != null && _ratingStats!.totalRatings > 0) ...[
          RatingDisplayWidget(
            rating: _ratingStats!.averageRating,
            totalRatings: _ratingStats!.totalRatings,
            starSize: 20,
            fontSize: 16,
          ),
          const SizedBox(height: 12),
        ],

        // User rating section
        _buildUserRatingSection(context),

        // Book stats
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.visibility, color: theme.hintColor, size: 16),
            const SizedBox(width: 4),
            Text(
              _book!.formattedReadCount,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build user rating section
  Widget _buildUserRatingSection(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.star_outline, color: theme.hintColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Puanlamak için giriş yapın',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _userRating != null ? 'Puanınız' : 'Bu kitabı puanlayın',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              StarRatingWidget(
                initialRating: _userRating?.rating ?? 0.0,
                onRatingChanged: _onRatingChanged,
                size: 28,
                filledColor: Colors.amber,
                unfilledColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 12),
              if (_userRating != null) ...[
                Text(
                  _getRatingText(_userRating!.rating),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          if (context.watch<RatingProvider>().isSubmitting) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Puanınız kaydediliyor...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Handle rating change
  void _onRatingChanged(double rating) async {
    final ratingProvider = context.read<RatingProvider>();

    final success = await ratingProvider.submitRating(widget.bookId, rating);

    if (success) {
      // Refresh rating data
      await _loadRatingData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Puanınız kaydedildi: ${_getRatingText(rating)}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Puan kaydedilemedi. Lütfen tekrar deneyin.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Get rating text description
  String _getRatingText(double rating) {
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

  /// Show share options dialog
  void _showShareOptions(BuildContext context) {
    if (_book == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          _ShareOptionsBottomSheet(book: _book!, ratingStats: _ratingStats),
    );
  }
}

/// Share options bottom sheet
class _ShareOptionsBottomSheet extends StatelessWidget {
  final BookModel book;
  final BookRatingStats? ratingStats;

  const _ShareOptionsBottomSheet({required this.book, this.ratingStats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Kitabı Paylaş',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Book info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: book.coverImageUrl,
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      book.author,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    if (ratingStats != null &&
                        ratingStats!.totalRatings > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${ratingStats!.averageRating.toStringAsFixed(1)} (${ratingStats!.totalRatings})',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Share options
          Column(
            children: [
              _ShareOptionTile(
                icon: Icons.share,
                title: 'Genel Paylaşım',
                subtitle: 'Mevcut tüm uygulamalar',
                onTap: () {
                  Navigator.pop(context);
                  AdvancedShareService.shareBook(
                    book,
                    ratingStats: ratingStats,
                  );
                },
              ),
              _ShareOptionTile(
                icon: Icons.message,
                title: 'WhatsApp',
                subtitle: 'WhatsApp ile paylaş',
                color: const Color(0xFF25D366),
                onTap: () {
                  Navigator.pop(context);
                  AdvancedShareService.shareBook(
                    book,
                    ratingStats: ratingStats,
                    platform: SharePlatform.whatsapp,
                  );
                },
              ),
              _ShareOptionTile(
                icon: Icons.camera_alt,
                title: 'Instagram',
                subtitle: 'Instagram Stories için kopyala',
                color: const Color(0xFFE4405F),
                onTap: () {
                  Navigator.pop(context);
                  AdvancedShareService.shareBook(
                    book,
                    ratingStats: ratingStats,
                    platform: SharePlatform.instagram,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Instagram için metin kopyalandı!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _ShareOptionTile(
                icon: Icons.alternate_email,
                title: 'Twitter',
                subtitle: 'Twitter\'da paylaş',
                color: const Color(0xFF1DA1F2),
                onTap: () {
                  Navigator.pop(context);
                  AdvancedShareService.shareBook(
                    book,
                    ratingStats: ratingStats,
                    platform: SharePlatform.twitter,
                  );
                },
              ),
              _ShareOptionTile(
                icon: Icons.copy,
                title: 'Linki Kopyala',
                subtitle: 'Panoya kopyala',
                onTap: () {
                  Navigator.pop(context);
                  final text =
                      '''
📚 "${book.title}" - ${book.author}

AlterTale'de keşfedin: https://altertale.github.io/altertale
'''
                          .trim();
                  AdvancedShareService.copyToClipboard(text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link kopyalandı!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Share option tile widget
class _ShareOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _ShareOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? theme.colorScheme.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color ?? theme.colorScheme.primary, size: 24),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
