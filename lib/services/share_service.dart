import 'package:flutter/material.dart';

/// Share Service
/// Handles sharing functionality for books and content
class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  /// Share a book
  Future<void> shareBook({
    required String bookId,
    required String title,
    required String author,
    String? description,
  }) async {
    try {
      final shareText = _buildBookShareText(
        title: title,
        author: author,
        description: description,
      );

      // For now, just print the share text (placeholder)
      print('📤 Sharing book: $shareText');

      // In a real implementation, you would use a sharing package like share_plus
      // await Share.share(shareText);
    } catch (e) {
      print('❌ Error sharing book: $e');
      rethrow;
    }
  }

  /// Share app recommendation
  Future<void> shareApp() async {
    try {
      const shareText =
          'AlterTale - Harika bir kitap okuma uygulaması! İndirmek için: [App Store Link]';

      print('📤 Sharing app: $shareText');

      // In a real implementation:
      // await Share.share(shareText);
    } catch (e) {
      print('❌ Error sharing app: $e');
      rethrow;
    }
  }

  /// Share reading progress
  Future<void> shareProgress({
    required String bookTitle,
    required int currentPage,
    required int totalPages,
  }) async {
    try {
      final progressPercent = ((currentPage / totalPages) * 100).toInt();
      final shareText =
          '$bookTitle kitabının %$progressPercent\'ini okudum! AlterTale ile okuma keyfinizi yaşayın.';

      print('📤 Sharing progress: $shareText');

      // In a real implementation:
      // await Share.share(shareText);
    } catch (e) {
      print('❌ Error sharing progress: $e');
      rethrow;
    }
  }

  /// Build share text for book
  String _buildBookShareText({
    required String title,
    required String author,
    String? description,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('📚 $title');
    buffer.writeln('✍️ Yazar: $author');

    if (description != null && description.isNotEmpty) {
      buffer.writeln('📝 $description');
    }

    buffer.writeln('');
    buffer.writeln('AlterTale uygulaması ile keşfedin! 🚀');

    return buffer.toString();
  }

  /// Show share dialog with options
  Future<void> showShareDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(content)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Trigger actual share
                print('📤 User confirmed share: $content');
              },
              child: const Text('Paylaş'),
            ),
          ],
        );
      },
    );
  }

  /// Check if sharing is available
  bool get isAvailable {
    // In a real implementation, check if share functionality is available
    return true;
  }
}
