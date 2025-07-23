import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../models/book_model.dart';
import '../models/rating_model.dart';

class AdvancedShareService {
  static const String _appName = 'AlterTale';
  static const String _appUrl = 'https://altertale.github.io/altertale';
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.altertale.app';
  static const String _appStoreUrl =
      'https://apps.apple.com/app/altertale/id123456789';

  /// Share a book with rich content
  static Future<void> shareBook(
    BookModel book, {
    BookRatingStats? ratingStats,
    String? customMessage,
    SharePlatform? platform,
  }) async {
    try {
      final shareData = _buildBookShareData(book, ratingStats, customMessage);

      switch (platform) {
        case SharePlatform.whatsapp:
          await _shareToWhatsApp(shareData);
          break;
        case SharePlatform.instagram:
          await _shareToInstagram(shareData);
          break;
        case SharePlatform.twitter:
          await _shareToTwitter(shareData);
          break;
        case SharePlatform.facebook:
          await _shareToFacebook(shareData);
          break;
        default:
          await _shareGeneric(shareData);
      }
    } catch (e) {
      print('Error sharing book: $e');
      // Fallback to simple share
      await _shareGeneric(_buildSimpleBookShareData(book));
    }
  }

  /// Share app with referral code
  static Future<void> shareApp({
    String? referralCode,
    String? customMessage,
  }) async {
    try {
      final message = _buildAppShareMessage(referralCode, customMessage);
      await SharePlus.instance.share(message);
    } catch (e) {
      print('Error sharing app: $e');
    }
  }

  /// Share reading achievement
  static Future<void> shareAchievement({
    required String achievementText,
    required int booksRead,
    required String timeSpent,
  }) async {
    try {
      final message = _buildAchievementShareMessage(
        achievementText,
        booksRead,
        timeSpent,
      );
      await SharePlus.instance.share(message);
    } catch (e) {
      print('Error sharing achievement: $e');
    }
  }

  /// Build book share data
  static ShareData _buildBookShareData(
    BookModel book,
    BookRatingStats? ratingStats,
    String? customMessage,
  ) {
    final ratingText = ratingStats != null && ratingStats.totalRatings > 0
        ? '⭐ ${ratingStats.averageRating.toStringAsFixed(1)}/5 (${ratingStats.totalRatings} değerlendirme)'
        : '';

    final message = customMessage ?? _getRandomBookShareMessage();

    final text =
        '''
$message

📚 "${book.title}"
✍️ ${book.author}
${ratingText.isNotEmpty ? '$ratingText\n' : ''}
💰 ${book.formattedPrice}

${book.description.length > 100 ? '${book.description.substring(0, 100)}...' : book.description}

📱 $_appName uygulamasında keşfedin:
$_appUrl

#AlterTale #Kitap #Okuma #${book.genre}
'''
            .trim();

    return ShareData(
      text: text,
      subject: '📚 ${book.title} - $_appName',
      imageUrl: book.coverImageUrl,
    );
  }

  /// Build simple book share data (fallback)
  static ShareData _buildSimpleBookShareData(BookModel book) {
    final text =
        '''
📚 "${book.title}" - ${book.author}

${book.description.length > 80 ? '${book.description.substring(0, 80)}...' : book.description}

$_appName'de keşfedin: $_appUrl
'''
            .trim();

    return ShareData(text: text, subject: book.title);
  }

  /// Build app share message
  static String _buildAppShareMessage(
    String? referralCode,
    String? customMessage,
  ) {
    final message =
        customMessage ?? 'Harika bir e-kitap uygulaması keşfettim! 📚';
    final referralText = referralCode != null
        ? '\n🎁 Referans kodumla indir: $referralCode'
        : '';

    return '''
$message

📱 $_appName - Binlerce kitaba anında erişim
✨ Offline okuma, favoriler, puanlama
🆓 Hemen indir ve okumaya başla

🌐 Web: $_appUrl
📱 Android: $_playStoreUrl
🍎 iOS: $_appStoreUrl$referralText

#AlterTale #Kitap #EKitap #Okuma
'''
        .trim();
  }

