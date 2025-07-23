import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Profile Service
///
/// Kullanıcı profili yönetimi için servis sınıfı
class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Demo mode for testing - Always true to support both demo and real users
  bool get isDemoMode => true; // Enable demo mode to support all users

  // In-memory storage for demo profiles
  static final Map<String, UserProfile> _demoProfiles = {};

  /// Collection reference for user profiles
  CollectionReference get _profilesCollection =>
      _firestore.collection('userProfiles');

  /// Initialize demo user profile
  void _initializeDemoProfile() {
    if (!_demoProfiles.containsKey('demo-user-123')) {
      // Restore normal demo profile
      _demoProfiles['demo-user-123'] = UserProfile.demo();
      if (kDebugMode) {
        print('👤 ProfileService: Demo profile initialized');
      }
    }
  }

  /// Initialize demo profile for any user
  void _initializeDemoProfileForUser(String userId) {
    if (!_demoProfiles.containsKey(userId)) {
      // Get real user info from Firebase Auth
      String userEmail = 'demo@test.com';
      String userName = 'Demo User';

      // Try to get real user info from Firebase Auth current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        userEmail = currentUser.email ?? 'demo@test.com';
        userName =
            currentUser.displayName ??
            currentUser.email?.split('@')[0] ??
            'User';

        // If displayName is null, create a name from email
        if (currentUser.displayName == null && currentUser.email != null) {
          final emailPart = currentUser.email!.split('@')[0];
          // Convert email part to proper name format
          userName = emailPart
              .split('.')
              .map(
                (part) => part.isEmpty
                    ? ''
                    : part[0].toUpperCase() + part.substring(1),
              )
              .join(' ');
        }
      }

      _demoProfiles[userId] = UserProfile(
        id: userId,
        fullName: userName,
        email: userEmail,
        profileImageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {},
      );
      if (kDebugMode) {
        print(
          '👤 ProfileService: Demo profile initialized for user: $userId ($userName)',
        );
      }
    }
  }

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    if (kDebugMode) {
      print('👤 ProfileService: Getting profile for user: $userId');
    }

    // Demo mode - return in-memory profile
    if (isDemoMode) {
      _initializeDemoProfileForUser(userId);
      final profile = _demoProfiles[userId];
      if (kDebugMode) {
        print(
          '👤 ProfileService: Demo profile retrieved: ${profile?.displayName}',
        );
      }
      return profile;
    }

    try {
      final doc = await _profilesCollection.doc(userId).get();
      if (doc.exists) {
        final profile = UserProfile.fromFirestore(doc);
        if (kDebugMode) {
          print('👤 ProfileService: Profile retrieved: ${profile.displayName}');
        }
        return profile;
      } else {
        if (kDebugMode) {
          print('👤 ProfileService: Profile not found for user: $userId');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ProfileService: Error getting profile: $e');
      }
      rethrow;
    }
  }

  /// Get user profile as stream
  Stream<UserProfile?> getUserProfileStream(String userId) {
    if (kDebugMode) {
      print('👤 ProfileService: Starting profile stream for user: $userId');
    }

    // Demo mode - return stream from in-memory storage
    if (isDemoMode) {
      _initializeDemoProfileForUser(userId);
      return Stream.periodic(const Duration(milliseconds: 100), (count) {
        return _demoProfiles[userId];
      }).take(1);
    }

    return _profilesCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        final profile = UserProfile.fromFirestore(doc);
        if (kDebugMode) {
          print('👤 ProfileService: Profile updated: ${profile.displayName}');
        }
        return profile;
      }
      return null;
    });
  }

  /// Update user profile
  Future<UserProfile> updateUserProfile({
    required String userId,
    String? fullName,
    String? profileImageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    if (kDebugMode) {
      print('👤 ProfileService: Updating profile for user: $userId');
      print('📝 ProfileService: New name: $fullName');
      print('📸 ProfileService: New image: $profileImageUrl');
    }

    try {
      // Get current profile
      final currentProfile = await getUserProfile(userId);
      if (currentProfile == null) {
        throw Exception('Kullanıcı profili bulunamadı');
      }

      // Create updated profile
      final updatedProfile = currentProfile.copyWith(
        fullName: fullName ?? currentProfile.fullName,
        profileImageUrl: profileImageUrl ?? currentProfile.profileImageUrl,
        updatedAt: DateTime.now(),
        metadata: metadata ?? currentProfile.metadata,
      );

      // Validate updated profile
      if (!updatedProfile.isValid()) {
        final error = updatedProfile.getValidationError();
        throw Exception('Profil güncellemesi geçersiz: $error');
      }

      // Demo mode - update in-memory storage
      if (isDemoMode) {
        _demoProfiles[userId] = updatedProfile;
        if (kDebugMode) {
          print('✅ ProfileService: Demo profile updated successfully');
        }
        return updatedProfile;
      }

      // Real mode - update Firestore
      await _profilesCollection.doc(userId).update(updatedProfile.toMap());

      if (kDebugMode) {
        print('✅ ProfileService: Profile updated successfully');
      }

      return updatedProfile;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ProfileService: Error updating profile: $e');
      }
      rethrow;
    }
  }

  /// Create new user profile
  Future<UserProfile> createUserProfile({
    required String userId,
    required String email,
    String? fullName,
    String? profileImageUrl,
    Map<String, dynamic>? metadata,
  }) async {
    if (kDebugMode) {
      print('👤 ProfileService: Creating profile for user: $userId');
    }

    try {
      final profile = UserProfile(
        id: userId,
        fullName: fullName ?? '',
        email: email,
        profileImageUrl: profileImageUrl,
        createdAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      // Validate profile
      if (!profile.isValid()) {
        final error = profile.getValidationError();
        throw Exception('Profil oluşturma geçersiz: $error');
      }

      // Demo mode - store in memory
      if (isDemoMode) {
        _demoProfiles[userId] = profile;
        if (kDebugMode) {
          print('✅ ProfileService: Demo profile created successfully');
        }
        return profile;
      }

      // Real mode - create in Firestore
      await _profilesCollection.doc(userId).set(profile.toMap());

      if (kDebugMode) {
        print('✅ ProfileService: Profile created successfully');
      }

      return profile;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ProfileService: Error creating profile: $e');
      }
      rethrow;
    }
  }

  /// Upload profile image (mock implementation)
  Future<String> uploadProfileImage({
    required String userId,
    required String imagePath,
  }) async {
    if (kDebugMode) {
      print('📸 ProfileService: Uploading profile image for user: $userId');
      print('📁 ProfileService: Image path: $imagePath');
    }

    try {
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));

      // Generate mock image URL
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomId = Random().nextInt(10000);
      final mockImageUrl =
          'https://api.dicebear.com/7.x/avataaars/svg?seed=$userId&size=200&timestamp=$timestamp&id=$randomId';

      if (kDebugMode) {
        print('✅ ProfileService: Profile image uploaded successfully');
        print('🔗 ProfileService: Image URL: $mockImageUrl');
      }

      return mockImageUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ProfileService: Error uploading profile image: $e');
      }
      rethrow;
    }
  }

  /// Delete user profile
  Future<void> deleteUserProfile(String userId) async {
    if (kDebugMode) {
      print('👤 ProfileService: Deleting profile for user: $userId');
    }

    try {
      // Demo mode - remove from memory
      if (isDemoMode) {
        _demoProfiles.remove(userId);
        if (kDebugMode) {
          print('✅ ProfileService: Demo profile deleted successfully');
        }
        return;
      }

      // Real mode - delete from Firestore
      await _profilesCollection.doc(userId).delete();

      if (kDebugMode) {
        print('✅ ProfileService: Profile deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ProfileService: Error deleting profile: $e');
      }
      rethrow;
    }
  }

  /// Check if user profile exists
  Future<bool> profileExists(String userId) async {
    try {
      // Demo mode - check in-memory storage
      if (isDemoMode) {
        _initializeDemoProfileForUser(userId);
        return _demoProfiles.containsKey(userId);
      }

      // Real mode - check Firestore
      final doc = await _profilesCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ProfileService: Error checking profile existence: $e');
      }
      return false;
    }
  }

  /// Get all demo profiles (for testing)
  Map<String, UserProfile> getDemoProfiles() {
    if (!isDemoMode) return {};
    _initializeDemoProfile();
    return Map.from(_demoProfiles);
  }

  /// Clear demo profiles (for testing)
  void clearDemoProfiles() {
    if (isDemoMode) {
      _demoProfiles.clear();
      if (kDebugMode) {
        print('🧹 ProfileService: Demo profiles cleared');
      }
    }
  }
}
