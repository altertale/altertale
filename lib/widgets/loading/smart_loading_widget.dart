import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Smart loading widget with contextual animations and messages
class SmartLoadingWidget extends StatefulWidget {
  final LoadingType type;
  final String? message;
  final String? subtitle;
  final bool showProgress;
  final double? progress;
  final Color? color;
  final double size;
  final Duration animationDuration;

  const SmartLoadingWidget({
    Key? key,
    this.type = LoadingType.books,
    this.message,
    this.subtitle,
    this.showProgress = false,
    this.progress,
    this.color,
    this.size = 80,
    this.animationDuration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<SmartLoadingWidget> createState() => _SmartLoadingWidgetState();
}

class _SmartLoadingWidgetState extends State<SmartLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _controller.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.color ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: _buildLoadingIcon(primaryColor),
              );
            },
          ),
        ),

        if (widget.showProgress && widget.progress != null) ...[
          const SizedBox(height: 16),
          _buildProgressBar(primaryColor),
        ],

        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        if (widget.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIcon(Color color) {
    switch (widget.type) {
      case LoadingType.books:
        return _buildBookLoadingIcon(color);
      case LoadingType.search:
        return _buildSearchLoadingIcon(color);
      case LoadingType.sync:
        return _buildSyncLoadingIcon(color);
      case LoadingType.reading:
        return _buildReadingLoadingIcon(color);
      case LoadingType.upload:
        return _buildUploadLoadingIcon(color);
      case LoadingType.download:
        return _buildDownloadLoadingIcon(color);
      case LoadingType.generic:
      default:
        return _buildGenericLoadingIcon(color);
    }
  }

  Widget _buildBookLoadingIcon(Color color) {
    return Transform.rotate(
      angle: _rotationAnimation.value,
      child: CustomPaint(
        painter: BookLoadingPainter(color),
        size: Size(widget.size, widget.size),
      ),
    );
  }

  Widget _buildSearchLoadingIcon(Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: _rotationAnimation.value,
          child: Icon(
            Icons.search,
            size: widget.size * 0.6,
            color: color.withOpacity(0.3),
          ),
        ),
        Positioned.fill(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncLoadingIcon(Color color) {
    return Transform.rotate(
      angle: _rotationAnimation.value,
      child: Icon(Icons.sync, size: widget.size * 0.7, color: color),
    );
  }

  Widget _buildReadingLoadingIcon(Color color) {
    return CustomPaint(
      painter: ReadingLoadingPainter(color, _rotationAnimation.value),
      size: Size(widget.size, widget.size),
    );
  }

  Widget _buildUploadLoadingIcon(Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, -10 * _pulseAnimation.value),
          child: Icon(
            Icons.cloud_upload,
            size: widget.size * 0.5,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: widget.size * 0.8,
          height: 4,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (_rotationAnimation.value / (2 * math.pi)).clamp(
              0.0,
              1.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadLoadingIcon(Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, 10 * _pulseAnimation.value),
          child: Icon(
            Icons.cloud_download,
            size: widget.size * 0.5,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: widget.size * 0.8,
          height: 4,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (_rotationAnimation.value / (2 * math.pi)).clamp(
              0.0,
              1.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenericLoadingIcon(Color color) {
    return CircularProgressIndicator(
      strokeWidth: 4,
      valueColor: AlwaysStoppedAnimation<Color>(color),
    );
  }

  Widget _buildProgressBar(Color color) {
    return Column(
      children: [
        Container(
          width: widget.size * 1.5,
          height: 6,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widget.progress!.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(widget.progress! * 100).toInt()}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Loading type enumeration
enum LoadingType { books, search, sync, reading, upload, download, generic }

/// Custom painter for book loading animation
class BookLoadingPainter extends CustomPainter {
  final Color color;

  BookLoadingPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = size.center(Offset.zero);
    final radius = size.width / 3;

    // Draw book pages
    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: 12, height: 16),
        paint..style = PaintingStyle.fill,
      );
    }

    // Draw center circle
    canvas.drawCircle(
      center,
      8,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(BookLoadingPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Custom painter for reading loading animation
class ReadingLoadingPainter extends CustomPainter {
  final Color color;
  final double progress;

  ReadingLoadingPainter(this.color, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = size.center(Offset.zero);
    final pageWidth = size.width * 0.3;
    final pageHeight = size.height * 0.4;

    // Draw left page
    final leftPage = Rect.fromCenter(
      center: Offset(center.dx - pageWidth / 2, center.dy),
      width: pageWidth,
      height: pageHeight,
    );
    canvas.drawRect(leftPage, paint..color = color.withOpacity(0.3));

    // Draw right page with animation
    final rightPage = Rect.fromCenter(
      center: Offset(center.dx + pageWidth / 2, center.dy),
      width: pageWidth,
      height: pageHeight,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * 0.3);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRect(rightPage, paint..color = color);
    canvas.restore();

    // Draw lines on pages
    paint.color = Colors.white;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      final y = leftPage.top + 10 + (i * 8);
      canvas.drawLine(
        Offset(leftPage.left + 5, y),
        Offset(leftPage.right - 5, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ReadingLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final LoadingType type;
  final String? message;
  final Color? overlayColor;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.type = LoadingType.generic,
    this.message,
    this.overlayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withOpacity(0.5),
            child: Center(
              child: SmartLoadingWidget(type: type, message: message),
            ),
          ),
      ],
    );
  }
}

/// Skelton loading widget for content placeholders
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [
                  math.max(0.0, _animation.value - 0.3),
                  math.max(0.0, _animation.value),
                  math.min(1.0, _animation.value + 0.3),
                ],
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Book card skeleton
class BookCardSkeleton extends StatelessWidget {
  const BookCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLoader(width: double.infinity, height: 150),
            const SizedBox(height: 8),
            const SkeletonLoader(width: double.infinity, height: 16),
            const SizedBox(height: 4),
            SkeletonLoader(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 14,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SkeletonLoader(width: 60, height: 12),
                const Spacer(),
                const SkeletonLoader(width: 40, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
