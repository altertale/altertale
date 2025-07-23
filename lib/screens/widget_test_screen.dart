import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

/// Widget Test Screen - Altertale Custom Widget'ların Test Ekranı
///
/// Bu ekran, oluşturulan tüm custom widget'ları test etmek ve
/// görsel olarak incelemek için tasarlanmıştır.
class WidgetTestScreen extends StatefulWidget {
  const WidgetTestScreen({super.key});

  @override
  State<WidgetTestScreen> createState() => _WidgetTestScreenState();
}

class _WidgetTestScreenState extends State<WidgetTestScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _searchController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isLoading = false;
  bool _showEmptyState = false;
  LoadingStyle _selectedLoadingStyle = LoadingStyle.circular;
  EmptyStateType _selectedEmptyType = EmptyStateType.general;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Widgets Test'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Custom Buttons'),
            _buildButtonTests(),

            const SizedBox(height: 32),
            _buildSectionTitle('Custom Text Fields'),
            _buildTextFieldTests(),

            const SizedBox(height: 32),
            _buildSectionTitle('Typography'),
            _buildTypographyTests(),

            const SizedBox(height: 32),
            _buildSectionTitle('Rounded Cards'),
            _buildCardTests(),

            const SizedBox(height: 32),
            _buildSectionTitle('Icon Text Buttons'),
            _buildIconTextButtonTests(),

            const SizedBox(height: 32),
            _buildSectionTitle('Loading Indicators'),
            _buildLoadingTests(),

            const SizedBox(height: 32),
            _buildSectionTitle('Empty States'),
            _buildEmptyStateTests(),
          ],
        ),
      ),
    );
  }

  /// Section başlığı oluşturur
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TitleText(
        title,
        size: TitleSize.large,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Button testlerini oluşturur
  Widget _buildButtonTests() {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SubtitleText('Primary Buttons'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              CustomButton(
                text: 'Normal Button',
                onPressed: () => _showSnackBar('Normal Button tıklandı'),
              ),
              CustomButton(
                text: 'Loading Button',
                isLoading: _isLoading,
                onPressed: () => _toggleLoading(),
              ),
              CustomButton(
                text: 'With Icon',
                icon: Icons.star,
                onPressed: () => _showSnackBar('Icon Button tıklandı'),
              ),
              const CustomButton(text: 'Disabled', onPressed: null),
            ],
          ),

          const SizedBox(height: 20),
          const SubtitleText('Secondary Buttons'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              CustomButton(
                text: 'Secondary',
                isPrimary: false,
                onPressed: () => _showSnackBar('Secondary Button tıklandı'),
              ),
              CustomButton(
                text: 'With Icon',
                icon: Icons.download,
                isPrimary: false,
                onPressed: () =>
                    _showSnackBar('Secondary Icon Button tıklandı'),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const SubtitleText('Size Variants'),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomButton(
                text: 'Small Button',
                height: 36.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                onPressed: () => _showSnackBar('Small Button tıklandı'),
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: 'Large Button',
                height: 56.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 16.0,
                ),
                onPressed: () => _showSnackBar('Large Button tıklandı'),
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: 'Full Width Button',
                width: double.infinity,
                onPressed: () => _showSnackBar('Full Width Button tıklandı'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Text field testlerini oluşturur
  Widget _buildTextFieldTests() {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SubtitleText('Standard Text Fields'),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Email adresinizi girin',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Email gerekli';
              if (!value!.contains('@')) return 'Geçerli email girin';
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: 'Şifrenizi girin',
            obscureText: true,
            prefixIcon: Icons.lock_outlined,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Şifre gerekli';
              if (value!.length < 6) return 'En az 6 karakter';
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _searchController,
            hintText: 'Kitap, yazar ara...',
            prefixIcon: Icons.search,
            suffixIcon: Icons.clear,
            onChanged: (value) => debugPrint('Search: $value'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _messageController,
            labelText: 'Mesaj',
            hintText: 'Mesajınızı yazın...',
            maxLines: 4,
            minLines: 2,
            maxLength: 500,
          ),
        ],
      ),
    );
  }

  /// Typography testlerini oluşturur
  Widget _buildTypographyTests() {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SubtitleText('Title Text Variants'),
          const SizedBox(height: 12),
          const TitleText('Display Title', size: TitleSize.display),
          const SizedBox(height: 8),
          const TitleText('Headline Title', size: TitleSize.headline),
          const SizedBox(height: 8),
          const TitleText('Large Title', size: TitleSize.large),
          const SizedBox(height: 8),
          const TitleText('Medium Title', size: TitleSize.medium),
          const SizedBox(height: 8),
          const TitleText('Small Title', size: TitleSize.small),

          const SizedBox(height: 20),
          const SubtitleText('Subtitle Text Variants'),
          const SizedBox(height: 12),
          const SubtitleText(
            'Large subtitle text for important descriptions',
            size: SubtitleSize.large,
          ),
          const SizedBox(height: 4),
          const SubtitleText(
            'Medium subtitle text for general descriptions',
            size: SubtitleSize.medium,
          ),
          const SizedBox(height: 4),
          const SubtitleText(
            'Small subtitle text for meta information',
            size: SubtitleSize.small,
          ),
          const SizedBox(height: 4),
          const SubtitleText(
            'Caption text for very small labels',
            size: SubtitleSize.caption,
          ),

          const SizedBox(height: 20),
          const SubtitleText('Colored Text Variants'),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final colorScheme = Theme.of(context).colorScheme;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleText('Primary Color Title', color: colorScheme.primary),
                  const SizedBox(height: 4),
                  SubtitleText(
                    'Success message text',
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 4),
                  SubtitleText(
                    'Warning message text',
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(height: 4),
                  SubtitleText('Error message text', color: colorScheme.error),
                  const SizedBox(height: 4),
                  const SubtitleText('Muted subtitle text', opacity: 0.6),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Card testlerini oluşturur
  Widget _buildCardTests() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: RoundedCard(
                padding: const EdgeInsets.all(12.0),
                borderRadius: 12.0,
                elevation: 1.0,
                onTap: () => _showSnackBar('Compact Card tıklandı'),
                child: const Column(
                  children: [
                    Icon(Icons.star, color: Colors.orange),
                    SizedBox(height: 8),
                    TitleText('Compact Card', size: TitleSize.small),
                    SubtitleText(
                      'Küçük boyutlu kart',
                      size: SubtitleSize.small,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RoundedCard(
                padding: const EdgeInsets.all(16.0),
                borderRadius: 16.0,
                elevation: 2.0,
                onTap: () => _showSnackBar('Medium Card tıklandı'),
                child: const Column(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(height: 8),
                    TitleText('Medium Card', size: TitleSize.small),
                    SubtitleText('Orta boyutlu kart', size: SubtitleSize.small),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RoundedCard(
          padding: const EdgeInsets.all(24.0),
          borderRadius: 20.0,
          elevation: 4.0,
          onTap: () => _showSnackBar('Large Card tıklandı'),
          child: Column(
            children: [
              const Icon(Icons.diamond, color: Colors.purple, size: 32),
              const SizedBox(height: 12),
              const TitleText('Large Card', size: TitleSize.medium),
              const SubtitleText('Büyük boyutlu kart ile daha fazla içerik'),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Action',
                height: 36.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                onPressed: () => _showSnackBar('Card Action tıklandı'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Icon text button testlerini oluşturur
  Widget _buildIconTextButtonTests() {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SubtitleText('Profile Items'),
          const SizedBox(height: 12),
          IconTextButton(
            icon: Icons.person,
            text: 'Profil Bilgileri',
            style: IconTextButtonStyle.flat,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onPressed: () => _showSnackBar('Profil tıklandı'),
          ),
          IconTextButton(
            icon: Icons.notifications,
            text: 'Bildirimler',
            style: IconTextButtonStyle.flat,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            badgeCount: 3,
            onPressed: () => _showSnackBar('Bildirimler tıklandı'),
          ),
          IconTextButton(
            icon: Icons.bookmark,
            text: 'Kayıtlı Kitaplar',
            style: IconTextButtonStyle.flat,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onPressed: () => _showSnackBar('Kayıtlı Kitaplar tıklandı'),
          ),

          const SizedBox(height: 20),
          const SubtitleText('Action Buttons'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              Builder(
                builder: (context) {
                  final colorScheme = Theme.of(context).colorScheme;
                  return IconTextButton(
                    icon: Icons.download,
                    text: 'Download',
                    style: IconTextButtonStyle.outlined,
                    iconColor: colorScheme.primary,
                    textColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 14.0,
                    ),
                    onPressed: () => _showSnackBar('Download tıklandı'),
                  );
                },
              ),
              Builder(
                builder: (context) {
                  final colorScheme = Theme.of(context).colorScheme;
                  return IconTextButton(
                    icon: Icons.share,
                    text: 'Share',
                    style: IconTextButtonStyle.filled,
                    backgroundColor: colorScheme.primary,
                    iconColor: colorScheme.onPrimary,
                    textColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 14.0,
                    ),
                    onPressed: () => _showSnackBar('Share tıklandı'),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),
          const SubtitleText('Size Variants'),
          const SizedBox(height: 12),
          IconTextButton(
            icon: Icons.settings,
            text: 'Compact Button',
            style: IconTextButtonStyle.flat,
            iconSize: 18,
            spacing: 8,
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            borderRadius: 8.0,
            onPressed: () => _showSnackBar('Compact tıklandı'),
          ),
          const SizedBox(height: 8),
          IconTextButton(
            icon: Icons.star,
            text: 'Large Button',
            style: IconTextButtonStyle.outlined,
            iconSize: 28,
            spacing: 16,
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 18.0,
            ),
            borderRadius: 16.0,
            onPressed: () => _showSnackBar('Large tıklandı'),
          ),
        ],
      ),
    );
  }

  /// Loading testlerini oluşturur
  Widget _buildLoadingTests() {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SubtitleText('Loading Styles'),
          const SizedBox(height: 12),
          Row(
            children: [
              const SubtitleText('Style: ', size: SubtitleSize.small),
              DropdownButton<LoadingStyle>(
                value: _selectedLoadingStyle,
                onChanged: (style) {
                  setState(() {
                    _selectedLoadingStyle = style!;
                  });
                },
                items: LoadingStyle.values.map((style) {
                  return DropdownMenuItem(
                    value: style,
                    child: Text(style.name),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  LoadingIndicator(
                    size: LoadingSize.small,
                    style: _selectedLoadingStyle,
                  ),
                  const SizedBox(height: 8),
                  const SubtitleText('Small', size: SubtitleSize.caption),
                ],
              ),
              Column(
                children: [
                  LoadingIndicator(
                    size: LoadingSize.medium,
                    style: _selectedLoadingStyle,
                  ),
                  const SizedBox(height: 8),
                  const SubtitleText('Medium', size: SubtitleSize.caption),
                ],
              ),
              Column(
                children: [
                  LoadingIndicator(
                    size: LoadingSize.large,
                    style: _selectedLoadingStyle,
                  ),
                  const SizedBox(height: 8),
                  const SubtitleText('Large', size: SubtitleSize.caption),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const SubtitleText('With Message'),
          const SizedBox(height: 12),
          LoadingIndicator(
            size: LoadingSize.medium,
            style: _selectedLoadingStyle,
            message: 'Kitaplar yükleniyor...',
          ),
        ],
      ),
    );
  }

  /// Empty state testlerini oluşturur
  Widget _buildEmptyStateTests() {
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SubtitleText(
                'Empty State Type: ',
                size: SubtitleSize.small,
              ),
              DropdownButton<EmptyStateType>(
                value: _selectedEmptyType,
                onChanged: (type) {
                  setState(() {
                    _selectedEmptyType = type!;
                    _showEmptyState = true;
                  });
                },
                items: EmptyStateType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.name));
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_showEmptyState) ...[
            _buildEmptyStateExample(_selectedEmptyType),
            const SizedBox(height: 16),
          ],

          CustomButton(
            text: 'Show Empty State',
            onPressed: () {
              setState(() {
                _showEmptyState = !_showEmptyState;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Empty state örneği oluşturur
  Widget _buildEmptyStateExample(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.search:
        return EmptyStateWidget(
          icon: Icons.search_off_outlined,
          title: 'Sonuç Bulunamadı',
          description:
              '"test query" için sonuç bulunamadı. Farklı arama terimleri deneyin.',
          actionText: 'Aramayı Temizle',
          onAction: () => _showSnackBar('Search cleared'),
          type: EmptyStateType.search,
        );
      case EmptyStateType.noFavorites:
        return EmptyStateWidget(
          icon: Icons.favorite_border_outlined,
          title: 'Henüz Favori Yok',
          description:
              'Beğendiğiniz içerikleri favorilerinize ekleyerek daha sonra kolayca bulabilirsiniz.',
          actionText: 'İçerikleri Keşfet',
          onAction: () => _showSnackBar('Explore tapped'),
          type: EmptyStateType.noFavorites,
        );
      case EmptyStateType.noNotifications:
        return const EmptyStateWidget(
          icon: Icons.notifications_none_outlined,
          title: 'Bildirim Yok',
          description:
              'Henüz hiç bildiriminiz bulunmuyor. Yeni bildirimler geldiğinde burada görünecek.',
          type: EmptyStateType.noNotifications,
        );
      case EmptyStateType.offline:
        return EmptyStateWidget(
          icon: Icons.cloud_off_outlined,
          title: 'İnternet Bağlantısı Yok',
          description:
              'Bu içerik için internet bağlantısı gerekiyor. Bağlantınızı kontrol edip tekrar deneyin.',
          actionText: 'Tekrar Dene',
          onAction: () => _showSnackBar('Retry tapped'),
          type: EmptyStateType.offline,
        );
      case EmptyStateType.error:
        return EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Test Error',
          description:
              'Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin.',
          actionText: 'Tekrar Dene',
          onAction: () => _showSnackBar('Retry tapped'),
          type: EmptyStateType.error,
          iconColor: Colors.red.shade400,
        );
      default:
        return EmptyStateWidget(
          icon: Icons.inbox_outlined,
          title: 'Liste Boş',
          description: 'Henüz hiç öğe yok.',
          actionText: 'Ekle',
          onAction: () => _showSnackBar('Add tapped'),
          type: EmptyStateType.general,
        );
    }
  }

  /// Loading durumunu toggle eder
  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });

    if (_isLoading) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  /// Snackbar gösterir
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
