import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/responsive_layout.dart';

/// Yasal sayfalar - Gizlilik politikası, kullanım koşulları vs.
class LegalPages {
  /// Gizlilik politikası sayfası
  static Widget privacyPolicyPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Politikası'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ResponsiveLayout.responsiveContainer(
        context: context,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveLayout.responsiveText(
                context: context,
                text: 'Gizlilik Politikası',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ResponsiveLayout.responsiveText(
                context: context,
                text:
                    'Son güncelleme: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),

              _buildSection(
                context,
                title: '1. Toplanan Bilgiler',
                content: '''
Altertale olarak, hizmetlerimizi sağlamak için aşağıdaki bilgileri toplarız:

• Hesap bilgileri (ad, e-posta, profil fotoğrafı)
• Kullanım verileri (okuma ilerlemesi, favoriler, ayarlar)
• Cihaz bilgileri (platform, işletim sistemi, tarayıcı)
• Analitik veriler (sayfa görüntülemeleri, kullanım süreleri)
• İletişim verileri (destek talepleri, geri bildirimler)
                ''',
              ),

              _buildSection(
                context,
                title: '2. Bilgilerin Kullanımı',
                content: '''
Topladığımız bilgileri aşağıdaki amaçlarla kullanırız:

• Hizmetlerimizi sağlamak ve iyileştirmek
• Kişiselleştirilmiş deneyim sunmak
• Güvenliği sağlamak ve dolandırıcılığı önlemek
• Yasal yükümlülükleri yerine getirmek
• İletişim kurmak ve destek sağlamak
                ''',
              ),

              _buildSection(
                context,
                title: '3. Bilgi Paylaşımı',
                content: '''
Bilgilerinizi üçüncü taraflarla paylaşmayız, ancak aşağıdaki durumlar hariç:

• Yasal zorunluluk durumunda
• Hizmet sağlayıcılarımızla (güvenlik ve gizlilik standartlarına uygun)
• İş transferi durumunda (kullanıcı onayı ile)
• Güvenlik ve dolandırıcılık önleme amaçlı
                ''',
              ),

              _buildSection(
                context,
                title: '4. Veri Güvenliği',
                content: '''
Verilerinizi korumak için aşağıdaki önlemleri alırız:

• End-to-end şifreleme
• Güvenli sunucu altyapısı
• Düzenli güvenlik denetimleri
• Erişim kontrolü ve yetkilendirme
• Veri yedekleme ve felaket kurtarma
                ''',
              ),

              _buildSection(
                context,
                title: '5. Kullanıcı Hakları',
                content: '''
Aşağıdaki haklara sahipsiniz:

• Verilerinize erişim
• Verilerinizi düzeltme
• Verilerinizi silme
• Veri işlemeyi kısıtlama
• Veri taşınabilirliği
• İtiraz etme hakkı
                ''',
              ),

              _buildSection(
                context,
                title: '6. Çerezler ve Takip',
                content: '''
Web sitemizde çerezler kullanırız:

• Gerekli çerezler (oturum yönetimi)
• Analitik çerezler (kullanım istatistikleri)
• Kişiselleştirme çerezleri (tercihler)
• Reklam çerezleri (üçüncü taraf)

Çerez tercihlerinizi tarayıcı ayarlarından yönetebilirsiniz.
                ''',
              ),

              _buildSection(
                context,
                title: '7. Çocukların Gizliliği',
                content: '''
13 yaşından küçük çocuklardan bilerek bilgi toplamayız. 
Eğer çocuğunuzun bilgilerini paylaştığını fark ederseniz, 
lütfen bizimle iletişime geçin.
                ''',
              ),

              _buildSection(
                context,
                title: '8. Uluslararası Veri Transferi',
                content: '''
Verileriniz Türkiye'de saklanır ve işlenir. 
Uluslararası transfer durumunda, uygun güvenlik 
önlemleri alınır ve yasal gereklilikler sağlanır.
                ''',
              ),

              _buildSection(
                context,
                title: '9. Politika Değişiklikleri',
                content: '''
Bu politika zaman zaman güncellenebilir. 
Önemli değişiklikler için size bildirim göndeririz. 
Güncel politika her zaman web sitemizde mevcuttur.
                ''',
              ),

              _buildSection(
                context,
                title: '10. İletişim',
                content: '''
Gizlilik ile ilgili sorularınız için:

E-posta: privacy@altertale.com
Adres: [Şirket Adresi]
Telefon: [Telefon Numarası]

Veri Koruma Sorumlusu: [DPO Adı]
                ''',
              ),

              const SizedBox(height: 32),

              // İletişim butonları
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchEmail('privacy@altertale.com'),
                      icon: const Icon(Icons.email),
                      label: const Text('E-posta Gönder'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _launchUrl('https://altertale.com/privacy'),
                      icon: const Icon(Icons.language),
                      label: const Text('Web Sitesi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kullanım koşulları sayfası
  static Widget termsOfServicePage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanım Koşulları'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ResponsiveLayout.responsiveContainer(
        context: context,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveLayout.responsiveText(
                context: context,
                text: 'Kullanım Koşulları',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ResponsiveLayout.responsiveText(
                context: context,
                text:
                    'Son güncelleme: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),

              _buildSection(
                context,
                title: '1. Hizmet Tanımı',
                content: '''
Altertale, dijital kitap okuma platformudur. 
Hizmetlerimiz şunları içerir:

• E-kitap satın alma ve okuma
• Okuma ilerlemesi takibi
• Kişiselleştirilmiş öneriler
• Sosyal özellikler (yorumlar, puanlama)
• Çoklu platform desteği
                ''',
              ),

              _buildSection(
                context,
                title: '2. Hesap Oluşturma',
                content: '''
Hizmetlerimizi kullanmak için hesap oluşturmanız gerekir:

• Gerçek bilgilerinizi kullanın
• Hesap güvenliğinizi sağlayın
• Hesabınızı başkalarına vermeyin
• Şüpheli aktiviteleri bildirin
• Hesap bilgilerinizi güncel tutun
                ''',
              ),

              _buildSection(
                context,
                title: '3. Kullanım Kuralları',
                content: '''
Aşağıdaki kurallara uymanız gerekir:

• Telif hakkı ihlali yapmayın
• Uygunsuz içerik paylaşmayın
• Spam veya zararlı içerik göndermeyin
• Sistem güvenliğini tehdit etmeyin
• Diğer kullanıcıları rahatsız etmeyin
                ''',
              ),

              _buildSection(
                context,
                title: '4. İçerik Politikası',
                content: '''
Paylaştığınız içerikler:

• Telif hakkına sahip olmalı
• Uygunsuz olmamalı
• Zararlı olmamalı
• Yasal olmalı
• Topluluk kurallarına uygun olmalı
                ''',
              ),

              _buildSection(
                context,
                title: '5. Ödeme ve İade',
                content: '''
Ödeme koşulları:

• Fiyatlar TL cinsinden gösterilir
• Ödeme anında tahsil edilir
• İade politikası: 14 gün içinde
• Dijital ürünler için özel kurallar
• Abonelik iptali her zaman mümkün
                ''',
              ),

              _buildSection(
                context,
                title: '6. Fikri Mülkiyet',
                content: '''
Altertale'nin fikri mülkiyet hakları:

• Platform ve yazılım hakları
• Ticari marka hakları
• Tasarım hakları
• İçerik hakları (kendi içeriklerimiz)
• Lisanslı içerik hakları
                ''',
              ),

              _buildSection(
                context,
                title: '7. Sorumluluk Sınırları',
                content: '''
Sorumluluk sınırlarımız:

• Hizmet kesintileri için sorumluluk yoktur
• Üçüncü taraf içerikler için sorumluluk yoktur
• Kullanıcı hataları için sorumluluk yoktur
• Maksimum sorumluluk: ödenen tutar
• Zorunlu yasal sorumluluklar hariç
                ''',
              ),

              _buildSection(
                context,
                title: '8. Hizmet Değişiklikleri',
                content: '''
Hizmetlerimiz değişebilir:

• Önceden bildirim yapılır
• Önemli değişiklikler için onay istenir
• Geriye dönük uyumluluk sağlanır
• Alternatif çözümler sunulur
• İptal hakkı tanınır
                ''',
              ),

              _buildSection(
                context,
                title: '9. Hesap Askıya Alma',
                content: '''
Hesabınız askıya alınabilir:

• Kural ihlali durumunda
• Şüpheli aktivite durumunda
• Yasal zorunluluk durumunda
• Ödeme sorunları durumunda
• Güvenlik tehdidi durumunda
                ''',
              ),

              _buildSection(
                context,
                title: '10. Uyuşmazlık Çözümü',
                content: '''
Uyuşmazlık çözüm süreci:

• Önce müzakere yapılır
• Gerekirse arabuluculuk
• Son çare: mahkeme
• Türkiye mahkemeleri yetkili
• Türk hukuku uygulanır
                ''',
              ),

              const SizedBox(height: 32),

              // İletişim butonları
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchEmail('legal@altertale.com'),
                      icon: const Icon(Icons.email),
                      label: const Text('E-posta Gönder'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _launchUrl('https://altertale.com/terms'),
                      icon: const Icon(Icons.language),
                      label: const Text('Web Sitesi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Yardım sayfası
  static Widget helpPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yardım'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ResponsiveLayout.responsiveContainer(
        context: context,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveLayout.responsiveText(
                context: context,
                text: 'Yardım Merkezi',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              _buildHelpSection(
                context,
                title: 'Sık Sorulan Sorular',
                items: [
                  'Nasıl kitap satın alabilirim?',
                  'Okuma ilerlemem nasıl kaydedilir?',
                  'Şifremi nasıl değiştirebilirim?',
                  'Hesabımı nasıl silebilirim?',
                  'Bildirimleri nasıl yönetebilirim?',
                ],
              ),

              _buildHelpSection(
                context,
                title: 'Teknik Destek',
                items: [
                  'Uygulama çöküyor',
                  'Giriş yapamıyorum',
                  'Kitap yüklenmiyor',
                  'Ödeme sorunu yaşıyorum',
                  'Bildirim gelmiyor',
                ],
              ),

              _buildHelpSection(
                context,
                title: 'İletişim Kanalları',
                items: [
                  'E-posta: support@altertale.com',
                  'Telefon: +90 xxx xxx xx xx',
                  'Canlı Destek: 09:00-18:00',
                  'Sosyal Medya: @altertale',
                  'Web Sitesi: altertale.com',
                ],
              ),

              const SizedBox(height: 32),

              // İletişim butonları
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchEmail('support@altertale.com'),
                      icon: const Icon(Icons.email),
                      label: const Text('E-posta ile İletişim'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl('https://altertale.com/help'),
                      icon: const Icon(Icons.language),
                      label: const Text('Web Sitesi'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl('tel:+90xxxxxxxxx'),
                      icon: const Icon(Icons.phone),
                      label: const Text('Telefon ile Ara'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bölüm widget'ı
  static Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveLayout.responsiveText(
          context: context,
          text: title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ResponsiveLayout.responsiveText(
          context: context,
          text: content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Yardım bölümü widget'ı
  static Widget _buildHelpSection(
    BuildContext context, {
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveLayout.responsiveText(
          context: context,
          text: title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.arrow_right,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ResponsiveLayout.responsiveText(
                    context: context,
                    text: item,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// E-posta gönder
  static Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Altertale Destek Talebi',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  /// URL aç
  static Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
