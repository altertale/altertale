import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/auth/auth_text_field.dart';

/// Profil düzenleme ekranı
/// Kullanıcının profil bilgilerini düzenlemesini sağlar
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();

  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final profileProvider = context.read<ProfileProvider>();
    final profile = profileProvider.profile;

    if (profile != null) {
      _nameController.text = profile.name;
      _usernameController.text = profile.username ?? '';
      _displayNameController.text = profile.displayName ?? '';
      _bioController.text = profile.bio ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: const Text('Kaydet'),
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profil fotoğrafı seçimi
                  _buildProfileImagePicker(theme, profileProvider),

                  const SizedBox(height: 32),

                  // Form alanları
                  _buildFormFields(theme),

                  const SizedBox(height: 32),

                  // Kaydet butonu
                  _buildSaveButton(theme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImagePicker(
    ThemeData theme,
    ProfileProvider profileProvider,
  ) {
    final profile = profileProvider.profile;

    return Center(
      child: Column(
        children: [
          // Profil fotoğrafı
          GestureDetector(
            onTap: _showImagePicker,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  backgroundImage: _selectedImage != null
                      ? null // XFile için NetworkImage kullanamayız, önce File'a çevirmek gerekir
                      : (profile?.hasProfileImage == true
                            ? NetworkImage(profile!.profileImageUrl!)
                            : null),
                  child:
                      _selectedImage == null && profile?.hasProfileImage != true
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
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
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Fotoğraf değiştir butonu
          TextButton.icon(
            onPressed: _showImagePicker,
            icon: const Icon(Icons.edit),
            label: Text(
              _selectedImage != null ? 'Fotoğrafı Değiştir' : 'Fotoğraf Seç',
            ),
          ),

          if (_selectedImage != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                });
              },
              icon: const Icon(Icons.delete),
              label: const Text('Fotoğrafı Kaldır'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // İsim
        AuthTextField(
          controller: _nameController,
          labelText: 'İsim',
          hintText: 'Adınızı girin',
          prefixIcon: const Icon(Icons.person),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'İsim gereklidir';
            }
            if (value.trim().length < 2) {
              return 'İsim en az 2 karakter olmalıdır';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Kullanıcı adı
        AuthTextField(
          controller: _usernameController,
          labelText: 'Kullanıcı Adı',
          hintText: 'Benzersiz kullanıcı adınız',
          prefixIcon: const Icon(Icons.alternate_email),
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              if (value.trim().length < 3) {
                return 'Kullanıcı adı en az 3 karakter olmalıdır';
              }
              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                return 'Sadece harf, rakam ve alt çizgi kullanılabilir';
              }
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Görünen ad
        AuthTextField(
          controller: _displayNameController,
          labelText: 'Görünen Ad',
          hintText: 'Profilde görünecek adınız',
          prefixIcon: const Icon(Icons.badge),
          validator: (value) {
            if (value != null && value.trim().isNotEmpty) {
              if (value.trim().length < 2) {
                return 'Görünen ad en az 2 karakter olmalıdır';
              }
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Bio
        TextFormField(
          controller: _bioController,
          decoration: InputDecoration(
            labelText: 'Hakkımda',
            hintText: 'Kendiniz hakkında kısa bir açıklama yazın',
            prefixIcon: const Icon(Icons.info_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          maxLength: 200,
          validator: (value) {
            if (value != null && value.trim().length > 200) {
              return 'Bio en fazla 200 karakter olabilir';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Değişiklikleri Kaydet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilirken hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profileProvider = context.read<ProfileProvider>();

      final success = await profileProvider.updateProfileInfo(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text.trim(),
        displayName: _displayNameController.text.trim().isEmpty
            ? null
            : _displayNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        profileImage: _selectedImage,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil başarıyla güncellendi'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                profileProvider.errorMessage ?? 'Profil güncellenemedi',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
