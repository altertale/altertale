import 'package:cloud_firestore/cloud_firestore.dart';

/// Kullanıcı rolü
enum UserRole {
  user('Kullanıcı'),
  editor('Editör'),
  admin('Yönetici'),
  superAdmin('Süper Yönetici');

  const UserRole(this.displayName);
  final String displayName;

  /// Rol yetkilerini kontrol et
  bool hasPermission(String permission) {
    switch (this) {
      case UserRole.superAdmin:
        return true; // Tüm yetkilere sahip
      case UserRole.admin:
        return permission != 'super_admin_only';
      case UserRole.editor:
        return ['read_content', 'edit_content', 'moderate_content'].contains(permission);
      case UserRole.user:
        return ['read_content', 'create_content'].contains(permission);
    }
  }
}

/// Güvenlik durumu
enum SecurityStatus {
  normal('Normal'),
  suspicious('Şüpheli'),
  flagged('İşaretli'),
  banned('Yasaklı'),
  deleted('Silinmiş');

  const SecurityStatus(this.displayName);
  final String displayName;
}

/// Oturum bilgileri modeli
class UserSession {
  final String id;
  final String userId;
  final String deviceId;
  final String deviceName;
  final String deviceType; // mobile, tablet, desktop, web
  final String ipAddress;
  final String userAgent;
  final String location; // Şehir/Ülke
  final DateTime loginTime;
  final DateTime? lastActivityTime;
  final DateTime? logoutTime;
  final bool isActive;
  final bool isCurrentSession;

  const UserSession({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.ipAddress,
    required this.userAgent,
    required this.location,
    required this.loginTime,
    this.lastActivityTime,
    this.logoutTime,
    this.isActive = true,
    this.isCurrentSession = false,
  });

  /// Firestore'dan model oluştur
  factory UserSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSession(
      id: doc.id,
      userId: data['userId'] ?? '',
      deviceId: data['deviceId'] ?? '',
      deviceName: data['deviceName'] ?? '',
      deviceType: data['deviceType'] ?? '',
      ipAddress: data['ipAddress'] ?? '',
      userAgent: data['userAgent'] ?? '',
      location: data['location'] ?? '',
      loginTime: (data['loginTime'] as Timestamp).toDate(),
      lastActivityTime: data['lastActivityTime'] != null 
          ? (data['lastActivityTime'] as Timestamp).toDate() 
          : null,
      logoutTime: data['logoutTime'] != null 
          ? (data['logoutTime'] as Timestamp).toDate() 
          : null,
      isActive: data['isActive'] ?? true,
      isCurrentSession: data['isCurrentSession'] ?? false,
    );
  }

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'location': location,
      'loginTime': Timestamp.fromDate(loginTime),
      'lastActivityTime': lastActivityTime != null 
          ? Timestamp.fromDate(lastActivityTime!) 
          : null,
      'logoutTime': logoutTime != null 
          ? Timestamp.fromDate(logoutTime!) 
          : null,
      'isActive': isActive,
      'isCurrentSession': isCurrentSession,
    };
  }

  /// Oturumu güncelle
  UserSession copyWith({
    DateTime? lastActivityTime,
    DateTime? logoutTime,
    bool? isActive,
    bool? isCurrentSession,
  }) {
    return UserSession(
      id: id,
      userId: userId,
      deviceId: deviceId,
      deviceName: deviceName,
      deviceType: deviceType,
      ipAddress: ipAddress,
      userAgent: userAgent,
      location: location,
      loginTime: loginTime,
      lastActivityTime: lastActivityTime ?? this.lastActivityTime,
      logoutTime: logoutTime ?? this.logoutTime,
      isActive: isActive ?? this.isActive,
      isCurrentSession: isCurrentSession ?? this.isCurrentSession,
    );
  }

  /// Oturum süresi
  Duration get sessionDuration {
    final endTime = logoutTime ?? DateTime.now();
    return endTime.difference(loginTime);
  }

  /// Son aktivite süresi
  Duration? get lastActivityDuration {
    if (lastActivityTime == null) return null;
    return DateTime.now().difference(lastActivityTime!);
  }

  /// Oturum aktif mi?
  bool get isSessionActive => isActive && logoutTime == null;
}

