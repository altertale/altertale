import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// PDF görüntüleyici widget'ı
class PdfViewerWidget extends StatefulWidget {
  final String pdfUrl;
  final int initialPage;
  final Function(int)? onPageChanged;
  final Function(double)? onProgressChanged;

  const PdfViewerWidget({
    super.key,
    required this.pdfUrl,
    this.initialPage = 0,
    this.onPageChanged,
    this.onProgressChanged,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'PDF yüklenirken hata oluştu',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoading = true;
                });
              },
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('PDF yükleniyor...'),
          ],
        ),
      );
    }

    return SfPdfViewer.network(
      widget.pdfUrl,
      key: _pdfViewerKey,
      initialPageNumber: widget.initialPage + 1, // SfPdfViewer 1'den başlar
      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
        setState(() {
          _isLoading = false;
          _totalPages = details.document.pages.count;
        });
      },
      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
        setState(() {
          _isLoading = false;
          _error = details.error;
        });
      },
      onPageChanged: (PdfPageChangedDetails details) {
        final newPage = details.newPageNumber - 1; // 0'dan başlayacak şekilde
        setState(() {
          _currentPage = newPage;
        });
        
        // Callback'leri çağır
        widget.onPageChanged?.call(newPage);
        
        final progress = _totalPages > 0 ? (newPage / _totalPages) * 100 : 0.0;
        widget.onProgressChanged?.call(progress);
      },
      enableDoubleTapZooming: true,
      enableTextSelection: false, // Metin seçimini engelle
      canShowScrollHead: false, // Scroll head'i gizle
      canShowScrollStatus: false, // Scroll status'u gizle
      canShowPaginationDialog: false, // Pagination dialog'u gizle
    );
  }

  /// Belirli bir sayfaya git
  void goToPage(int pageNumber) {
    if (pageNumber >= 0 && pageNumber < _totalPages) {
      _pdfViewerKey.currentState?.jumpToPage(pageNumber + 1);
    }
  }

  /// Önceki sayfa
  void previousPage() {
    if (_currentPage > 0) {
      goToPage(_currentPage - 1);
    }
  }

  /// Sonraki sayfa
  void nextPage() {
    if (_currentPage < _totalPages - 1) {
      goToPage(_currentPage + 1);
    }
  }

  /// Zoom in
  void zoomIn() {
    _pdfViewerKey.currentState?.zoomLevel = 
        (_pdfViewerKey.currentState?.zoomLevel ?? 1.0) + 0.25;
  }

  /// Zoom out
  void zoomOut() {
    _pdfViewerKey.currentState?.zoomLevel = 
        (_pdfViewerKey.currentState?.zoomLevel ?? 1.0) - 0.25;
  }

  /// Mevcut sayfa numarasını al
  int get currentPage => _currentPage;

  /// Toplam sayfa sayısını al
  int get totalPages => _totalPages;
}
