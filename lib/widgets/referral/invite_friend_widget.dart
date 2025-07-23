import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Arkadaş davet widget'ı
class InviteFriendWidget extends StatelessWidget {
  final String referralCode;
  final VoidCallback? onCodeCopied;

  const InviteFriendWidget({
    super.key,
    required this.referralCode,
    this.onCodeCopied,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Icon(
                  Icons.share,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Arkadaşlarını Davet Et',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Açıklama
            Text(
              'Arkadaşlarını Altertale\'ye davet et ve puan kazan!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Referans kodu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Referans Kodunuz',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          referralCode,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _copyCode,
                        icon: const Icon(Icons.copy),
                        tooltip: 'Kodu Kopyala',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Puan bilgileri
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kazanacağınız Puanlar',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Her davet ettiğiniz arkadaş için: 50 puan',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '• Arkadaşınız da: 10 hoş geldin puanı',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Paylaş butonları
            Text(
              'Paylaş',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildShareButton(
                  context,
                  'WhatsApp',
                  Icons.chat,
                  Colors.green,
                  () => _shareToWhatsApp(),
                ),
                _buildShareButton(
                  context,
                  'Telegram',
                  Icons.telegram,
                  Colors.blue,
                  () => _shareToTelegram(),
                ),
                _buildShareButton(
                  context,
                  'E-posta',
                  Icons.email,
                  Colors.orange,
                  () => _shareToEmail(),
                ),
                _buildShareButton(
                  context,
                  'SMS',
                  Icons.sms,
                  Colors.green,
                  () => _shareToSMS(),
                ),
                _buildShareButton(
                  context,
                  'Kopyala',
                  Icons.copy,
                  theme.colorScheme.primary,
                  _copyCode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Paylaş butonu oluştur
  Widget _buildShareButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PAYLAŞIM FONKSİYONLARI ====================

  /// Kodu kopyala
  void _copyCode() {
    Clipboard.setData(ClipboardData(text: referralCode));
    onCodeCopied?.call();
  }

  /// WhatsApp'ta paylaş
  void _shareToWhatsApp() {
    final message = _getShareMessage();
    final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(message)}';
    
    launchUrl(Uri.parse(whatsappUrl)).catchError((e) {
      // WhatsApp yüklü değilse genel paylaşım menüsünü aç
      SharePlus.instance.share(message);
    });
  }

  /// Telegram'da paylaş
  void _shareToTelegram() {
    final message = _getShareMessage();
    final telegramUrl = 'https://t.me/share/url?url=${Uri.encodeComponent("https://altertale.com")}&text=${Uri.encodeComponent(message)}';
    
    launchUrl(Uri.parse(telegramUrl)).catchError((e) {
      // Telegram yüklü değilse genel paylaşım menüsünü aç
      SharePlus.instance.share(message);
    });
  }

  /// E-posta ile paylaş
  void _shareToEmail() {
    final message = _getShareMessage();
    final emailUrl = 'mailto:?subject=Altertale Daveti&body=${Uri.encodeComponent(message)}';
    
    launchUrl(Uri.parse(emailUrl)).catchError((e) {
      // E-posta uygulaması yoksa genel paylaşım menüsünü aç
      SharePlus.instance.share(message);
    });
  }

  /// SMS ile paylaş
  void _shareToSMS() {
    final message = _getShareMessage();
    final smsUrl = 'sms:?body=${Uri.encodeComponent(message)}';
    
    launchUrl(Uri.parse(smsUrl)).catchError((e) {
      // SMS uygulaması yoksa genel paylaşım menüsünü aç
      SharePlus.instance.share(message);
    });
  }

  /// Paylaşım mesajını oluştur
  String _getShareMessage() {
    return '''Altertale'ye davet edildiniz! 📚

Altertale, gelişmiş kitap okuma uygulamasıdır. Binlerce kitaba erişim, offline okuma, puan sistemi ve daha fazlası!

Referans kodum: $referralCode

Bu kod ile kayıt olursanız hem siz hem de ben puan kazanırız!

İndir: https://altertale.com''';
  }
}

/// Referans başarı widget'ı
class ReferralSuccessWidget extends StatelessWidget {
  final String referredUserName;
  final int pointsEarned;

  const ReferralSuccessWidget({
    super.key,
    required this.referredUserName,
    required this.pointsEarned,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Başarı ikonu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 32,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Başlık
          Text(
            'Tebrikler!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Mesaj
          Text(
            '$referredUserName Altertale\'ye katıldı!',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Puan bilgisi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '+$pointsEarned puan kazandınız!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
