import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Yerel depolama servisi (Hive + SharedPreferences)
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  late Box _userDataBox;
  late Box _booksBox;
  late Box _pendingActionsBox;
  late Box _readingProgressBox;
  late SharedPreferences _prefs;

  /// Servisi başlat
  Future<void> initialize() async {
    // Hive'ı başlat
    await Hive.initFlutter();
    
    // SharedPreferences'ı başlat
    _prefs = await SharedPreferences.getInstance();

    // Hive box'larını aç
    _userDataBox = await Hive.openBox('user_data');
    _booksBox = await Hive.openBox('books');
    _pendingActionsBox = await Hive.openBox('pending_actions');
    _readingProgressBox = await Hive.openBox('reading_progress');
  }

  // ==================== KULLANICI VERİLERİ ====================

  /// Kullanıcı verilerini kaydet
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _userDataBox.put('current_user', userData);
  }

  /// Kullanıcı verilerini getir
  Map<String, dynamic>? getUserData() {
    return _userDataBox.get('current_user') as Map<String, dynamic>?;
  }

  /// Kullanıcı puanını güncelle
  Future<void> updateUserPoints(int points) async {
    final userData = getUserData();
    if (userData != null) {
      userData['totalPoints'] = points;
      await saveUserData(userData);
    }
  }

  /// Kullanıcı puanını getir
  int getUserPoints() {
    final userData = getUserData();
    return userData?['totalPoints'] ?? 0;
  }

  /// Satın alınan kitapları kaydet
  Future<void> savePurchasedBooks(List<String> bookIds) async {
    await _userDataBox.put('purchased_books', bookIds);
  }

  /// Satın alınan kitapları getir
  List<String> getPurchasedBooks() {
    final books = _userDataBox.get('purchased_books') as List<dynamic>?;
    return books?.cast<String>() ?? [];
  }

  // ==================== KİTAP VERİLERİ ====================

  /// Kitap verilerini kaydet
  Future<void> saveBook(Map<String, dynamic> bookData) async {
    final bookId = bookData['id'] as String;
    await _booksBox.put(bookId, bookData);
  }

  /// Kitap verilerini getir
  Map<String, dynamic>? getBook(String bookId) {
    return _booksBox.get(bookId) as Map<String, dynamic>?;
  }

  /// Tüm kitapları getir
  List<Map<String, dynamic>> getAllBooks() {
    final books = <Map<String, dynamic>>[];
    for (final key in _booksBox.keys) {
      final book = _booksBox.get(key) as Map<String, dynamic>?;
      if (book != null) {
        books.add(book);
      }
    }
    return books;
  }

  /// Kitabı sil
  Future<void> deleteBook(String bookId) async {
    await _booksBox.delete(bookId);
  }

  // ==================== KİTAP İÇERİĞİ (ŞİFRELİ) ====================

  /// Kitap içeriğini şifreli olarak kaydet
  Future<void> saveBookContent(String bookId, String content, String contentType) async {
    try {
      // İçeriği şifrele
      final encryptedContent = _encryptContent(content);
      
      // Dosya yolunu al
      final directory = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${directory.path}/books');
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }

      // Şifreli içeriği kaydet
      final file = File('${booksDir.path}/${bookId}_$contentType.enc');
      await file.writeAsBytes(encryptedContent);

      // Metadata'yı kaydet
      await _booksBox.put('${bookId}_content_meta', {
        'contentType': contentType,
        'filePath': file.path,
        'size': content.length,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Kitap içeriği kaydedilemedi: $e');
    }
  }

  /// Kitap içeriğini şifreli olarak getir
  Future<String?> getBookContent(String bookId, String contentType) async {
    try {
      // Metadata'yı kontrol et
      final meta = _booksBox.get('${bookId}_content_meta') as Map<String, dynamic>?;
      if (meta == null || meta['contentType'] != contentType) {
        return null;
      }

      // Şifreli dosyayı oku
      final file = File(meta['filePath'] as String);
      if (!await file.exists()) {
        return null;
      }

      final encryptedBytes = await file.readAsBytes();
      final decryptedContent = _decryptContent(encryptedBytes);
      
      return decryptedContent;
    } catch (e) {
      return null;
    }
  }

  /// Kitap içeriğinin varlığını kontrol et
  bool hasBookContent(String bookId, String contentType) {
    final meta = _booksBox.get('${bookId}_content_meta') as Map<String, dynamic>?;
    return meta != null && meta['contentType'] == contentType;
  }

  /// Kitap içeriğini sil
  Future<void> deleteBookContent(String bookId) async {
    try {
      final meta = _booksBox.get('${bookId}_content_meta') as Map<String, dynamic>?;
      if (meta != null) {
        final file = File(meta['filePath'] as String);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await _booksBox.delete('${bookId}_content_meta');
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  // ==================== BEKLEYEN İŞLEMLER ====================

  /// Bekleyen işlem ekle
  Future<void> addPendingAction(Map<String, dynamic> action) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    action['id'] = id;
    action['createdAt'] = DateTime.now().millisecondsSinceEpoch;
    action['retryCount'] = 0;
    action['status'] = 'pending';
    
    await _pendingActionsBox.put(id, action);
  }

  /// Bekleyen işlemleri getir
  List<Map<String, dynamic>> getPendingActions() {
    final actions = <Map<String, dynamic>>[];
    for (final key in _pendingActionsBox.keys) {
      final action = _pendingActionsBox.get(key) as Map<String, dynamic>?;
      if (action != null) {
        actions.add(action);
      }
    }
    return actions;
  }

  /// Bekleyen işlemi sil
  Future<void> removePendingAction(String actionId) async {
    await _pendingActionsBox.delete(actionId);
  }

  /// Bekleyen işlemi güncelle
  Future<void> updatePendingAction(String actionId, Map<String, dynamic> updates) async {
    final action = _pendingActionsBox.get(actionId) as Map<String, dynamic>?;
    if (action != null) {
      action.addAll(updates);
      await _pendingActionsBox.put(actionId, action);
    }
  }

  // ==================== OKUMA İLERLEMESİ ====================

  /// Okuma ilerlemesini kaydet
  Future<void> saveReadingProgress(String bookId, Map<String, dynamic> progress) async {
    progress['lastUpdated'] = DateTime.now().millisecondsSinceEpoch;
    await _readingProgressBox.put(bookId, progress);
  }

  /// Okuma ilerlemesini getir
  Map<String, dynamic>? getReadingProgress(String bookId) {
    return _readingProgressBox.get(bookId) as Map<String, dynamic>?;
  }

  /// Tüm okuma ilerlemelerini getir
  List<Map<String, dynamic>> getAllReadingProgress() {
    final progress = <Map<String, dynamic>>[];
    for (final key in _readingProgressBox.keys) {
      final data = _readingProgressBox.get(key) as Map<String, dynamic>?;
      if (data != null) {
        data['bookId'] = key;
        progress.add(data);
      }
    }
    return progress;
  }

  // ==================== AYARLAR ====================

  /// Ayar kaydet
  Future<void> saveSetting(String key, dynamic value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  /// Ayar getir
  T? getSetting<T>(String key, T defaultValue) {
    final value = _prefs.getString(key);
    if (value == null) return defaultValue;
    
    try {
      final decoded = jsonDecode(value);
      return decoded as T;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Ayar sil
  Future<void> removeSetting(String key) async {
    await _prefs.remove(key);
  }

  // ==================== ŞİFRELEME ====================

  /// İçeriği şifrele
  Uint8List _encryptContent(String content) {
    // Basit şifreleme (production'da daha güçlü şifreleme kullanın)
    final salt = 'Altertale_Offline_2024';
    final key = utf8.encode(salt);
    final contentBytes = utf8.encode(content);
    
    // XOR şifreleme
    final encrypted = Uint8List(contentBytes.length);
    for (int i = 0; i < contentBytes.length; i++) {
      encrypted[i] = contentBytes[i] ^ key[i % key.length];
    }
    
    return encrypted;
  }

  /// İçeriği şifre çöz
  String _decryptContent(Uint8List encryptedBytes) {
    // Basit şifre çözme
    final salt = 'Altertale_Offline_2024';
    final key = utf8.encode(salt);
    
    // XOR şifre çözme
    final decrypted = Uint8List(encryptedBytes.length);
    for (int i = 0; i < encryptedBytes.length; i++) {
      decrypted[i] = encryptedBytes[i] ^ key[i % key.length];
    }
    
    return utf8.decode(decrypted);
  }

  // ==================== TEMİZLİK ====================

  /// Eski verileri temizle
  Future<void> cleanup() async {
    try {
      // 30 günden eski bekleyen işlemleri sil
      final cutoff = DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
      final actions = getPendingActions();
      
      for (final action in actions) {
        final createdAt = action['createdAt'] as int?;
        if (createdAt != null && createdAt < cutoff) {
          await removePendingAction(action['id'] as String);
        }
      }

      // Kullanılmayan kitap içeriklerini sil
      final purchasedBooks = getPurchasedBooks();
      final allBooks = getAllBooks();
      
      for (final book in allBooks) {
        final bookId = book['id'] as String;
        if (!purchasedBooks.contains(bookId)) {
          await deleteBookContent(bookId);
        }
      }
    } catch (e) {
      // Temizlik hatası kritik değil
    }
  }

  /// Tüm verileri temizle
  Future<void> clearAll() async {
    await _userDataBox.clear();
    await _booksBox.clear();
    await _pendingActionsBox.clear();
    await _readingProgressBox.clear();
    await _prefs.clear();
  }
}
