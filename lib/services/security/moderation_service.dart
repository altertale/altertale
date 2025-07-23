import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/security/report_model.dart';

/// Moderasyon servisi
class ModerationService {
  static final ModerationService _instance = ModerationService._internal();
  factory ModerationService() => _instance;
  ModerationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Koleksiyon isimleri
  static const String _reportsCollection = 'reports';
  static const String _moderationQueueCollection = 'moderationQueue';
  static const String _moderationStatsCollection = 'moderationStats';

  // Moderasyon ayarları
  static const int _autoFlagThreshold = 3; // Aynı içerik için rapor sayısı
  static const int _autoBanThreshold = 5; // Aynı kullanıcı için rapor sayısı

  // ==================== RAPOR YÖNETİMİ ====================

  /// Rapor oluştur
  Future<void> createReport(Report report) async {
    try {
      // Raporu kaydet
      await _firestore
          .collection(_reportsCollection)
          .add(report.toFirestore());

      // Moderasyon kuyruğuna ekle
      await _addToModerationQueue(report);

      // Otomatik moderasyon kontrolü
      await _checkAutoModeration(report);

      // İstatistikleri güncelle
      await _updateModerationStats();
    } catch (e) {
      throw Exception('Rapor oluşturulurken hata oluştu: $e');
    }
  }

