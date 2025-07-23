import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom TextField Widget - Altertale Uygulaması için Temaya Uyumlu Input Alanı
///
/// Bu widget, form işlemleri için tutarlı input deneyimi sağlar.
/// Validation, farklı keyboard türleri ve çeşitli özelleştirme seçenekleri sunar.
/// Material 3 design principles'a uygun olarak tasarlanmıştır.
class CustomTextField extends StatefulWidget {
  /// Input alanında gösterilecek placeholder metin
  final String? hintText;

  /// Input alanının üst etiket metni
  final String? labelText;

  /// Text controller - dış taraftan kontrol için
  final TextEditingController? controller;

  /// Şifre alanı için text gizleme
  final bool obscureText;

  /// Keyboard türü (email, number, text, etc.)
  final TextInputType keyboardType;

  /// Validation fonksiyonu
  final String? Function(String?)? validator;

  /// Input değeri değiştiğinde çalışacak fonksiyon
  final void Function(String)? onChanged;

  /// Input tamamlandığında çalışacak fonksiyon
  final void Function(String)? onSubmitted;

  /// Focus kaybedildiğinde çalışacak fonksiyon
  final VoidCallback? onTapOutside;

  /// Input alanının başında gösterilecek ikon
  final IconData? prefixIcon;

  /// Input alanının sonunda gösterilecek ikon
  final IconData? suffixIcon;

  /// Suffix icon'a tıklandığında çalışacak fonksiyon
  final VoidCallback? onSuffixIconPressed;

  /// Input alanının okunabilir olup olmadığı
  final bool readOnly;

  /// Input alanının aktif olup olmadığı
  final bool enabled;

  /// Maksimum satır sayısı (null = tek satır)
  final int? maxLines;

  /// Minimum satır sayısı
  final int? minLines;

  /// Maksimum karakter sayısı
  final int? maxLength;

  /// Input formatters (telefon, para birimi vs.)
  final List<TextInputFormatter>? inputFormatters;

  /// Text capitalization ayarı
  final TextCapitalization textCapitalization;

  /// Input action (next, done, etc.)
  final TextInputAction? textInputAction;

  /// Focus node - dış taraftan focus kontrolü için
  final FocusNode? focusNode;

  /// Error durumunda gösterilecek mesaj
  final String? errorText;

  /// Helper text (yardımcı açıklama)
  final String? helperText;

  const CustomTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.focusNode,
    this.errorText,
    this.helperText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();

    // Focus değişikliklerini dinle
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    // Sadece widget içinde oluşturulan focus node'u dispose et
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label text (varsa)
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: theme.textTheme.labelMedium?.copyWith(
              color: widget.enabled
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurface.withOpacity(0.38),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Text Field
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTapOutside: widget.onTapOutside != null
              ? (_) => widget.onTapOutside!()
              : null,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: widget.enabled
                ? colorScheme.onSurface
                : colorScheme.onSurface.withOpacity(0.38),
          ),
          decoration: _buildInputDecoration(theme, colorScheme),
        ),

        // Helper text (varsa)
        if (widget.helperText != null && widget.errorText == null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  /// Input decoration'ı tema ile uyumlu şekilde oluşturur
  InputDecoration _buildInputDecoration(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return InputDecoration(
      hintText: widget.hintText,
      hintStyle: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),

      // Prefix Icon
      prefixIcon: widget.prefixIcon != null
          ? Icon(
              widget.prefixIcon,
              color: _isFocused
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 20,
            )
          : null,

      // Suffix Icon
      suffixIcon: _buildSuffixIcon(colorScheme),

      // Error text
      errorText: widget.errorText,
      errorStyle: theme.textTheme.bodySmall?.copyWith(color: colorScheme.error),

      // Border styles
      border: _buildBorder(colorScheme.outline),
      enabledBorder: _buildBorder(colorScheme.outline),
      focusedBorder: _buildBorder(colorScheme.primary, width: 2.0),
      errorBorder: _buildBorder(colorScheme.error),
      focusedErrorBorder: _buildBorder(colorScheme.error, width: 2.0),
      disabledBorder: _buildBorder(colorScheme.onSurface.withOpacity(0.12)),

      // Fill color
      filled: true,
      fillColor: widget.enabled
          ? (_isFocused
                ? colorScheme.primaryContainer.withOpacity(0.08)
                : colorScheme.surfaceVariant.withOpacity(0.3))
          : colorScheme.onSurface.withOpacity(0.04),

      // Content padding
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),

      // Dense layout
      isDense: true,

      // Counter
      counterStyle: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// Suffix icon oluşturur (şifre göster/gizle, clear button, vs.)
  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    // Şifre alanı için göster/gizle ikonu
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          size: 20,
        ),
        color: _isFocused ? colorScheme.primary : colorScheme.onSurfaceVariant,
        onPressed: _toggleObscureText,
        tooltip: _obscureText ? 'Şifreyi göster' : 'Şifreyi gizle',
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(widget.suffixIcon, size: 20),
        color: _isFocused ? colorScheme.primary : colorScheme.onSurfaceVariant,
        onPressed: widget.onSuffixIconPressed,
      );
    }

    return null;
  }

  /// Border stilini oluşturur
  OutlineInputBorder _buildBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

/// Custom TextField için özel constructor'lar
extension CustomTextFieldExtensions on CustomTextField {
  /// Email input field oluşturur
  static CustomTextField email({
    Key? key,
    String? hintText,
    String? labelText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? errorText,
  }) {
    return CustomTextField(
      key: key,
      hintText: hintText ?? 'Email adresinizi girin',
      labelText: labelText ?? 'Email',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      prefixIcon: Icons.email_outlined,
      validator: validator,
      onChanged: onChanged,
      errorText: errorText,
    );
  }

  /// Password input field oluşturur
  static CustomTextField password({
    Key? key,
    String? hintText,
    String? labelText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? errorText,
  }) {
    return CustomTextField(
      key: key,
      hintText: hintText ?? 'Şifrenizi girin',
      labelText: labelText ?? 'Şifre',
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
      prefixIcon: Icons.lock_outlined,
      validator: validator,
      onChanged: onChanged,
      errorText: errorText,
    );
  }

  /// Search input field oluşturur
  static CustomTextField search({
    Key? key,
    String? hintText,
    TextEditingController? controller,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    VoidCallback? onClearPressed,
  }) {
    return CustomTextField(
      key: key,
      hintText: hintText ?? 'Arama yapın...',
      controller: controller,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      prefixIcon: Icons.search,
      suffixIcon: Icons.clear,
      onSuffixIconPressed: onClearPressed,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }

  /// Phone number input field oluşturur
  static CustomTextField phone({
    Key? key,
    String? hintText,
    String? labelText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? errorText,
  }) {
    return CustomTextField(
      key: key,
      hintText: hintText ?? '(555) 123 45 67',
      labelText: labelText ?? 'Telefon',
      controller: controller,
      keyboardType: TextInputType.phone,
      prefixIcon: Icons.phone_outlined,
      validator: validator,
      onChanged: onChanged,
      errorText: errorText,
    );
  }

  /// Multiline text area oluşturur
  static CustomTextField textArea({
    Key? key,
    String? hintText,
    String? labelText,
    TextEditingController? controller,
    int maxLines = 4,
    int? maxLength,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? errorText,
  }) {
    return CustomTextField(
      key: key,
      hintText: hintText,
      labelText: labelText,
      controller: controller,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: maxLines,
      minLines: 2,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      errorText: errorText,
    );
  }
}
