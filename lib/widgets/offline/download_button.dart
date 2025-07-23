import 'package:flutter/material.dart';
import '../../services/offline/offline_service.dart';

/// Kitap indirme butonu
class DownloadButton extends StatefulWidget {
  final String bookId;
  final String downloadUrl;
  final String? title;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const DownloadButton({
    super.key,
    required this.bookId,
    required this.downloadUrl,
    this.title,
    this.onSuccess,
    this.onError,
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  final OfflineService _offlineService = OfflineService();
  bool _isDownloading = false;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isDownloaded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.download_done,
              color: Colors.green,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'İndirildi',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _isDownloading ? null : _downloadBook,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      icon: _isDownloading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            )
          : const Icon(Icons.download, size: 16),
      label: Text(
        _isDownloading ? 'İndiriliyor...' : 'İndir',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  /// İndirme durumunu kontrol et
  void _checkDownloadStatus() {
    final contentType = _getContentType(widget.downloadUrl);
    _isDownloaded = _offlineService.isBookAvailableOffline(widget.bookId, contentType);
  }

  /// Kitabı indir
  Future<void> _downloadBook() async {
    if (!_offlineService.isConnected) {
      widget.onError?.call();
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      final success = await _offlineService.downloadBookForOffline(
        widget.bookId,
        widget.downloadUrl,
      );

      if (success) {
        setState(() {
          _isDownloaded = true;
        });
        widget.onSuccess?.call();
      } else {
        widget.onError?.call();
      }
    } catch (e) {
      widget.onError?.call();
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  /// İçerik türünü belirle
  String _getContentType(String url) {
    if (url.toLowerCase().endsWith('.pdf')) {
      return 'pdf';
    } else if (url.toLowerCase().endsWith('.html') || url.toLowerCase().endsWith('.htm')) {
      return 'html';
    } else if (url.toLowerCase().endsWith('.md') || url.toLowerCase().endsWith('.markdown')) {
      return 'markdown';
    } else {
      return 'text';
    }
  }
}
