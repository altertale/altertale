import '../models/book_model.dart';
import '../services/service_locator.dart';
import '../utils/base_provider.dart';

/// Kitap satın alma kontrolcüsü
class PurchaseController extends BaseProvider {
  // Dependency injection kullanarak servisleri al
  late final _pointsService = pointsService;
  late final _notificationService = notificationService;

  String? _successMessage;

  String? get successMessage => _successMessage;

  /// Kitabı puanla satın al
  Future<bool> purchaseBookWithPoints({
    required String userId,
    required BookModel book,
  }) async {
    return await executeAsyncVoid(() async {
      await _pointsService.purchaseBookWithPoints(
        userId: userId,
        points: book.points,
        bookId: book.id,
      );

      // Puan harcamasını geçmişe kaydet
      await _pointsService.recordPointsSpent(
        userId: userId,
        points: book.points,
        reason: 'Kitap satın alma: ${book.title}',
      );

      // Başarı bildirimi gönder
      _notificationService.saveNotification(
        'Kitap Satın Alındı!',
        '${book.title} kitabını ${book.points} puan ile başarıyla satın aldın.',
      );

      // Loyalty puanı kontrolü
      await _pointsService.checkAndAddLoyaltyPoints(userId);

      _setSuccessMessage('Kitap başarıyla satın alındı!');
    }, errorMessage: 'Kitap satın alınırken hata oluştu');
  }

  /// Kullanıcının kitabı satın almaya yetecek puanı var mı kontrol et
  Future<bool> canPurchaseBook({
    required String userId,
    required BookModel book,
  }) async {
    try {
      final userPoints = await _pointsService.getUserPoints(userId);
      return userPoints >= book.points;
    } catch (e) {
      return false;
    }
  }

  /// Kullanıcının puanını getir
  Future<int> getUserPoints(String userId) async {
    try {
      return await _pointsService.getUserPoints(userId);
    } catch (e) {
      return 0;
    }
  }

  /// Puan geçmişini getir
  Future<List<Map<String, dynamic>>> getPointsHistory({
    required String userId,
  }) async {
    try {
      return await _pointsService.getPointsHistory(userId);
    } catch (e) {
      return [];
    }
  }

  /// Loyalty puanı kontrolü
  Future<void> checkLoyaltyPoints(String userId) async {
    try {
      await _pointsService.checkAndAddLoyaltyPoints(userId);
    } catch (e) {
      // Loyalty puanı hatası kritik değil, sessizce geç
    }
  }

  /// Başarı mesajını ayarla
  void _setSuccessMessage(String message) {
    _successMessage = message;
    clearError(); // Hata mesajını temizle
    notifyListeners();
  }

  /// Başarı mesajını temizle
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }
}
