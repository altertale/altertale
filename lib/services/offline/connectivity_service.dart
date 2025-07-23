import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// İnternet bağlantısı durumu servisi
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();

  bool _isConnected = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Bağlantı durumu stream'i
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  /// Mevcut bağlantı durumu
  bool get isConnected => _isConnected;

  /// Servisi başlat
  Future<void> initialize() async {
    try {
      // İlk bağlantı durumunu kontrol et
      final results = await _connectivity.checkConnectivity();
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      _updateConnectionStatus(result);

      // Bağlantı değişikliklerini dinle
      _subscription = _connectivity.onConnectivityChanged.listen((results) {
        final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
        _updateConnectionStatus(result);
      });
    } catch (e) {
      // Hata durumunda varsayılan olarak bağlı kabul et
      _isConnected = true;
      _connectionStatusController.add(true);
    }
  }

  /// Bağlantı durumunu güncelle
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;

    // Durum değiştiyse stream'e gönder
    if (wasConnected != _isConnected) {
      _connectionStatusController.add(_isConnected);
    }
  }

  /// Manuel bağlantı kontrolü
  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      _updateConnectionStatus(result);
      return _isConnected;
    } catch (e) {
      return false;
    }
  }

  /// Servisi durdur
  void dispose() {
    _subscription?.cancel();
    _connectionStatusController.close();
  }
}