/// Güvenlik olayı modeli
class SecurityEvent {
  final String id;
  final String userId;
  final String eventType; // login_attempt, suspicious_activity, abuse_report, etc.
  final String description;
  final String severity; // low, medium, high, critical
  final String ipAddress;
  final String deviceId;
  final String userAgent;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final bool isResolved;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? resolution;

  const SecurityEvent({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.description,
    required this.severity,
    required this.ipAddress,
    required this.deviceId,
    required this.userAgent,
    required this.metadata,
    required this.timestamp,
    this.isResolved = false,
    this.resolvedBy,
    this.resolvedAt,
    this.resolution,
  });

  /// Firestore'dan model oluştur
  factory SecurityEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SecurityEvent(
      id: doc.id,
      userId: data['userId'] ?? '',
      eventType: data['eventType'] ?? '',
      description: data['description'] ?? '',
      severity: data['severity'] ?? 'low',
      ipAddress: data['ipAddress'] ?? '',
      deviceId: data['deviceId'] ?? '',
      userAgent: data['userAgent'] ?? '',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isResolved: data['isResolved'] ?? false,
      resolvedBy: data['resolvedBy'],
      resolvedAt: data['resolvedAt'] != null 
          ? (data['resolvedAt'] as Timestamp).toDate() 
          : null,
      resolution: data['resolution'],
    );
  }

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'eventType': eventType,
      'description': description,
      'severity': severity,
      'ipAddress': ipAddress,
      'deviceId': deviceId,
      'userAgent': userAgent,
      'metadata': metadata,
      'timestamp': Timestamp.fromDate(timestamp),
      'isResolved': isResolved,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolution': resolution,
    };
  }

  /// Olayı çöz
  SecurityEvent resolve(String resolvedBy, String resolution) {
    return SecurityEvent(
      id: id,
      userId: userId,
      eventType: eventType,
      description: description,
      severity: severity,
      ipAddress: ipAddress,
      deviceId: deviceId,
      userAgent: userAgent,
      metadata: metadata,
      timestamp: timestamp,
      isResolved: true,
      resolvedBy: resolvedBy,
      resolvedAt: DateTime.now(),
      resolution: resolution,
    );
  }

  /// Kritik seviye mi?
  bool get isCritical => severity == 'critical';

  /// Yüksek seviye mi?
  bool get isHigh => severity == 'high' || severity == 'critical';

  /// Orta seviye mi?
  bool get isMedium => severity == 'medium' || severity == 'high' || severity == 'critical';
}

/// Kullanıcı güvenlik profili
class UserSecurityProfile {
  final String userId;
  final UserRole role;
  final SecurityStatus status;
  final bool isSuspicious;
  final bool isFlagged;
  final bool isBanned;
  final bool isDeleted;
  final int failedLoginAttempts;
  final DateTime? lastFailedLogin;
  final DateTime? lockoutUntil;
  final List<String> suspiciousActivities;
  final Map<String, dynamic> securitySettings;
  final DateTime createdAt;
  final DateTime lastUpdated;

  const UserSecurityProfile({
    required this.userId,
    this.role = UserRole.user,
    this.status = SecurityStatus.normal,
    this.isSuspicious = false,
    this.isFlagged = false,
    this.isBanned = false,
    this.isDeleted = false,
    this.failedLoginAttempts = 0,
    this.lastFailedLogin,
    this.lockoutUntil,
    this.suspiciousActivities = const [],
    this.securitySettings = const {},
    required this.createdAt,
    required this.lastUpdated,
  });

  /// Varsayılan güvenlik profili
  factory UserSecurityProfile.defaultProfile(String userId) {
    final now = DateTime.now();
    return UserSecurityProfile(
      userId: userId,
      createdAt: now,
      lastUpdated: now,
    );
  }

