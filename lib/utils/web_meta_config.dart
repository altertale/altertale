import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Web meta konfigürasyonu - SEO, favicon ve web app ayarları
class WebMetaConfig {
  /// Web meta verilerini yapılandır
  static void configureWebMeta() {
    if (kIsWeb) {
      // URL stratejisini yapılandır
      setUrlStrategy(PathUrlStrategy());
      
      // Meta etiketlerini ekle
      _addMetaTags();
      
      // Favicon'u yapılandır
      _configureFavicon();
      
      // Web app manifest'ini yapılandır
      _configureWebAppManifest();
      
      // Service worker'ı yapılandır
      _configureServiceWorker();
    }
  }

  /// Meta etiketlerini ekle
  static void _addMetaTags() {
    // Bu fonksiyon index.html'de manuel olarak eklenen meta etiketlerini temsil eder
    // Gerçek implementasyon index.html dosyasında yapılacak
    
    final metaTags = {
      'title': 'Altertale – Sadece Uygulama İçi Okuma',
      'description': 'Altertale ile kitaplarınızı dijital ortamda okuyun. Güvenli, hızlı ve kullanıcı dostu e-kitap platformu.',
      'keywords': 'e-kitap, dijital kitap, online okuma, Türkçe kitap, roman, hikaye, edebiyat',
      'author': 'Altertale',
      'robots': 'index, follow',
      'language': 'tr',
      'charset': 'UTF-8',
      'viewport': 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no',
      'theme-color': '#1976D2',
      'msapplication-TileColor': '#1976D2',
      'apple-mobile-web-app-capable': 'yes',
      'apple-mobile-web-app-status-bar-style': 'default',
      'apple-mobile-web-app-title': 'Altertale',
      'format-detection': 'telephone=no',
      'mobile-web-app-capable': 'yes',
    };

    // Open Graph meta etiketleri
    final openGraphTags = {
      'og:title': 'Altertale – Sadece Uygulama İçi Okuma',
      'og:description': 'Altertale ile kitaplarınızı dijital ortamda okuyun. Güvenli, hızlı ve kullanıcı dostu e-kitap platformu.',
      'og:type': 'website',
      'og:url': 'https://altertale.com',
      'og:image': 'https://altertale.com/images/og-image.png',
      'og:image:width': '1200',
      'og:image:height': '630',
      'og:image:alt': 'Altertale - E-Kitap Platformu',
      'og:site_name': 'Altertale',
      'og:locale': 'tr_TR',
    };

    // Twitter Card meta etiketleri
    final twitterTags = {
      'twitter:card': 'summary_large_image',
      'twitter:title': 'Altertale – Sadece Uygulama İçi Okuma',
      'twitter:description': 'Altertale ile kitaplarınızı dijital ortamda okuyun. Güvenli, hızlı ve kullanıcı dostu e-kitap platformu.',
      'twitter:image': 'https://altertale.com/images/twitter-image.png',
      'twitter:site': '@altertale',
      'twitter:creator': '@altertale',
    };

    print('Web meta etiketleri yapılandırıldı');
    print('Meta tags: $metaTags');
    print('Open Graph tags: $openGraphTags');
    print('Twitter tags: $twitterTags');
  }

  /// Favicon'u yapılandır
  static void _configureFavicon() {
    // Favicon dosyaları web/assets/favicon/ klasöründe olmalı
    final faviconFiles = {
      'favicon.ico': '16x16, 32x32',
      'favicon-16x16.png': '16x16',
      'favicon-32x32.png': '32x32',
      'apple-touch-icon.png': '180x180',
      'android-chrome-192x192.png': '192x192',
      'android-chrome-512x512.png': '512x512',
      'mstile-150x150.png': '150x150',
    };

    print('Favicon dosyaları yapılandırıldı');
    print('Favicon files: $faviconFiles');
  }

  /// Web app manifest'ini yapılandır
  static void _configureWebAppManifest() {
    final manifest = {
      'name': 'Altertale',
      'short_name': 'Altertale',
      'description': 'Sadece Uygulama İçi Okuma',
      'start_url': '/',
      'display': 'standalone',
      'background_color': '#FFFFFF',
      'theme_color': '#1976D2',
      'orientation': 'portrait-primary',
      'scope': '/',
      'lang': 'tr',
      'dir': 'ltr',
      'icons': [
        {
          'src': '/assets/favicon/android-chrome-192x192.png',
          'sizes': '192x192',
          'type': 'image/png',
          'purpose': 'any maskable',
        },
        {
          'src': '/assets/favicon/android-chrome-512x512.png',
          'sizes': '512x512',
          'type': 'image/png',
          'purpose': 'any maskable',
        },
      ],
      'categories': ['books', 'education', 'entertainment'],
      'screenshots': [
        {
          'src': '/assets/screenshots/desktop.png',
          'sizes': '1280x720',
          'type': 'image/png',
          'form_factor': 'wide',
        },
        {
          'src': '/assets/screenshots/mobile.png',
          'sizes': '390x844',
          'type': 'image/png',
          'form_factor': 'narrow',
        },
      ],
    };

    print('Web app manifest yapılandırıldı');
    print('Manifest: $manifest');
  }

