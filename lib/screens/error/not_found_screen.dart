import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../navigation/route_names.dart';

/// 404 - Sayfa Bulunamadı Ekranı
/// Bilinmeyen route'larda gösterilir
class NotFoundScreen extends StatelessWidget {
  final String? attemptedRoute;

  const NotFoundScreen({super.key, this.attemptedRoute});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => _navigateToHome(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 404 İkon ve Animasyon
              _build404Icon(theme),

              const SizedBox(height: 32),

              // Başlık
              Text(
                'Sayfa Bulunamadı',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Açıklama
              Text(
                attemptedRoute != null
                    ? 'Aradığınız sayfa mevcut değil.\n"$attemptedRoute" bulunamadı.'
                    : 'Aradığınız sayfa mevcut değil veya taşınmış olabilir.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Ana Sayfa Butonu
              _buildHomeButton(theme, context),

              const SizedBox(height: 16),

              // Geri Git Butonu
              _buildBackButton(theme, context),

              const SizedBox(height: 32),

              // Debug Bilgisi (sadece debug mode'da)
              if (kDebugMode && attemptedRoute != null) _buildDebugInfo(theme),
            ],
          ),
        ),
      ),
    );
  }

  /// 404 ikonu
  Widget _build404Icon(ThemeData theme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(60),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan desen
          CustomPaint(
            size: const Size(120, 120),
            painter: _ErrorPatternPainter(
              color: theme.colorScheme.onErrorContainer.withAlpha(
                51,
              ), // 0.2 opacity
            ),
          ),

          // 404 Text
          Text(
            '404',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  /// Ana sayfa butonu
  Widget _buildHomeButton(ThemeData theme, BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToHome(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.home_rounded),
        label: const Text(
          'Ana Sayfaya Dön',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Geri git butonu
  Widget _buildBackButton(ThemeData theme, BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => _goBack(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.arrow_back_rounded),
        label: const Text(
          'Geri Git',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Debug bilgisi
  Widget _buildDebugInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(
          77,
        ), // 0.3 opacity
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(51), // 0.2 opacity
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debug Bilgisi:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Attempted Route: $attemptedRoute',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            'Valid Routes: Available',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  /// Ana sayfaya yönlendir
  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      RouteNames.home,
      (route) => false, // Tüm route'ları temizle
    );
  }

  /// Geri git
  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      _navigateToHome(context);
    }
  }
}

/// 404 ikon için pattern çizici
class _ErrorPatternPainter extends CustomPainter {
  final Color color;

  _ErrorPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Daire çiz
    canvas.drawCircle(center, radius, paint);

    // X çiz
    canvas.drawLine(
      Offset(center.dx - radius / 2, center.dy - radius / 2),
      Offset(center.dx + radius / 2, center.dy + radius / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius / 2, center.dy - radius / 2),
      Offset(center.dx - radius / 2, center.dy + radius / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