  /// Firestore'dan model oluştur
  factory UserSecurityProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSecurityProfile(
      userId: doc.id,
      role: UserRole.values.firstWhere(
        (e) => e.name == (data['role'] ?? 'user'),
        orElse: () => UserRole.user,
      ),
      status: SecurityStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'normal'),
        orElse: () => SecurityStatus.normal,
      ),
      isSuspicious: data['isSuspicious'] ?? false,
      isFlagged: data['isFlagged'] ?? false,
      isBanned: data['isBanned'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      failedLoginAttempts: data['failedLoginAttempts'] ?? 0,
      lastFailedLogin: data['lastFailedLogin'] != null 
          ? (data['lastFailedLogin'] as Timestamp).toDate() 
          : null,
      lockoutUntil: data['lockoutUntil'] != null 
          ? (data['lockoutUntil'] as Timestamp).toDate() 
          : null,
      suspiciousActivities: List<String>.from(data['suspiciousActivities'] ?? []),
      securitySettings: Map<String, dynamic>.from(data['securitySettings'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'role': role.name,
      'status': status.name,
      'isSuspicious': isSuspicious,
      'isFlagged': isFlagged,
      'isBanned': isBanned,
      'isDeleted': isDeleted,
      'failedLoginAttempts': failedLoginAttempts,
      'lastFailedLogin': lastFailedLogin != null 
          ? Timestamp.fromDate(lastFailedLogin!) 
          : null,
      'lockoutUntil': lockoutUntil != null 
          ? Timestamp.fromDate(lockoutUntil!) 
          : null,
      'suspiciousActivities': suspiciousActivities,
      'securitySettings': securitySettings,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Güvenlik profilini güncelle
  UserSecurityProfile copyWith({
    UserRole? role,
    SecurityStatus? status,
    bool? isSuspicious,
    bool? isFlagged,
    bool? isBanned,
    bool? isDeleted,
    int? failedLoginAttempts,
    DateTime? lastFailedLogin,
    DateTime? lockoutUntil,
    List<String>? suspiciousActivities,
    Map<String, dynamic>? securitySettings,
  }) {
    return UserSecurityProfile(
      userId: userId,
      role: role ?? this.role,
      status: status ?? this.status,
      isSuspicious: isSuspicious ?? this.isSuspicious,
      isFlagged: isFlagged ?? this.isFlagged,
      isBanned: isBanned ?? this.isBanned,
      isDeleted: isDeleted ?? this.isDeleted,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      lastFailedLogin: lastFailedLogin ?? this.lastFailedLogin,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
      suspiciousActivities: suspiciousActivities ?? this.suspiciousActivities,
      securitySettings: securitySettings ?? this.securitySettings,
      createdAt: createdAt,
      lastUpdated: DateTime.now(),
    );
  }

  /// Hesap kilitli mi?
  bool get isLocked => lockoutUntil != null && lockoutUntil!.isAfter(DateTime.now());

  /// Güvenli mi?
  bool get isSecure => !isSuspicious && !isFlagged && !isBanned && !isDeleted && !isLocked;

  /// Admin mi?
  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;

  /// Editör mü?
  bool get isEditor => role == UserRole.editor || role == UserRole.admin || role == UserRole.superAdmin;

  /// Yetki kontrolü
  bool hasPermission(String permission) => role.hasPermission(permission);
}

/// Cihaz bilgileri modeli
class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String platform;
  final String version;
  final String buildNumber;
  final String deviceModel;
  final String systemVersion;
  final bool isPhysicalDevice;
  final String? deviceToken; // Push notification token

  const DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.platform,
    required this.version,
    required this.buildNumber,
    required this.deviceModel,
    required this.systemVersion,
    required this.isPhysicalDevice,
    this.deviceToken,
  });

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'platform': platform,
      'version': version,
      'buildNumber': buildNumber,
      'deviceModel': deviceModel,
      'systemVersion': systemVersion,
      'isPhysicalDevice': isPhysicalDevice,
      'deviceToken': deviceToken,
    };
  }

  /// Firestore'dan model oluştur
  factory DeviceInfo.fromFirestore(Map<String, dynamic> data) {
    return DeviceInfo(
      deviceId: data['deviceId'] ?? '',
      deviceName: data['deviceName'] ?? '',
      deviceType: data['deviceType'] ?? '',
      platform: data['platform'] ?? '',
      version: data['version'] ?? '',
      buildNumber: data['buildNumber'] ?? '',
      deviceModel: data['deviceModel'] ?? '',
      systemVersion: data['systemVersion'] ?? '',
      isPhysicalDevice: data['isPhysicalDevice'] ?? false,
      deviceToken: data['deviceToken'],
    );
  }
}
