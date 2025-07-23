import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// Performance monitoring widget for development
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool showInRelease;
  final Duration updateInterval;

  const PerformanceMonitor({
    Key? key,
    required this.child,
    this.showInRelease = false,
    this.updateInterval = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  Timer? _updateTimer;
  double _fps = 0.0;
  int _frameCount = 0;
  DateTime _lastUpdate = DateTime.now();
  bool _showOverlay = false;

  // Memory tracking
  int _currentMemoryUsage = 0;
  int _maxMemoryUsage = 0;

  // Build time tracking
  final List<int> _buildTimes = [];
  late Stopwatch _buildStopwatch;

  @override
  void initState() {
    super.initState();

    if (kDebugMode || widget.showInRelease) {
      _initializeMonitoring();
    }

    _buildStopwatch = Stopwatch();
  }

  void _initializeMonitoring() {
    // Start FPS monitoring
    _updateTimer = Timer.periodic(widget.updateInterval, _updateMetrics);

    // Add frame callback for FPS calculation
    WidgetsBinding.instance.addPostFrameCallback(_onFrameRendered);
  }

  void _onFrameRendered(Duration timeStamp) {
    if (mounted) {
      setState(() {
        _frameCount++;
      });

      // Schedule next frame callback
      WidgetsBinding.instance.addPostFrameCallback(_onFrameRendered);
    }
  }

  void _updateMetrics(Timer timer) {
    if (!mounted) return;

    final now = DateTime.now();
    final elapsed = now.difference(_lastUpdate);

    if (elapsed.inMilliseconds > 0) {
      final newFps = (_frameCount * 1000) / elapsed.inMilliseconds;

      setState(() {
        _fps = newFps;
        _frameCount = 0;
        _lastUpdate = now;
      });

      _updateMemoryUsage();
    }
  }

  void _updateMemoryUsage() {
    // Simplified memory tracking (would need platform-specific implementation)
    // For now, just simulate memory usage tracking
    _currentMemoryUsage = DateTime.now().millisecondsSinceEpoch % 100000;
    if (_currentMemoryUsage > _maxMemoryUsage) {
      _maxMemoryUsage = _currentMemoryUsage;
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _buildStopwatch.start();

    final child = widget.child;

    _buildStopwatch.stop();
    _recordBuildTime(_buildStopwatch.elapsedMicroseconds);
    _buildStopwatch.reset();

    if (!kDebugMode && !widget.showInRelease) {
      return child;
    }

    return Stack(
      children: [
        child,
        if (_showOverlay) _buildPerformanceOverlay(),
        _buildToggleButton(),
      ],
    );
  }

  Widget _buildPerformanceOverlay() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 10,
      child: Material(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Performance Monitor',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _buildMetricRow(
                'FPS',
                '${_fps.toStringAsFixed(1)}',
                _getFpsColor(),
              ),
              _buildMetricRow(
                'Memory',
                '${(_currentMemoryUsage / 1024).toStringAsFixed(1)}KB',
                Colors.blue,
              ),
              _buildMetricRow(
                'Max Memory',
                '${(_maxMemoryUsage / 1024).toStringAsFixed(1)}KB',
                Colors.orange,
              ),
              _buildMetricRow(
                'Avg Build',
                '${_getAverageBuildTime().toStringAsFixed(1)}ms',
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildFpsChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFpsChart() {
    return Container(
      height: 30,
      child: CustomPaint(
        painter: FpsChartPainter(_fps),
        size: const Size(double.infinity, 30),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 10,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showOverlay = !_showOverlay;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            _showOverlay ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Color _getFpsColor() {
    if (_fps >= 55) return Colors.green;
    if (_fps >= 30) return Colors.orange;
    return Colors.red;
  }

  double _getAverageBuildTime() {
    if (_buildTimes.isEmpty) return 0.0;
    return _buildTimes.reduce((a, b) => a + b) / _buildTimes.length / 1000;
  }

  void _recordBuildTime(int microseconds) {
    _buildTimes.add(microseconds);

    // Keep only last 100 build times
    if (_buildTimes.length > 100) {
      _buildTimes.removeAt(0);
    }
  }
}

/// Custom painter for FPS chart
class FpsChartPainter extends CustomPainter {
  final double fps;

  FpsChartPainter(this.fps);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getFpsColor()
      ..style = PaintingStyle.fill;

    final width = size.width;
    final height = size.height;
    final barWidth = (fps / 60) * width;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = Colors.grey.withOpacity(0.3),
    );

    // FPS bar
    canvas.drawRect(Rect.fromLTWH(0, 0, barWidth, height), paint);

    // Target FPS line (60 FPS)
    canvas.drawLine(
      Offset(width * 0.9, 0),
      Offset(width * 0.9, height),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1,
    );
  }

  Color _getFpsColor() {
    if (fps >= 55) return Colors.green;
    if (fps >= 30) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(FpsChartPainter oldDelegate) {
    return oldDelegate.fps != fps;
  }
}

/// Performance metrics utility
class PerformanceMetrics {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<int>> _measurements = {};

  /// Start timing an operation
  static void startTimer(String operation) {
    _timers[operation] = Stopwatch()..start();
  }

  /// Stop timing and record measurement
  static void stopTimer(String operation) {
    final timer = _timers[operation];
    if (timer != null) {
      timer.stop();
      _recordMeasurement(operation, timer.elapsedMicroseconds);
      _timers.remove(operation);
    }
  }

  /// Record a measurement manually
  static void recordMeasurement(String operation, int microseconds) {
    _recordMeasurement(operation, microseconds);
  }

  static void _recordMeasurement(String operation, int microseconds) {
    _measurements.putIfAbsent(operation, () => []);
    _measurements[operation]!.add(microseconds);

    // Keep only last 100 measurements
    if (_measurements[operation]!.length > 100) {
      _measurements[operation]!.removeAt(0);
    }

    if (kDebugMode) {
      print('⏱️ $operation: ${microseconds / 1000}ms');
    }
  }

  /// Get average time for an operation
  static double getAverageTime(String operation) {
    final measurements = _measurements[operation];
    if (measurements == null || measurements.isEmpty) return 0.0;

    return measurements.reduce((a, b) => a + b) / measurements.length / 1000;
  }

  /// Get all performance stats
  static Map<String, dynamic> getAllStats() {
    final stats = <String, dynamic>{};

    for (final entry in _measurements.entries) {
      final operation = entry.key;
      final measurements = entry.value;

      if (measurements.isNotEmpty) {
        final avgTime =
            measurements.reduce((a, b) => a + b) / measurements.length / 1000;
        final maxTime = measurements.reduce((a, b) => a > b ? a : b) / 1000;
        final minTime = measurements.reduce((a, b) => a < b ? a : b) / 1000;

        stats[operation] = {
          'average_ms': avgTime,
          'max_ms': maxTime,
          'min_ms': minTime,
          'count': measurements.length,
        };
      }
    }

    return stats;
  }

  /// Clear all measurements
  static void clearStats() {
    _measurements.clear();
    _timers.clear();
    print('🧹 Cleared all performance measurements');
  }

  /// Print performance report
  static void printReport() {
    if (!kDebugMode) return;

    print('\n📊 Performance Report:');
    print('========================');

    final stats = getAllStats();
    for (final entry in stats.entries) {
      final operation = entry.key;
      final data = entry.value;

      print('$operation:');
      print('  Average: ${data['average_ms'].toStringAsFixed(2)}ms');
      print('  Max: ${data['max_ms'].toStringAsFixed(2)}ms');
      print('  Min: ${data['min_ms'].toStringAsFixed(2)}ms');
      print('  Count: ${data['count']}');
      print('');
    }
  }
}

/// Mixin for automatic performance tracking
mixin PerformanceTracking<T extends StatefulWidget> on State<T> {
  late String _widgetName;

  @override
  void initState() {
    super.initState();
    _widgetName = widget.runtimeType.toString();
    PerformanceMetrics.startTimer('${_widgetName}_init');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PerformanceMetrics.stopTimer('${_widgetName}_init');
  }

  @override
  Widget build(BuildContext context) {
    PerformanceMetrics.startTimer('${_widgetName}_build');
    final widget = buildWidget(context);
    PerformanceMetrics.stopTimer('${_widgetName}_build');
    return widget;
  }

  /// Override this instead of build()
  Widget buildWidget(BuildContext context);
}
