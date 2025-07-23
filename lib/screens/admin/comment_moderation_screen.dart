import 'package:flutter/material.dart';
import '../../services/comment_service.dart';

/// Yorum moderasyonu ekranı
class CommentModerationScreen extends StatefulWidget {
  const CommentModerationScreen({super.key});

  @override
  State<CommentModerationScreen> createState() =>
      _CommentModerationScreenState();
}

class _CommentModerationScreenState extends State<CommentModerationScreen> {
  final CommentService _commentService = CommentService();
  List<CommentReport> _reports = [];
  bool _isLoading = true;
  String _filterStatus = 'pending'; // 'pending', 'reviewed', 'resolved'

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Text(
            'Yorum Moderasyonu',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_reports.length} rapor bulundu',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 24),

          // Filtreler
          Row(
            children: [
              DropdownButton<String>(
                value: _filterStatus,
                decoration: const InputDecoration(
                  labelText: 'Durum',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Bekleyen')),
                  DropdownMenuItem(value: 'reviewed', child: Text('İncelenen')),
                  DropdownMenuItem(value: 'resolved', child: Text('Çözülen')),
                ],
                onChanged: (value) {
                  setState(() {
                    _filterStatus = value!;
                  });
                  _loadReports();
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Rapor listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reports.isEmpty
                ? _buildEmptyState(theme)
                : _buildReportList(theme),
          ),
        ],
      ),
    );
  }

  /// Boş durum widget'ı
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Raporlanan yorum yok',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tüm yorumlar temiz görünüyor',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  /// Rapor listesi
  Widget _buildReportList(ThemeData theme) {
    return ListView.builder(
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Row(
              children: [
                Icon(
                  Icons.flag,
                  color: _getStatusColor(report.status),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${report.reason} - ${report.reporterName}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(report.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(report.status),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(report.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Raporlanan yorum: "${report.commentText}"',
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${report.reportCount} kullanıcı tarafından raporlandı',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Yorum detayları
                    _buildCommentDetails(theme, report),

                    const SizedBox(height: 16),

                    // Rapor detayları
                    _buildReportDetails(theme, report),

                    const SizedBox(height: 16),

                    // Aksiyon butonları
                    _buildActionButtons(theme, report),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Yorum detayları
  Widget _buildCommentDetails(ThemeData theme, CommentReport report) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yorum Detayları',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(report.commentText, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Yazar: ${report.commentAuthor}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Text(
                'Tarih: ${_formatDate(report.commentDate)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Rapor detayları
  Widget _buildReportDetails(ThemeData theme, CommentReport report) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        border: Border.all(color: theme.colorScheme.errorContainer),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rapor Detayları',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text('Sebep: ${report.reason}', style: theme.textTheme.bodyMedium),
          if (report.description != null && report.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Açıklama: ${report.description}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Raporlayan: ${report.reporterName} (${report.reporterEmail})',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            'Tarih: ${_formatDate(report.reportDate)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// Aksiyon butonları
  Widget _buildActionButtons(ThemeData theme, CommentReport report) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _hideComment(report),
            icon: const Icon(Icons.visibility_off),
            label: const Text('Gizle'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _deleteComment(report),
            icon: const Icon(Icons.delete),
            label: const Text('Sil'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _resolveReport(report),
            icon: const Icon(Icons.check),
            label: const Text('Çözüldü'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Raporları yükle
  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reports = await _commentService.getCommentReports(
        status: _filterStatus,
      );
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Raporlar yüklenirken hata: $e')));
    }
  }

  /// Yorumu gizle
  Future<void> _hideComment(CommentReport report) async {
    try {
      await _commentService.toggleCommentVisibility(
        commentId: report.commentId,
        isHidden: true,
      );

      await _loadReports();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Yorum gizlendi')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Yorum gizlenirken hata: $e')));
    }
  }

  /// Yorumu sil
  Future<void> _deleteComment(CommentReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yorumu Sil'),
        content: const Text(
          'Bu yorumu kalıcı olarak silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _commentService.deleteComment(
          userId: 'admin', // Admin silme işlemi
          commentId: report.commentId,
        );

        await _loadReports();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Yorum silindi')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Yorum silinirken hata: $e')));
      }
    }
  }

  /// Raporu çözüldü olarak işaretle
  Future<void> _resolveReport(CommentReport report) async {
    try {
      await _commentService.resolveCommentReport(report.id);

      await _loadReports();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rapor çözüldü olarak işaretlendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Rapor güncellenirken hata: $e')));
    }
  }

  /// Durum rengi
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Durum metni
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Bekliyor';
      case 'reviewed':
        return 'İncelendi';
      case 'resolved':
        return 'Çözüldü';
      default:
        return 'Bilinmiyor';
    }
  }

  /// Tarih formatla
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

/// Yorum raporu modeli
class CommentReport {
  final String id;
  final String commentId;
  final String commentText;
  final String commentAuthor;
  final DateTime commentDate;
  final String reporterId;
  final String reporterName;
  final String reporterEmail;
  final String reason;
  final String? description;
  final DateTime reportDate;
  final String status;
  final int reportCount;

  CommentReport({
    required this.id,
    required this.commentId,
    required this.commentText,
    required this.commentAuthor,
    required this.commentDate,
    required this.reporterId,
    required this.reporterName,
    required this.reporterEmail,
    required this.reason,
    this.description,
    required this.reportDate,
    required this.status,
    required this.reportCount,
  });
}
