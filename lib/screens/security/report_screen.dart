import 'package:flutter/material.dart';
import '../../models/security/report_model.dart';
import '../../services/security/moderation_service.dart';
import '../../widgets/security/report_form_widget.dart';

/// Rapor ekranı
class ReportScreen extends StatefulWidget {
  final String? reportedUserId;
  final String? reportedContentId;
  final String contentType;
  final String contentTitle;

  const ReportScreen({
    super.key,
    this.reportedUserId,
    this.reportedContentId,
    required this.contentType,
    required this.contentTitle,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ModerationService _moderationService = ModerationService();

  bool _isSubmitting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İçeriği Rapor Et'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget(theme)
          : _buildContent(theme),
    );
  }

  /// İçerik widget'ı
  Widget _buildContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Text(
            'İçeriği Rapor Et',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aşağıdaki içeriği rapor etmek istediğinizden emin misiniz?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 24),

          // Rapor edilen içerik
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rapor Edilen İçerik',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.contentTitle, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Tür: ${_getContentTypeDisplayName(widget.contentType)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Rapor formu
          ReportFormWidget(
            onReportSubmitted: _submitReport,
            reportedUserId: widget.reportedUserId,
            reportedContentId: widget.reportedContentId,
            contentType: widget.contentType,
          ),
        ],
      ),
    );
  }

  /// Hata widget'ı
  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Rapor gönderilirken hata oluştu',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _error = null;
              });
            },
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// İçerik türü görünen adını al
  String _getContentTypeDisplayName(String contentType) {
    switch (contentType) {
      case 'comment':
        return 'Yorum';
      case 'book':
        return 'Kitap';
      case 'user':
        return 'Kullanıcı';
      case 'review':
        return 'Değerlendirme';
      default:
        return 'İçerik';
    }
  }

  /// Rapor gönder
  Future<void> _submitReport(Report report) async {
    try {
      setState(() {
        _isSubmitting = true;
        _error = null;
      });

      await _moderationService.createReport(report);

      setState(() {
        _isSubmitting = false;
      });

      // Başarı mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rapor başarıyla gönderildi. İncelenecektir.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = e.toString();
      });
    }
  }
}

/// Rapor listesi ekranı (admin için)
class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen>
    with SingleTickerProviderStateMixin {
  final ModerationService _moderationService = ModerationService();

  late TabController _tabController;
  final ReportStatus _selectedStatus = ReportStatus.pending;
  final ReportPriority _selectedPriority = ReportPriority.medium;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.onPrimary,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withValues(
            alpha: 0.7,
          ),
          tabs: const [
            Tab(text: 'Bekleyen'),
            Tab(text: 'İncelenen'),
            Tab(text: 'Çözülen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsList(ReportStatus.pending),
          _buildReportsList(ReportStatus.underReview),
          _buildReportsList(ReportStatus.resolved),
        ],
      ),
    );
  }

  /// Raporlar listesi oluştur
  Widget _buildReportsList(ReportStatus status) {
    return StreamBuilder<List<Report>>(
      stream: _moderationService.getReports(status: status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final reports = snapshot.data ?? [];

        if (reports.isEmpty) {
          return const Center(child: Text('Bu kategoride rapor bulunmuyor'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return _ReportCard(
              report: report,
              onTap: () => _showReportDetails(report),
            );
          },
        );
      },
    );
  }

  /// Rapor detaylarını göster
  void _showReportDetails(Report report) {
    showDialog(
      context: context,
      builder: (context) => _ReportDetailsDialog(report: report),
    );
  }
}

/// Rapor kartı widget'ı
class _ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;

  const _ReportCard({required this.report, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.reportType.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.description,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildPriorityChip(theme),
                ],
              ),

              const SizedBox(height: 12),

              // Alt kısım
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(report.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Öncelik chip'i oluştur
  Widget _buildPriorityChip(ThemeData theme) {
    Color color;
    switch (report.priority) {
      case ReportPriority.urgent:
        color = Colors.red;
        break;
      case ReportPriority.high:
        color = Colors.orange;
        break;
      case ReportPriority.medium:
        color = Colors.blue;
        break;
      case ReportPriority.low:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        report.priority.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Durum chip'i oluştur
  Widget _buildStatusChip(ThemeData theme) {
    Color color;
    switch (report.status) {
      case ReportStatus.pending:
        color = Colors.orange;
        break;
      case ReportStatus.underReview:
        color = Colors.blue;
        break;
      case ReportStatus.resolved:
        color = Colors.green;
        break;
      case ReportStatus.dismissed:
        color = Colors.grey;
        break;
      case ReportStatus.escalated:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        report.status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Tarih formatla
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Rapor detayları dialog'u
class _ReportDetailsDialog extends StatelessWidget {
  final Report report;

  const _ReportDetailsDialog({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Rapor Detayları',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Rapor bilgileri
            _buildDetailRow('Tür', report.reportType.displayName),
            _buildDetailRow('Öncelik', report.priority.displayName),
            _buildDetailRow('Durum', report.status.displayName),
            _buildDetailRow('Açıklama', report.description),
            _buildDetailRow('Tarih', _formatDate(report.createdAt)),

            if (report.evidence.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Kanıtlar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...report.evidence.map((evidence) => Text('• $evidence')),
            ],

            if (report.reviewNotes != null) ...[
              const SizedBox(height: 16),
              Text(
                'İnceleme Notları',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(report.reviewNotes!),
            ],

            const SizedBox(height: 20),

            // Butonlar
            if (report.isPending || report.isUnderReview) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kapat'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Raporu çöz
                      },
                      child: const Text('Çöz'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kapat'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Detay satırı oluştur
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Tarih formatla
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
