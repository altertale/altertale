import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/book_model.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/books/book_card.dart';
import 'package:go_router/go_router.dart';
import "../../widgets/books/book_purchase_button.dart";
import '../../widgets/books/preview_reader.dart';
import '../../widgets/comments/book_comments_section.dart';
import 'reading_screen.dart';
import '../../widgets/purchase/purchase_confirmation_dialog.dart';
import '../../services/purchase_service.dart';

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
  bool _isPurchased =
      false; // TODO: Kullanıcının satın alıp almadığını kontrol et
  String? _error;
  List<String> _bookPages = [];

  @override
  void initState() {
    super.initState();
    _loadBookDetails();
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
    if (book == null) return;
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
          onPressed: () {
            // TODO: Paylaş işlemi
          },
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
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber[600], size: 20),
              const SizedBox(width: 4),
              Text(
                _book!.formattedRating,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${_book!.formattedRatingCount})',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const Spacer(),
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
}
