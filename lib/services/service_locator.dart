import 'package:get_it/get_it.dart';
import 'auth_service.dart';
import 'book_service.dart';
import 'notification_service.dart';
import 'points_service.dart';
import 'profile/profile_service.dart';
import 'preferences/preferences_service.dart';
import 'search/search_service.dart';
import 'security/security_service.dart';
import 'security/moderation_service.dart';
import 'security/device_check_service.dart';
import 'referral/referral_service.dart';
import 'admin/admin_service.dart';
import 'offline/local_storage_service.dart';
import 'offline/connectivity_service.dart';

/// Service Locator - Dependency Injection sistemi
/// get_it paketi kullanarak tüm servisleri yönetir
final GetIt serviceLocator = GetIt.instance;

/// Tüm servisleri kayıt eder
Future<void> setupServiceLocator() async {
  // Core Services
  serviceLocator.registerLazySingleton<AuthService>(() => AuthService());
  serviceLocator.registerLazySingleton<BookService>(() => BookService());
  serviceLocator.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );
  serviceLocator.registerLazySingleton<PointsService>(() => PointsService());

  // Profile & Preferences
  serviceLocator.registerLazySingleton<ProfileService>(() => ProfileService());
  serviceLocator.registerLazySingleton<PreferencesService>(
    () => PreferencesService(),
  );

  // Search
  serviceLocator.registerLazySingleton<SearchService>(() => SearchService());

  // Security Services
  serviceLocator.registerLazySingleton<SecurityService>(
    () => SecurityService(),
  );
  serviceLocator.registerLazySingleton<ModerationService>(
    () => ModerationService(),
  );
  serviceLocator.registerLazySingleton<DeviceCheckService>(
    () => DeviceCheckService(),
  );

  // Referral Service
  serviceLocator.registerLazySingleton<ReferralService>(
    () => ReferralService(),
  );

  // Admin Service
  serviceLocator.registerLazySingleton<AdminService>(() => AdminService());

  // Offline Services
  serviceLocator.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(),
  );
  serviceLocator.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(),
  );
}

/// Service Locator'ı temizler
Future<void> resetServiceLocator() async {
  await serviceLocator.reset();
}

// Convenience getters
AuthService get authService => serviceLocator<AuthService>();
BookService get bookService => serviceLocator<BookService>();
NotificationService get notificationService =>
    serviceLocator<NotificationService>();
PointsService get pointsService => serviceLocator<PointsService>();
ProfileService get profileService => serviceLocator<ProfileService>();
PreferencesService get preferencesService =>
    serviceLocator<PreferencesService>();
SearchService get searchService => serviceLocator<SearchService>();
SecurityService get securityService => serviceLocator<SecurityService>();
ModerationService get moderationService => serviceLocator<ModerationService>();
DeviceCheckService get deviceCheckService =>
    serviceLocator<DeviceCheckService>();
ReferralService get referralService => serviceLocator<ReferralService>();
AdminService get adminService => serviceLocator<AdminService>();
LocalStorageService get localStorageService =>
    serviceLocator<LocalStorageService>();
ConnectivityService get connectivityService =>
    serviceLocator<ConnectivityService>();
