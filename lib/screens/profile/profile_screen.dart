import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile/profile_service.dart';
import '../../models/user_profile_model.dart';
import '../../widgets/widgets.dart';
import '../../widgets/profile/profile_stats_widget.dart';

/// Profile Screen - Kullanıcı Profili Ekranı
///
/// Kullanıcının profil bilgilerini görüntüleme ve düzenleme ekranı
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _fullNameController = TextEditingController();

  // State variables
  UserProfile? _currentProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _newProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) return;

    if (!mounted) return; // Add mounted check

    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _profileService.getUserProfile(authProvider.userId);
      if (!mounted) return; // Add mounted check before setState
      setState(() {
        _currentProfile = profile;
        _fullNameController.text = profile?.fullName ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // Add mounted check before setState
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil yüklenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) return;

    if (!mounted) return; // Add mounted check

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedProfile = await _profileService.updateUserProfile(
        userId: authProvider.userId,
        fullName: _fullNameController.text.trim(),
        profileImageUrl:
            _newProfileImageUrl ?? _currentProfile?.profileImageUrl,
      );

      if (!mounted) return; // Add mounted check before setState

      setState(() {
        _currentProfile = updatedProfile;
        _isEditing = false;
        _isSaving = false;
        _newProfileImageUrl = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return; // Add mounted check before setState
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil güncelleme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) return;

    if (!mounted) return; // Add mounted check

    setState(() {
      _isUploadingImage = true;
    });

    try {
      // Mock image upload (in real app, use image_picker)
      final imageUrl = await _profileService.uploadProfileImage(
        userId: authProvider.userId,
        imagePath: 'mock_image_path.jpg',
      );

      if (!mounted) return; // Add mounted check before setState

      setState(() {
        _newProfileImageUrl = imageUrl;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil resmi yüklendi! Kaydet\'e basın.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return; // Add mounted check before setState
      setState(() {
        _isUploadingImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resim yükleme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TitleText('Çıkış Yap'),
        content: const SubtitleText(
          'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthProvider>().signOut();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      return _buildLoginPrompt();
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const TitleText('Profilim'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          if (!_isEditing && !_isLoading)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () {
                      setState(() {
                        _isEditing = false;
                        _fullNameController.text =
                            _currentProfile?.fullName ?? '';
                        _newProfileImageUrl = null;
                      });
                    },
              child: const Text('İptal'),
            ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Handle null profile case with better UI
    if (_currentProfile == null) {
      return _buildNullProfileContent(theme);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Profile Image Section
            _buildProfileImageSection(colorScheme),

            const SizedBox(height: 32),

            // Profile Information Section
            _buildProfileInfoSection(theme),

            const SizedBox(height: 32),

            // Profile Statistics Section
            const ProfileStatsWidget(
              showDetailed: true,
              padding: EdgeInsets.zero,
            ),

            const SizedBox(height: 32),

            // Action Buttons Section
            _buildActionButtonsSection(theme),

            const SizedBox(height: 32),

            // Quick Actions Section
            _buildQuickActionsSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildNullProfileContent(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final authProvider = context.read<AuthProvider>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 64,
              color: colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            const TitleText('Profil Oluşturunuz', size: TitleSize.medium),
            const SizedBox(height: 8),
            SubtitleText(
              'Henüz bir profil bilginiz bulunmuyor.\nİlk profilinizi oluşturmak için aşağıdaki butona tıklayın.',
              textAlign: TextAlign.center,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Profil Oluştur',
              onPressed: () => _createInitialProfile(authProvider.userId),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadUserProfile,
              child: const Text('Yeniden Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createInitialProfile(String userId) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final email = authProvider.isDemoMode
          ? 'demo@test.com'
          : 'user@example.com';

      final newProfile = await _profileService.createUserProfile(
        userId: userId,
        email: email,
        fullName: 'Yeni Kullanıcı',
        metadata: {'createdVia': 'profile_screen', 'initialSetup': true},
      );

      if (!mounted) return;

      setState(() {
        _currentProfile = newProfile;
        _fullNameController.text = newProfile.fullName;
        _isLoading = false;
        _isEditing = true; // Start in editing mode
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profil oluşturuldu! Bilgilerinizi düzenleyebilirsiniz.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil oluşturma hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProfileImageSection(ColorScheme colorScheme) {
    final imageUrl = _newProfileImageUrl ?? _currentProfile?.profileImageUrl;

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primaryContainer,
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: _isUploadingImage
                ? const Center(child: CircularProgressIndicator())
                : imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildAvatarFallback(colorScheme);
                      },
                    ),
                  )
                : _buildAvatarFallback(colorScheme),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 2),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                  onPressed: _isUploadingImage ? null : _uploadProfileImage,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(ColorScheme colorScheme) {
    // Better fallback for initials
    String initials = 'U'; // Default fallback

    if (_currentProfile != null) {
      initials = _currentProfile!.initials;
    } else {
      // If no profile, try to get from auth provider
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isDemoMode) {
        initials = 'D'; // Demo user
      }
    }

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildProfileInfoSection(ThemeData theme) {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleText('Kişisel Bilgiler', size: TitleSize.medium),
          const SizedBox(height: 16),

          // Full Name Field
          TextFormField(
            controller: _fullNameController,
            enabled: _isEditing,
            decoration: InputDecoration(
              labelText: 'Ad Soyad',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
              enabled: _isEditing,
              // Add placeholder when no name is available
              hintText: _currentProfile?.fullName.isEmpty == true
                  ? 'Adınızı girin'
                  : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ad soyad gerekli';
              }
              if (value.trim().length < 2) {
                return 'Ad soyad en az 2 karakter olmalı';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Email Field (Read-only)
          TextFormField(
            initialValue: _currentProfile?.email ?? 'E-posta yükleniyor...',
            enabled: false,
            decoration: InputDecoration(
              labelText: 'E-posta',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email),
              suffixIcon: Icon(
                Icons.lock,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Email Verification Status
          _buildEmailVerificationStatus(theme),

          const SizedBox(height: 8),
          SubtitleText(
            'E-posta adresi değiştirilemez',
            size: SubtitleSize.small,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),

          // Show profile creation date if available
          if (_currentProfile?.createdAt != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                SubtitleText(
                  'Üyelik: ${_formatDate(_currentProfile!.createdAt)}',
                  size: SubtitleSize.small,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else {
      return 'Bugün';
    }
  }

  Widget _buildActionButtonsSection(ThemeData theme) {
    if (!_isEditing) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'İptal',
            onPressed: _isSaving
                ? null
                : () {
                    setState(() {
                      _isEditing = false;
                      _fullNameController.text =
                          _currentProfile?.fullName ?? '';
                      _newProfileImageUrl = null;
                    });
                  },
            type: ButtonType.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'Kaydet',
            onPressed: _isSaving ? null : _saveProfile,
            isLoading: _isSaving,
            type: ButtonType.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleText('Hızlı İşlemler', size: TitleSize.medium),
        const SizedBox(height: 16),

        RoundedCard(
          child: Column(
            children: [
              // Orders History
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Sipariş Geçmişim'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pushNamed('/orders');
                },
              ),

              const Divider(height: 1),

              // Settings
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Ayarlar'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pushNamed('/settings');
                },
              ),

              const Divider(height: 1),

              // Help
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Yardım & Destek'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yardım yakında...')),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Logout Button
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Çıkış Yap',
            onPressed: _logout,
            type: ButtonType.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const TitleText('Profilim'),
        backgroundColor: colorScheme.surface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const TitleText(
                'Profil Bilgilerinizi Görüntüleyin',
                size: TitleSize.medium,
              ),
              const SizedBox(height: 8),
              SubtitleText(
                'Profil bilgilerinizi görüntülemek ve düzenlemek için giriş yapmanız gerekiyor.',
                textAlign: TextAlign.center,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Demo Giriş Yap',
                onPressed: () => context.read<AuthProvider>().signInDemoMode(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          SubtitleText('Profil bilgileri yükleniyor...'),
        ],
      ),
    );
  }

  Widget _buildEmailVerificationStatus(ThemeData theme) {
    final authProvider = context.read<AuthProvider>();
    final isEmailVerified = authProvider.isEmailVerified;

    return Row(
      children: [
        Icon(
          isEmailVerified ? Icons.verified : Icons.verified_outlined,
          color: isEmailVerified ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        SubtitleText(
          isEmailVerified
              ? 'E-posta adresiniz doğrulanmış'
              : 'E-posta adresiniz doğrulanmamış',
          size: SubtitleSize.small,
          color: isEmailVerified ? Colors.green : Colors.red,
        ),
      ],
    );
  }
}