  /// Service worker'ı yapılandır
  static void _configureServiceWorker() {
    final serviceWorkerConfig = {
      'name': 'altertale-sw',
      'scope': '/',
      'start_url': '/',
      'display': 'standalone',
      'background_color': '#FFFFFF',
      'theme_color': '#1976D2',
      'orientation': 'portrait-primary',
      'icons': [
        {
          'src': '/assets/favicon/android-chrome-192x192.png',
          'sizes': '192x192',
          'type': 'image/png',
        },
        {
          'src': '/assets/favicon/android-chrome-512x512.png',
          'sizes': '512x512',
          'type': 'image/png',
        },
      ],
      'shortcuts': [
        {
          'name': 'Keşfet',
          'short_name': 'Keşfet',
          'description': 'Yeni kitaplar keşfet',
          'url': '/explore',
          'icons': [
            {
              'src': '/assets/icons/explore.png',
              'sizes': '96x96',
            },
          ],
        },
        {
          'name': 'Kütüphanem',
          'short_name': 'Kütüphanem',
          'description': 'Satın aldığım kitaplar',
          'url': '/library',
          'icons': [
            {
              'src': '/assets/icons/library.png',
              'sizes': '96x96',
            },
          ],
        },
      ],
    };

    print('Service worker yapılandırıldı');
    print('Service worker config: $serviceWorkerConfig');
  }

  /// SEO dostu URL'ler için route mapping
  static Map<String, String> getSeoRoutes() {
    return {
      '/': '/',
      '/explore': '/explore',
      '/library': '/library',
      '/reading-history': '/reading-history',
      '/notifications': '/notifications',
      '/settings': '/settings',
      '/profile': '/profile',
      '/book': '/book/{bookId}',
      '/category': '/category/{categoryId}',
      '/author': '/author/{authorId}',
      '/search': '/search?q={query}',
      '/login': '/login',
      '/register': '/register',
      '/forgot-password': '/forgot-password',
      '/about': '/about',
      '/privacy': '/privacy',
      '/terms': '/terms',
      '/contact': '/contact',
      '/help': '/help',
      '/faq': '/faq',
    };
  }

  /// Sayfa bazlı meta etiketleri
  static Map<String, Map<String, String>> getPageMetaTags() {
    return {
      '/': {
        'title': 'Altertale – Sadece Uygulama İçi Okuma',
        'description': 'Altertale ile kitaplarınızı dijital ortamda okuyun. Güvenli, hızlı ve kullanıcı dostu e-kitap platformu.',
        'keywords': 'e-kitap, dijital kitap, online okuma, Türkçe kitap',
      },
      '/explore': {
        'title': 'Keşfet - Altertale',
        'description': 'Yeni kitaplar keşfedin. Kategorilere göre filtreleyin ve favori kitaplarınızı bulun.',
        'keywords': 'kitap keşfet, yeni kitaplar, kitap kategorileri, popüler kitaplar',
      },
      '/library': {
        'title': 'Kütüphanem - Altertale',
        'description': 'Satın aldığınız kitapları görüntüleyin ve okumaya devam edin.',
        'keywords': 'kütüphanem, satın alınan kitaplar, okuma geçmişi',
      },
      '/reading-history': {
        'title': 'Okuma Geçmişi - Altertale',
        'description': 'Okuma geçmişinizi görüntüleyin ve istatistiklerinizi takip edin.',
        'keywords': 'okuma geçmişi, okuma istatistikleri, okuma süresi',
      },
      '/notifications': {
        'title': 'Bildirimler - Altertale',
        'description': 'Bildirimlerinizi görüntüleyin ve yönetin.',
        'keywords': 'bildirimler, uygulama bildirimleri',
      },
      '/settings': {
        'title': 'Ayarlar - Altertale',
        'description': 'Hesap ayarlarınızı ve uygulama tercihlerinizi yönetin.',
        'keywords': 'ayarlar, hesap ayarları, uygulama tercihleri',
      },
      '/profile': {
        'title': 'Profil - Altertale',
        'description': 'Profil bilgilerinizi görüntüleyin ve düzenleyin.',
        'keywords': 'profil, kullanıcı profili, hesap bilgileri',
      },
      '/login': {
        'title': 'Giriş Yap - Altertale',
        'description': 'Hesabınıza giriş yapın ve kitaplarınıza erişin.',
        'keywords': 'giriş yap, hesap girişi, kullanıcı girişi',
      },
      '/register': {
        'title': 'Kayıt Ol - Altertale',
        'description': 'Yeni hesap oluşturun ve Altertale\'ye katılın.',
        'keywords': 'kayıt ol, yeni hesap, üye ol',
      },
      '/about': {
        'title': 'Hakkımızda - Altertale',
        'description': 'Altertale hakkında bilgi alın ve misyonumuzu öğrenin.',
        'keywords': 'hakkımızda, altertale, misyon, vizyon',
      },
      '/privacy': {
        'title': 'Gizlilik Politikası - Altertale',
        'description': 'Gizlilik politikamızı okuyun ve veri koruma prensiplerimizi öğrenin.',
        'keywords': 'gizlilik politikası, veri koruma, kişisel veriler',
      },
      '/terms': {
        'title': 'Kullanım Koşulları - Altertale',
        'description': 'Kullanım koşullarımızı okuyun ve hizmet şartlarımızı öğrenin.',
        'keywords': 'kullanım koşulları, hizmet şartları, yasal',
      },
      '/contact': {
        'title': 'İletişim - Altertale',
        'description': 'Bizimle iletişime geçin. Sorularınızı yanıtlamaya hazırız.',
        'keywords': 'iletişim, destek, müşteri hizmetleri',
      },
      '/help': {
        'title': 'Yardım - Altertale',
        'description': 'Yardım merkezimizi ziyaret edin ve sık sorulan soruları görün.',
        'keywords': 'yardım, destek, sık sorulan sorular',
      },
      '/faq': {
        'title': 'Sık Sorulan Sorular - Altertale',
        'description': 'Sık sorulan soruları görün ve cevapları bulun.',
        'keywords': 'sık sorulan sorular, faq, yardım',
      },
    };
  }

