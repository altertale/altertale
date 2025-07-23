import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/profile/profile_service.dart';

/// Kullanıcı avatar widget'ı
class UserAvatarWidget extends StatelessWidget {
  final String? profilePhotoUrl;
  final String displayName;
  final double size;
  final bool isEditable;
  final Function(String)? onPhotoChanged;

  const UserAvatarWidget({
    super.key,
    this.profilePhotoUrl,
    required this.displayName,
    this.size = 80,
    this.isEditable = false,
    this.onPhotoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isEditable ? () => _showImagePicker(context) : null,
      child: Stack(
        children: [
          // Avatar
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
            ),
            child: profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      profilePhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialsAvatar(theme);
                      },
                    ),
                  )
                : _buildInitialsAvatar(theme),
          ),
          
          // Düzenleme ikonu
          if (isEditable)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: size * 0.2,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Baş harflerden avatar oluştur
  Widget _buildInitialsAvatar(ThemeData theme) {
    final initials = _getInitials(displayName);
    
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// İsimden baş harfleri al
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
    }
  }

  /// Resim seçici göster
  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ImagePickerBottomSheet(
        onPhotoChanged: onPhotoChanged,
      ),
    );
  }
}

/// Resim seçici bottom sheet
class _ImagePickerBottomSheet extends StatelessWidget {
  final Function(String)? onPhotoChanged;

  const _ImagePickerBottomSheet({
    this.onPhotoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Profil Fotoğrafı Seç',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOptionButton(
                context,
                'Kameradan Çek',
                Icons.camera_alt,
                () => _pickImage(context, ImageSource.camera),
              ),
              _buildOptionButton(
                context,
                'Galeriden Seç',
                Icons.photo_library,
                () => _pickImage(context, ImageSource.gallery),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
          ),
        ],
      ),
    );
  }

  /// Seçenek butonu oluştur
  Widget _buildOptionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  /// Resim seç
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final profileService = ProfileService();
        final user = profileService.currentUser;

        if (user != null) {
          // Loading göster
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          try {
            // Fotoğrafı yükle
            final photoUrl = await profileService.uploadProfilePhoto(
              user.uid,
              file,
            );

            // Dialog'u kapat
            Navigator.pop(context);

            // Bottom sheet'i kapat
            Navigator.pop(context);

            // Callback'i çağır
            onPhotoChanged?.call(photoUrl);

            // Başarı mesajı göster
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil fotoğrafı güncellendi'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            // Dialog'u kapat
            Navigator.pop(context);

            // Hata mesajı göster
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fotoğraf yüklenirken hata oluştu: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resim seçilirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
