import 'package:flutter/material.dart';
import '../../services/offline/offline_service.dart';
import '../../widgets/offline/sync_status_widget.dart';

/// Offline ayarlar ekranı
class OfflineSettingsScreen extends StatefulWidget {
  const OfflineSettingsScreen({super.key});

  @override
  State<OfflineSettingsScreen> createState() => _OfflineSettingsScreenState();
}

class _OfflineSettingsScreenState extends State<OfflineSettingsScreen> {
  final OfflineService _offlineService = OfflineService();

  bool _offlineMode = false;
  bool _autoDownload = true;
  List<Map<String, dynamic>> _pendingActions = [];
  List<String> _downloadedBooks = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Ayarlar'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [SyncStatusWidget(showProgress: false)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildConnectionStatus(theme),
          const SizedBox(height: 16),
          _buildGeneralSettings(theme),
          const SizedBox(height: 16),
          _buildStorageInfo(theme),
          const SizedBox(height: 16),
          _buildPendingActions(theme),
          const SizedBox(height: 16),
          _buildDownloadedBooks(theme),
          const SizedBox(height: 16),
          _buildActions(theme),
        ],
      ),
    );
  }

  /// Bağlantı durumu kartı
  Widget _buildConnectionStatus(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _offlineService.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _offlineService.isConnected
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                Text('Bağlantı Durumu', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _offlineService.isConnected
                  ? 'İnternet bağlantısı mevcut'
                  : 'Çevrimdışı mod - İnternet bağlantısı yok',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _offlineService.isConnected ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Genel ayarlar kartı
  Widget _buildGeneralSettings(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Genel Ayarlar', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),

            // Offline mod
            SwitchListTile(
              title: const Text('Offline Mod'),
              subtitle: const Text('Çevrimdışı kullanımı etkinleştir'),
              value: _offlineMode,
              onChanged: (value) {
                setState(() {
                  _offlineMode = value;
                });
                _offlineService.setOfflineMode(value);
              },
            ),

            // Otomatik indirme
            SwitchListTile(
              title: const Text('Otomatik İndirme'),
              subtitle: const Text('Satın alınan kitapları otomatik indir'),
              value: _autoDownload,
              onChanged: (value) {
                setState(() {
                  _autoDownload = value;
                });
                _offlineService.setAutoDownload(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Depolama bilgisi kartı
  Widget _buildStorageInfo(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Depolama Bilgisi', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),

            FutureBuilder<int>(
              future: _offlineService.getUsedStorage(),
              builder: (context, snapshot) {
                final usedStorage = snapshot.data ?? 0;
                final usedMB = (usedStorage / (1024 * 1024)).toStringAsFixed(1);

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kullanılan Alan:'),
                        Text('$usedMB MB'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: usedStorage > 0 ? 0.3 : 0.0, // Örnek değer
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Bekleyen işlemler kartı
  Widget _buildPendingActions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bekleyen İşlemler', style: theme.textTheme.titleMedium),
                if (_pendingActions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_pendingActions.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (_pendingActions.isEmpty)
              Text(
                'Bekleyen işlem yok',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              )
            else
              Column(
                children: _pendingActions.take(3).map((action) {
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      _getActionIcon(action['type'] as String),
                      size: 16,
                    ),
                    title: Text(
                      _getActionTitle(action['type'] as String),
                      style: const TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      _getActionDescription(action),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// İndirilen kitaplar kartı
  Widget _buildDownloadedBooks(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('İndirilen Kitaplar', style: theme.textTheme.titleMedium),
                Text(
                  '${_downloadedBooks.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_downloadedBooks.isEmpty)
              Text(
                'İndirilen kitap yok',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              )
            else
              Column(
                children: _downloadedBooks.take(3).map((bookId) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.book, size: 16),
                    title: Text(
                      'Kitap ID: $bookId',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 16),
                      onPressed: () => _removeBook(bookId),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// Aksiyonlar kartı
  Widget _buildActions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aksiyonlar', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),

            // Manuel senkronizasyon
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Manuel Senkronizasyon'),
              subtitle: const Text('Bekleyen işlemleri senkronize et'),
              onTap: _performManualSync,
            ),

            // Önbelleği temizle
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Önbelleği Temizle'),
              subtitle: const Text('Tüm offline verileri sil'),
              onTap: _clearCache,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Ayarları yükle
  void _loadSettings() {
    _offlineMode = _offlineService.getOfflineMode();
    _autoDownload = _offlineService.getAutoDownload();
  }

  /// Verileri yükle
  void _loadData() {
    _pendingActions = _offlineService.getPendingActions();
    _downloadedBooks = _offlineService.getPurchasedBooks();
  }

  /// Manuel senkronizasyon
  Future<void> _performManualSync() async {
    await _offlineService.performSync();
    _loadData();
    setState(() {});
  }

  /// Önbelleği temizle
  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Önbelleği Temizle'),
        content: const Text(
          'Tüm offline veriler silinecek. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Önbelleği temizle
      // _offlineService.clearCache();
      _loadData();
      setState(() {});
    }
  }

  /// Kitabı kaldır
  Future<void> _removeBook(String bookId) async {
    await _offlineService.removeBookFromOffline(bookId);
    _loadData();
    setState(() {});
  }

  /// İşlem ikonu getir
  IconData _getActionIcon(String type) {
    switch (type) {
      case 'purchase_book':
        return Icons.shopping_cart;
      case 'add_points':
        return Icons.stars;
      case 'reading_progress':
        return Icons.book;
      case 'book_like':
        return Icons.favorite;
      case 'add_comment':
        return Icons.comment;
      default:
        return Icons.info;
    }
  }

  /// İşlem başlığı getir
  String _getActionTitle(String type) {
    switch (type) {
      case 'purchase_book':
        return 'Kitap Satın Alma';
      case 'add_points':
        return 'Puan Ekleme';
      case 'reading_progress':
        return 'Okuma İlerlemesi';
      case 'book_like':
        return 'Kitap Beğenisi';
      case 'add_comment':
        return 'Yorum Ekleme';
      default:
        return 'Bilinmeyen İşlem';
    }
  }

  /// İşlem açıklaması getir
  String _getActionDescription(Map<String, dynamic> action) {
    switch (action['type'] as String) {
      case 'purchase_book':
        return '${action['bookTitle'] ?? 'Bilinmeyen Kitap'} - ${action['points']} puan';
      case 'add_points':
        return '${action['points']} puan - ${action['reason']}';
      case 'reading_progress':
        return 'Sayfa ${action['progress']?['currentPage'] ?? 0}';
      case 'book_like':
        return action['isLiked'] == true ? 'Beğenildi' : 'Beğeni kaldırıldı';
      case 'add_comment':
        return action['comment']?.toString().substring(0, 30) ?? '';
      default:
        return 'Bilinmeyen işlem';
    }
  }
}
