import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;

/// HTML/Markdown görüntüleyici widget'ı
class HtmlViewerWidget extends StatefulWidget {
  final String content;
  final String contentType; // 'html' veya 'markdown'
  final int initialPage;
  final Function(int)? onPageChanged;
  final Function(double)? onProgressChanged;
  final double fontSize;
  final double lineHeight;
  final bool isDarkMode;

  const HtmlViewerWidget({
    super.key,
    required this.content,
    this.contentType = 'html',
    this.initialPage = 0,
    this.onPageChanged,
    this.onProgressChanged,
    this.fontSize = 16.0,
    this.lineHeight = 1.5,
    this.isDarkMode = false,
  });

  @override
  State<HtmlViewerWidget> createState() => _HtmlViewerWidgetState();
}

class _HtmlViewerWidgetState extends State<HtmlViewerWidget> {
  late List<String> _pages;
  int _currentPage = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _processContent();
  }

  @override
  void didUpdateWidget(HtmlViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content ||
        oldWidget.contentType != widget.contentType) {
      _processContent();
    }
  }

  /// İçeriği işle ve sayfalara böl
  void _processContent() {
    setState(() {
      _isLoading = true;
    });

    try {
      String processedContent;
      
      if (widget.contentType == 'markdown') {
        // Markdown'ı HTML'e çevir
        processedContent = md.markdownToHtml(widget.content);
      } else {
        processedContent = widget.content;
      }

      // HTML'i sayfalara böl
      _pages = _splitIntoPages(processedContent);
      
      setState(() {
        _isLoading = false;
      });

      // İlerleme callback'ini çağır
      if (_pages.isNotEmpty) {
        final progress = (_currentPage / _pages.length) * 100;
        widget.onProgressChanged?.call(progress);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('İçerik işlenirken hata: $e');
    }
  }

  /// HTML içeriğini sayfalara böl
  List<String> _splitIntoPages(String htmlContent) {
    // Basit sayfa bölme algoritması
    // Gerçek uygulamada daha gelişmiş bir algoritma kullanılabilir
    const int wordsPerPage = 300; // Sayfa başına kelime sayısı
    
    // HTML tag'lerini geçici olarak kaldır
    final textContent = _stripHtmlTags(htmlContent);
    final words = textContent.split(' ');
    
    final pages = <String>[];
    int currentWordIndex = 0;
    
    while (currentWordIndex < words.length) {
      final endIndex = (currentWordIndex + wordsPerPage).clamp(0, words.length);
      final pageWords = words.sublist(currentWordIndex, endIndex);
      
      // Sayfa içeriğini HTML formatında oluştur
      final pageContent = '''
        <div style="
          font-size: ${widget.fontSize}px;
          line-height: ${widget.lineHeight};
          color: ${widget.isDarkMode ? '#ffffff' : '#000000'};
          background-color: ${widget.isDarkMode ? '#000000' : '#ffffff'};
          padding: 20px;
          text-align: justify;
        ">
          ${pageWords.join(' ')}
        </div>
      ''';
      
      pages.add(pageContent);
      currentWordIndex = endIndex;
    }
    
    return pages;
  }

  /// HTML tag'lerini kaldır
  String _stripHtmlTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Sayfa değiştir
  void _changePage(int delta) {
    final newPage = _currentPage + delta;
    if (newPage >= 0 && newPage < _pages.length) {
      setState(() {
        _currentPage = newPage;
      });
      
      widget.onPageChanged?.call(newPage);
      
      if (_pages.isNotEmpty) {
        final progress = (newPage / _pages.length) * 100;
        widget.onProgressChanged?.call(progress);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_pages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'İçerik bulunamadı',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTapUp: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        final tapX = details.localPosition.dx;
        
        if (tapX < screenWidth / 3) {
          // Sol tarafa dokunuldu - önceki sayfa
          _changePage(-1);
        } else if (tapX > screenWidth * 2 / 3) {
          // Sağ tarafa dokunuldu - sonraki sayfa
          _changePage(1);
        }
      },
      child: Container(
        color: widget.isDarkMode ? Colors.black : Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Html(
            data: _pages[_currentPage],
            style: {
              "div": Style(
                fontSize: FontSize(widget.fontSize),
                lineHeight: LineHeight(widget.lineHeight),
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            },
          ),
        ),
      ),
    );
  }

  /// Belirli bir sayfaya git
  void goToPage(int pageNumber) {
    if (pageNumber >= 0 && pageNumber < _pages.length) {
      setState(() {
        _currentPage = pageNumber;
      });
      
      widget.onPageChanged?.call(pageNumber);
      
      if (_pages.isNotEmpty) {
        final progress = (pageNumber / _pages.length) * 100;
        widget.onProgressChanged?.call(progress);
      }
    }
  }

  /// Önceki sayfa
  void previousPage() {
    _changePage(-1);
  }

  /// Sonraki sayfa
  void nextPage() {
    _changePage(1);
  }

  /// Mevcut sayfa numarasını al
  int get currentPage => _currentPage;

  /// Toplam sayfa sayısını al
  int get totalPages => _pages.length;
}
