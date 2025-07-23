import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../utils/base_provider.dart';

/// Profil durumu yönetimi için provider
/// Profil bilgileri, ayarlar ve tercihleri yönetir
class ProfileProvider extends BaseProvider {
  final ProfileService _profileService = ProfileService();

  // Durum değişkenleri
  ProfileModel? _profile;
  Map<String, dynamic>? _stats;
  bool _isUpdating = false;

  // Getters
  ProfileModel? get profile => _profile;
  Map<String, dynamic>? get stats => _stats;
  bool get isUpdating => _isUpdating;
  bool get hasProfile => _profile != null;

  /// Profil bilgilerini yükler
  Future<void> loadProfile(String uid) async {
    await executeAsync<void>(() async {
      final profile = await _profileService.getProfile(uid);
      if (profile != null) {
        _profile = profile;
        await _loadProfileStats(uid);
        notifyListeners();
      }
    }, errorMessage: 'Profil yüklenemedi');
  }

  /// Profil istatistiklerini yükler
  Future<void> _loadProfileStats(String uid) async {
    try {
      final stats = await _profileService.getProfileStats(uid);
      _stats = stats;
      notifyListeners();
    } catch (e) {
      // İstatistik yükleme hatası kritik değil
      _stats = <String, dynamic>{};
    }
  }

  /// Profil bilgilerini günceller
  Future<bool> updateProfileInfo({
    String? name,
    String? username,
    String? bio,
    String? displayName,
    XFile? profileImage,
  }) async {
    if (_profile == null) return false;

    _setUpdating(true);

    final success = await executeAsyncVoid(
      () async {
        // Profil fotoğrafı varsa önce yükle
        String? newProfileImageUrl;
        if (profileImage != null) {
          newProfileImageUrl = await _profileService.uploadProfileImage(
            _profile!.uid,
            profileImage,
          );
        }

        // Profil bilgilerini güncelle
        _profile = _profile!.updateProfileInfo(
          name: name,
          username: username,
          bio: bio,
          displayName: displayName,
          profileImageUrl: newProfileImageUrl,
        );

        // ProfileModel'i service'e kaydet
        await _profileService.saveProfile(_profile!);
        notifyListeners();
      },
      errorMessage: 'Profil güncellenemedi',
      showLoading: false,
    );

    _setUpdating(false);
    return success;
  }

  /// Profil fotoğrafını günceller
  Future<bool> updateProfilePhoto(XFile imageFile) async {
    if (_profile == null) return false;

    _setUpdating(true);

    final success = await executeAsyncVoid(
      () async {
        final imageUrl = await _profileService.uploadProfileImage(
          _profile!.uid,
          imageFile,
        );

        if (imageUrl != null) {
          _profile = _profile!.copyWith(
            profileImageUrl: imageUrl,
            lastUpdated: DateTime.now(),
            lastActiveDate: DateTime.now(),
          );

          await _profileService.saveProfile(_profile!);
          notifyListeners();
        }
      },
      errorMessage: 'Profil fotoğrafı güncellenemedi',
      showLoading: false,
    );

    _setUpdating(false);
    return success;
  }

  /// Tema ayarını günceller
  Future<bool> updateTheme(String theme) async {
    if (_profile == null) return false;

    _setUpdating(true);

    final success = await executeAsyncVoid(
      () async {
        _profile = _profile!.updateTheme(theme);
        await _profileService.saveProfile(_profile!);
        notifyListeners();
      },
      errorMessage: 'Tema güncellenemedi',
      showLoading: false,
    );

    _setUpdating(false);
    return success;
  }

  /// Bildirim ayarını günceller
  Future<bool> updateNotificationSetting(String key, bool value) async {
    if (_profile == null) return false;

    _setUpdating(true);

    final success = await executeAsyncVoid(
      () async {
        _profile = _profile!.updateNotificationSetting(key, value);
        await _profileService.saveProfile(_profile!);
        notifyListeners();
      },
      errorMessage: 'Bildirim ayarı güncellenemedi',
      showLoading: false,
    );

    _setUpdating(false);
    return success;
  }

  /// Tercih ayarını günceller
  Future<bool> updatePreference(String key, dynamic value) async {
    if (_profile == null) return false;

    _setUpdating(true);

    final success = await executeAsyncVoid(
      () async {
        _profile = _profile!.updatePreference(key, value);
        await _profileService.saveProfile(_profile!);
        notifyListeners();
      },
      errorMessage: 'Tercih güncellenemedi',
      showLoading: false,
    );

    _setUpdating(false);
    return success;
  }

  /// Güncelleme durumunu ayarlar
  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  /// Hata mesajını temizler (public)
  @override
  void clearError() {
    super.clearError();
  }

  // MARK: - Convenience Getters

  /// Mevcut tema ayarını döndürür
  String get currentTheme => _profile?.theme ?? 'system';

  /// Mevcut dil ayarını döndürür
  String get currentLanguage => _profile?.language ?? 'tr';

  /// Profil tamamlanma yüzdesi
  double get profileCompletionPercentage =>
      _profile?.profileCompletionPercentage ?? 0.0;

  /// Üyelik süresi
  int get membershipDays => _profile?.membershipDays ?? 0;

  /// Mock data set etmek için (demo amaçlı)
  void setMockData(ProfileModel profile, Map<String, dynamic> stats) {
    _profile = profile;
    _stats = stats;
    notifyListeners();
  }
}
