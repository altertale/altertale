import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Smart error widget with contextual error handling and recovery options
class SmartErrorWidget extends StatelessWidget {
  final String error;
  final ErrorType type;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final String? customMessage;
  final String? customSubtitle;
  final List<ErrorAction>? customActions;
  final bool showDetails;

  const SmartErrorWidget({
    Key? key,
    required this.error,
    this.type = ErrorType.generic,
    this.onRetry,
    this.onGoBack,
    this.customMessage,
    this.customSubtitle,
    this.customActions,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorInfo = _getErrorInfo();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: errorInfo.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(errorInfo.icon, size: 40, color: errorInfo.color),
          ),

          const SizedBox(height: 24),

          // Error Title
          Text(
            customMessage ?? errorInfo.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: errorInfo.color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Error Subtitle
          Text(
            customSubtitle ?? errorInfo.subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
            textAlign: TextAlign.center,
          ),

          if (showDetails) ...[
            const SizedBox(height: 16),
            _buildErrorDetails(theme),
          ],

          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(context, errorInfo),

          if (errorInfo.suggestions.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSuggestions(theme, errorInfo.suggestions),
          ],
        ],
      ),
    );
  }

  ErrorInfo _getErrorInfo() {
    switch (type) {
      case ErrorType.network:
        return ErrorInfo(
          icon: Icons.wifi_off,
          title: 'Bağlantı Problemi',
          subtitle: 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.',
          color: Colors.orange,
          suggestions: [
            'WiFi bağlantınızı kontrol edin',
            'Mobil verilerinizi açmayı deneyin',
            'Birkaç dakika sonra tekrar deneyin',
          ],
        );

      case ErrorType.auth:
        return ErrorInfo(
          icon: Icons.lock_outline,
          title: 'Yetkilendirme Hatası',
          subtitle: 'Oturum açmanız gerekiyor.',
          color: Colors.red,
          suggestions: [
            'Giriş yapın veya hesap oluşturun',
            'Şifrenizi sıfırlamayı deneyin',
            'Hesap bilgilerinizi kontrol edin',
          ],
        );

      case ErrorType.notFound:
        return ErrorInfo(
          icon: Icons.search_off,
          title: 'İçerik Bulunamadı',
          subtitle: 'Aradığınız içerik mevcut değil veya kaldırılmış.',
          color: Colors.blue,
          suggestions: [
            'Arama terimlerinizi değiştirin',
            'Kategorileri kontrol edin',
            'Ana sayfaya dönün',
          ],
        );

      case ErrorType.server:
        return ErrorInfo(
          icon: Icons.cloud_off,
          title: 'Sunucu Hatası',
          subtitle: 'Sunucularımızda geçici bir sorun var.',
          color: Colors.purple,
          suggestions: [
            'Birkaç dakika sonra tekrar deneyin',
            'Uygulamayı yeniden başlatın',
            'Destek ekibiyle iletişime geçin',
          ],
        );

      case ErrorType.validation:
        return ErrorInfo(
          icon: Icons.error_outline,
          title: 'Geçersiz Veri',
          subtitle: 'Girdiğiniz bilgiler doğru formatta değil.',
          color: Colors.amber,
          suggestions: [
            'Tüm alanları doğru doldurun',
            'Özel karakterleri kontrol edin',
            'Zorunlu alanları doldurun',
          ],
        );

      case ErrorType.permission:
        return ErrorInfo(
          icon: Icons.block,
          title: 'İzin Gerekli',
          subtitle: 'Bu işlem için ek izinler gerekiyor.',
          color: Colors.indigo,
          suggestions: [
            'Uygulama ayarlarından izinleri açın',
            'Cihaz ayarlarını kontrol edin',
            'Uygulamayı yeniden başlatın',
          ],
        );

      case ErrorType.storage:
        return ErrorInfo(
          icon: Icons.storage,
          title: 'Depolama Hatası',
          subtitle: 'Cihazınızda yeterli depolama alanı yok.',
          color: Colors.brown,
          suggestions: [
            'Gereksiz dosyaları silin',
            'Önbelleği temizleyin',
            'Uygulamaları kontrol edin',
          ],
        );

      case ErrorType.generic:
      default:
        return ErrorInfo(
          icon: Icons.error,
          title: 'Bir Hata Oluştu',
          subtitle: 'Beklenmeyen bir sorun yaşandı.',
          color: Colors.grey,
          suggestions: [
            'Sayfayı yenileyin',
            'Uygulamayı yeniden başlatın',
            'Destek ekibiyle iletişime geçin',
          ],
        );
    }
  }

  Widget _buildErrorDetails(ThemeData theme) {
    return ExpansionTile(
      title: Text('Hata Detayları', style: theme.textTheme.titleSmall),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teknik Detay:',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                error,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _copyToClipboard(error),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Kopyala'),
                    style: TextButton.styleFrom(
                      textStyle: theme.textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ErrorInfo errorInfo) {
    final actions = customActions ?? _getDefaultActions(context, errorInfo);

    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: actions.map((action) => _buildActionButton(action)).toList(),
    );
  }

  Widget _buildActionButton(ErrorAction action) {
    if (action.isPrimary) {
      return ElevatedButton.icon(
        onPressed: action.onPressed,
        icon: Icon(action.icon),
        label: Text(action.label),
        style: ElevatedButton.styleFrom(
          backgroundColor: action.color,
          foregroundColor: Colors.white,
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: action.onPressed,
        icon: Icon(action.icon),
        label: Text(action.label),
        style: OutlinedButton.styleFrom(
          foregroundColor: action.color,
          side: BorderSide(color: action.color),
        ),
      );
    }
  }

  List<ErrorAction> _getDefaultActions(
    BuildContext context,
    ErrorInfo errorInfo,
  ) {
    final actions = <ErrorAction>[];

    // Retry action
    if (onRetry != null) {
      actions.add(
        ErrorAction(
          label: 'Tekrar Dene',
          icon: Icons.refresh,
          onPressed: onRetry!,
          isPrimary: true,
          color: errorInfo.color,
        ),
      );
    }

    // Go back action
    if (onGoBack != null) {
      actions.add(
        ErrorAction(
          label: 'Geri Dön',
          icon: Icons.arrow_back,
          onPressed: onGoBack!,
          isPrimary: false,
          color: Colors.grey,
        ),
      );
    }

    // Type-specific actions
    switch (type) {
      case ErrorType.network:
        actions.add(
          ErrorAction(
            label: 'Ayarlar',
            icon: Icons.settings,
            onPressed: () => _openNetworkSettings(),
            isPrimary: false,
            color: Colors.blue,
          ),
        );
        break;

      case ErrorType.auth:
        actions.add(
          ErrorAction(
            label: 'Giriş Yap',
            icon: Icons.login,
            onPressed: () => _navigateToLogin(context),
            isPrimary: false,
            color: Colors.green,
          ),
        );
        break;

      case ErrorType.notFound:
        actions.add(
          ErrorAction(
            label: 'Ana Sayfa',
            icon: Icons.home,
            onPressed: () => _navigateToHome(context),
            isPrimary: false,
            color: Colors.indigo,
          ),
        );
        break;

      case ErrorType.server:
        actions.add(
          ErrorAction(
            label: 'Destek',
            icon: Icons.support,
            onPressed: () => _contactSupport(),
            isPrimary: false,
            color: Colors.purple,
          ),
        );
        break;

      default:
        break;
    }

    return actions;
  }

  Widget _buildSuggestions(ThemeData theme, List<String> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Öneriler:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...suggestions.map(
          (suggestion) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(suggestion, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void _openNetworkSettings() {
    // Platform-specific network settings opening
    print('Opening network settings...');
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _contactSupport() {
    // Contact support functionality
    print('Contacting support...');
  }
}

/// Error type enumeration
enum ErrorType {
  network,
  auth,
  notFound,
  server,
  validation,
  permission,
  storage,
  generic,
}

/// Error information data class
class ErrorInfo {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<String> suggestions;

  ErrorInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.suggestions,
  });
}

/// Error action data class
class ErrorAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final Color color;

  ErrorAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    required this.color,
  });
}

