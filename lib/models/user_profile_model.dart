import 'package:cloud_firestore/cloud_firestore.dart';

/// User Profile Model
///
/// Kullanıcının profil bilgilerini temsil eden model
class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String? profileImageUrl;
  final DateTime createdAt; // Restore non-nullable
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.profileImageUrl,
    required this.createdAt, // Restore required
    this.updatedAt,
    this.metadata,
  });

  /// Create UserProfile from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile.fromMap(data, doc.id);
  }

  /// Create UserProfile from Map with ID
  factory UserProfile.fromMap(Map<String, dynamic> map, [String? id]) {
    return UserProfile(
      id: id ?? map['id'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String?,
      // Restore original createdAt handling
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt), // Restore original
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'metadata': metadata,
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  /// Copy with modifications
  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get display name (fallback to email if fullName is empty)
  String get displayName {
    if (fullName.trim().isNotEmpty) {
      return fullName.trim();
    }
    return email.split('@').first;
  }

  /// Get initials for avatar
  String get initials {
    final name = displayName;
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  /// Check if profile is complete
  bool get isComplete {
    return fullName.trim().isNotEmpty && email.trim().isNotEmpty;
  }

  /// Demo user profile for testing
  static UserProfile demo() {
    return UserProfile(
      id: 'demo-user-123',
      fullName: 'Demo Kullanıcı',
      email: 'demo@test.com',
      profileImageUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      metadata: {
        'isDemoUser': true,
        'source': 'demo_creation',
        'version': '1.0',
      },
    );
  }

  /// Validation
  bool isValid() {
    return id.isNotEmpty && email.trim().isNotEmpty && _isValidEmail(email);
  }

  /// Get validation error message
  String? getValidationError() {
    if (id.isEmpty) return 'Kullanıcı ID boş olamaz';
    if (email.trim().isEmpty) return 'E-posta boş olamaz';
    if (!_isValidEmail(email)) return 'Geçersiz e-posta formatı';
    return null;
  }

  /// Private email validation helper
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, fullName: $fullName, email: $email, isComplete: $isComplete)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
