/// Uygulama içindeki tüm route path'lerini içeren sabitler sınıfı
/// Merkezi route yönetimi için kullanılır
class RouteNames {
  // Private constructor - Bu sınıftan instance oluşturulamaz
  RouteNames._();

  // ==================== AUTH ROUTES ====================
  /// Giriş ekranı route'u
  static const String login = '/login';

  /// Kayıt ekranı route'u
  static const String register = '/register';

  /// Şifre sıfırlama ekranı route'u
  static const String forgotPassword = '/forgot-password';

  /// E-posta doğrulama ekranı route'u
  static const String emailVerification = '/email-verification';

  // ==================== MAIN ROUTES ====================
  /// Ana sayfa route'u
  static const String home = '/home';

  /// Splash ekranı route'u (başlangıç)
  static const String splash = '/splash';

  // ==================== USER ROUTES ====================
  /// Profil ekranı route'u
  static const String profile = '/profile';

  /// Profil düzenleme ekranı route'u
  static const String editProfile = '/edit-profile';

  /// Ayarlar ekranı route'u
  static const String settings = '/settings';

  /// Bildirim ayarları ekranı route'u
  static const String notificationSettings = '/notification-settings';

  // ==================== BOOK ROUTES ====================
  /// Kitap arama ekranı route'u
  static const String search = '/search';

  /// Kitap detay ekranı route'u
  static const String bookDetail = '/book-detail';

  /// Kitap okuma ekranı route'u
  static const String reading = '/reading';

  /// Kütüphane ekranı route'u
  static const String library = '/library';

  /// Okuma geçmişi ekranı route'u
  static const String readingHistory = '/reading-history';

  /// Keşfet ekranı route'u
  static const String explore = '/explore';

  // ==================== TRANSACTION ROUTES ====================
  /// Puan geçmişi ekranı route'u
  static const String pointsHistory = '/points-history';

  /// Referans ekranı route'u
  static const String referral = '/referral';

  // ==================== NOTIFICATION ROUTES ====================
  /// Bildirim merkezi ekranı route'u
  static const String notificationCenter = '/notification-center';

  /// Bildirim detay ekranı route'u
  static const String notificationDetail = '/notification-detail';

  // ==================== ADMIN ROUTES ====================
  /// Admin paneli route'u
  static const String adminPanel = '/admin';

  /// Admin kitap yönetimi route'u
  static const String adminBooks = '/admin/books';

  /// Admin kullanıcı yönetimi route'u
  static const String adminUsers = '/admin/users';

  // ==================== OFFLINE ROUTES ====================
  /// Offline okuma ekranı route'u
  static const String offlineReading = '/offline-reading';

  /// Offline ayarları ekranı route'u
  static const String offlineSettings = '/offline-settings';

  // ==================== SECURITY ROUTES ====================
  /// Rapor gönderme ekranı route'u
  static const String reportScreen = '/report';

  // ==================== LEGAL ROUTES ====================
  /// Yasal sayfalar route'u
  static const String legalPages = '/legal';

  // ==================== TEST ROUTES ====================
  /// Test ekranı route'u (development)
  static const String test = '/test';

  // ==================== ERROR ROUTES ====================
  /// 404 - Sayfa bulunamadı route'u
  static const String notFound = '/not-found';

  // ==================== HELPER METHODS ====================

  /// Verilen route name'in geçerli olup olmadığını kontrol eder
  static bool isValidRoute(String? routeName) {
    if (routeName == null) return false;

    return _getAllRoutes().contains(routeName);
  }

  /// Tüm route'ları liste halinde döndürür
  static List<String> _getAllRoutes() {
    return [
      // Auth routes
      login,
      register,
      forgotPassword,
      emailVerification,

      // Main routes
      home,
      splash,

      // User routes
      profile,
      editProfile,
      settings,
      notificationSettings,

      // Book routes
      search,
      bookDetail,
      reading,
      library,
      readingHistory,
      explore,

      // Transaction routes
      pointsHistory,
      referral,

      // Notification routes
      notificationCenter,
      notificationDetail,

      // Admin routes
      adminPanel,
      adminBooks,
      adminUsers,

      // Offline routes
      offlineReading,
      offlineSettings,

      // Security routes
      reportScreen,

      // Legal routes
      legalPages,

      // Test routes
      test,

      // Error routes
      notFound,
    ];
  }

  /// Route name'den human-readable title üretir
  static String getRouteTitle(String routeName) {
    switch (routeName) {
      case login:
        return 'Giriş Yap';
      case register:
        return 'Kayıt Ol';
      case forgotPassword:
        return 'Şifremi Unuttum';
      case emailVerification:
        return 'E-posta Doğrulama';
      case home:
        return 'Ana Sayfa';
      case profile:
        return 'Profil';
      case editProfile:
        return 'Profili Düzenle';
      case settings:
        return 'Ayarlar';
      case search:
        return 'Arama';
      case library:
        return 'Kütüphanem';
      case explore:
        return 'Keşfet';
      case notFound:
        return 'Sayfa Bulunamadı';
      default:
        return 'Altertale';
    }
  }
}
