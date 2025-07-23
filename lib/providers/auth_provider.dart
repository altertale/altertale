import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Mock User class for demo mode
class MockUser {
  final String uid;
  final String email;
  final String displayName;
  final bool emailVerified;

  MockUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.emailVerified,
  });
}

/// Authentication Provider
///
/// Manages authentication state using ChangeNotifier pattern
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // Auth state
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Demo mode for testing
  bool _isDemoMode = false;
  User? _demoUser;

  // Getters
  User? get user => _user;

  // Mock user for services that need Firebase User object in demo mode
  dynamic get currentUser => _isDemoMode ? _createMockUser() : _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null || _isDemoMode;
  bool get isInitialized => _isInitialized;
  bool get isEmailVerified =>
      _user?.emailVerified ?? _isDemoMode; // Demo mode is always verified
  bool get isDemoMode => _isDemoMode;

  // User info getters
  String get userId => _isDemoMode ? 'demo-user-123' : (_user?.uid ?? '');
  String get userEmail => _isDemoMode ? 'demo@test.com' : (_user?.email ?? '');
  String get userDisplayName =>
      _isDemoMode ? 'Demo User' : (_user?.displayName ?? '');

  /// Create a mock user object for demo mode
  dynamic _createMockUser() {
    return MockUser(
      uid: 'demo-user-123',
      email: 'demo@test.com',
      displayName: 'Demo User',
      emailVerified: true,
    );
  }

  AuthProvider() {
    _initAuthListener();
  }

  /// Initialize auth state listener
  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      if (kDebugMode) {
        print('🔥 AuthProvider: Auth state changed - User: ${user?.email}');
      }

      _user = user;
      _isInitialized = true;
      _clearError();
      notifyListeners();
    });
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // ==================== AUTHENTICATION METHODS ====================

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (kDebugMode) {
        print('🔐 AuthProvider: Attempting sign in for: $email');
      }

      await _authService.signInWithEmail(email: email, password: password);

      if (kDebugMode) {
        print('✅ AuthProvider: Sign in successful');
      }

      return true;
    } catch (e) {
      final errorMessage = e.toString();
      if (kDebugMode) {
        print('❌ AuthProvider: Sign in error: $errorMessage');
      }
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register with email and password
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (kDebugMode) {
        print('📝 AuthProvider: Attempting registration for: $email');
      }

      await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (kDebugMode) {
        print('✅ AuthProvider: Registration successful');
      }

      return true;
    } catch (e) {
      final errorMessage = e.toString();
      if (kDebugMode) {
        print('❌ AuthProvider: Registration error: $errorMessage');
      }
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out (works for both Firebase and demo mode)
  Future<void> signOut() async {
    if (kDebugMode) {
      print('🚪 AuthProvider: Signing out (demo mode: $_isDemoMode)');
    }

    _setLoading(true);
    _clearError();

    try {
      if (_isDemoMode) {
        _isDemoMode = false;
        _demoUser = null;
        _user = null;
      } else {
        await _authService.signOut();
      }

      if (kDebugMode) {
        print('✅ AuthProvider: Sign out successful');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthProvider: Sign out error: $e');
      }
      _setError('Çıkış yapılırken hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Demo login for testing (bypasses Firebase Auth)
  Future<void> signInDemoMode() async {
    if (kDebugMode) {
      print('🎭 AuthProvider: Signing in with demo mode');
    }

    _setLoading(true);
    _clearError();

    try {
      // Create a fake user for demo
      _isDemoMode = true;
      _demoUser = null; // We'll use the _user field differently

      // For demo mode, we'll simulate a logged-in state
      // Since we can't create a Firebase User directly, we'll set _user to null
      // and override isLoggedIn getter
      _user = null; // Firebase user will be null in demo mode

      if (kDebugMode) {
        print('✅ AuthProvider: Demo login successful');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthProvider: Demo login error: $e');
      }
      _setError('Demo giriş başarısız: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      if (kDebugMode) {
        print('📧 AuthProvider: Sending password reset email to: $email');
      }

      await _authService.sendPasswordResetEmail(email);

      if (kDebugMode) {
        print('✅ AuthProvider: Password reset email sent');
      }

      return true;
    } catch (e) {
      final errorMessage = e.toString();
      if (kDebugMode) {
        print('❌ AuthProvider: Password reset error: $errorMessage');
      }
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      _setLoading(true);
      _clearError();

      if (kDebugMode) {
        print('📧 AuthProvider: Sending email verification');
      }

      await _authService.sendEmailVerification();

      if (kDebugMode) {
        print('✅ AuthProvider: Email verification sent');
      }

      return true;
    } catch (e) {
      final errorMessage = e.toString();
      if (kDebugMode) {
        print('❌ AuthProvider: Email verification error: $errorMessage');
      }
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reload user data
  Future<void> reloadUser() async {
    try {
      if (kDebugMode) {
        print('🔄 AuthProvider: Reloading user data');
      }

      await _authService.reloadUser();

      // Update user from auth service
      _user = _authService.currentUser;
      notifyListeners();

      if (kDebugMode) {
        print('✅ AuthProvider: User data reloaded');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthProvider: User reload error: $e');
      }
    }
  }

  /// Update display name
  Future<bool> updateDisplayName(String displayName) async {
    try {
      _setLoading(true);
      _clearError();

      if (kDebugMode) {
        print('✏️ AuthProvider: Updating display name to: $displayName');
      }

      await _authService.updateDisplayName(displayName);
      await reloadUser();

      if (kDebugMode) {
        print('✅ AuthProvider: Display name updated');
      }

      return true;
    } catch (e) {
      final errorMessage = e.toString();
      if (kDebugMode) {
        print('❌ AuthProvider: Display name update error: $errorMessage');
      }
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update email
  Future<bool> updateEmail(String newEmail) async {
    try {
      _setLoading(true);
      _clearError();

      if (kDebugMode) {
        print('✏️ AuthProvider: Updating email to: $newEmail');
      }

      await _authService.updateEmail(newEmail);

      if (kDebugMode) {
        print('✅ AuthProvider: Email update verification sent');
      }

      return true;
    } catch (e) {
      final errorMessage = e.toString();
      if (kDebugMode) {
        print('❌ AuthProvider: Email update error: $errorMessage');
      }
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update password
  Future<bool> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      _clearError();

      if (kDebugMode) {
        print('🔒 AuthProvider: Updating password');
      }

      await _authService.updatePassword(newPassword);

      if (kDebugMode) {
        print('✅ AuthProvider: Password updated');
      }

      return true;
    } catch (e) {
      final errorMessage = e.toString();
      if (kDebugMode) {
        print('❌ AuthProvider: Password update error: $errorMessage');
      }
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();

      if (kDebugMode) {
        print('🗑️ AuthProvider: Deleting account');
      }

      await _authService.deleteAccount();

      if (kDebugMode) {
        print('✅ AuthProvider: Account deleted');
      }

      return true;
    } catch (e) {
      final errorMessage = e.toString();
      if (kDebugMode) {
        print('❌ AuthProvider: Account deletion error: $errorMessage');
      }
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Re-authenticate with password
  Future<bool> reauthenticateWithPassword(String password) async {
    try {
      _setLoading(true);
      _clearError();

      if (kDebugMode) {
        print('🔐 AuthProvider: Re-authenticating user');
      }

      await _authService.reauthenticateWithPassword(password);

      if (kDebugMode) {
        print('✅ AuthProvider: Re-authentication successful');
      }

      return true;
    } catch (e) {
      final errorMessage = e.toString();
      if (kDebugMode) {
        print('❌ AuthProvider: Re-authentication error: $errorMessage');
      }
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==================== VALIDATION METHODS ====================

  /// Validate email format
  static bool isValidEmail(String email) {
    return AuthService.isValidEmail(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    return AuthService.isValidPassword(password);
  }

  /// Get password strength message
  static String getPasswordStrengthMessage(String password) {
    return AuthService.getPasswordStrengthMessage(password);
  }

  // ==================== UTILITY METHODS ====================

  /// Check if current user needs email verification
  bool needsEmailVerification() {
    return _user != null && !_user!.emailVerified;
  }

  /// Get user initials for avatar display
  String getUserInitials() {
    if (userDisplayName.isNotEmpty) {
      final names = userDisplayName.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else {
        return names[0][0].toUpperCase();
      }
    } else if (userEmail.isNotEmpty) {
      return userEmail[0].toUpperCase();
    }
    return 'U';
  }

  /// Get user display text
  String getUserDisplayText() {
    if (userDisplayName.isNotEmpty) {
      return userDisplayName;
    } else if (userEmail.isNotEmpty) {
      return userEmail;
    }
    return 'Kullanıcı';
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('🔥 AuthProvider: Disposing');
    }
    super.dispose();
  }
}
