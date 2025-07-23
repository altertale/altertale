import 'package:flutter/material.dart';
import '../../models/profile/user_books_model.dart';
import '../../services/profile/profile_service.dart';
import 'user_avatar_widget.dart';

/// Profil ayarları widget'ı
class ProfileSettingsWidget extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onProfileUpdated;

  const ProfileSettingsWidget({
    super.key,
    required this.userProfile,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileSettingsWidget> createState() => _ProfileSettingsWidgetState();
}

class _ProfileSettingsWidgetState extends State<ProfileSettingsWidget> {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _usernameController;
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.userProfile.username);
    _displayNameController = TextEditingController(text: widget.userProfile.displayName ?? '');
    _bioController = TextEditingController(text: widget.userProfile.bio ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profil fotoğrafı
          _buildProfilePhotoSection(theme),
          
          const SizedBox(height: 24),
          
          // Temel bilgiler
          _buildBasicInfoSection(theme),
          
          const SizedBox(height: 24),
          
          // Hesap bilgileri
          _buildAccountInfoSection(theme),
          
          const SizedBox(height: 24),
          
          // Hesap işlemleri
          _buildAccountActionsSection(theme),
          
          if (_error != null) ...[
            const SizedBox(height: 16),
            _buildErrorWidget(theme),
          ],
        ],
      ),
    );
  }

  /// Profil fotoğrafı bölümü
  Widget _buildProfilePhotoSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Profil Fotoğrafı',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            UserAvatarWidget(
              profilePhotoUrl: widget.userProfile.profilePhotoUrl,
              displayName: widget.userProfile.displayNameOrUsername,
              size: 100,
              isEditable: true,
              onPhotoChanged: _onPhotoChanged,
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _onPhotoChanged,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Fotoğraf Değiştir'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _deleteProfilePhoto,
                    icon: const Icon(Icons.delete),
                    label: const Text('Fotoğrafı Sil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Temel bilgiler bölümü
  Widget _buildBasicInfoSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temel Bilgiler',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            
            // Kullanıcı adı
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Kullanıcı Adı',
                hintText: 'Kullanıcı adınızı girin',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kullanıcı adı gerekli';
                }
                if (value.length < 3) {
                  return 'Kullanıcı adı en az 3 karakter olmalı';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Görünen ad
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Görünen Ad (İsteğe Bağlı)',
                hintText: 'Görünen adınızı girin',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bio
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Hakkımda (İsteğe Bağlı)',
                hintText: 'Kendiniz hakkında kısa bir açıklama yazın',
                border: OutlineInputBorder(),
                helperText: 'Maksimum 200 karakter',
              ),
              maxLines: 3,
              maxLength: 200,
            ),
            
            const SizedBox(height: 20),
            
            // Kaydet butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveBasicInfo,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Bilgileri Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hesap bilgileri bölümü
  Widget _buildAccountInfoSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hesap Bilgileri',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            
            // E-posta
            _buildInfoRow(
              theme,
              'E-posta Adresi',
              widget.userProfile.email,
              Icons.email,
              isEditable: false,
            ),
            
            const SizedBox(height: 12),
            
            // Üyelik tarihi
            _buildInfoRow(
              theme,
              'Üyelik Tarihi',
              _formatDate(widget.userProfile.joinDate),
              Icons.calendar_today,
              isEditable: false,
            ),
            
            const SizedBox(height: 12),
            
            // Üyelik süresi
            _buildInfoRow(
              theme,
              'Üyelik Süresi',
              '${widget.userProfile.membershipDays} gün',
              Icons.timer,
              isEditable: false,
            ),
            
            const SizedBox(height: 12),
            
            // Premium durumu
            _buildInfoRow(
              theme,
              'Premium Durumu',
              widget.userProfile.isPremium ? 'Premium Üye' : 'Standart Üye',
              Icons.star,
              isEditable: false,
              valueColor: widget.userProfile.isPremium ? Colors.amber : null,
            ),
            
            const SizedBox(height: 20),
            
            // Şifre değiştir butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _changePassword,
                icon: const Icon(Icons.lock),
                label: const Text('Şifre Değiştir'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hesap işlemleri bölümü
  Widget _buildAccountActionsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hesap İşlemleri',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            
            // Veri dışa aktar
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Verilerimi Dışa Aktar'),
              subtitle: const Text('Tüm verilerinizi JSON formatında indirin'),
              onTap: _exportData,
            ),
            
            const Divider(),
            
            // Hesap silme
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Hesabımı Sil'),
              subtitle: const Text('Hesabınızı kalıcı olarak silin'),
              onTap: _deleteAccount,
            ),
          ],
        ),
      ),
    );
  }

  /// Hata widget'ı
  Widget _buildErrorWidget(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== YARDIMCI FONKSİYONLAR ====================

  /// Bilgi satırı oluştur
  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon, {
    bool isEditable = true,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (isEditable)
          Icon(
            Icons.edit,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
      ],
    );
  }

  /// Profil fotoğrafı değiştiğinde
  void _onPhotoChanged(String? photoUrl) {
    if (photoUrl != null) {
      final updatedProfile = widget.userProfile.copyWith(
        profilePhotoUrl: photoUrl,
      );
      widget.onProfileUpdated(updatedProfile);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil fotoğrafı güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Profil fotoğrafını sil
  Future<void> _deleteProfilePhoto() async {
    try {
      await _profileService.deleteProfilePhoto(widget.userProfile.userId);
      
      final updatedProfile = widget.userProfile.copyWith(
        profilePhotoUrl: null,
      );
      widget.onProfileUpdated(updatedProfile);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil fotoğrafı silindi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf silinirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Temel bilgileri kaydet
  Future<void> _saveBasicInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final updatedProfile = widget.userProfile.copyWith(
        username: _usernameController.text.trim(),
        displayName: _displayNameController.text.trim().isEmpty 
            ? null 
            : _displayNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty 
            ? null 
            : _bioController.text.trim(),
      );

      await _profileService.updateUserProfile(updatedProfile);
      widget.onProfileUpdated(updatedProfile);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bilgiler başarıyla kaydedildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  /// Şifre değiştir
  void _changePassword() {
    // Şifre değiştirme ekranına yönlendir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Şifre değiştirme özelliği yakında eklenecek'),
      ),
    );
  }

  /// Veri dışa aktar
  void _exportData() {
    // Veri dışa aktarma özelliği
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veri dışa aktarma özelliği yakında eklenecek'),
      ),
    );
  }

  /// Hesap sil
  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabımı Sil'),
        content: const Text(
          'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz kalıcı olarak silinecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hesabımı Sil'),
          ),
        ],
      ),
    );
  }

  /// Hesap silmeyi onayla
  Future<void> _confirmDeleteAccount() async {
    try {
      await _profileService.requestAccountDeletion(widget.userProfile.userId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hesap silme talebi oluşturuldu. Admin onayı bekleniyor.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hesap silme talebi oluşturulurken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Tarih formatla
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
