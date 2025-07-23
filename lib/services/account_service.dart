import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';

/// Hesap servisi - Kullanıcı hesap işlemlerini yönetir
class AccountService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  
  static const String _usersCollection = 'users';
  static const String _userActivitiesCollection = 'user_activities';

  /// Mevcut kullanıcıyı getir
  User? get currentUser => _auth.currentUser;

  /// Kullanıcı giriş yapmış mı?
  bool get isLoggedIn => _auth.currentUser != null;

  /// Kullanıcı ID'sini getir
  String? get userId => _auth.currentUser?.uid;

  /// Kullanıcı profil bilgilerini getir
  Future<UserModel?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Kullanıcı profili getirilirken hata: $e');
      return null;
    }
  }

  /// Kullanıcı profil bilgilerini güncelle
  Future<bool> updateUserProfile({
    String? displayName,
    String? about,
    String? phoneNumber,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Firebase Auth'da display name güncelle
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      // Firestore'da profil bilgilerini güncelle
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (about != null) updateData['about'] = about;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (additionalData != null) updateData.addAll(additionalData);

      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .update(updateData);

      // Aktivite logu
      await _logUserActivity('profile_updated', {
        'displayName': displayName,
        'about': about,
        'phoneNumber': phoneNumber,
      });

      return true;
    } catch (e) {
      print('Kullanıcı profili güncellenirken hata: $e');
      return false;
    }
  }

  /// Profil fotoğrafını güncelle
  Future<bool> updateProfilePhoto({bool fromCamera = false}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Resim seç
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null) return false;

      // TODO: Resmi Firebase Storage'a yükle
      // Şimdilik sadece dosya yolunu kaydet
      final photoUrl = image.path;

      // Firebase Auth'da photo URL güncelle
      await user.updatePhotoURL(photoUrl);

      // Firestore'da profil fotoğrafını güncelle
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .update({
        'photoURL': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Aktivite logu
      await _logUserActivity('profile_photo_updated', {
        'fromCamera': fromCamera,
        'photoUrl': photoUrl,
      });

      return true;
    } catch (e) {
      print('Profil fotoğrafı güncellenirken hata: $e');
      return false;
    }
  }

  /// E-posta adresini güncelle
  Future<bool> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // E-posta güncelle (doğrulama ile)
      await user.verifyBeforeUpdateEmail(newEmail);

      // Firestore'da e-posta güncelle
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .update({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Aktivite logu
      await _logUserActivity('email_updated', {
        'oldEmail': user.email,
        'newEmail': newEmail,
      });

      return true;
    } catch (e) {
      print('E-posta güncellenirken hata: $e');
      return false;
    }
  }

  /// Şifre değiştir
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Mevcut şifreyi doğrula
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Yeni şifreyi ayarla
      await user.updatePassword(newPassword);

      // Aktivite logu
      await _logUserActivity('password_changed', {
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Şifre değiştirilirken hata: $e');
      return false;
    }
  }

  /// Şifre sıfırlama e-postası gönder
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      
      // Aktivite logu
      await _logUserActivity('password_reset_email_sent', {
        'email': email,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Şifre sıfırlama e-postası gönderilirken hata: $e');
      return false;
    }
  }

  /// Oturumu kapat
  Future<bool> signOut() async {
    try {
      // Aktivite logu
      await _logUserActivity('user_signed_out', {
        'timestamp': DateTime.now().toIso8601String(),
      });

      await _auth.signOut();
      return true;
    } catch (e) {
      print('Oturum kapatılırken hata: $e');
      return false;
    }
  }

  /// Hesabı sil
  Future<bool> deleteAccount({
    required String password,
    required bool deleteData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Şifreyi doğrula
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Verileri sil (eğer isteniyorsa)
      if (deleteData) {
        await _deleteUserData(user.uid);
      }

      // Aktivite logu (son aktivite)
      await _logUserActivity('account_deleted', {
        'deleteData': deleteData,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Hesabı sil
      await user.delete();

      return true;
    } catch (e) {
      print('Hesap silinirken hata: $e');
      return false;
    }
  }

  /// Kullanıcı verilerini sil
  Future<void> _deleteUserData(String userId) async {
    try {
      // Kullanıcı koleksiyonlarını sil
      final collections = [
        'readingProgress',
        'favorites',
        'notifications',
        'userActivities',
        'settings',
      ];

      for (final collection in collections) {
        final snapshot = await _firestore
            .collection(collection)
            .where('userId', isEqualTo: userId)
            .get();

        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // Ana kullanıcı dokümanını sil
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .delete();

      print('Kullanıcı verileri silindi: $userId');
    } catch (e) {
      print('Kullanıcı verileri silinirken hata: $e');
    }
  }

  /// Kullanıcı verilerini dışa aktar
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final exportData = <String, dynamic>{
        'user': {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'emailVerified': user.emailVerified,
          'creationTime': user.metadata.creationTime?.toIso8601String(),
          'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
        },
        'profile': await _getUserProfileData(user.uid),
        'readingProgress': await _getReadingProgressData(user.uid),
        'favorites': await _getFavoritesData(user.uid),
        'notifications': await _getNotificationsData(user.uid),
        'activities': await _getActivitiesData(user.uid),
        'settings': await _getSettingsData(user.uid),
        'exportDate': DateTime.now().toIso8601String(),
        'exportVersion': '1.0',
      };

      return exportData;
    } catch (e) {
      print('Kullanıcı verileri dışa aktarılırken hata: $e');
      return {};
    }
  }

  /// Kullanıcı profil verilerini getir
  Future<Map<String, dynamic>> _getUserProfileData(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data()!;
      }
      return {};
    } catch (e) {
      print('Profil verileri getirilirken hata: $e');
      return {};
    }
  }

  /// Okuma ilerleme verilerini getir
  Future<List<Map<String, dynamic>>> _getReadingProgressData(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('readingProgress')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Okuma ilerleme verileri getirilirken hata: $e');
      return [];
    }
  }

  /// Favori verilerini getir
  Future<List<Map<String, dynamic>>> _getFavoritesData(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Favori verileri getirilirken hata: $e');
      return [];
    }
  }

  /// Bildirim verilerini getir
  Future<List<Map<String, dynamic>>> _getNotificationsData(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Bildirim verileri getirilirken hata: $e');
      return [];
    }
  }

  /// Aktivite verilerini getir
  Future<List<Map<String, dynamic>>> _getActivitiesData(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_userActivitiesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Aktivite verileri getirilirken hata: $e');
      return [];
    }
  }

  /// Ayar verilerini getir
  Future<Map<String, dynamic>> _getSettingsData(String userId) async {
    try {
      final settings = <String, dynamic>{};
      
      final collections = ['theme', 'locale', 'notifications'];
      
      for (final collection in collections) {
        final doc = await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .collection('settings')
            .doc(collection)
            .get();

        if (doc.exists) {
          settings[collection] = doc.data();
        }
      }

      return settings;
    } catch (e) {
      print('Ayar verileri getirilirken hata: $e');
      return {};
    }
  }

  /// Kullanıcı aktivitesini logla
  Future<void> _logUserActivity(String activity, Map<String, dynamic> metadata) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection(_userActivitiesCollection)
          .add({
        'userId': user.uid,
        'activity': activity,
        'metadata': metadata,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'flutter',
      });
    } catch (e) {
      print('Aktivite loglanırken hata: $e');
    }
  }

  /// Hesap istatistiklerini getir
  Future<Map<String, dynamic>> getAccountStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final stats = <String, dynamic>{
        'accountCreated': user.metadata.creationTime?.toIso8601String(),
        'lastSignIn': user.metadata.lastSignInTime?.toIso8601String(),
        'emailVerified': user.emailVerified,
        'providerData': user.providerData.map((p) => p.providerId).toList(),
      };

      // Okuma istatistikleri
      final readingSnapshot = await _firestore
          .collection('readingProgress')
          .where('userId', isEqualTo: user.uid)
          .get();

      stats['totalBooksRead'] = readingSnapshot.docs.length;

      // Favori istatistikleri
      final favoritesSnapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .get();

      stats['totalFavorites'] = favoritesSnapshot.docs.length;

      return stats;
    } catch (e) {
      print('Hesap istatistikleri getirilirken hata: $e');
      return {};
    }
  }

  /// Hesap güvenlik durumunu kontrol et
  Future<Map<String, dynamic>> getSecurityStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      return {
        'emailVerified': user.emailVerified,
        'hasPassword': user.providerData.any((p) => p.providerId == 'password'),
        'hasGoogleSignIn': user.providerData.any((p) => p.providerId == 'google.com'),
        'hasAppleSignIn': user.providerData.any((p) => p.providerId == 'apple.com'),
        'lastPasswordChange': null, // TODO: Şifre değişim tarihini takip et
        'twoFactorEnabled': false, // TODO: 2FA desteği ekle
      };
    } catch (e) {
      print('Güvenlik durumu kontrol edilirken hata: $e');
      return {};
    }
  }
} 