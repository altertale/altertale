import 'package:intl/intl.dart';

/// Tarih yardımcı sınıfı
class DateUtils {
  /// Göreceli zaman formatı (örn: "2 saat önce", "3 gün önce")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Dün';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} gün önce';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks hafta önce';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months ay önce';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years yıl önce';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  /// Tam tarih formatı
  static String formatFullDate(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy, HH:mm').format(dateTime);
  }

  /// Kısa tarih formatı
  static String formatShortDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }

  /// Saat formatı
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Tarih ve saat formatı
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }
}
