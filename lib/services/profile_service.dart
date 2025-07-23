import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/profile_model.dart';
import '../constants/app_constants.dart';

/// Profil yönetimi servisi
/// Firestore ve Firebase Storage ile profil işlemlerini yönetir
class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker();

  /// Kullanıcının profil bilgilerini Firestore'dan alır (ProfileModel olarak)
  Future<ProfileModel?> getProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return ProfileModel.fromFirestore(doc);
      }

      // Profil yoksa varsayılan profil oluştur
      final user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        final defaultProfile = ProfileModel.defaultProfile(
          uid,
          name: user.displayName,
          email: user.email,
        );
        await saveProfile(defaultProfile);
        return defaultProfile;
      }

      return null;
    } catch (e) {
      throw Exception('Profil bilgileri alınamadı: $e');
    }
  }

  /// Profil bilgilerini Firestore'a kaydeder
  Future<void> saveProfile(ProfileModel profile) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(profile.uid)
          .set(profile.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Profil kaydedilemedi: $e');
    }
  }

  /// Profil bilgilerini günceller
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(profile.uid)
          .update(profile.toFirestore());
    } catch (e) {
      throw Exception('Profil güncellenemedi: $e');
    }
  }

  /// Profil fotoğrafını yükler
  Future<String?> uploadProfileImage(String uid, XFile imageFile) async {
    try {
      // Dosya referansı oluştur
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');

      // Dosyayı yükle
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;

      // Download URL'ini al
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Profil fotoğrafı yüklenemedi: $e');
    }
  }

  /// Profil fotoğrafını siler
  Future<void> deleteProfileImage(String uid) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');

      await ref.delete();
    } catch (e) {
      // Hata durumunda sessizce geç (dosya zaten yoksa normal)
      print('Profil fotoğrafı silinemedi: $e');
    }
  }

  /// Kullanıcı adının kullanılabilir olup olmadığını kontrol eder
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final query = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      return query.docs.isEmpty;
    } catch (e) {
      throw Exception('Kullanıcı adı kontrol edilemedi: $e');
    }
  }

  /// Galeriden fotoğraf seçer
  Future<XFile?> pickImageFromGallery() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
    } catch (e) {
      throw Exception('Fotoğraf seçilemedi: $e');
    }
  }

  /// Kameradan fotoğraf çeker
  Future<XFile?> takePhotoWithCamera() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
    } catch (e) {
      throw Exception('Fotoğraf çekilemedi: $e');
    }
  }

  /// Profil istatistiklerini getirir
  Future<Map<String, dynamic>> getProfileStats(String uid) async {
    try {
      // Bu kısım gerçek istatistikleri getirmeli
      // Şimdilik örnek veri döndürüyoruz
      return {
        'totalBooksRead': 0,
        'totalReadingTime': 0,
        'totalPointsEarned': 0,
        'totalBooksPurchased': 0,
        'totalBooksFavorited': 0,
        'totalPointsSpent': 0,
        'averageRating': 0.0,
        'currentStreak': 0,
        'longestStreak': 0,
      };
    } catch (e) {
      throw Exception('Profil istatistikleri alınamadı: $e');
    }
  }

  /// Hesabı siler
  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı bulunamadı');
      }

      // Önce şifreyi doğrula
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Profil fotoğrafını sil
      await deleteProfileImage(user.uid);

      // Firestore'dan profil verilerini sil
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();

      // Firebase Auth'dan hesabı sil
      await user.delete();
    } catch (e) {
      throw Exception('Hesap silinemedi: $e');
    }
  }

  /// Şifre değiştirir
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı bulunamadı');
      }

      // Mevcut şifreyi doğrula
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Yeni şifreyi ayarla
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Şifre değiştirilemedi: $e');
    }
  }

  /// Kullanıcı verilerini dışa aktarır
  Future<Map<String, dynamic>> exportUserData(String uid) async {
    try {
      final profile = await getProfile(uid);
      final stats = await getProfileStats(uid);

      return {
        'profile': profile?.toFirestore(),
        'stats': stats,
        'exportDate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Kullanıcı verileri dışa aktarılamadı: $e');
    }
  }
}
