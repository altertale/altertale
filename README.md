# 📚 Altertale - E-Book Reading Platform

**Versiyon:** v1.0.0  
**Tarih:** 23 Ocak 2025  
**Durum:** Production Ready 🚀

## 🌟 Özellikler

### ✅ **v1.0 Temel Özellikler**

- **🔐 Kullanıcı Yönetimi**
  - Firebase Authentication ile güvenli giriş/kayıt
  - Email doğrulama
  - Şifre sıfırlama

- **📖 Kitap Kataloğu**
  - 10 demo kitap ile zengin katalog
  - Lorem Ipsum içerikli demo kitaplar
  - Kategorilere göre filtreleme
  - Arama özelliği

- **🛒 Sepet & Satın Alma**
  - Duplicate kontrolü ile akıllı sepet
  - Demo ödeme sistemi
  - Anlık sepet geri bildirimleri
  - Order takip sistemi

- **💖 Favoriler**
  - Anlık senkronizasyon
  - Kalıcı favoriler (SharedPreferences)
  - Cross-screen sync

- **📚 Kitaplarım/MyBooks**
  - Smart navigation (favorites → detail, purchased → reader)
  - Satın alınan kitaplar
  - Okuma geçmişi
  - Anlık güncelleme

- **📖 ReaderScreen**
  - Sayfa bazlı okuma deneyimi
  - Okuma progress takibi
  - Navigasyon kontrolleri
  - Lorem Ipsum demo içerik

- **📤 Paylaşım**
  - share_plus entegrasyonu
  - Platform optimize edilmiş içerik
  - WhatsApp, Instagram desteği

- **💬 Yorum Sistemi**
  - Modal tabanlı yorum formu
  - Rating sistemi
  - Satın alınan kitaplar için aktif

- **⚡ Performans**
  - Firebase query caching
  - Debounced search (800ms)
  - CachedNetworkImage
  - Lazy loading

## 🏗️ Teknik Altyapı

### **Framework & Dil**
- Flutter 3.x
- Dart 3.x

### **State Management**
- Provider pattern
- Real-time reactive UI

### **Backend & Database**
- Firebase Firestore
- Firebase Authentication
- Local storage (SharedPreferences)

### **UI/UX**
- Material Design 3
- Responsive design
- Dark/Light theme support
- Custom animations

## 📱 Platform Desteği

- ✅ **Web** (Chrome, Safari, Firefox)
- ✅ **Android** (Android 6.0+)
- ✅ **iOS** (iOS 12.0+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Linux**
- ✅ **Windows**

## 🚀 Kurulum & Çalıştırma

### **Gereksinimler**
```bash
Flutter SDK 3.x
Dart SDK 3.x
Firebase CLI
```

### **Kurulum**
```bash
# Repository clone
git clone https://github.com/[username]/altertale.git
cd altertale

# Dependencies
flutter pub get

# Firebase setup (optional - demo mode active)
flutterfire configure

# Run
flutter run -d chrome  # Web için
flutter run -d android # Android için
flutter run -d ios     # iOS için
```

### **Demo Mode**
Uygulama Firebase bağlantısı olmadan demo modda çalışır:
- Demo kullanıcı: byrm.sevim@outlook.com
- Demo kitaplar: 10 hazır kitap
- Demo ödeme: Otomatik başarılı
- Local storage: SharedPreferences

## 📝 Test Senaryoları

### **Temel Akış**
1. ✅ Kayıt/Giriş
2. ✅ Kitap keşfetme
3. ✅ Favorilere ekleme
4. ✅ Sepete ekleme (duplicate kontrolü)
5. ✅ Satın alma
6. ✅ MyBooks'tan okuma
7. ✅ ReaderScreen navigation
8. ✅ Progress takibi

### **Edge Cases**
- ✅ Duplicate sepet engelleme
- ✅ Offline mode fallback
- ✅ Cross-screen sync
- ✅ Memory management

## 🔄 Versiyon Geçmişi

### **v1.0.0 - 23 Ocak 2025**
- 🎉 İlk production release
- ✅ Tüm temel özellikler
- ✅ Cross-platform destek
- ✅ Demo mode
- ✅ Performance optimizations

## 🛣️ Roadmap v1.1+

### **v1.1 Planlanan Özellikler**
- 📊 Gelişmiş analytics
- 🔔 Push notifications
- 🌐 Multi-language support
- 💳 Gerçek ödeme entegrasyonu
- 📚 Gelişmiş yorum sistemi
- 🎨 Tema customization

### **v1.2+ Gelecek Özellikler**
- 🎧 Audiobook desteği
- 📖 PDF kitap desteği
- 👥 Sosyal özellikler
- 🔍 AI powered recommendations
- 📱 Offline reading mode

## 🤝 Katkıda Bulunma

1. Fork this repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 📞 İletişim

- 👨‍💻 Geliştirici: Bayram Sevim
- 📧 Email: byrm.sevim@outlook.com
- 🌐 Website: [altertale.com](https://altertale.com)

---

**Altertale v1.0** - Modern e-kitap okuma deneyimi 📚✨
