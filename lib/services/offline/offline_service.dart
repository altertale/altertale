import 'dart:io';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';
import 'connectivity_service.dart';
import 'sync_manager.dart';

/// Offline servis - Ana offline işlemleri yönetir
class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final LocalStorageService _localStorage = LocalStorageService();
  final ConnectivityService _connectivity = ConnectivityService();
  final SyncManager _syncManager = SyncManager();

  /// Servisi başlat
  Future<void> initialize() async {
    await _localStorage.initialize();
    await _connectivity.initialize();
    await _syncManager.initialize();
  }

  // ==================== KİTAP İNDİRME ====================

  /// Kitabı offline kullanım için indir
  Future<bool> downloadBookForOffline(String bookId, String downloadUrl) async {
    try {
      // Bağlantı kontrolü
      if (!_connectivity.isConnected) {
        throw Exception('İnternet bağlantısı gerekli');
      }

      // Kitap verilerini al
      final book = _localStorage.getBook(bookId);
      if (book == null) {
        throw Exception('Kitap bulunamadı');
      }

      // İçeriği indir
      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode != 200) {
        throw Exception('Kitap indirilemedi');
      }

      final content = response.body;
      final contentType = _getContentType(downloadUrl);

      // İçeriği şifreli olarak kaydet
      await _localStorage.saveBookContent(bookId, content, contentType);

      // Satın alınan kitaplara ekle
      final purchasedBooks = _localStorage.getPurchasedBooks();
      if (!purchasedBooks.contains(bookId)) {
        purchasedBooks.add(bookId);
        await _localStorage.savePurchasedBooks(purchasedBooks);
      }

      return true;
    } catch (e) {
      throw Exception('Kitap indirme hatası: $e');
    }
  }

  /// Kitap içeriğini getir (offline)
  Future<String?> getBookContent(String bookId, String contentType) async {
    return await _localStorage.getBookContent(bookId, contentType);
  }

  /// Kitabın offline kullanılabilir olup olmadığını kontrol et
  bool isBookAvailableOffline(String bookId, String contentType) {
    return _localStorage.hasBookContent(bookId, contentType);
  }

  /// Kitabı offline kullanımdan kaldır
  Future<void> removeBookFromOffline(String bookId) async {
    await _localStorage.deleteBookContent(bookId);
    
    // Satın alınan kitaplardan da kaldır
    final purchasedBooks = _localStorage.getPurchasedBooks();
    purchasedBooks.remove(bookId);
    await _localStorage.savePurchasedBooks(purchasedBooks);
  }

  // ==================== OFFLINE İŞLEMLER ====================

  /// Offline kitap satın alma
  Future<bool> purchaseBookOffline(String bookId, int points) async {
    try {
      final userData = _localStorage.getUserData();
      if (userData == null) {
        throw Exception('Kullanıcı bilgisi bulunamadı');
      }

      final userId = userData['uid'] as String;
      final currentPoints = _localStorage.getUserPoints();

      // Puan kontrolü
      if (currentPoints < points) {
        throw Exception('Yeterli puanınız yok');
      }

      // Kitap kontrolü
      final book = _localStorage.getBook(bookId);
      if (book == null) {
        throw Exception('Kitap bulunamadı');
      }

      // Yerel puanı düş
      await _localStorage.updateUserPoints(currentPoints - points);

      // Satın alınan kitaplara ekle
      final purchasedBooks = _localStorage.getPurchasedBooks();
      if (!purchasedBooks.contains(bookId)) {
        purchasedBooks.add(bookId);
        await _localStorage.savePurchasedBooks(purchasedBooks);
      }

      // Bekleyen işlem olarak ekle
      await _localStorage.addPendingAction({
        'type': 'purchase_book',
        'userId': userId,
        'bookId': bookId,
        'points': points,
        'bookTitle': book['title'],
        'bookAuthor': book['author'],
      });

      return true;
    } catch (e) {
      throw Exception('Offline satın alma hatası: $e');
    }
  }

  /// Offline puan ekleme
  Future<void> addPointsOffline(int points, String reason) async {
    final userData = _localStorage.getUserData();
    if (userData == null) return;

    final userId = userData['uid'] as String;
    final currentPoints = _localStorage.getUserPoints();

    // Yerel puanı artır
    await _localStorage.updateUserPoints(currentPoints + points);

    // Bekleyen işlem olarak ekle
    await _localStorage.addPendingAction({
      'type': 'add_points',
      'userId': userId,
      'points': points,
      'reason': reason,
    });
  }

  /// Offline okuma ilerlemesi kaydetme
  Future<void> saveReadingProgressOffline(String bookId, Map<String, dynamic> progress) async {
    final userData = _localStorage.getUserData();
    if (userData == null) return;

    final userId = userData['uid'] as String;

    // Yerel ilerlemeyi kaydet
    progress['userId'] = userId;
    await _localStorage.saveReadingProgress(bookId, progress);

    // Bekleyen işlem olarak ekle
    await _localStorage.addPendingAction({
      'type': 'reading_progress',
      'userId': userId,
      'bookId': bookId,
      'progress': progress,
    });
  }

  /// Offline kitap beğenisi
  Future<void> toggleBookLikeOffline(String bookId, bool isLiked) async {
    final userData = _localStorage.getUserData();
    if (userData == null) return;

    final userId = userData['uid'] as String;

    // Bekleyen işlem olarak ekle
    await _localStorage.addPendingAction({
      'type': 'book_like',
      'userId': userId,
      'bookId': bookId,
      'isLiked': isLiked,
    });
  }

  /// Offline yorum ekleme
  Future<void> addCommentOffline(String bookId, String comment) async {
    final userData = _localStorage.getUserData();
    if (userData == null) return;

    final userId = userData['uid'] as String;

    // Bekleyen işlem olarak ekle
    await _localStorage.addPendingAction({
      'type': 'add_comment',
      'userId': userId,
      'bookId': bookId,
      'comment': comment,
    });
  }

  // ==================== DURUM KONTROLLERİ ====================

  /// İnternet bağlantısı durumu
  bool get isConnected => _connectivity.isConnected;

  /// Bağlantı durumu stream'i
  Stream<bool> get connectionStatus => _connectivity.connectionStatus;

  /// Senkronizasyon durumu
  bool get isSyncing => _syncManager.isSyncing;

  /// Senkronizasyon durumu stream'i
  Stream<SyncStatus> get syncStatus => _syncManager.syncStatus;

  /// Manuel senkronizasyon
  Future<void> performSync() async {
    await _syncManager.performManualSync();
  }

  // ==================== VERİ YÖNETİMİ ====================

  /// Kullanıcı puanını getir
  int getUserPoints() {
    return _localStorage.getUserPoints();
  }

  /// Satın alınan kitapları getir
  List<String> getPurchasedBooks() {
    return _localStorage.getPurchasedBooks();
  }

  /// Kitap verilerini getir
  Map<String, dynamic>? getBook(String bookId) {
    return _localStorage.getBook(bookId);
  }

  /// Okuma ilerlemesini getir
  Map<String, dynamic>? getReadingProgress(String bookId) {
    return _localStorage.getReadingProgress(bookId);
  }

  /// Bekleyen işlemleri getir
  List<Map<String, dynamic>> getPendingActions() {
    return _localStorage.getPendingActions();
  }

  // ==================== AYARLAR ====================

  /// Offline mod ayarını kaydet
  Future<void> setOfflineMode(bool enabled) async {
    await _localStorage.saveSetting('offline_mode', enabled);
  }

  /// Offline mod ayarını getir
  bool getOfflineMode() {
    return _localStorage.getSetting<bool>('offline_mode', false) ?? false;
  }

  /// Otomatik indirme ayarını kaydet
  Future<void> setAutoDownload(bool enabled) async {
    await _localStorage.saveSetting('auto_download', enabled);
  }

  /// Otomatik indirme ayarını getir
  bool getAutoDownload() {
    return _localStorage.getSetting<bool>('auto_download', true) ?? true;
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

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

  /// Depolama alanını kontrol et
  Future<int> getAvailableStorage() async {
    try {
      final directory = Directory('/');
      final stat = await directory.stat();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }

  /// Kullanılan depolama alanını hesapla
  Future<int> getUsedStorage() async {
    try {
      final directory = await Directory('/').list(recursive: true).toList();
      int totalSize = 0;
      
      for (final entity in directory) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Servisi durdur
  void dispose() {
    _connectivity.dispose();
    _syncManager.dispose();
  }
}
