import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReadingProgressBar extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final Function(int)? onPageTap;
  final Color? progressColor;
  final Color? backgroundColor;

  const ReadingProgressBar({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    this.onPageTap,
    this.progressColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<ReadingProgressBar> createState() => _ReadingProgressBarState();
}

class _ReadingProgressBarState extends State<ReadingProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation =
        Tween<double>(
          begin: 0.0,
          end: widget.currentPage / widget.totalPages,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(ReadingProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentPage != widget.currentPage) {
      _progressAnimation =
          Tween<double>(
            begin: _progressAnimation.value,
            end: widget.currentPage / widget.totalPages,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            ),
          );

      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressColor =
        widget.progressColor ?? Theme.of(context).colorScheme.primary;
    final backgroundColor =
        widget.backgroundColor ?? Colors.white.withOpacity(0.3);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
        ),
      ),
      child: Column(
        children: [
          // Progress Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sayfa ${widget.currentPage + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${((widget.currentPage + 1) / widget.totalPages * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${widget.totalPages} sayfa',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress Bar
          GestureDetector(
            onTapDown: (details) => _handleProgressTap(details),
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(3),
              ),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Progress Fill
                      FractionallySizedBox(
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: progressColor,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: progressColor.withOpacity(0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Current Position Indicator
                      Positioned(
                        left:
                            (_progressAnimation.value *
                                (MediaQuery.of(context).size.width - 32)) -
                            4,
                        top: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: progressColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleProgressTap(TapDownDetails details) {
    if (widget.onPageTap == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final progressWidth = renderBox.size.width - 32; // Account for padding
    final tapPosition = (localPosition.dx - 16).clamp(0.0, progressWidth);

    final progress = tapPosition / progressWidth;
    final targetPage = (progress * widget.totalPages).round().clamp(
      0,
      widget.totalPages - 1,
    );

    widget.onPageTap!(targetPage);

    // Haptic feedback
    HapticFeedback.lightImpact();
  }
}

/// Mini progress indicator for app bars
class MiniProgressIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color? color;
  final double width;

  const MiniProgressIndicator({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    this.color,
    this.width = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = currentPage / totalPages;
    final indicatorColor = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: indicatorColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
