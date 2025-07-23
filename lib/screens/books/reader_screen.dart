import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/reading_progress_service.dart';
import '../../services/book_service.dart';
import '../../widgets/common/title_text.dart';
import '../../widgets/common/subtitle_text.dart';

/// Reader Screen - E-kitap Okuma Ekranı
///
/// Kullanıcıların satın aldığı kitapları tam ekran okuyabilmesini sağlar.
/// Sayfa navigasyonu, okuma ilerlemesi takibi ve kullanıcı dostu tasarım içerir.
class ReaderScreen extends StatefulWidget {
  final String bookId;
  final BookModel? book; // Optional, will be fetched if not provided

  const ReaderScreen({super.key, required this.bookId, this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with TickerProviderStateMixin {
  // ==================== SERVICES ====================
  final BookService _bookService = BookService();
  late ReadingProgressService _readingProgressService;

  // ==================== STATE ====================
  BookModel? _book;
  List<String> _pages = [];
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showControls = true;
  double _fontSize = 16.0;
  double _lineHeight = 1.5;

  // ==================== CONTROLLERS ====================
  late PageController _pageController;
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;

  @override
  void initState() {
    super.initState();
    _readingProgressService = ReadingProgressService();
    _pageController = PageController();
    _setupAnimations();
    _loadBook();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controlsAnimationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controlsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controlsAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _controlsAnimationController.forward();
  }

  // ==================== DATA LOADING ====================

  Future<void> _loadBook() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Use provided book or fetch from service
      if (widget.book != null) {
        _book = widget.book as BookModel?;
      } else {
        _book = await _bookService.getBookById(widget.bookId);
      }

      if (_book == null) {
        setState(() {
          _errorMessage = 'Kitap bulunamadı.';
          _isLoading = false;
        });
        return;
      }

      // Load book content and reading progress
      await _loadBookContent();
      await _loadReadingProgress();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kitap yüklenirken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBookContent() async {
    if (_book == null) return;

    try {
      // For demo mode, generate content from book description
      if (_bookService.isDemoMode) {
        _pages = _generateDemoContent(_book!);
      } else {
        // In production, load from Firestore content collection
        _pages = await _loadFirestoreContent(_book!.id);
      }

      _totalPages = _pages.length;
    } catch (e) {
      // Fallback to demo content
      _pages = _generateDemoContent(_book!);
      _totalPages = _pages.length;
    }
  }

  List<String> _generateDemoContent(BookModel book) {
    // Use the new book.content field if available, otherwise fallback to description
    final baseContent = book.content ?? book.description;
    final pages = <String>[];

    if (book.content != null && book.content!.isNotEmpty) {
      // Split the book content into pages based on natural breaks
      final paragraphs = baseContent.split('\n\n');
      const paragraphsPerPage = 8; // About 8 paragraphs per page

      for (int i = 0; i < paragraphs.length; i += paragraphsPerPage) {
        final endIndex = (i + paragraphsPerPage).clamp(0, paragraphs.length);
        final pageContent = paragraphs.sublist(i, endIndex).join('\n\n');

        String formattedContent = pageContent;

        if (i == 0) {
          // First page - add title and author
          formattedContent =
              '${book.title}\n\n${book.author}\n\n\n$pageContent';
        }

        pages.add(formattedContent);
      }
    } else {
      // Fallback to old method using description
      final words = baseContent.split(' ');
      const wordsPerPage = 200; // Approximately 200 words per page

      for (int i = 0; i < words.length; i += wordsPerPage) {
        final endIndex = (i + wordsPerPage).clamp(0, words.length);
        final pageContent = words.sublist(i, endIndex).join(' ');

        // Add some realistic book content structure
        String formattedContent = pageContent;

        if (i == 0) {
          // First page - add title
          formattedContent =
              '${book.title}\n\n${book.author}\n\n\n$pageContent';
        }

        // Add some paragraph breaks for readability
        formattedContent = formattedContent.replaceAll('. ', '.\n\n');

        pages.add(formattedContent);
      }
    }

    // If we don't have enough pages, add some more
    if (pages.length < 10) {
      for (int i = pages.length; i < 20; i++) {
        pages.add(_generateRandomPage(book, i + 1));
      }
    }

    return pages;
  }

  String _generateRandomPage(BookModel book, int pageNumber) {
    final sampleTexts = [
      'Bu hikayenin başlangıcı çok eskiye dayanır. O zamanlar şehirde henüz teknoloji yaygın değildi ve insanlar daha sade bir hayat sürüyordu.',
      'Kahramanımız sabah erkenden uyanıp pencereden dışarıyı izledi. Güneş henüz doğmamış, sokaklar sessizdi.',
      'Kitaplar her zaman insanoğlunun en büyük hazinesi olmuştur. Bilgiyi, hikayeyi, hayal gücünü gelecek nesillere aktarır.',
      'Bu bölümde karakterlerin gelişimi gözle görülür bir şekilde artmaya başlar. Her birinin kendine özgü hikayesi vardır.',
      'Sayfa sayfa ilerledikçe okuyucu da hikayenin içine çekilir ve kendini karakterlerin yerine koyar.',
    ];

    final randomText = sampleTexts[pageNumber % sampleTexts.length];
    return '$randomText\n\n[Bu ${book.title} kitabının $pageNumber. sayfasıdır]\n\nDevam eden metin buraya gelecek. Gerçek bir e-kitap uygulamasında bu içerik Firebase Firestore\'dan yüklenir ve kitabın gerçek metni gösterilir.\n\nSayfa navigasyonu için alt kısımdaki butonları kullanabilir veya sayfa üzerinde sağa/sola kaydırabilirsiniz.';
  }

  Future<List<String>> _loadFirestoreContent(String bookId) async {
    // TODO: Implement Firestore content loading
    // This would load the actual book content from Firestore
    throw UnimplementedError('Firestore content loading not implemented yet');
  }

  Future<void> _loadReadingProgress() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn || _book == null) return;

    try {
      final progress = await _readingProgressService.getReadingProgress(
        userId: authProvider.userId,
        bookId: _book!.id,
      );

      if (progress != null) {
        setState(() {
          _currentPage = progress.currentPage.clamp(0, _totalPages - 1);
        });

        // Jump to saved page
        if (_currentPage > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _pageController.jumpToPage(_currentPage);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading reading progress: $e');
    }
  }

  // ==================== READING PROGRESS ====================

  Future<void> _saveReadingProgress() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn || _book == null) return;

    try {
      await _readingProgressService.updateReadingProgress(
        userId: authProvider.userId,
        bookId: _book!.id,
        currentPage: _currentPage,
        totalPages: _totalPages,
        percentRead: (_currentPage + 1) / _totalPages * 100,
      );
    } catch (e) {
      debugPrint('Error saving reading progress: $e');
    }
  }

  // ==================== NAVIGATION ====================

  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      setState(() {
        _currentPage = page;
      });
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _saveReadingProgress();
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _goToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  // ==================== UI CONTROLS ====================

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _controlsAnimationController.forward();
    } else {
      _controlsAnimationController.reverse();
    }
  }

  void _showSettingsDialog() {
    showDialog(context: context, builder: (context) => _buildSettingsDialog());
  }

  // ==================== BUILD METHODS ====================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            _buildReaderContent(),

            // Top controls
            if (_showControls) _buildTopControls(),

            // Bottom controls
            if (_showControls) _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            SubtitleText('Kitap yükleniyor...', color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Hata'),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              TitleText(
                'Kitap Yüklenemedi',
                size: TitleSize.medium,
                color: Colors.red[400],
              ),
              const SizedBox(height: 8),
              SubtitleText(
                _errorMessage!,
                textAlign: TextAlign.center,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadBook,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReaderContent() {
    return GestureDetector(
      onTap: _toggleControls,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
          _saveReadingProgress();
        },
        itemCount: _totalPages,
        itemBuilder: (context, index) {
          return _buildPage(_pages[index]);
        },
      ),
    );
  }

  Widget _buildPage(String content) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 120),
      child: SingleChildScrollView(
        child: Text(
          content,
          style: TextStyle(
            fontSize: _fontSize,
            height: _lineHeight,
            color: Colors.black87,
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(0, -60 * (1 - _controlsAnimation.value)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _book?.title ?? 'Kitap',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _book?.author ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.black87),
                    onPressed: _showSettingsDialog,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls() {
    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(0, 120 * (1 - _controlsAnimation.value)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bar
                  _buildProgressBar(),
                  const SizedBox(height: 16),

                  // Navigation buttons
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    final progress = _totalPages > 0 ? (_currentPage + 1) / _totalPages : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sayfa ${_currentPage + 1}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              '$_totalPages sayfa',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: _currentPage > 0 ? _previousPage : null,
          icon: const Icon(Icons.chevron_left),
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: _currentPage > 0
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.grey[200],
          ),
        ),
        Expanded(
          child: Slider(
            value: _currentPage.toDouble(),
            min: 0,
            max: (_totalPages - 1).toDouble(),
            divisions: _totalPages > 1 ? _totalPages - 1 : 1,
            onChanged: (value) {
              _goToPage(value.round());
            },
          ),
        ),
        IconButton(
          onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
          icon: const Icon(Icons.chevron_right),
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: _currentPage < _totalPages - 1
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsDialog() {
    return AlertDialog(
      title: const Text('Okuma Ayarları'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Font size
          Row(
            children: [
              const Text('Yazı Boyutu: '),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 12.0,
                  max: 24.0,
                  divisions: 12,
                  label: _fontSize.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value;
                    });
                  },
                ),
              ),
            ],
          ),

          // Line height
          Row(
            children: [
              const Text('Satır Aralığı: '),
              Expanded(
                child: Slider(
                  value: _lineHeight,
                  min: 1.0,
                  max: 2.0,
                  divisions: 10,
                  label: _lineHeight.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      _lineHeight = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}
