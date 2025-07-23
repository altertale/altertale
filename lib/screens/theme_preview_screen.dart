import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Theme Preview Screen
///
/// Comprehensive theme system showcase:
/// - All color palettes with names and hex codes
/// - Typography samples from all text styles
/// - Button styles demonstration
/// - Form field examples
/// - Theme switching capabilities
/// - Light/Dark mode toggle
/// - Component theme previews
class ThemePreviewScreen extends StatefulWidget {
  const ThemePreviewScreen({super.key});

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen> {
  // ==================== STATE ====================
  bool _isDarkMode = false;
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  bool _switchValue = false;
  double _sliderValue = 0.5;

  @override
  void initState() {
    super.initState();
    // Theme context access moved to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get initial theme mode after dependencies are available
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ==================== THEME SWITCHING ====================
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _isDarkMode ? Brightness.dark : Brightness.light;
    final colorScheme = _isDarkMode
        ? AppColors.darkColorScheme
        : AppColors.lightColorScheme;

    return Theme(
      data: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tema Sistemi Preview'),
          // AppBar Theme Test - Custom theme ile modern app bar
          actions: [
            // Theme Toggle Switch
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
                const SizedBox(width: 8),
                Switch(
                  value: _isDarkMode,
                  onChanged: (value) => _toggleTheme(),
                  // Switch Theme Test - Custom switch styling
                ),
                const SizedBox(width: 16),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Mode Indicator
              _buildThemeModeIndicator(brightness),

              const SizedBox(height: 24),

              // Color Palette Section
              _buildColorPaletteSection(colorScheme, brightness),

              const SizedBox(height: 32),

              // Typography Section
              _buildTypographySection(brightness),

              const SizedBox(height: 32),

              // Button Styles Section
              _buildButtonStylesSection(brightness),

              const SizedBox(height: 32),

              // Form Styles Section
              _buildFormStylesSection(brightness),

              const SizedBox(height: 32),

              // Component Themes Section
              _buildComponentThemesSection(brightness),

              const SizedBox(height: 32),

              // Reading Styles Section
              _buildReadingStylesSection(brightness),
            ],
          ),
        ),
        // FloatingActionButton Theme Test
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleTheme,
          child: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
          // FAB Theme Test - Custom FAB styling from AppTheme
        ),
      ),
    );
  }

  /// Theme Mode Indicator - Shows current active theme
  Widget _buildThemeModeIndicator(Brightness brightness) {
    return Card(
      // Card Theme Test - Custom card styling
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 32,
              // Icon Theme Test - Primary color from theme
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aktif Tema: ${_isDarkMode ? "Dark Mode" : "Light Mode"}',
                  // Title Text Style Test - Material 3 typography
                  style: AppTextStyles.getTextTheme(brightness).titleLarge,
                ),
                Text(
                  'Tema sistemi Material 3 uyumlu',
                  // Body Text Style Test - Secondary text color
                  style: AppTextStyles.getTextTheme(brightness).bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Color Palette Section - Shows all available colors
  Widget _buildColorPaletteSection(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎨 Renk Paleti',
          // Section Header Test - Headline text style
          style: AppTextStyles.getTextTheme(brightness).headlineMedium,
        ),
        const SizedBox(height: 16),

        // Primary Colors
        _buildColorGroup('Primary Colors', [
          _ColorInfo('Primary', colorScheme.primary, '#6366F1'),
          _ColorInfo('On Primary', colorScheme.onPrimary, '#FFFFFF'),
          _ColorInfo(
            'Primary Container',
            colorScheme.primaryContainer,
            '#E0E7FF',
          ),
          _ColorInfo(
            'On Primary Container',
            colorScheme.onPrimaryContainer,
            '#312E81',
          ),
        ], brightness),

        const SizedBox(height: 16),

        // Secondary Colors
        _buildColorGroup('Secondary Colors', [
          _ColorInfo('Secondary', colorScheme.secondary, '#8B5CF6'),
          _ColorInfo('On Secondary', colorScheme.onSecondary, '#FFFFFF'),
          _ColorInfo(
            'Secondary Container',
            colorScheme.secondaryContainer,
            '#EDE9FE',
          ),
          _ColorInfo(
            'On Secondary Container',
            colorScheme.onSecondaryContainer,
            '#581C87',
          ),
        ], brightness),

        const SizedBox(height: 16),

        // Surface Colors
        _buildColorGroup('Surface Colors', [
          _ColorInfo(
            'Surface',
            colorScheme.surface,
            _isDarkMode ? '#1E293B' : '#FFFFFF',
          ),
          _ColorInfo(
            'On Surface',
            colorScheme.onSurface,
            _isDarkMode ? '#F1F5F9' : '#1F2937',
          ),
          _ColorInfo(
            'Surface Variant',
            colorScheme.surfaceVariant,
            _isDarkMode ? '#334155' : '#F3F4F6',
          ),
          _ColorInfo(
            'On Surface Variant',
            colorScheme.onSurfaceVariant,
            _isDarkMode ? '#94A3B8' : '#6B7280',
          ),
        ], brightness),

        const SizedBox(height: 16),

        // Error Colors
        _buildColorGroup('Error Colors', [
          _ColorInfo(
            'Error',
            colorScheme.error,
            _isDarkMode ? '#F87171' : '#EF4444',
          ),
          _ColorInfo(
            'On Error',
            colorScheme.onError,
            _isDarkMode ? '#991B1B' : '#FFFFFF',
          ),
          _ColorInfo(
            'Error Container',
            colorScheme.errorContainer,
            _isDarkMode ? '#DC2626' : '#FEF2F2',
          ),
          _ColorInfo(
            'On Error Container',
            colorScheme.onErrorContainer,
            _isDarkMode ? '#FEF2F2' : '#991B1B',
          ),
        ], brightness),

        const SizedBox(height: 16),

        // Semantic Colors
        _buildColorGroup('Semantic Colors', [
          _ColorInfo(
            'Success',
            AppColors.getSuccessColor(brightness),
            _isDarkMode ? '#34D399' : '#10B981',
          ),
          _ColorInfo(
            'Warning',
            AppColors.getWarningColor(brightness),
            _isDarkMode ? '#FBBF24' : '#F59E0B',
          ),
          _ColorInfo(
            'Info',
            AppColors.getInfoColor(brightness),
            _isDarkMode ? '#60A5FA' : '#3B82F6',
          ),
        ], brightness),
      ],
    );
  }

  /// Color Group - Displays a group of related colors
  Widget _buildColorGroup(
    String title,
    List<_ColorInfo> colors,
    Brightness brightness,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          // Color Group Title Test - Title text style
          style: AppTextStyles.getTextTheme(brightness).titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors
              .map((color) => _buildColorCard(color, brightness))
              .toList(),
        ),
      ],
    );
  }

  /// Color Card - Individual color display
  Widget _buildColorCard(_ColorInfo colorInfo, Brightness brightness) {
    return SizedBox(
      width: 140,
      child: Card(
        // Card Theme Test - Color display cards
        child: Column(
          children: [
            // Color Sample
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: colorInfo.color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    colorInfo.name,
                    // Color Name Test - Label text style
                    style: AppTextStyles.getTextTheme(brightness).labelMedium,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    colorInfo.hexCode,
                    // Hex Code Test - Caption text style
                    style: AppTextStyles.getTextTheme(brightness).bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Typography Section - Shows all text styles
  Widget _buildTypographySection(Brightness brightness) {
    final textTheme = AppTextStyles.getTextTheme(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📝 Tipografi Sistemi', style: textTheme.headlineMedium),
        const SizedBox(height: 16),

        // Display Styles
        _buildTypographyGroup('Display Styles', [
          _TextStyleInfo(
            'Display Large',
            'Ana Başlık Stili',
            textTheme.displayLarge!,
          ),
          _TextStyleInfo(
            'Display Medium',
            'Orta Başlık Stili',
            textTheme.displayMedium!,
          ),
          _TextStyleInfo(
            'Display Small',
            'Küçük Başlık Stili',
            textTheme.displaySmall!,
          ),
        ]),

        const SizedBox(height: 16),

        // Headline Styles
        _buildTypographyGroup('Headline Styles', [
          _TextStyleInfo(
            'Headline Large',
            'Büyük Bölüm Başlığı',
            textTheme.headlineLarge!,
          ),
          _TextStyleInfo(
            'Headline Medium',
            'Orta Bölüm Başlığı',
            textTheme.headlineMedium!,
          ),
          _TextStyleInfo(
            'Headline Small',
            'Küçük Bölüm Başlığı',
            textTheme.headlineSmall!,
          ),
        ]),

        const SizedBox(height: 16),

        // Title Styles
        _buildTypographyGroup('Title Styles', [
          _TextStyleInfo(
            'Title Large',
            'Büyük Kart Başlığı',
            textTheme.titleLarge!,
          ),
          _TextStyleInfo(
            'Title Medium',
            'Orta Kart Başlığı',
            textTheme.titleMedium!,
          ),
          _TextStyleInfo(
            'Title Small',
            'Küçük Kart Başlığı',
            textTheme.titleSmall!,
          ),
        ]),

        const SizedBox(height: 16),

        // Body Styles
        _buildTypographyGroup('Body Styles', [
          _TextStyleInfo(
            'Body Large',
            'Büyük paragraf metni okuma için optimize edilmiş',
            textTheme.bodyLarge!,
          ),
          _TextStyleInfo(
            'Body Medium',
            'Orta paragraf metni günlük kullanım için ideal',
            textTheme.bodyMedium!,
          ),
          _TextStyleInfo(
            'Body Small',
            'Küçük paragraf metni alt açıklamalar için',
            textTheme.bodySmall!,
          ),
        ]),

        const SizedBox(height: 16),

        // Label Styles
        _buildTypographyGroup('Label Styles', [
          _TextStyleInfo('Label Large', 'Büyük Etiket', textTheme.labelLarge!),
          _TextStyleInfo('Label Medium', 'Orta Etiket', textTheme.labelMedium!),
          _TextStyleInfo('Label Small', 'Küçük Etiket', textTheme.labelSmall!),
        ]),
      ],
    );
  }

  /// Typography Group - Groups related text styles
  Widget _buildTypographyGroup(String title, List<_TextStyleInfo> styles) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.getTextTheme(
                _isDarkMode ? Brightness.dark : Brightness.light,
              ).titleMedium,
            ),
            const SizedBox(height: 12),
            ...styles.map(
              (style) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(style.example, style: style.textStyle),
                    Text(
                      '${style.name} - ${style.textStyle.fontSize?.toInt()}px',
                      style: AppTextStyles.getTextTheme(
                        _isDarkMode ? Brightness.dark : Brightness.light,
                      ).bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Button Styles Section - Shows all button variants
  Widget _buildButtonStylesSection(Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔘 Button Stilleri',
          style: AppTextStyles.getTextTheme(brightness).headlineMedium,
        ),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primary Buttons
                Text(
                  'Primary Buttons - Ana Aksiyonlar',
                  style: AppTextStyles.getTextTheme(brightness).titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Normal Button'),
                      // ElevatedButton Theme Test - Primary button styling
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Icon Button'),
                      // ElevatedButton.icon Theme Test
                    ),
                    const ElevatedButton(
                      onPressed: null,
                      child: Text('Disabled Button'),
                      // Disabled state test
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Secondary Buttons
                Text(
                  'Secondary Buttons - İkincil Aksiyonlar',
                  style: AppTextStyles.getTextTheme(brightness).titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Outlined Button'),
                      // OutlinedButton Theme Test - Secondary button styling
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Button'),
                      // OutlinedButton.icon Theme Test
                    ),
                    const OutlinedButton(
                      onPressed: null,
                      child: Text('Disabled Outlined'),
                      // Disabled outlined button test
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Text Buttons
                Text(
                  'Text Buttons - Minimal Aksiyonlar',
                  style: AppTextStyles.getTextTheme(brightness).titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Text Button'),
                      // TextButton Theme Test - Minimal button styling
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.info),
                      label: const Text('Info Button'),
                      // TextButton.icon Theme Test
                    ),
                    const TextButton(
                      onPressed: null,
                      child: Text('Disabled Text'),
                      // Disabled text button test
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Form Styles Section - Shows form field examples
  Widget _buildFormStylesSection(Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📋 Form Stilleri',
          style: AppTextStyles.getTextTheme(brightness).headlineMedium,
        ),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Form Field Examples - Input Decoration Theme Test',
                    style: AppTextStyles.getTextTheme(brightness).titleMedium,
                  ),
                  const SizedBox(height: 16),

                  // Standard Text Field
                  TextFormField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Standard Text Field',
                      hintText: 'Placeholder text burada',
                      prefixIcon: Icon(Icons.person),
                      helperText: 'Bu bir helper text örneğidir',
                    ),
                    // InputDecoration Theme Test - Standard field styling
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password Field',
                      hintText: 'Şifrenizi girin',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.visibility),
                    ),
                    // Password field theme test
                  ),

                  const SizedBox(height: 16),

                  // Error Field
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Error Field',
                      hintText: 'Bu field hata durumunda',
                      prefixIcon: Icon(Icons.error),
                      errorText: 'Bu bir hata mesajı örneğidir',
                    ),
                    // Error state theme test
                  ),

                  const SizedBox(height: 16),

                  // Multiline Field
                  TextFormField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Multiline Field',
                      hintText: 'Çok satırlı metin alanı...',
                      alignLabelWithHint: true,
                    ),
                    // Multiline field theme test
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Component Themes Section - Shows other widget themes
  Widget _buildComponentThemesSection(Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🧩 Component Themes',
          style: AppTextStyles.getTextTheme(brightness).headlineMedium,
        ),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interactive Components',
                  style: AppTextStyles.getTextTheme(brightness).titleMedium,
                ),
                const SizedBox(height: 16),

                // Switch
                Row(
                  children: [
                    Switch(
                      value: _switchValue,
                      onChanged: (value) =>
                          setState(() => _switchValue = value),
                      // Switch Theme Test
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Switch Component',
                      style: AppTextStyles.getTextTheme(brightness).bodyMedium,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _switchValue,
                      onChanged: (value) =>
                          setState(() => _switchValue = value ?? false),
                      // Checkbox Theme Test
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Checkbox Component',
                      style: AppTextStyles.getTextTheme(brightness).bodyMedium,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Radio
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _switchValue,
                      onChanged: (value) =>
                          setState(() => _switchValue = value ?? false),
                      // Radio Theme Test
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Radio Component',
                      style: AppTextStyles.getTextTheme(brightness).bodyMedium,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Slider Component',
                      style: AppTextStyles.getTextTheme(brightness).bodyMedium,
                    ),
                    Slider(
                      value: _sliderValue,
                      onChanged: (value) =>
                          setState(() => _sliderValue = value),
                      // Slider Theme Test
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress Indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Indicators',
                      style: AppTextStyles.getTextTheme(brightness).bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: _sliderValue),
                    const SizedBox(height: 8),
                    const Center(child: CircularProgressIndicator()),
                    // Progress Indicator Theme Test
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Reading Styles Section - Shows content-specific styles
  Widget _buildReadingStylesSection(Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📖 Reading Styles',
          style: AppTextStyles.getTextTheme(brightness).headlineMedium,
        ),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Story Title
                Text(
                  'Örnek Hikaye Başlığı',
                  style: ReadingStyles.storyTitle(brightness),
                  // ReadingStyles.storyTitle Test - Story content styling
                ),

                const SizedBox(height: 8),

                // Author Name
                Text(
                  'Yazar: Örnek Yazarı',
                  style: ReadingStyles.authorName(brightness),
                  // ReadingStyles.authorName Test - Author styling
                ),

                const SizedBox(height: 8),

                // Reading Time
                Text(
                  'Okuma süresi: 5 dakika',
                  style: ReadingStyles.readingTime(brightness),
                  // ReadingStyles.readingTime Test - Reading time indicator
                ),

                const SizedBox(height: 16),

                // Chapter Title
                Text(
                  'Bölüm 1: Başlangıç',
                  style: ReadingStyles.chapterTitle(brightness),
                  // ReadingStyles.chapterTitle Test - Chapter styling
                ),

                const SizedBox(height: 12),

                // Story Content
                Text(
                  'Bu bir örnek hikaye içeriğidir. ReadingStyles.storyContent stili '
                  'uzun metinlerin okunabilirliği için özel olarak optimize edilmiştir. '
                  'Satır aralığı, harf aralığı ve font büyüklüğü okuma deneyimini '
                  'iyileştirmek için ayarlanmıştır. Bu metin reading-focused tipografi '
                  'sisteminin nasıl çalıştığını göstermektedir.',
                  style: ReadingStyles.storyContent(brightness),
                  // ReadingStyles.storyContent Test - Main content styling
                ),

                const SizedBox(height: 16),

                // Different font sizes
                Text(
                  'Küçük font boyutu (14px)',
                  style: ReadingStyles.storyContent(brightness, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Orta font boyutu (16px)',
                  style: ReadingStyles.storyContent(brightness, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Büyük font boyutu (18px)',
                  style: ReadingStyles.storyContent(brightness, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== DATA MODELS ====================

/// Color Information Model
class _ColorInfo {
  final String name;
  final Color color;
  final String hexCode;

  _ColorInfo(this.name, this.color, this.hexCode);
}

/// Text Style Information Model
class _TextStyleInfo {
  final String name;
  final String example;
  final TextStyle textStyle;

  _TextStyleInfo(this.name, this.example, this.textStyle);
}