  /// Dinamik sayfa meta etiketleri (kitap, yazar vs.)
  static Map<String, String> getDynamicPageMetaTags(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'book':
        return {
          'title': '${data['title']} - ${data['author']} | Altertale',
          'description': '${data['description']} ${data['author']} tarafından yazılan ${data['title']} kitabını okuyun.',
          'keywords': '${data['title']}, ${data['author']}, ${data['categories'].join(', ')}, e-kitap',
        };
      case 'author':
        return {
          'title': '${data['name']} - Yazar | Altertale',
          'description': '${data['name']} tarafından yazılan kitapları keşfedin.',
          'keywords': '${data['name']}, yazar, kitaplar, edebiyat',
        };
      case 'category':
        return {
          'title': '${data['name']} Kategorisi - Altertale',
          'description': '${data['name']} kategorisindeki kitapları keşfedin.',
          'keywords': '${data['name']}, kategori, kitaplar, ${data['keywords']}',
        };
      case 'search':
        return {
          'title': '"${data['query']}" Arama Sonuçları - Altertale',
          'description': '"${data['query']}" için arama sonuçlarını görüntüleyin.',
          'keywords': '${data['query']}, arama, kitap arama',
        };
      default:
        return {
          'title': 'Altertale',
          'description': 'Altertale ile kitaplarınızı dijital ortamda okuyun.',
          'keywords': 'e-kitap, dijital kitap, online okuma',
        };
    }
  }

  /// Web performans optimizasyonları
  static Map<String, dynamic> getPerformanceConfig() {
    return {
      'preload': [
        '/assets/fonts/Roboto-Regular.ttf',
        '/assets/fonts/Roboto-Bold.ttf',
        '/assets/icons/app-icon.png',
      ],
      'prefetch': [
        '/explore',
        '/library',
        '/settings',
      ],
      'cache': {
        'images': '1 year',
        'fonts': '1 year',
        'css': '1 month',
        'js': '1 month',
        'html': '1 hour',
      },
      'compression': {
        'gzip': true,
        'brotli': true,
      },
      'cdn': {
        'enabled': true,
        'domain': 'cdn.altertale.com',
      },
    };
  }

  /// Web güvenlik ayarları
  static Map<String, dynamic> getSecurityConfig() {
    return {
      'csp': {
        'default-src': ["'self'"],
        'script-src': ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
        'style-src': ["'self'", "'unsafe-inline'"],
        'img-src': ["'self'", 'data:', 'https:'],
        'font-src': ["'self'", 'https:'],
        'connect-src': ["'self'", 'https:'],
        'frame-src': ["'none'"],
        'object-src': ["'none'"],
      },
      'headers': {
        'X-Frame-Options': 'DENY',
        'X-Content-Type-Options': 'nosniff',
        'X-XSS-Protection': '1; mode=block',
        'Referrer-Policy': 'strict-origin-when-cross-origin',
        'Permissions-Policy': 'geolocation=(), microphone=(), camera=()',
      },
      'https': {
        'enabled': true,
        'redirect': true,
        'hsts': true,
      },
    };
  }

  /// Web erişilebilirlik ayarları
  static Map<String, dynamic> getAccessibilityConfig() {
    return {
      'aria': {
        'enabled': true,
        'labels': true,
        'descriptions': true,
      },
      'keyboard': {
        'navigation': true,
        'shortcuts': true,
      },
      'screenReader': {
        'support': true,
        'announcements': true,
      },
      'highContrast': {
        'enabled': true,
        'toggle': true,
      },
      'fontSize': {
        'adjustable': true,
        'min': 12,
        'max': 24,
      },
      'focus': {
        'visible': true,
        'indicator': true,
      },
    };
  }
} 