  /// Build achievement share message
  static String _buildAchievementShareMessage(
    String achievementText,
    int booksRead,
    String timeSpent,
  ) {
    return '''
🎉 $achievementText

📊 İstatistiklerim:
📚 $booksRead kitap okudum
⏰ $timeSpent okuma saati
📱 $_appName ile

Sen de okuma hedeflerine ulaş! 🚀
$_appUrl

#AlterTale #OkumaHedefi #Kitap #EKitap
'''
        .trim();
  }

  /// Platform-specific sharing methods

  static Future<void> _shareToWhatsApp(ShareData data) async {
    // WhatsApp prefers shorter, emoji-rich messages
    final whatsappText =
        '''
📚 ${_extractBookTitle(data.text)}
${_extractAuthor(data.text)}

${_extractRating(data.text)}

📱 $_appName'de keşfet:
$_appUrl
'''
            .trim();

    await SharePlus.instance.share(whatsappText);
  }

  static Future<void> _shareToInstagram(ShareData data) async {
    // Instagram Stories - copy to clipboard with hashtags
    final instagramText =
        '''
${data.text}

#AlterTale #Kitap #Okuma #EKitap #KitapSeverlere #OkumaZamanı
'''
            .trim();

    await Clipboard.setData(ClipboardData(text: instagramText));
    // Note: Instagram Stories API requires special integration
  }

  static Future<void> _shareToTwitter(ShareData data) async {
    // Twitter has character limits
    final bookTitle = _extractBookTitle(data.text);
    final author = _extractAuthor(data.text);

    final twitterText =
        '''
📚 "$bookTitle" - $author

$_appName'de keşfettim! Harika bir e-kitap uygulaması 📱

$_appUrl

#AlterTale #Kitap #EKitap
'''
            .trim();

    await SharePlus.instance.share(twitterText);
  }

  static Future<void> _shareToFacebook(ShareData data) async {
    // Facebook allows longer content
    await SharePlus.instance.share(data.text, subject: data.subject);
  }

  static Future<void> _shareGeneric(ShareData data) async {
    await SharePlus.instance.share(data.text, subject: data.subject);
  }

  /// Helper methods to extract content parts

  static String _extractBookTitle(String text) {
    final match = RegExp(r'"([^"]+)"').firstMatch(text);
    return match?.group(1) ?? 'Kitap';
  }

  static String _extractAuthor(String text) {
    final match = RegExp(r'✍️ ([^\n]+)').firstMatch(text);
    return match?.group(1) ?? '';
  }

  static String _extractRating(String text) {
    final match = RegExp(r'⭐ [^\n]+').firstMatch(text);
    return match?.group(0) ?? '';
  }

  /// Random share messages for variety
  static String _getRandomBookShareMessage() {
    final messages = [
      'Bu kitabı keşfettim ve harika! 📚✨',
      'Okuma listemde bir yeni favorim! 📖❤️',
      'Bu kitabı tavsiye ediyorum! 🌟',
      'Harika bir kitap buldum! 📚🔥',
      'Bu kitap gerçekten etkileyici! 📖✨',
      'Okuması gereken bir kitap! 📚👍',
      'Bu kitapla harika zaman geçirdim! 📖😊',
      'Mükemmel bir kitap! 📚🌟',
    ];

    return messages[DateTime.now().millisecondsSinceEpoch % messages.length];
  }

  /// Copy content to clipboard
  static Future<void> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (e) {
      print('Error copying to clipboard: $e');
    }
  }

  /// Share with files (for book covers, etc.)
  static Future<void> shareWithFiles({
    required String text,
    required List<String> imagePaths,
    String? subject,
  }) async {
    try {
      await SharePlus.instance.shareXFiles(
        imagePaths.map((path) => XFile(path)).toList(),
        text: text,
        subject: subject,
      );
    } catch (e) {
      print('Error sharing with files: $e');
      // Fallback to text only
      await SharePlus.instance.share(text, subject: subject);
    }
  }
}

/// Share data model
class ShareData {
  final String text;
  final String? subject;
  final String? imageUrl;

  ShareData({required this.text, this.subject, this.imageUrl});
}

/// Supported share platforms
enum SharePlatform { whatsapp, instagram, twitter, facebook, generic }
