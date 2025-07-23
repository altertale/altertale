import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../models/book_model.dart';
import '../../models/reading_settings_model.dart';
import '../../providers/reading_settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/books/reading_progress_bar.dart';
import '../../widgets/books/reading_settings_panel.dart';

/// Enhanced Reading Screen with animations and customization
class EnhancedReadingScreen extends StatefulWidget {
  final BookModel book;
  final List<String> pages;
  final int initialPage;

  const EnhancedReadingScreen({
    Key? key,
    required this.book,
    required this.pages,
    this.initialPage = 0,
  }) : super(key: key);

  @override
  State<EnhancedReadingScreen> createState() => _EnhancedReadingScreenState();
}

class _EnhancedReadingScreenState extends State<EnhancedReadingScreen>
    with TickerProviderStateMixin {
  // Controllers and Animation
  late PageController _pageController;
  late AnimationController _uiAnimationController;
  late AnimationController _settingsAnimationController;
  late AnimationController _autoScrollController;
  late Animation<double> _uiOpacityAnimation;
  late Animation<Offset> _settingsSlideAnimation;

  // State variables
  int _currentPage = 0;
  bool _showUI = true;
  bool _showSettings = false;
  bool _isFullscreen = false;
  bool _autoScrollActive = false;
  Timer? _uiHideTimer;
  Timer? _progressSaveTimer;
  ScrollController? _scrollController;

  // Reading session tracking
  DateTime? _sessionStartTime;
  int _sessionReadingTime = 0;

  @override
  void initState() {
    super.initState();
    _initializeReading();
    _setupAnimations();
    _setupControllers();
    _startReadingSession();
  }

  void _initializeReading() {
    _currentPage = widget.initialPage.clamp(0, widget.pages.length - 1);
    _sessionStartTime = DateTime.now();
  }

  void _setupAnimations() {
    // UI Animation Controller
    _uiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _uiOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _uiAnimationController, curve: Curves.easeInOut),
    );

    // Settings Animation Controller
    _settingsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _settingsSlideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _settingsAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Auto Scroll Controller
    _autoScrollController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Initial UI state
    _uiAnimationController.forward();
  }

  void _setupControllers() {
    _pageController = PageController(initialPage: _currentPage);
    _scrollController = ScrollController();
  }

  void _startReadingSession() {
    // Auto-save progress every 30 seconds
    _progressSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _saveReadingProgress();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController?.dispose();
    _uiAnimationController.dispose();
    _settingsAnimationController.dispose();
    _autoScrollController.dispose();
    _uiHideTimer?.cancel();
    _progressSaveTimer?.cancel();
    _saveReadingProgress();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ReadingSettingsProvider>(
        builder: (context, settings, child) {
          return Stack(
            children: [
              // Main Reading Content
              _buildReadingContent(settings),

              // UI Overlay
              AnimatedBuilder(
                animation: _uiOpacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _showUI ? _uiOpacityAnimation.value : 0.0,
                    child: IgnorePointer(ignoring: !_showUI, child: child),
                  );
                },
                child: _buildUIOverlay(settings),
              ),

              // Settings Panel
              AnimatedBuilder(
                animation: _settingsSlideAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _settingsSlideAnimation,
                    child: child,
                  );
                },
                child: _showSettings
                    ? ReadingSettingsPanel(onClose: () => _toggleSettings())
                    : const SizedBox.shrink(),
              ),

              // Reading Progress Bar
              if (_showUI && !_showSettings)
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  child: ReadingProgressBar(
                    currentPage: _currentPage,
                    totalPages: widget.pages.length,
                    onPageTap: _jumpToPage,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReadingContent(ReadingSettingsProvider settings) {
    return GestureDetector(
      onTap: _toggleUI,
      onLongPress: _showContextMenu,
      child: Container(
        color: settings.backgroundColor,
        child: SafeArea(
          child: settings.readingMode == 'continuous'
              ? _buildContinuousReading(settings)
              : _buildPaginatedReading(settings),
        ),
      ),
    );
  }

  Widget _buildContinuousReading(ReadingSettingsProvider settings) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: settings.settings.padding,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= widget.pages.length) return null;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: settings.pageWidth,
                margin: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (settings.showPageNumbers)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Sayfa ${index + 1}',
                          style: settings.textStyle.copyWith(
                            fontSize: 12,
                            color: settings.textColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: settings.textStyle,
                      child: SelectableText(
                        widget.pages[index],
                        textAlign: settings.textAlign,
                        onSelectionChanged: _handleTextSelection,
                      ),
                    ),
                  ],
                ),
              );
            }, childCount: widget.pages.length),
          ),
        ),
        // End spacing
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildPaginatedReading(ReadingSettingsProvider settings) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: widget.pages.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: settings.settings.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (settings.showPageNumbers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Sayfa ${index + 1} / ${widget.pages.length}',
                    style: settings.textStyle.copyWith(
                      fontSize: 12,
                      color: settings.textColor.withOpacity(0.6),
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: settings.textStyle,
                    child: SelectableText(
                      widget.pages[index],
                      textAlign: settings.textAlign,
                      onSelectionChanged: _handleTextSelection,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUIOverlay(ReadingSettingsProvider settings) {
    return Container(
      child: Column(
        children: [
          // Top Bar
          Container(
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: _exitReading,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      widget.book.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleFullscreen,
                    icon: Icon(
                      _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleSettings,
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Bottom Controls
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: Icons.bookmark_border,
                    label: 'Bookmark',
                    onPressed: _addBookmark,
                  ),
                  _buildControlButton(
                    icon: settings.autoScroll ? Icons.pause : Icons.play_arrow,
                    label: 'Auto Scroll',
                    onPressed: _toggleAutoScroll,
                  ),
                  _buildControlButton(
                    icon: Icons.text_format,
                    label: 'Font Size',
                    onPressed: _showFontSizeDialog,
                  ),
                  _buildControlButton(
                    icon: Icons.palette,
                    label: 'Theme',
                    onPressed: _showThemeSelector,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // Event Handlers
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _saveReadingProgress();
  }

  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
    });

    if (_showUI) {
      _uiAnimationController.forward();
      _scheduleUIHide();
    } else {
      _uiAnimationController.reverse();
      _uiHideTimer?.cancel();
    }
  }

  void _scheduleUIHide() {
    _uiHideTimer?.cancel();
    _uiHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showUI && !_showSettings) {
        _toggleUI();
      }
    });
  }

  void _toggleSettings() {
    setState(() {
      _showSettings = !_showSettings;
    });

    if (_showSettings) {
      _settingsAnimationController.forward();
    } else {
      _settingsAnimationController.reverse();
    }
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleAutoScroll() {
    final settingsProvider = context.read<ReadingSettingsProvider>();
    settingsProvider.toggleAutoScroll();

    if (settingsProvider.autoScroll) {
      _startAutoScroll();
    } else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll() {
    if (_scrollController == null) return;

    final settings = context.read<ReadingSettingsProvider>();
    final scrollSpeed = settings.autoScrollSpeed * 50; // pixels per second

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!settings.autoScroll || _scrollController == null) {
        timer.cancel();
        return;
      }

      final currentOffset = _scrollController!.offset;
      final maxOffset = _scrollController!.position.maxScrollExtent;

      if (currentOffset >= maxOffset) {
        timer.cancel();
        return;
      }

      _scrollController!.animateTo(
        currentOffset + (scrollSpeed * 0.1),
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    });
  }

  void _stopAutoScroll() {
    // Auto scroll will stop automatically when autoScroll becomes false
  }

  void _jumpToPage(int page) {
    if (context.read<ReadingSettingsProvider>().readingMode == 'paginated') {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // For continuous mode, calculate scroll position
      final scrollPosition =
          (page / widget.pages.length) *
          (_scrollController?.position.maxScrollExtent ?? 0);
      _scrollController?.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleTextSelection(
    TextSelection selection,
    SelectionChangedCause? cause,
  ) {
    if (selection.isValid && !selection.isCollapsed) {
      // Handle text selection (e.g., show definition, highlight, etc.)
      _showTextSelectionMenu(selection);
    }
  }

  void _showTextSelectionMenu(TextSelection selection) {
    // Show context menu for selected text
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.highlight),
              title: const Text('Vurgula'),
              onTap: () {
                Navigator.pop(context);
                _highlightText(selection);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('Not Ekle'),
              onTap: () {
                Navigator.pop(context);
                _addNote(selection);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Tanım Ara'),
              onTap: () {
                Navigator.pop(context);
                _searchDefinition(selection);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu() {
    // Long press context menu
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Sayfa İmi Ekle'),
              onTap: () {
                Navigator.pop(context);
                _addBookmark();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Paylaş'),
              onTap: () {
                Navigator.pop(context);
                _shareCurrentPage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Sayfa Bilgisi'),
              onTap: () {
                Navigator.pop(context);
                _showPageInfo();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog() {
    final settings = context.read<ReadingSettingsProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Boyutu'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Boyut: ${settings.fontSize.toInt()}pt'),
              Slider(
                value: settings.fontSize,
                min: 12,
                max: 32,
                divisions: 20,
                onChanged: (value) {
                  settings.updateFontSize(value);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector() {
    final settings = context.read<ReadingSettingsProvider>();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Açık Tema'),
              onTap: () {
                settings.applyTheme(ReadingSettingsModel.defaultLight());
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Koyu Tema'),
              onTap: () {
                settings.applyTheme(ReadingSettingsModel.defaultDark());
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Sepia'),
              onTap: () {
                settings.applyTheme(ReadingSettingsModel.sepia());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Utility methods
  void _saveReadingProgress() async {
    try {
      // Save current page and reading time
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isLoggedIn) {
        // Save to backend
        print('💾 Saving reading progress: Page $_currentPage');
      }
    } catch (e) {
      print('❌ Error saving progress: $e');
    }
  }

  void _exitReading() {
    _saveReadingProgress();
    Navigator.pop(context);
  }

  void _addBookmark() {
    // Add bookmark functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sayfa imi eklendi!')));
  }

  void _highlightText(TextSelection selection) {
    // Highlight text functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Metin vurgulandı!')));
  }

  void _addNote(TextSelection selection) {
    // Add note functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Not eklendi!')));
  }

  void _searchDefinition(TextSelection selection) {
    // Search definition functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tanım aranıyor...')));
  }

  void _shareCurrentPage() {
    // Share current page functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sayfa paylaşıldı!')));
  }

  void _showPageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sayfa Bilgisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sayfa: ${_currentPage + 1} / ${widget.pages.length}'),
            Text(
              'İlerleme: ${((_currentPage + 1) / widget.pages.length * 100).toStringAsFixed(1)}%',
            ),
            Text('Okuma Süresi: ${_getReadingTime()}'),
            Text('Kelime Sayısı: ${_getCurrentPageWordCount()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  String _getReadingTime() {
    if (_sessionStartTime == null) return '0 dakika';

    final elapsed = DateTime.now().difference(_sessionStartTime!);
    final minutes = elapsed.inMinutes;

    if (minutes < 60) {
      return '$minutes dakika';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}sa ${remainingMinutes}dk';
    }
  }

  int _getCurrentPageWordCount() {
    if (_currentPage >= widget.pages.length) return 0;
    return widget.pages[_currentPage].split(' ').length;
  }
}