/// Convenient error widget builders
class ErrorWidgets {
  static Widget networkError({VoidCallback? onRetry}) {
    return SmartErrorWidget(
      error: 'Network connection failed',
      type: ErrorType.network,
      onRetry: onRetry,
    );
  }

  static Widget notFound({VoidCallback? onGoBack}) {
    return SmartErrorWidget(
      error: 'Content not found',
      type: ErrorType.notFound,
      onGoBack: onGoBack,
    );
  }

  static Widget serverError({VoidCallback? onRetry}) {
    return SmartErrorWidget(
      error: 'Server error occurred',
      type: ErrorType.server,
      onRetry: onRetry,
    );
  }

  static Widget authError() {
    return const SmartErrorWidget(
      error: 'Authentication required',
      type: ErrorType.auth,
    );
  }

  static Widget custom({
    required String error,
    required String message,
    String? subtitle,
    VoidCallback? onRetry,
    VoidCallback? onGoBack,
  }) {
    return SmartErrorWidget(
      error: error,
      type: ErrorType.generic,
      customMessage: message,
      customSubtitle: subtitle,
      onRetry: onRetry,
      onGoBack: onGoBack,
    );
  }
}

/// Error boundary widget for catching and displaying errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
    this.onError,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      } else {
        return SmartErrorWidget(
          error: _error.toString(),
          type: ErrorType.generic,
          onRetry: () {
            setState(() {
              _error = null;
              _stackTrace = null;
            });
          },
        );
      }
    }

    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FlutterError.onError = (details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
        widget.onError?.call(details.exception, details.stack);
      }
    };
  }
}
