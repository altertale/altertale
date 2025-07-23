import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/points_service.dart';

/// Puan işlemleri için provider
/// Kullanıcı puanlarını yönetir ve günceller
class PointsProvider extends ChangeNotifier {
  final PointsService _pointsService = PointsService();

  // Durum değişkenleri
  int _userPoints = 0;
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _pointsHistory = [];

  // Getters
  int get userPoints => _userPoints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get pointsHistory => _pointsHistory;

  /// Provider'a erişim için static metod
  static PointsProvider of(BuildContext context) {
    return Provider.of<PointsProvider>(context, listen: false);
  }

  /// Kullanıcı puanlarını yükle
  Future<void> loadUserPoints(String userId) async {
    _setLoading(true);
    try {
      // TODO: PointsService'e getUserPoints metodu eklenmeli
      _userPoints = 0; // Geçici değer
      _clearError();
    } catch (e) {
      _setError('Puanlar yüklenirken hata: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Puan ekle
  Future<void> addPoints({
    required String userId,
    required int points,
    String reason = '',
  }) async {
    try {
      _pointsService.addPoints(userId: userId, points: points, reason: reason);
      _userPoints += points;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Puan eklenirken hata: $e');
    }
  }

  /// Puan düş
  Future<void> deductPoints({
    required String userId,
    required int points,
    String reason = '',
  }) async {
    try {
      await _pointsService.deductPoints(
        userId: userId,
        points: points,
        reason: reason,
      );
      _userPoints -= points;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Puan düşülürken hata: $e');
    }
  }

  /// Kitap satın alma ile puan düş
  Future<void> purchaseBookWithPoints({
    required String userId,
    required int points,
    required String bookId,
  }) async {
    try {
      // TODO: PointsService'e purchaseBookWithPoints metodu eklenmeli
      await deductPoints(
        userId: userId,
        points: points,
        reason: 'Kitap satın alma: $bookId',
      );
      _clearError();
    } catch (e) {
      _setError('Kitap satın alınırken hata: $e');
    }
  }

  /// Puan geçmişini yükle
  Future<void> loadPointsHistory(String userId) async {
    _setLoading(true);
    try {
      // TODO: PointsService'e getPointsHistory metodu eklenmeli
      _pointsHistory = []; // Geçici boş liste
      _clearError();
    } catch (e) {
      _setError('Puan geçmişi yüklenirken hata: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sadakat puanları kontrol et ve ekle
  Future<void> checkAndAddLoyaltyPoints(String userId) async {
    try {
      // TODO: PointsService'e checkAndAddLoyaltyPoints metodu eklenmeli
      _clearError();
    } catch (e) {
      _setError('Sadakat puanları kontrol edilirken hata: $e');
    }
  }

  /// Harcanan puanları kaydet
  Future<void> recordPointsSpent({
    required String userId,
    required int points,
    required String reason,
  }) async {
    try {
      // TODO: PointsService'e recordPointsSpent metodu eklenmeli
      _clearError();
    } catch (e) {
      _setError('Puan harcama kaydedilirken hata: $e');
    }
  }

  // Private metodlar
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
