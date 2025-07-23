import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reading_settings_provider.dart';
import '../../models/reading_settings_model.dart';

class ReadingSettingsPanel extends StatefulWidget {
  final VoidCallback? onClose;

  const ReadingSettingsPanel({Key? key, this.onClose}) : super(key: key);

  @override
  State<ReadingSettingsPanel> createState() => _ReadingSettingsPanelState();
}

class _ReadingSettingsPanelState extends State<ReadingSettingsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 350,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(theme),
            _buildTabBar(theme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFontTab(),
                  _buildThemeTab(),
                  _buildLayoutTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tune,
            color: theme.colorScheme.onPrimaryContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Okuma Ayarları',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.hintColor,
        indicatorColor: theme.colorScheme.primary,
        tabs: const [
          Tab(icon: Icon(Icons.text_fields), text: 'Font'),
          Tab(icon: Icon(Icons.palette), text: 'Tema'),
          Tab(icon: Icon(Icons.view_agenda), text: 'Düzen'),
        ],
      ),
    );
  }

  Widget _buildFontTab() {
    return Consumer<ReadingSettingsProvider>(
      builder: (context, settings, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Font Boyutu'),
              _buildFontSizeControl(settings),

              const SizedBox(height: 24),

              _buildSectionTitle('Satır Aralığı'),
              _buildLineHeightControl(settings),

              const SizedBox(height: 24),

              _buildSectionTitle('Font Ailesi'),
              _buildFontFamilySelector(settings),

              const SizedBox(height: 24),

              _buildSectionTitle('Harf Aralığı'),
              _buildLetterSpacingControl(settings),

              const SizedBox(height: 24),

              _buildSectionTitle('Metin Hizalama'),
              _buildTextAlignSelector(settings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeTab() {
    return Consumer<ReadingSettingsProvider>(
      builder: (context, settings, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Hazır Temalar'),
              _buildPresetThemes(settings),

              const SizedBox(height: 24),

              _buildSectionTitle('Parlaklık'),
              _buildBrightnessControl(settings),

              const SizedBox(height: 24),

              _buildSectionTitle('Özel Renkler'),
              _buildCustomColors(settings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLayoutTab() {
    return Consumer<ReadingSettingsProvider>(
      builder: (context, settings, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Okuma Modu'),
              _buildReadingModeSelector(settings),

              const SizedBox(height: 24),

              _buildSectionTitle('Sayfa Genişliği'),
              _buildPageWidthControl(settings),

              const SizedBox(height: 24),

              _buildSectionTitle('Otomatik Kaydırma'),
              _buildAutoScrollControls(settings),

              const SizedBox(height: 24),

              _buildSectionTitle('Görünüm Seçenekleri'),
              _buildDisplayOptions(settings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildFontSizeControl(ReadingSettingsProvider settings) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: settings.decreaseFontSize,
              icon: const Icon(Icons.text_decrease),
            ),
            Text(
              '${settings.fontSize.toInt()}pt',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: settings.increaseFontSize,
              icon: const Icon(Icons.text_increase),
            ),
          ],
        ),
        Slider(
          value: settings.fontSize,
          min: 12,
          max: 32,
          divisions: 20,
          onChanged: settings.updateFontSize,
        ),
      ],
    );
  }

  Widget _buildLineHeightControl(ReadingSettingsProvider settings) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Sıkışık'),
            Text(
              '${settings.lineHeight.toStringAsFixed(1)}x',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Geniş'),
          ],
        ),
        Slider(
          value: settings.lineHeight,
          min: 1.0,
          max: 3.0,
          divisions: 20,
          onChanged: settings.updateLineHeight,
        ),
      ],
    );
  }

  Widget _buildFontFamilySelector(ReadingSettingsProvider settings) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReadingSettingsModel.availableFonts.map((font) {
        final isSelected = settings.fontFamily == font;
        return GestureDetector(
          onTap: () => settings.updateFontFamily(font),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? null
                  : Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Text(
              font,
              style: TextStyle(
                fontFamily: font,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLetterSpacingControl(ReadingSettingsProvider settings) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Normal'),
            Text(
              '${settings.settings.letterSpacing.toStringAsFixed(1)}px',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Geniş'),
          ],
        ),
        Slider(
          value: settings.settings.letterSpacing,
          min: -1.0,
          max: 3.0,
          divisions: 40,
          onChanged: settings.updateLetterSpacing,
        ),
      ],
    );
  }

  Widget _buildTextAlignSelector(ReadingSettingsProvider settings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ReadingSettingsModel.textAlignOptions.map((option) {
        final isSelected = settings.textAlign == option['value'];
        return GestureDetector(
          onTap: () => settings.updateTextAlign(option['value']),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  option['icon'],
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  option['label'],
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPresetThemes(ReadingSettingsProvider settings) {
    final presets = [
      {'name': 'Açık', 'theme': ReadingSettingsModel.defaultLight()},
      {'name': 'Koyu', 'theme': ReadingSettingsModel.defaultDark()},
      {'name': 'Sepia', 'theme': ReadingSettingsModel.sepia()},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: presets.map((preset) {
        final theme = preset['theme'] as ReadingSettingsModel;
        final isSelected =
            settings.isDarkMode == theme.isDarkMode &&
            settings.isSepia == theme.isSepia;

        return GestureDetector(
          onTap: () => settings.applyTheme(theme),
          child: Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : theme.textColor.withOpacity(0.3),
                width: isSelected ? 3 : 1,
              ),
            ),
            child: Center(
              child: Text(
                'Aa',
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBrightnessControl(ReadingSettingsProvider settings) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.brightness_low),
            Text(
              '${(settings.brightness * 100).toInt()}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.brightness_high),
          ],
        ),
        Slider(
          value: settings.brightness,
          min: 0.3,
          max: 1.0,
          divisions: 7,
          onChanged: settings.updateBrightness,
        ),
      ],
    );
  }

  Widget _buildCustomColors(ReadingSettingsProvider settings) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildColorPicker(
                'Arka Plan',
                settings.backgroundColor,
                settings.updateBackgroundColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildColorPicker(
                'Metin',
                settings.textColor,
                settings.updateTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorPicker(
    String label,
    Color color,
    Function(Color) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _showColorPicker(color, onChanged),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadingModeSelector(ReadingSettingsProvider settings) {
    return Column(
      children: ReadingSettingsModel.readingModeOptions.map((mode) {
        final isSelected = settings.readingMode == mode['value'];
        return ListTile(
          leading: Icon(mode['icon']),
          title: Text(mode['label']),
          subtitle: Text(mode['description']),
          trailing: isSelected ? const Icon(Icons.check) : null,
          selected: isSelected,
          onTap: () => settings.updateReadingMode(mode['value']),
        );
      }).toList(),
    );
  }

  Widget _buildPageWidthControl(ReadingSettingsProvider settings) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Dar'),
            Text(
              '${settings.settings.pageWidth.toInt()}px',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Geniş'),
          ],
        ),
        Slider(
          value: settings.settings.pageWidth,
          min: 400,
          max: 800,
          divisions: 8,
          onChanged: settings.updatePageWidth,
        ),
      ],
    );
  }

  Widget _buildAutoScrollControls(ReadingSettingsProvider settings) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Otomatik Kaydırma'),
          subtitle: const Text('Metin otomatik olarak kaydırılsın'),
          value: settings.autoScroll,
          onChanged: (_) => settings.toggleAutoScroll(),
        ),
        if (settings.autoScroll) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Hız: '),
              Expanded(
                child: Slider(
                  value: settings.autoScrollSpeed,
                  min: 0.5,
                  max: 3.0,
                  divisions: 5,
                  label: '${settings.autoScrollSpeed.toStringAsFixed(1)}x',
                  onChanged: settings.updateAutoScrollSpeed,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDisplayOptions(ReadingSettingsProvider settings) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Sayfa Numaraları'),
          subtitle: const Text('Sayfa numaralarını göster'),
          value: settings.settings.showPageNumbers,
          onChanged: (value) {
            final newSettings = settings.settings.copyWith(
              showPageNumbers: value,
            );
            settings.applySettings(newSettings);
          },
        ),
        SwitchListTile(
          title: const Text('İlerleme Çubuğu'),
          subtitle: const Text('Okuma ilerlemesini göster'),
          value: settings.settings.showProgressBar,
          onChanged: (value) {
            final newSettings = settings.settings.copyWith(
              showProgressBar: value,
            );
            settings.applySettings(newSettings);
          },
        ),
      ],
    );
  }

  void _showColorPicker(Color currentColor, Function(Color) onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renk Seç'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: currentColor,
            onColorChanged: onChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

/// Simple color picker using predefined colors
class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final Function(Color) onColorChanged;

  const BlockPicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const colors = [
      Colors.white,
      Colors.black,
      Color(0xFFF4F1E8), // Sepia background
      Color(0xFF1A1A1A), // Dark background
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: pickerColor == color ? Colors.blue : Colors.grey,
                width: pickerColor == color ? 3 : 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