  /// Raporları getir
  Stream<List<Report>> getReports({
    ReportStatus? status,
    ReportPriority? priority,
    ReportType? reportType,
    int limit = 50,
  }) {
    Query query = _firestore
        .collection(_reportsCollection)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    if (priority != null) {
      query = query.where('priority', isEqualTo: priority.name);
    }

    if (reportType != null) {
      query = query.where('reportType', isEqualTo: reportType.name);
    }

    return query.limit(limit).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Report.fromFirestore(doc);
      }).toList();
    });
  }

  /// Raporu güncelle
  Future<void> updateReport(Report report) async {
    try {
      await _firestore
          .collection(_reportsCollection)
          .doc(report.id)
          .update(report.toFirestore());

      // Moderasyon kuyruğunu güncelle
      await _updateModerationQueue(report);
    } catch (e) {
      throw Exception('Rapor güncellenirken hata oluştu: $e');
    }
  }

  /// Raporu çöz
  Future<void> resolveReport(String reportId, String resolvedBy, String resolution) async {
    try {
      final doc = await _firestore
          .collection(_reportsCollection)
          .doc(reportId)
          .get();

      if (!doc.exists) {
        throw Exception('Rapor bulunamadı');
      }

      final report = Report.fromFirestore(doc);
      final resolvedReport = report.resolve(resolution);

      await updateReport(resolvedReport);

      // İlgili içeriği işaretle
      await _flagContent(report.reportedContentId, report.contentType);
    } catch (e) {
      throw Exception('Rapor çözülürken hata oluştu: $e');
    }
  }

  /// Raporu reddet
  Future<void> dismissReport(String reportId, String dismissedBy, String reason) async {
    try {
      final doc = await _firestore
          .collection(_reportsCollection)
          .doc(reportId)
          .get();

      if (!doc.exists) {
        throw Exception('Rapor bulunamadı');
      }

      final report = Report.fromFirestore(doc);
      final dismissedReport = report.dismiss(reason);

      await updateReport(dismissedReport);
    } catch (e) {
      throw Exception('Rapor reddedilirken hata oluştu: $e');
    }
  }

  /// Raporu yükselt
  Future<void> escalateReport(String reportId) async {
    try {
      final doc = await _firestore
          .collection(_reportsCollection)
          .doc(reportId)
          .get();

      if (!doc.exists) {
        throw Exception('Rapor bulunamadı');
      }

      final report = Report.fromFirestore(doc);
      final escalatedReport = report.escalate();

      await updateReport(escalatedReport);
    } catch (e) {
      throw Exception('Rapor yükseltilirken hata oluştu: $e');
    }
  }

  // ==================== MODERASYON KUYRUĞU ====================

  /// Moderasyon kuyruğunu getir
  Stream<List<Report>> getModerationQueue({
    ReportPriority? priority,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(_moderationQueueCollection)
        .where('status', whereIn: ['pending', 'underReview'])
        .orderBy('priority', descending: true)
        .orderBy('createdAt', descending: true);

    if (priority != null) {
      query = query.where('priority', isEqualTo: priority.name);
    }

    return query.limit(limit).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Report.fromFirestore(doc);
      }).toList();
    });
  }

  /// Moderasyon kuyruğuna ekle
  Future<void> _addToModerationQueue(Report report) async {
    try {
      await _firestore
          .collection(_moderationQueueCollection)
          .doc(report.id)
          .set(report.toFirestore());
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  /// Moderasyon kuyruğunu güncelle
  Future<void> _updateModerationQueue(Report report) async {
    try {
      if (report.isResolved) {
        // Çözülen raporları kuyruktan kaldır
        await _firestore
            .collection(_moderationQueueCollection)
            .doc(report.id)
            .delete();
      } else {
        // Kuyruğu güncelle
        await _firestore
            .collection(_moderationQueueCollection)
            .doc(report.id)
            .update(report.toFirestore());
      }
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  // ==================== OTOMATİK MODERASYON ====================

  /// Otomatik moderasyon kontrolü
  Future<void> _checkAutoModeration(Report newReport) async {
    try {
      // Aynı içerik için rapor sayısını kontrol et
      if (newReport.reportedContentId != null) {
        final contentReports = await _firestore
            .collection(_reportsCollection)
            .where('reportedContentId', isEqualTo: newReport.reportedContentId)
            .where('status', whereIn: ['pending', 'underReview'])
            .get();

        if (contentReports.docs.length >= _autoFlagThreshold) {
          // İçeriği otomatik olarak işaretle
          await _flagContent(newReport.reportedContentId, newReport.contentType);
        }
      }

      // Aynı kullanıcı için rapor sayısını kontrol et
      final userReports = await _firestore
          .collection(_reportsCollection)
          .where('reportedUserId', isEqualTo: newReport.reportedUserId)
          .where('status', whereIn: ['pending', 'underReview'])
          .get();

      if (userReports.docs.length >= _autoBanThreshold) {
        // Kullanıcıyı otomatik olarak yasakla
        await _banUser(newReport.reportedUserId);
      }
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  /// İçeriği işaretle
  Future<void> _flagContent(String? contentId, String contentType) async {
    if (contentId == null) return;

    try {
      // İçerik türüne göre koleksiyonu belirle
      String collectionName;
      switch (contentType) {
        case 'comment':
          collectionName = 'comments';
          break;
        case 'book':
          collectionName = 'books';
          break;
        case 'user':
          collectionName = 'users';
          break;
        default:
          return;
      }

      // İçeriği işaretle
      await _firestore
          .collection(collectionName)
          .doc(contentId)
          .update({
        'isFlagged': true,
        'flaggedAt': FieldValue.serverTimestamp(),
        'flaggedReason': 'Multiple reports',
      });
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  /// Kullanıcıyı yasakla
  Future<void> _banUser(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'isBanned': true,
        'bannedAt': FieldValue.serverTimestamp(),
        'bannedReason': 'Multiple abuse reports',
      });
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  // ==================== MODERASYON İSTATİSTİKLERİ ====================

  /// Moderasyon istatistiklerini getir
  Future<ReportStats> getModerationStats() async {
    try {
      final doc = await _firestore
          .collection(_moderationStatsCollection)
          .doc('stats')
          .get();

      if (doc.exists) {
        return ReportStats.fromFirestore(doc.data()!);
      } else {
        return ReportStats(lastUpdated: DateTime.now());
      }
    } catch (e) {
      return ReportStats(lastUpdated: DateTime.now());
    }
  }

  /// Moderasyon istatistiklerini güncelle
  Future<void> _updateModerationStats() async {
    try {
      final reports = await _firestore
          .collection(_reportsCollection)
          .get();

      int totalReports = 0;
      int pendingReports = 0;
      int underReviewReports = 0;
      int resolvedReports = 0;
      int dismissedReports = 0;
      int escalatedReports = 0;
      final reportsByType = <ReportType, int>{};
      final reportsByPriority = <ReportPriority, int>{};

      for (final doc in reports.docs) {
        final report = Report.fromFirestore(doc);
        totalReports++;

        switch (report.status) {
          case ReportStatus.pending:
            pendingReports++;
            break;
          case ReportStatus.underReview:
            underReviewReports++;
            break;
          case ReportStatus.resolved:
            resolvedReports++;
            break;
          case ReportStatus.dismissed:
            dismissedReports++;
            break;
          case ReportStatus.escalated:
            escalatedReports++;
            break;
        }

        // Tür bazında sayım
        reportsByType[report.reportType] = (reportsByType[report.reportType] ?? 0) + 1;

        // Öncelik bazında sayım
        reportsByPriority[report.priority] = (reportsByPriority[report.priority] ?? 0) + 1;
      }

      final stats = ReportStats(
        totalReports: totalReports,
        pendingReports: pendingReports,
        underReviewReports: underReviewReports,
        resolvedReports: resolvedReports,
        dismissedReports: dismissedReports,
        escalatedReports: escalatedReports,
        reportsByType: reportsByType,
        reportsByPriority: reportsByPriority,
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection(_moderationStatsCollection)
          .doc('stats')
          .set(stats.toFirestore());
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  // ==================== RAPOR ANALİZİ ====================

  /// Rapor analizi
  Future<Map<String, dynamic>> analyzeReports() async {
    try {
      final reports = await _firestore
          .collection(_reportsCollection)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: 30)),
          ))
          .get();

      final analysis = <String, dynamic>{
        'totalReports': reports.docs.length,
        'reportsByType': <String, int>{},
        'reportsByPriority': <String, int>{},
        'reportsByStatus': <String, int>{},
        'topReportedUsers': <String, int>{},
        'topReportedContent': <String, int>{},
        'averageResolutionTime': 0.0,
      };

      final userReports = <String, int>{};
      final contentReports = <String, int>{};
      final resolutionTimes = <int>[];

      for (final doc in reports.docs) {
        final report = Report.fromFirestore(doc);

        // Tür bazında sayım
        analysis['reportsByType'][report.reportType.name] = 
            (analysis['reportsByType'][report.reportType.name] ?? 0) + 1;

        // Öncelik bazında sayım
        analysis['reportsByPriority'][report.priority.name] = 
            (analysis['reportsByPriority'][report.priority.name] ?? 0) + 1;

        // Durum bazında sayım
        analysis['reportsByStatus'][report.status.name] = 
            (analysis['reportsByStatus'][report.status.name] ?? 0) + 1;

        // Kullanıcı bazında sayım
        userReports[report.reportedUserId] = (userReports[report.reportedUserId] ?? 0) + 1;

        // İçerik bazında sayım
        if (report.reportedContentId != null) {
          contentReports[report.reportedContentId!] = 
              (contentReports[report.reportedContentId!] ?? 0) + 1;
        }

        // Çözüm süresi hesapla
        if (report.reviewedAt != null) {
          final resolutionTime = report.reviewedAt!.difference(report.createdAt).inHours;
          resolutionTimes.add(resolutionTime);
        }
      }

      // En çok rapor edilen kullanıcılar
      final sortedUsers = userReports.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      analysis['topReportedUsers'] = Map.fromEntries(sortedUsers.take(10));

      // En çok rapor edilen içerikler
      final sortedContent = contentReports.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      analysis['topReportedContent'] = Map.fromEntries(sortedContent.take(10));

      // Ortalama çözüm süresi
      if (resolutionTimes.isNotEmpty) {
        analysis['averageResolutionTime'] = 
            resolutionTimes.reduce((a, b) => a + b) / resolutionTimes.length;
      }

      return analysis;
    } catch (e) {
      return {
        'totalReports': 0,
        'reportsByType': {},
        'reportsByPriority': {},
        'reportsByStatus': {},
        'topReportedUsers': {},
        'topReportedContent': {},
        'averageResolutionTime': 0.0,
      };
    }
  }
}
