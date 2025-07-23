import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/notification_service.dart';
import '../../providers/auth_provider.dart';

/// Admin bildirim gönderme ekranı
class NotificationSender extends StatefulWidget {
  const NotificationSender({super.key});

  @override
  State<NotificationSender> createState() => _NotificationSenderState();
}

class _NotificationSenderState extends State<NotificationSender> {
  final NotificationService _notificationService = NotificationService();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _targetAudience = 'all';
  String _notificationType = 'general';
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  final List<Map<String, String>> _audienceOptions = [
    {'value': 'all', 'label': 'Tüm Kullanıcılar'},
    {'value': 'premium', 'label': 'Premium Kullanıcılar'},
    {'value': 'new_users', 'label': 'Yeni Kullanıcılar (Son 7 gün)'},
    {'value': 'active_users', 'label': 'Aktif Kullanıcılar'},
  ];

  final List<Map<String, String>> _typeOptions = [
    {'value': 'general', 'label': 'Genel'},
    {'value': 'book_update', 'label': 'Kitap Güncellemesi'},
    {'value': 'referral', 'label': 'Referans'},
    {'value': 'points', 'label': 'Puan Kazanımı'},
    {'value': 'comment', 'label': 'Yorum Onayı'},
    {'value': 'promotion', 'label': 'Promosyon'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Gönder'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başarı mesajı
                    if (_successMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),

                    // Hata mesajı
                    if (_error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    // Bildirim türü
                    Text(
                      'Bildirim Türü',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _notificationType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _typeOptions.map((option) {
                        return DropdownMenuItem(
                          value: option['value'],
                          child: Text(option['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _notificationType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Hedef kitle
                    Text(
                      'Hedef Kitle',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _targetAudience,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _audienceOptions.map((option) {
                        return DropdownMenuItem(
                          value: option['value'],
                          child: Text(option['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _targetAudience = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Başlık
                    Text(
                      'Başlık',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Bildirim başlığını girin',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Başlık gereklidir';
                        }
                        if (value.length > 100) {
                          return 'Başlık 100 karakterden uzun olamaz';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mesaj
                    Text(
                      'Mesaj',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bodyController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Bildirim mesajını girin',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Mesaj gereklidir';
                        }
                        if (value.length > 500) {
                          return 'Mesaj 500 karakterden uzun olamaz';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Gönder butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sendNotification,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        child: const Text(
                          'Bildirim Gönder',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bilgi kartı
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Bildirim Gönderme Hakkında',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoItem(
                              theme,
                              'Bildirimler anında gönderilir ve kullanıcılar tarafından görülebilir',
                            ),
                            _buildInfoItem(
                              theme,
                              'Spam koruması: Aynı kullanıcıya saatte maksimum 5 bildirim',
                            ),
                            _buildInfoItem(
                              theme,
                              'Bildirimler 30 gün sonra otomatik olarak temizlenir',
                            ),
                            _buildInfoItem(
                              theme,
                              'Kullanıcılar bildirim ayarlarından belirli türleri kapatabilir',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Bilgi öğesi
  Widget _buildInfoItem(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// Bildirim gönder
  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _successMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      
      if (currentUser == null) {
        setState(() {
          _error = 'Kullanıcı bilgisi bulunamadı';
          _isLoading = false;
        });
        return;
      }

      // Bildirim gönder
      await _notificationService.sendNotificationToUsers(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        data: {
          'type': _notificationType,
          'targetAudience': _targetAudience,
          'sentBy': currentUser.uid,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
        targetAudience: _targetAudience,
        type: _notificationType,
      );

      setState(() {
        _successMessage = 'Bildirim başarıyla gönderildi!';
        _isLoading = false;
      });

      // Formu temizle
      _titleController.clear();
      _bodyController.clear();
      _formKey.currentState!.reset();
    } catch (e) {
      setState(() {
        _error = 'Bildirim gönderilirken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }
}
