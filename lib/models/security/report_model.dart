import 'package:cloud_firestore/cloud_firestore.dart';

/// Rapor türü
enum ReportType {
  spam('Spam'),
  inappropriate('Uygunsuz İçerik'),
  harassment('Taciz'),
  fake('Sahte Hesap'),
  copyright('Telif Hakkı İhlali'),
  violence('Şiddet'),
  other('Diğer');

  const ReportType(this.displayName);
  final String displayName;
}

/// Rapor durumu
enum ReportStatus {
  pending('Beklemede'),
  underReview('İnceleniyor'),
  resolved('Çözüldü'),
  dismissed('Reddedildi'),
  escalated('Yükseltildi');

  const ReportStatus(this.displayName);
  final String displayName;
}

/// Rapor önceliği
enum ReportPriority {
  low('Düşük'),
  medium('Orta'),
  high('Yüksek'),
  urgent('Acil');

  const ReportPriority(this.displayName);
  final String displayName;
}

/// Rapor modeli
class Report {
  final String id;
  final String reporterId; // Rapor eden kullanıcı
  final String reportedUserId; // Rapor edilen kullanıcı
  final String? reportedContentId; // Rapor edilen içerik ID'si
  final String contentType; // comment, book, user, etc.
  final ReportType reportType;
  final ReportStatus status;
  final ReportPriority priority;
  final String description;
  final List<String> evidence; // Kanıt dosyaları (URL'ler)
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? reviewNotes;
  final String? resolution;
  final bool isResolved;
  final bool isEscalated;

  const Report({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    this.reportedContentId,
    required this.contentType,
    required this.reportType,
    this.status = ReportStatus.pending,
    this.priority = ReportPriority.medium,
    required this.description,
    this.evidence = const [],
    this.metadata = const {},
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewNotes,
    this.resolution,
    this.isResolved = false,
    this.isEscalated = false,
  });

  /// Firestore'dan model oluştur
  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      reporterId: data['reporterId'] ?? '',
      reportedUserId: data['reportedUserId'] ?? '',
      reportedContentId: data['reportedContentId'],
      contentType: data['contentType'] ?? '',
      reportType: ReportType.values.firstWhere(
        (e) => e.name == (data['reportType'] ?? 'other'),
        orElse: () => ReportType.other,
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => ReportStatus.pending,
      ),
      priority: ReportPriority.values.firstWhere(
        (e) => e.name == (data['priority'] ?? 'medium'),
        orElse: () => ReportPriority.medium,
      ),
      description: data['description'] ?? '',
      evidence: List<String>.from(data['evidence'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      reviewedAt: data['reviewedAt'] != null 
          ? (data['reviewedAt'] as Timestamp).toDate() 
          : null,
      reviewedBy: data['reviewedBy'],
      reviewNotes: data['reviewNotes'],
      resolution: data['resolution'],
      isResolved: data['isResolved'] ?? false,
      isEscalated: data['isEscalated'] ?? false,
    );
  }

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reportedContentId': reportedContentId,
      'contentType': contentType,
      'reportType': reportType.name,
      'status': status.name,
      'priority': priority.name,
      'description': description,
      'evidence': evidence,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
      'reviewNotes': reviewNotes,
      'resolution': resolution,
      'isResolved': isResolved,
      'isEscalated': isEscalated,
    };
  }

  /// Raporu güncelle
  Report copyWith({
    ReportStatus? status,
    ReportPriority? priority,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewNotes,
    String? resolution,
    bool? isResolved,
    bool? isEscalated,
  }) {
    return Report(
      id: id,
      reporterId: reporterId,
      reportedUserId: reportedUserId,
      reportedContentId: reportedContentId,
      contentType: contentType,
      reportType: reportType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      description: description,
      evidence: evidence,
      metadata: metadata,
      createdAt: createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      resolution: resolution ?? this.resolution,
      isResolved: isResolved ?? this.isResolved,
      isEscalated: isEscalated ?? this.isEscalated,
    );
  }

  /// Raporu incele
  Report review(String reviewedBy, String reviewNotes, ReportStatus status) {
    return copyWith(
      reviewedBy: reviewedBy,
      reviewNotes: reviewNotes,
      status: status,
      reviewedAt: DateTime.now(),
      isResolved: status == ReportStatus.resolved || status == ReportStatus.dismissed,
    );
  }

  /// Raporu çöz
  Report resolve(String resolution) {
    return copyWith(
      status: ReportStatus.resolved,
      resolution: resolution,
      isResolved: true,
      reviewedAt: DateTime.now(),
    );
  }

  /// Raporu reddet
  Report dismiss(String reviewNotes) {
    return copyWith(
      status: ReportStatus.dismissed,
      reviewNotes: reviewNotes,
      isResolved: true,
      reviewedAt: DateTime.now(),
    );
  }

  /// Raporu yükselt
  Report escalate() {
    return copyWith(
      status: ReportStatus.escalated,
      priority: ReportPriority.urgent,
      isEscalated: true,
    );
  }

  /// Acil rapor mu?
  bool get isUrgent => priority == ReportPriority.urgent;

  /// Yüksek öncelikli mi?
  bool get isHighPriority => priority == ReportPriority.high || priority == ReportPriority.urgent;

  /// Beklemede mi?
  bool get isPending => status == ReportStatus.pending;

  /// İnceleniyor mu?
  bool get isUnderReview => status == ReportStatus.underReview;

  /// Çözüldü mü?
  bool get isResolvedStatus => status == ReportStatus.resolved;

  /// Reddedildi mi?
  bool get isDismissed => status == ReportStatus.dismissed;

  /// Yükseltildi mi?
  bool get isEscalatedStatus => status == ReportStatus.escalated;
}

