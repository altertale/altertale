import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animation service for managing smooth transitions and effects
class AnimationService {
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration verySlowDuration = Duration(milliseconds: 800);

  /// Fade transition
  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
    Duration? duration,
  }) {
    return FadeTransition(opacity: animation, child: child);
  }

  /// Slide transition from direction
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.bottom,
    double offset = 1.0,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.top:
        begin = Offset(0, -offset);
        break;
      case SlideDirection.bottom:
        begin = Offset(0, offset);
        break;
      case SlideDirection.left:
        begin = Offset(-offset, 0);
        break;
      case SlideDirection.right:
        begin = Offset(offset, 0);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  }

  /// Scale transition
  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
    double startScale = 0.0,
    double endScale = 1.0,
    Alignment alignment = Alignment.center,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: startScale,
        end: endScale,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut)),
      alignment: alignment,
      child: child,
    );
  }

  /// Rotation transition
  static Widget rotationTransition({
    required Widget child,
    required Animation<double> animation,
    double turns = 1.0,
  }) {
    return RotationTransition(
      turns: Tween<double>(begin: 0, end: turns).animate(animation),
      child: child,
    );
  }

  /// Combined entrance animation (fade + slide + scale)
  static Widget entranceAnimation({
    required Widget child,
    required Animation<double> animation,
    SlideDirection slideDirection = SlideDirection.bottom,
    bool includeScale = false,
    bool includeFade = true,
  }) {
    Widget result = child;

    if (includeScale) {
      result = scaleTransition(
        child: result,
        animation: animation,
        startScale: 0.8,
      );
    }

    result = slideTransition(
      child: result,
      animation: animation,
      direction: slideDirection,
      offset: 0.3,
    );

    if (includeFade) {
      result = fadeTransition(child: result, animation: animation);
    }

    return result;
  }

  /// Staggered list animation
  static Widget staggeredAnimation({
    required Widget child,
    required int index,
    required Animation<double> animation,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    final itemDelay = delay.inMilliseconds * index;
    final totalDuration = animation.duration?.inMilliseconds ?? 1000;

    final startTime = math.min(itemDelay / totalDuration, 0.8);
    final endTime = math.min(startTime + 0.4, 1.0);

    final intervalAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(startTime, endTime, curve: Curves.easeOutCubic),
    );

    return entranceAnimation(
      child: child,
      animation: intervalAnimation,
      slideDirection: SlideDirection.bottom,
      includeScale: true,
    );
  }

  /// Shimmer loading animation
  static Widget shimmerAnimation({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return _ShimmerWidget(
      child: child,
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      duration: duration,
    );
  }

  /// Bounce animation
  static Widget bounceAnimation({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final bounceValue = math.sin(animation.value * math.pi * 2) * 0.1 + 1.0;
        return Transform.scale(scale: bounceValue, child: child);
      },
      child: child,
    );
  }

  /// Wave animation
  static Widget waveAnimation({
    required Widget child,
    required Animation<double> animation,
    double amplitude = 10.0,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final waveValue = math.sin(animation.value * math.pi * 2) * amplitude;
        return Transform.translate(offset: Offset(0, waveValue), child: child);
      },
      child: child,
    );
  }

  /// Typewriter animation for text
  static Widget typewriterAnimation({
    required String text,
    required Animation<double> animation,
    TextStyle? style,
    Duration characterDelay = const Duration(milliseconds: 50),
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final charactersToShow = (text.length * animation.value).floor();
        final displayText = text.substring(0, charactersToShow);

        return Text(displayText, style: style);
      },
    );
  }

  /// Page transition animations
  static Route<T> createRoute<T>({
    required Widget page,
    TransitionType type = TransitionType.slide,
    Duration duration = normalDuration,
    SlideDirection slideDirection = SlideDirection.right,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case TransitionType.fade:
            return fadeTransition(child: child, animation: animation);

          case TransitionType.slide:
            return slideTransition(
              child: child,
              animation: animation,
              direction: slideDirection,
            );

          case TransitionType.scale:
            return scaleTransition(child: child, animation: animation);

          case TransitionType.rotation:
            return rotationTransition(child: child, animation: animation);

          case TransitionType.none:
          default:
            return child;
        }
      },
    );
  }
}

/// Animation presets for common UI elements
class AnimationPresets {
  /// Card entrance animation
  static Widget cardEntrance({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimationService.entranceAnimation(
      child: child,
      animation: animation,
      slideDirection: SlideDirection.bottom,
      includeScale: true,
    );
  }

  /// Button press animation
  static Widget buttonPress({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimationService.scaleTransition(
      child: child,
      animation: animation,
      startScale: 1.0,
      endScale: 0.95,
    );
  }

  /// Modal popup animation
  static Widget modalPopup({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimationService.scaleTransition(
      child: AnimationService.fadeTransition(
        child: child,
        animation: animation,
      ),
      animation: animation,
      startScale: 0.7,
    );
  }

  /// Notification slide-in
  static Widget notificationSlide({
    required Widget child,
    required Animation<double> animation,
  }) {
    return AnimationService.slideTransition(
      child: child,
      animation: animation,
      direction: SlideDirection.top,
    );
  }

  /// Loading dots animation
  static Widget loadingDots({
    required Animation<double> animation,
    Color? color,
    double size = 8.0,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final delay = index * 0.2;
            final adjustedAnimation = (animation.value - delay).clamp(0.0, 1.0);
            final scale = math.sin(adjustedAnimation * math.pi) * 0.5 + 0.5;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: color ?? Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Slide direction enumeration
enum SlideDirection { top, bottom, left, right }

/// Transition type enumeration
enum TransitionType { none, fade, slide, scale, rotation }

/// Shimmer widget implementation
class _ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const _ShimmerWidget({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    required this.duration,
  });

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                math.max(0.0, _animation.value - 0.3),
                math.max(0.0, _animation.value),
                math.min(1.0, _animation.value + 0.3),
              ],
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Animation utils for common scenarios
class AnimationUtils {
  /// Create staggered controller for multiple items
  static List<AnimationController> createStaggeredControllers({
    required TickerProvider vsync,
    required int count,
    Duration itemDuration = AnimationService.normalDuration,
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    return List.generate(count, (index) {
      final controller = AnimationController(
        duration: itemDuration,
        vsync: vsync,
      );

      // Start animation with delay
      Future.delayed(staggerDelay * index, () {
        if (!controller.isDisposed) {
          controller.forward();
        }
      });

      return controller;
    });
  }

  /// Create bounce effect controller
  static AnimationController createBounceController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    final controller = AnimationController(duration: duration, vsync: vsync);

    return controller;
  }

  /// Trigger haptic feedback with animation
  static void animateWithHaptic(VoidCallback animation) {
    HapticFeedback.lightImpact();
    animation();
  }
}

/// Mixin for automatic animation management
mixin AnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  final List<AnimationController> _controllers = [];

  AnimationController createController({
    Duration duration = AnimationService.normalDuration,
    double value = 0.0,
  }) {
    final controller = AnimationController(
      duration: duration,
      vsync: this,
      value: value,
    );
    _controllers.add(controller);
    return controller;
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }
}
