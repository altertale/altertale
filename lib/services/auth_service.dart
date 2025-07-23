import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Firebase Authentication Service
///
/// Firebase Auth ile kullanıcı girişi, kayıt, çıkış ve
/// oturum yönetimi işlemlerini gerçekleştirir.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current user getter
  User? get currentUser => _auth.currentUser;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// User ID getter
  String? get uid => currentUser?.uid;

  /// User email getter
  String? get userEmail => currentUser?.email;

  /// User display name getter
  String? get userDisplayName => currentUser?.displayName;

  /// User email verified status
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // ==================== AUTHENTICATION METHODS ====================

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        print('🔐 AuthService: Attempting sign in for email: $email');
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (kDebugMode) {
        print(
          '✅ AuthService: Sign in successful for: ${credential.user?.email}',
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Sign in error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Unexpected sign in error: $e');
      }
      throw 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  /// Register with email and password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      if (kDebugMode) {
        print('📝 AuthService: Attempting registration for email: $email');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
        await credential.user?.reload();
      }

      // Send email verification
      await sendEmailVerification();

      if (kDebugMode) {
        print(
          '✅ AuthService: Registration successful for: ${credential.user?.email}',
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Registration error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Unexpected registration error: $e');
      }
      throw 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      if (kDebugMode) {
        print('👋 AuthService: Signing out user: ${currentUser?.email}');
      }

      await _auth.signOut();

      if (kDebugMode) {
        print('✅ AuthService: Sign out successful');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Sign out error: $e');
      }
      throw 'Çıkış yapılırken bir hata oluştu.';
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (kDebugMode) {
        print('📧 AuthService: Sending password reset email to: $email');
      }

      await _auth.sendPasswordResetEmail(email: email.trim());

      if (kDebugMode) {
        print('✅ AuthService: Password reset email sent');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Password reset error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Unexpected password reset error: $e');
      }
      throw 'Şifre sıfırlama emaili gönderilirken bir hata oluştu.';
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      if (currentUser != null && !currentUser!.emailVerified) {
        if (kDebugMode) {
          print(
            '📧 AuthService: Sending email verification to: ${currentUser!.email}',
          );
        }

        await currentUser!.sendEmailVerification();

        if (kDebugMode) {
          print('✅ AuthService: Email verification sent');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Email verification error: $e');
      }
      throw 'Email doğrulama gönderilirken bir hata oluştu.';
    }
  }

  /// Reload user data
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
      if (kDebugMode) {
        print('🔄 AuthService: User data reloaded');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: User reload error: $e');
      }
    }
  }

  /// Update user display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      if (kDebugMode) {
        print('✏️ AuthService: Updating display name to: $displayName');
      }

      await currentUser?.updateDisplayName(displayName.trim());
      await reloadUser();

      if (kDebugMode) {
        print('✅ AuthService: Display name updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Display name update error: $e');
      }
      throw 'İsim güncellenirken bir hata oluştu.';
    }
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      if (kDebugMode) {
        print('✏️ AuthService: Updating email to: $newEmail');
      }

      await currentUser?.verifyBeforeUpdateEmail(newEmail.trim());

      if (kDebugMode) {
        print('✅ AuthService: Email update verification sent');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Email update error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Unexpected email update error: $e');
      }
      throw 'Email güncellenirken bir hata oluştu.';
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      if (kDebugMode) {
        print('🔒 AuthService: Updating password');
      }

      await currentUser?.updatePassword(newPassword);

      if (kDebugMode) {
        print('✅ AuthService: Password updated');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Password update error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Unexpected password update error: $e');
      }
      throw 'Şifre güncellenirken bir hata oluştu.';
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      if (kDebugMode) {
        print('🗑️ AuthService: Deleting user account: ${currentUser?.email}');
      }

      await currentUser?.delete();

      if (kDebugMode) {
        print('✅ AuthService: Account deleted');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(
          '❌ AuthService: Account deletion error: ${e.code} - ${e.message}',
        );
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Unexpected account deletion error: $e');
      }
      throw 'Hesap silinirken bir hata oluştu.';
    }
  }

  /// Re-authenticate user
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      if (currentUser?.email == null) {
        throw 'Kullanıcı bilgisi bulunamadı.';
      }

      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );

      await currentUser!.reauthenticateWithCredential(credential);

      if (kDebugMode) {
        print('✅ AuthService: Re-authentication successful');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(
          '❌ AuthService: Re-authentication error: ${e.code} - ${e.message}',
        );
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthService: Unexpected re-authentication error: $e');
      }
      throw 'Yeniden kimlik doğrulama başarısız oldu.';
    }
  }

  // ==================== HELPER METHODS ====================

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu email adresi ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre girdiniz.';
      case 'email-already-in-use':
        return 'Bu email adresi zaten kullanılıyor.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalı.';
      case 'invalid-email':
        return 'Geçersiz email adresi.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda izin verilmiyor.';
      case 'invalid-credential':
        return 'Geçersiz kullanıcı bilgileri.';
      case 'account-exists-with-different-credential':
        return 'Bu email adresi farklı bir giriş yöntemi ile kayıtlı.';
      case 'requires-recent-login':
        return 'Bu işlem için yeniden giriş yapmanız gerekiyor.';
      case 'provider-already-linked':
        return 'Bu hesap zaten bağlanmış.';
      case 'no-such-provider':
        return 'Bu giriş sağlayıcısı bulunamadı.';
      case 'invalid-user-token':
        return 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin.';
      case 'internal-error':
        return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
      default:
        return e.message ?? 'Bilinmeyen bir hata oluştu.';
    }
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    // At least 6 characters, 1 uppercase, 1 lowercase, 1 number
    return password.length >= 6 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  /// Get password strength message
  static String getPasswordStrengthMessage(String password) {
    if (password.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Şifre en az bir büyük harf içermeli';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Şifre en az bir küçük harf içermeli';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Şifre en az bir rakam içermeli';
    }
    return 'Güçlü şifre';
  }
}
