import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/offline/offline_service.dart';
import '../../widgets/offline/connection_status_bar.dart';
import '../../widgets/offline/sync_status_widget.dart';
import '../reading/pdf_viewer_widget.dart';
import '../reading/html_viewer_widget.dart';

/// Offline okuma ekranı
class OfflineReadingScreen extends StatefulWidget {
  final BookModel book;
  final String contentType;

  const OfflineReadingScreen({
    super.key,
    required this.book,
    required this.contentType,
  });

  @override
  State<OfflineReadingScreen> createState() => _OfflineReadingScreenState();
}

class _OfflineReadingScreenState extends State<OfflineReadingScreen> {
  final OfflineService _offlineService = OfflineService();
  String? _bookContent;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _readingProgress;

  @override
  void initState() {
    super.initState();
    _loadBookContent();
    _loadReadingProgress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          SyncStatusWidget(showProgress: false),
        ],
      ),
      body: Column(
        children: [
          // Bağlantı durumu çubuğu
          ConnectionStatusBar(),
          
          // Ana içerik
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorWidget(theme)
                    : _buildContentWidget(theme),
          ),
        ],
      ),
    );
  }

  /// Hata widget'ı
  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Kitap yüklenemedi',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadBookContent,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  /// İçerik widget'ı
  Widget _buildContentWidget(ThemeData theme) {
    if (_bookContent == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: 64,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Kitap içeriği bulunamadı',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Kitabı tekrar indirmeniz gerekebilir',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // İçerik türüne göre widget seç
    switch (widget.contentType.toLowerCase()) {
      case 'pdf':
        return PDFViewerWidget(
          content: _bookContent!,
          bookId: widget.book.id,
          onProgressUpdate: _updateReadingProgress,
          initialProgress: _readingProgress,
        );
      
      case 'html':
      case 'markdown':
        return HTMLViewerWidget(
          content: _bookContent!,
          bookId: widget.book.id,
          onProgressUpdate: _updateReadingProgress,
          initialProgress: _readingProgress,
        );
      
      default:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Offline uyarısı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.download_done,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Çevrimdışı okuma modu - İlerleme otomatik kaydediliyor',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Kitap içeriği
              Text(
                _bookContent!,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        );
    }
  }

  // ==================== VERİ YÖNETİMİ ====================

  /// Kitap içeriğini yükle
  Future<void> _loadBookContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final content = await _offlineService.getBookContent(
        widget.book.id,
        widget.contentType,
      );

      setState(() {
        _bookContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Okuma ilerlemesini yükle
  void _loadReadingProgress() {
    final progress = _offlineService.getReadingProgress(widget.book.id);
    setState(() {
      _readingProgress = progress;
    });
  }

  /// Okuma ilerlemesini güncelle
  void _updateReadingProgress(Map<String, dynamic> progress) {
    // Yerel olarak kaydet
    _offlineService.saveReadingProgressOffline(widget.book.id, progress);
    
    // UI'ı güncelle
    setState(() {
      _readingProgress = progress;
    });
  }
}
