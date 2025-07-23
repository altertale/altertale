import 'package:flutter/material.dart';
import '../../models/security/report_model.dart';
import '../../services/security/security_service.dart';

/// Rapor formu widget'ı
class ReportFormWidget extends StatefulWidget {
  final Function(Report) onReportSubmitted;
  final String? reportedUserId;
  final String? reportedContentId;
  final String contentType;

  const ReportFormWidget({
    super.key,
    required this.onReportSubmitted,
    this.reportedUserId,
    this.reportedContentId,
    required this.contentType,
  });

  @override
  State<ReportFormWidget> createState() => _ReportFormWidgetState();
}

class _ReportFormWidgetState extends State<ReportFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  ReportType _selectedReportType = ReportType.other;
  ReportPriority _selectedPriority = ReportPriority.medium;
  final List<String> _evidence = [];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rapor türü seçimi
          Text(
            'Rapor Türü',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildReportTypeSelector(theme),

          const SizedBox(height: 20),

          // Öncelik seçimi
          Text(
            'Öncelik',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildPrioritySelector(theme),

          const SizedBox(height: 20),

          // Açıklama alanı
          Text(
            'Açıklama',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: 'Raporunuzu detaylı bir şekilde açıklayın...',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Açıklama gerekli';
              }
              if (value.trim().length < 10) {
                return 'Açıklama en az 10 karakter olmalı';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Kanıt ekleme
          Text(
            'Kanıt (İsteğe Bağlı)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildEvidenceSection(theme),

          const SizedBox(height: 24),

          // Gönder butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitReport,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Raporu Gönder'),
            ),
          ),
        ],
      ),
    );
  }

  /// Rapor türü seçici
  Widget _buildReportTypeSelector(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: ReportType.values.map((type) {
          return RadioListTile<ReportType>(
            title: Text(type.displayName),
            value: type,
            groupValue: _selectedReportType,
            onChanged: (value) {
              setState(() {
                _selectedReportType = value!;
              });
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          );
        }).toList(),
      ),
    );
  }

  /// Öncelik seçici
  Widget _buildPrioritySelector(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: ReportPriority.values.map((priority) {
          return RadioListTile<ReportPriority>(
            title: Row(
              children: [
                Text(priority.displayName),
                const SizedBox(width: 8),
                _getPriorityIcon(priority),
              ],
            ),
            value: priority,
            groupValue: _selectedPriority,
            onChanged: (value) {
              setState(() {
                _selectedPriority = value!;
              });
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          );
        }).toList(),
      ),
    );
  }

  /// Öncelik ikonu
  Widget _getPriorityIcon(ReportPriority priority) {
    IconData icon;
    Color color;

    switch (priority) {
      case ReportPriority.urgent:
        icon = Icons.priority_high;
        color = Colors.red;
        break;
      case ReportPriority.high:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case ReportPriority.medium:
        icon = Icons.info;
        color = Colors.blue;
        break;
      case ReportPriority.low:
        icon = Icons.low_priority;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color, size: 20);
  }

  /// Kanıt bölümü
  Widget _buildEvidenceSection(ThemeData theme) {
    return Column(
      children: [
        // Kanıt listesi
        if (_evidence.isNotEmpty) ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _evidence.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.link),
                title: Text(_evidence[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _evidence.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],

        // Kanıt ekleme butonu
        OutlinedButton.icon(
          onPressed: _addEvidence,
          icon: const Icon(Icons.add),
          label: const Text('Kanıt Ekle'),
        ),
      ],
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Kanıt ekle
  void _addEvidence() {
    showDialog(
      context: context,
      builder: (context) => _EvidenceDialog(
        onEvidenceAdded: (evidence) {
          setState(() {
            _evidence.add(evidence);
          });
        },
      ),
    );
  }

  /// Rapor gönder
  void _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final securityService = SecurityService();
      final currentUser = securityService.currentUser;

      if (currentUser == null) {
        throw Exception('Kullanıcı girişi yapılmamış');
      }

      final report = Report(
        id: '', // Firestore tarafından oluşturulacak
        reporterId: currentUser.uid,
        reportedUserId: widget.reportedUserId ?? '',
        reportedContentId: widget.reportedContentId,
        contentType: widget.contentType,
        reportType: _selectedReportType,
        priority: _selectedPriority,
        description: _descriptionController.text.trim(),
        evidence: _evidence,
        createdAt: DateTime.now(),
      );

      widget.onReportSubmitted(report);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rapor gönderilirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Kanıt ekleme dialog'u
class _EvidenceDialog extends StatefulWidget {
  final Function(String) onEvidenceAdded;

  const _EvidenceDialog({required this.onEvidenceAdded});

  @override
  State<_EvidenceDialog> createState() => _EvidenceDialogState();
}

class _EvidenceDialogState extends State<_EvidenceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _evidenceController = TextEditingController();

  @override
  void dispose() {
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Kanıt Ekle'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kanıt olarak URL, dosya adı veya açıklama ekleyebilirsiniz.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _evidenceController,
              decoration: const InputDecoration(
                labelText: 'Kanıt',
                hintText: 'URL, dosya adı veya açıklama',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kanıt gerekli';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onEvidenceAdded(_evidenceController.text.trim());
              Navigator.pop(context);
            }
          },
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}
