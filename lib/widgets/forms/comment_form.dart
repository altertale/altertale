import 'package:flutter/material.dart';
import '../../models/comment_model.dart';
import '../../utils/alerts.dart';

/// Yorum formu widget'ı
class CommentForm extends StatefulWidget {
  final CommentModel? initialComment;
  final Function({required int rating, required String text}) onSubmit;

  const CommentForm({super.key, this.initialComment, required this.onSubmit});

  @override
  State<CommentForm> createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Mevcut yorum varsa formu doldur
    if (widget.initialComment != null) {
      _rating = widget.initialComment!.rating;
      _textController.text = widget.initialComment!.text;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
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
          // Yıldız puanı
          Text(
            'Puanınız:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Yıldız seçimi
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
              );
            }),
          ),

          if (_rating > 0) ...[
            const SizedBox(height: 4),
            Text(
              '$_rating yıldız',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Yorum metni
          TextFormField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Yorumunuz',
              hintText: 'Bu kitap hakkında düşüncelerinizi paylaşın...',
              border: OutlineInputBorder(),
              counterText: '', // Karakter sayacını gizle
            ),
            maxLines: 4,
            maxLength: 500,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Yorum metni gereklidir';
              }
              if (value.length > 500) {
                return 'Yorum maksimum 500 karakter olabilir';
              }
              return null;
            },
          ),

          // Karakter sayacı
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_textController.text.length}/500',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _textController.text.length > 450
                    ? Colors.orange
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Gönder butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting || _rating == 0 ? null : _submitComment,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.initialComment != null ? 'Güncelle' : 'Yorum Yap',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Yorumu gönder
  Future<void> _submitComment() async {
    if (!_formKey.currentState!.validate() || _rating == 0) {
      Alerts.showError(context, 'Lütfen puan ve yorum metni girin');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(rating: _rating, text: _textController.text.trim());
      Alerts.showSuccess(
        context,
        widget.initialComment != null
            ? 'Yorum güncellendi!'
            : 'Yorum gönderildi!',
      );

      // Formu temizle (sadece yeni yorum ise)
      if (widget.initialComment == null) {
        setState(() {
          _rating = 0;
          _textController.clear();
        });
      }
    } catch (e) {
      Alerts.showError(context, 'Yorum gönderilemedi: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
