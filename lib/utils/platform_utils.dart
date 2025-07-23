import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Platform algılama ve yardımcı fonksiyonlar
class PlatformUtils {
  /// Web platformunda mı?
  static bool get isWeb => kIsWeb;

  /// Android platformunda mı?
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// iOS platformunda mı?
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Mobil platform mu? (Android veya iOS)
  static bool get isMobile => isAndroid || isIOS;

  /// Masaüstü platform mu? (Web)
  static bool get isDesktop => isWeb;

  /// Platform adını döndür
  static String get platformName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    return 'Unknown';
  }

  /// Platform ikonunu döndür
  static IconData get platformIcon {
    if (isWeb) return Icons.web;
    if (isAndroid) return Icons.android;
    if (isIOS) return Icons.phone_iphone;
    return Icons.device_unknown;
  }

  /// Platform rengini döndür
  static Color get platformColor {
    if (isWeb) return Colors.blue;
    if (isAndroid) return Colors.green;
    if (isIOS) return Colors.black;
    return Colors.grey;
  }

  /// Ekran boyutuna göre cihaz tipini belirle
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (isWeb) {
      if (width >= 1200) return DeviceType.desktop;
      if (width >= 768) return DeviceType.tablet;
      return DeviceType.mobile;
    } else {
      // Mobil platformlarda ekran boyutuna göre
      if (width >= 600) return DeviceType.tablet;
      return DeviceType.mobile;
    }
  }

  /// Ekran boyutuna göre responsive breakpoint'leri
  static ResponsiveBreakpoint getResponsiveBreakpoint(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) return ResponsiveBreakpoint.desktop;
    if (width >= 768) return ResponsiveBreakpoint.tablet;
    if (width >= 480) return ResponsiveBreakpoint.mobile;
    return ResponsiveBreakpoint.smallMobile;
  }

  /// Grid kolon sayısını hesapla
  static int getGridColumnCount(BuildContext context) {
    final breakpoint = getResponsiveBreakpoint(context);
    
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return 4; // Masaüstü: 4 kolon
      case ResponsiveBreakpoint.tablet:
        return 3; // Tablet: 3 kolon
      case ResponsiveBreakpoint.mobile:
        return 2; // Mobil: 2 kolon
      case ResponsiveBreakpoint.smallMobile:
        return 1; // Küçük mobil: 1 kolon
    }
  }

  /// Kart genişliğini hesapla
  static double getCardWidth(BuildContext context, {double padding = 16.0}) {
    final width = MediaQuery.of(context).size.width;
    final breakpoint = getResponsiveBreakpoint(context);
    
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return (width - (padding * 5)) / 4; // 4 kolon, 5 boşluk
      case ResponsiveBreakpoint.tablet:
        return (width - (padding * 4)) / 3; // 3 kolon, 4 boşluk
      case ResponsiveBreakpoint.mobile:
        return (width - (padding * 3)) / 2; // 2 kolon, 3 boşluk
      case ResponsiveBreakpoint.smallMobile:
        return width - (padding * 2); // 1 kolon, 2 boşluk
    }
  }

  /// Platform bazlı padding değerleri
  static EdgeInsets getPlatformPadding(BuildContext context) {
    final breakpoint = getResponsiveBreakpoint(context);
    
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return const EdgeInsets.all(24.0);
      case ResponsiveBreakpoint.tablet:
        return const EdgeInsets.all(20.0);
      case ResponsiveBreakpoint.mobile:
        return const EdgeInsets.all(16.0);
      case ResponsiveBreakpoint.smallMobile:
        return const EdgeInsets.all(12.0);
    }
  }

  /// Platform bazlı font boyutları
  static double getPlatformFontSize(BuildContext context, double baseSize) {
    final breakpoint = getResponsiveBreakpoint(context);
    
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return baseSize * 1.2; // Masaüstü: %20 büyük
      case ResponsiveBreakpoint.tablet:
        return baseSize * 1.1; // Tablet: %10 büyük
      case ResponsiveBreakpoint.mobile:
        return baseSize; // Mobil: normal boyut
      case ResponsiveBreakpoint.smallMobile:
        return baseSize * 0.9; // Küçük mobil: %10 küçük
    }
  }

  /// Platform bazlı icon boyutları
  static double getPlatformIconSize(BuildContext context, double baseSize) {
    final breakpoint = getResponsiveBreakpoint(context);
    
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return baseSize * 1.3; // Masaüstü: %30 büyük
      case ResponsiveBreakpoint.tablet:
        return baseSize * 1.15; // Tablet: %15 büyük
      case ResponsiveBreakpoint.mobile:
        return baseSize; // Mobil: normal boyut
      case ResponsiveBreakpoint.smallMobile:
        return baseSize * 0.85; // Küçük mobil: %15 küçük
    }
  }

  /// Platform bazlı animasyon süreleri
  static Duration getPlatformAnimationDuration(BuildContext context) {
    final breakpoint = getResponsiveBreakpoint(context);
    
    switch (breakpoint) {
      case ResponsiveBreakpoint.desktop:
        return const Duration(milliseconds: 300); // Masaüstü: daha hızlı
      case ResponsiveBreakpoint.tablet:
        return const Duration(milliseconds: 350); // Tablet: orta hız
      case ResponsiveBreakpoint.mobile:
        return const Duration(milliseconds: 400); // Mobil: normal hız
      case ResponsiveBreakpoint.smallMobile:
        return const Duration(milliseconds: 450); // Küçük mobil: daha yavaş
    }
  }

  /// Platform bazlı scroll davranışı
  static ScrollPhysics getPlatformScrollPhysics(BuildContext context) {
    if (isWeb) {
      return const BouncingScrollPhysics(); // Web: bouncing effect
    } else {
      return const AlwaysScrollableScrollPhysics(); // Mobil: normal scroll
    }
  }

  /// Platform bazlı hover efektleri
  static bool shouldShowHoverEffects(BuildContext context) {
    return isWeb && getResponsiveBreakpoint(context) != ResponsiveBreakpoint.smallMobile;
  }

  /// Platform bazlı sağ tık menüsü
  static bool shouldDisableContextMenu(BuildContext context) {
    return isWeb; // Web'de sağ tık menüsünü devre dışı bırak
  }

  /// Platform bazlı bildirim desteği
  static bool supportsNotifications(BuildContext context) {
    if (isWeb) {
      // Web'de masaüstü bildirimleri kontrol et
      return true; // TODO: Gerçek kontrol eklenecek
    } else {
      // Mobilde push bildirimleri mevcut
      return true;
    }
  }

  /// Platform bazlı dosya seçici
  static bool supportsFilePicker(BuildContext context) {
    if (isWeb) {
      return true; // Web'de dosya seçici mevcut
    } else {
      return true; // Mobilde de mevcut
    }
  }

  /// Platform bazlı paylaşım
  static bool supportsSharing(BuildContext context) {
    return true; // Tüm platformlarda desteklenir
  }

  /// Platform bazlı kamera erişimi
  static bool supportsCamera(BuildContext context) {
    if (isWeb) {
      return true; // Web'de kamera erişimi mevcut
    } else {
      return true; // Mobilde de mevcut
    }
  }

  /// Platform bazlı konum erişimi
  static bool supportsLocation(BuildContext context) {
    if (isWeb) {
      return true; // Web'de konum erişimi mevcut
    } else {
      return true; // Mobilde de mevcut
    }
  }

  /// Platform bazlı depolama
  static bool supportsLocalStorage(BuildContext context) {
    return true; // Tüm platformlarda desteklenir
  }

  /// Platform bazlı ağ durumu
  static bool supportsNetworkStatus(BuildContext context) {
    return true; // Tüm platformlarda desteklenir
  }

  /// Platform bazlı tema desteği
  static bool supportsSystemTheme(BuildContext context) {
    if (isWeb) {
      return true; // Web'de sistem teması desteği
    } else {
      return true; // Mobilde de mevcut
    }
  }

  /// Platform bazlı dil desteği
  static bool supportsLocalization(BuildContext context) {
    return true; // Tüm platformlarda desteklenir
  }

  /// Platform bazlı erişilebilirlik
  static bool supportsAccessibility(BuildContext context) {
    return true; // Tüm platformlarda desteklenir
  }

  /// Platform bazlı performans optimizasyonları
  static Map<String, dynamic> getPerformanceSettings(BuildContext context) {
    final breakpoint = getResponsiveBreakpoint(context);
    
    return {
      'imageCacheSize': breakpoint == ResponsiveBreakpoint.desktop ? 100 : 50,
      'animationQuality': breakpoint == ResponsiveBreakpoint.desktop ? 'high' : 'medium',
      'scrollPhysics': getPlatformScrollPhysics(context),
      'animationDuration': getPlatformAnimationDuration(context),
    };
  }
}

/// Cihaz tipleri
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Responsive breakpoint'ler
enum ResponsiveBreakpoint {
  smallMobile, // < 480px
  mobile,      // 480px - 767px
  tablet,      // 768px - 1199px
  desktop,     // >= 1200px
}

/// Platform bazlı widget builder
typedef PlatformWidgetBuilder = Widget Function(BuildContext context, bool isWeb, bool isMobile);

/// Responsive widget builder
typedef ResponsiveWidgetBuilder = Widget Function(BuildContext context, ResponsiveBreakpoint breakpoint);

/// Platform bazlı widget
class PlatformWidget extends StatelessWidget {
  final PlatformWidgetBuilder builder;

  const PlatformWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, PlatformUtils.isWeb, PlatformUtils.isMobile);
  }
}

/// Responsive widget
class ResponsiveWidget extends StatelessWidget {
  final ResponsiveWidgetBuilder builder;

  const ResponsiveWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final breakpoint = PlatformUtils.getResponsiveBreakpoint(context);
    return builder(context, breakpoint);
  }
} 