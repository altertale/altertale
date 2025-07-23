/// Uygulama genelinde kullanılan sabitler
class AppConstants {
  // Uygulama Bilgileri
  static const String appName = 'Altertale';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Alternatif Evren Fan Fiction Okuma Uygulaması';
  
  // Firebase Koleksiyonları
  static const String usersCollection = 'users';
  static const String booksCollection = 'books';
  static const String commentsCollection = 'comments';
  static const String referralsCollection = 'referrals';
  static const String transactionsCollection = 'transactions';
  static const String notificationsCollection = 'notifications';
  
  // Puan Sistemi
  static const int newUserPoints = 100;
  static const int referralPoints = 50;
  static const int dailyLoginPoints = 10;
  static const int bookPurchasePoints = 5;
  static const int commentPoints = 2;
  
  // Kitap Ayarları
  static const int maxPreviewLength = 1000; // karakter
  static const int minBookPrice = 0;
  static const int maxBookPrice = 1000;
  
  // Güvenlik
  static const int maxLoginAttempts = 5;
  static const int lockoutDuration = 15; // dakika
  static const int sessionTimeout = 30; // gün
  
  // Dosya Boyutları
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxBookFileSize = 50 * 1024 * 1024; // 50MB
  
  // Sayfalama
  static const int booksPerPage = 20;
  static const int commentsPerPage = 10;
  
  // Zaman Formatları
  static const String dateFormat = 'dd.MM.yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';
  
  // Dil Kodları
  static const String defaultLanguage = 'tr';
  static const List<String> supportedLanguages = ['tr', 'en'];
  
  // Tema
  static const String lightTheme = 'light';
  static const String darkTheme = 'dark';
  static const String systemTheme = 'system';
  
  // Bildirim Türleri
  static const String newBookNotification = 'new_book';
  static const String commentNotification = 'comment';
  static const String referralNotification = 'referral';
  static const String systemNotification = 'system';
  
  // Hata Mesajları
  static const String networkError = 'İnternet bağlantısı hatası';
  static const String serverError = 'Sunucu hatası';
  static const String unknownError = 'Bilinmeyen hata';
  static const String permissionDenied = 'İzin reddedildi';
  static const String fileNotFound = 'Dosya bulunamadı';
  
  // Başarı Mesajları
  static const String loginSuccess = 'Giriş başarılı';
  static const String registerSuccess = 'Kayıt başarılı';
  static const String bookPurchaseSuccess = 'Kitap satın alma başarılı';
  static const String commentSuccess = 'Yorum gönderildi';
  static const String profileUpdateSuccess = 'Profil güncellendi';
  
  // Uyarı Mesajları
  static const String insufficientPoints = 'Yetersiz puan';
  static const String bookAlreadyPurchased = 'Bu kitap zaten satın alınmış';
  static const String commentAlreadyExists = 'Bu kitap için zaten yorum yapmışsınız';
  
  // Regex Patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  
  // Cache Keys
  static const String userCacheKey = 'user_data';
  static const String booksCacheKey = 'books_data';
  static const String settingsCacheKey = 'app_settings';
  static const String themeCacheKey = 'app_theme';
  static const String languageCacheKey = 'app_language';
  
  // API Endpoints (Firebase Functions için)
  static const String baseUrl = 'https://us-central1-altertale-app.cloudfunctions.net';
  static const String apiVersion = '/api/v1';
  
  // Animasyon Süreleri
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Debounce Süreleri
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration scrollDebounce = Duration(milliseconds: 100);
  
  // Retry Ayarları
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Offline Ayarları
  static const int maxOfflineBooks = 50;
  static const Duration offlineSyncInterval = Duration(hours: 1);
  
  // Test Ayarları
  static const bool enableCrashlytics = true;
  static const bool enableAnalytics = true;
  static const bool enableDebugLogs = true;
} 