/// Rapor istatistikleri
class ReportStats {
  final int totalReports;
  final int pendingReports;
  final int underReviewReports;
  final int resolvedReports;
  final int dismissedReports;
  final int escalatedReports;
  final Map<ReportType, int> reportsByType;
  final Map<ReportPriority, int> reportsByPriority;
  final DateTime lastUpdated;

  const ReportStats({
    this.totalReports = 0,
    this.pendingReports = 0,
    this.underReviewReports = 0,
    this.resolvedReports = 0,
    this.dismissedReports = 0,
    this.escalatedReports = 0,
    this.reportsByType = const {},
    this.reportsByPriority = const {},
    required this.lastUpdated,
  });

  /// Firestore'dan model oluştur
  factory ReportStats.fromFirestore(Map<String, dynamic> data) {
    return ReportStats(
      totalReports: data['totalReports'] ?? 0,
      pendingReports: data['pendingReports'] ?? 0,
      underReviewReports: data['underReviewReports'] ?? 0,
      resolvedReports: data['resolvedReports'] ?? 0,
      dismissedReports: data['dismissedReports'] ?? 0,
      escalatedReports: data['escalatedReports'] ?? 0,
      reportsByType: Map<ReportType, int>.from(
        (data['reportsByType'] ?? {}).map(
          (key, value) => MapEntry(
            ReportType.values.firstWhere(
              (e) => e.name == key,
              orElse: () => ReportType.other,
            ),
            value as int,
          ),
        ),
      ),
      reportsByPriority: Map<ReportPriority, int>.from(
        (data['reportsByPriority'] ?? {}).map(
          (key, value) => MapEntry(
            ReportPriority.values.firstWhere(
              (e) => e.name == key,
              orElse: () => ReportPriority.medium,
            ),
            value as int,
          ),
        ),
      ),
      lastUpdated: data['lastUpdated'] != null 
          ? (data['lastUpdated'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  /// Firestore'a gönderilecek map
  Map<String, dynamic> toFirestore() {
    return {
      'totalReports': totalReports,
      'pendingReports': pendingReports,
      'underReviewReports': underReviewReports,
      'resolvedReports': resolvedReports,
      'dismissedReports': dismissedReports,
      'escalatedReports': escalatedReports,
      'reportsByType': reportsByType.map((key, value) => MapEntry(key.name, value)),
      'reportsByPriority': reportsByPriority.map((key, value) => MapEntry(key.name, value)),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Çözülme oranı
  double get resolutionRate {
    if (totalReports == 0) return 0.0;
    return (resolvedReports + dismissedReports) / totalReports;
  }

  /// Ortalama çözüm süresi (gün)
  double get averageResolutionTime {
    // Bu değer hesaplanacak
    return 0.0;
  }

  /// Acil rapor sayısı
  int get urgentReportsCount {
    return reportsByPriority[ReportPriority.urgent] ?? 0;
  }

  /// Yüksek öncelikli rapor sayısı
  int get highPriorityReportsCount {
    return (reportsByPriority[ReportPriority.high] ?? 0) + urgentReportsCount;
  }
}
