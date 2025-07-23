import 'package:flutter/material.dart';

/// Yorum raporlama dialog'u
class ReportCommentDialog extends StatefulWidget {
  final String commentId;

  const ReportCommentDialog({super.key, required this.commentId});

  @override
  State<ReportCommentDialog> createState() => _ReportCommentDialogState();
}

class _ReportCommentDialogState extends State<ReportCommentDialog> {
  String? _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> _reportReasons = [
    {'value': 'spam', 'label': 'Spam / Gereksiz içerik'},
    {'value': 'inappropriate', 'label': 'Uygunsuz içerik'},
    {'value': 'hate_speech', 'label': 'Nefret söylemi'},
    {'value': 'harassment', 'label': 'Taciz / Rahatsız edici'},
    {'value': 'advertisement', 'label': 'Reklam / Tanıtım'},
    {'value': 'other', 'label': 'Diğer'},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Yorumu Şikayet Et'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu yorumu neden şikayet ediyorsunuz?',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Şikayet sebepleri
            ..._reportReasons.map(
              (reason) => RadioListTile<String>(
                title: Text(reason['label']!),
                value: reason['value']!,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const SizedBox(height: 16),

            // Açıklama alanı
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama (isteğe bağlı)',
                hintText:
                    'Şikayetiniz hakkında daha fazla bilgi verebilirsiniz...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 200,
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
          onPressed: _selectedReason == null ? null : _submitReport,
          child: const Text('Şikayet Et'),
        ),
      ],
    );
  }

  /// Raporu gönder
  void _submitReport() {
    if (_formKey.currentState!.validate() && _selectedReason != null) {
      Navigator.pop(context, {
        'reason': _selectedReason!,
        'description': _descriptionController.text.trim(),
      });
    }
  }
}
