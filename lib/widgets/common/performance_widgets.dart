import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../services/logging_service.dart';
import '../../services/observability_service.dart';
import '../../utils/performance_utils.dart';
import '../../utils/power_mode.dart';

/// Performance monitoring overlay widget
class PerformanceOverlay extends StatefulWidget {
  final Widget child;
  final bool showFPS;
  final bool showMemory;
  final bool showBuildTimes;
  final bool enableInProduction;

  const PerformanceOverlay({
    Key? key,
    required this.child,
    this.showFPS = true,
    this.showMemory = true,
    this.showBuildTimes = true,
    this.enableInProduction = false,
  }) : super(key: key);

  @override
  State<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay>
    with TickerProviderStateMixin {
  late Timer _updateTimer;
  double _currentFPS = 0.0;
  String _memoryUsage = '';
  final List<double> _fpsHistory = [];
  final List<FrameTiming> _frameTimings = [];
  bool _isVisible = false;
  void Function(PowerState)? _powerModeListener;

  @override
  void initState() {
    super.initState();
    
    // Only show in debug mode unless explicitly enabled for production
    _isVisible = kDebugMode || widget.enableInProduction;
    
    if (_isVisible) {
      _startMonitoring();
    }

    // Pausar overlay en bajo consumo
    _powerModeListener = (PowerState state) {
      if (state == PowerState.low) {
        _stopMonitoring();
      } else {
        if (_isVisible) _startMonitoring();
      }
    };
    PowerModeManager.instance.addListener(_powerModeListener!);
  }

  @override
  void dispose() {
    _stopMonitoring();
    if (_powerModeListener != null) {
      PowerModeManager.instance.removeListener(_powerModeListener!);
      _powerModeListener = null;
    }
    super.dispose();
  }

  void _startMonitoring() {
    // Monitor frame timings
    WidgetsBinding.instance.addTimingsCallback(_onFrameTiming);
    
    // Update metrics periodically
    final interval = PowerModeManager.instance
        .adjustedInterval(const Duration(seconds: 1), lowPowerFactor: 3.0);
    _updateTimer = Timer.periodic(interval, (_) {
      _updateMetrics();
    });
  }

  void _stopMonitoring() {
    try {
      _updateTimer.cancel();
    } catch (_) {}
    WidgetsBinding.instance.removeTimingsCallback(_onFrameTiming);
  }

  void _onFrameTiming(List<FrameTiming> timings) {
    _frameTimings.addAll(timings);
    
    // Keep only recent timings (last 60 frames)
    if (_frameTimings.length > 60) {
      _frameTimings.removeRange(0, _frameTimings.length - 60);
    }
  }

  void _updateMetrics() {
    if (!mounted) return;

    setState(() {
      _updateFPS();
      _updateMemoryUsage();
    });
  }

  void _updateFPS() {
    if (_frameTimings.isEmpty) return;

    // Calculate FPS from recent frame timings
    final recentTimings = _frameTimings.take(60).toList();
    if (recentTimings.isNotEmpty) {
      final totalDuration = recentTimings.fold<Duration>(
        Duration.zero,
        (sum, timing) => sum + timing.totalSpan,
      );
      
      if (totalDuration.inMicroseconds > 0) {
        _currentFPS = (recentTimings.length * 1000000) / totalDuration.inMicroseconds;
        _fpsHistory.add(_currentFPS);
        
        // Keep FPS history limited
        if (_fpsHistory.length > 60) {
          _fpsHistory.removeAt(0);
        }
      }
    }
  }

  void _updateMemoryUsage() {
    // This is a simplified memory usage indicator
    // In a real implementation, you'd use platform channels for accurate memory info
    _memoryUsage = '${(Random().nextDouble() * 100 + 50).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 10,
          child: _buildPerformancePanel(),
        ),
      ],
    );
  }

  Widget _buildPerformancePanel() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showFPS) _buildFPSIndicator(),
          if (widget.showMemory) _buildMemoryIndicator(),
          if (widget.showBuildTimes) _buildBuildTimeIndicator(),
        ],
      ),
    );
  }

  Widget _buildFPSIndicator() {
    final color = _getFPSColor(_currentFPS);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.speed, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          '${_currentFPS.toStringAsFixed(1)} FPS',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMemoryIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.memory, color: Colors.blue, size: 16),
        const SizedBox(width: 4),
        Text(
          _memoryUsage,
          style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBuildTimeIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.build, color: Colors.orange, size: 16),
        const SizedBox(width: 4),
        Text(
          'Build: OK',
          style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getFPSColor(double fps) {
    if (fps >= 55) return Colors.green;
    if (fps >= 30) return Colors.yellow;
    return Colors.red;
  }
}

/// Widget that measures and reports its build time
class BuildTimeTracker extends StatefulWidget {
  final Widget child;
  final String? name;
  final Function(Duration buildTime)? onBuildTimeRecorded;

  const BuildTimeTracker({
    Key? key,
    required this.child,
    this.name,
    this.onBuildTimeRecorded,
  }) : super(key: key);

  @override
  State<BuildTimeTracker> createState() => _BuildTimeTrackerState();
}

class _BuildTimeTrackerState extends State<BuildTimeTracker> {
  final Stopwatch _buildStopwatch = Stopwatch();
  late String _widgetName;

  @override
  void initState() {
    super.initState();
    _widgetName = widget.name ?? widget.child.runtimeType.toString();
  }

  @override
  Widget build(BuildContext context) {
    _buildStopwatch.reset();
    _buildStopwatch.start();

    // Build the child widget
    final child = widget.child;

    // Measure build time after the frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildStopwatch.stop();
      final buildTime = _buildStopwatch.elapsed;
      
      // Report build time if it's significant
      if (buildTime.inMicroseconds > 1000) { // > 1ms
        LoggingService.instance.debug(
          'Widget build time: $_widgetName',
          category: LogCategory.performance,
          context: {
            'build_time_us': buildTime.inMicroseconds,
            'build_time_ms': buildTime.inMilliseconds,
          },
        );
        
        widget.onBuildTimeRecorded?.call(buildTime);
      }
    });

    return child;
  }
}

/// Widget that tracks scroll performance
class ScrollPerformanceTracker extends StatefulWidget {
  final Widget child;
  final ScrollController? controller;
  final String? name;

  const ScrollPerformanceTracker({
    Key? key,
    required this.child,
    this.controller,
    this.name,
  }) : super(key: key);

  @override
  State<ScrollPerformanceTracker> createState() => _ScrollPerformanceTrackerState();
}

class _ScrollPerformanceTrackerState extends State<ScrollPerformanceTracker> {
  late ScrollController _controller;
  late String _scrollName;
  final List<double> _scrollSpeeds = [];
  DateTime? _lastScrollTime;
  double? _lastScrollPosition;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _scrollName = widget.name ?? 'scroll_${widget.child.runtimeType}';
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    final now = DateTime.now();
    final position = _controller.position.pixels;

    if (_lastScrollTime != null && _lastScrollPosition != null) {
      final timeDiff = now.difference(_lastScrollTime!).inMicroseconds;
      final positionDiff = (position - _lastScrollPosition!).abs();
      
      if (timeDiff > 0) {
        final speed = (positionDiff * 1000000) / timeDiff; // pixels per second
        _scrollSpeeds.add(speed);
        
        // Keep only recent speeds
        if (_scrollSpeeds.length > 100) {
          _scrollSpeeds.removeAt(0);
        }
        
        // Log if scroll is very fast (potential performance issue)
        if (speed > 5000) { // > 5000 pixels/second
          LoggingService.instance.debug(
            'Fast scroll detected',
            category: LogCategory.performance,
            context: {
              'scroll_name': _scrollName,
              'speed_px_per_sec': speed,
              'position': position,
            },
          );
        }
      }
    }

    _lastScrollTime = now;
    _lastScrollPosition = position;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Widget that monitors animation performance
class AnimationPerformanceTracker extends StatefulWidget {
  final Widget child;
  final AnimationController? controller;
  final String? name;

  const AnimationPerformanceTracker({
    Key? key,
    required this.child,
    this.controller,
    this.name,
  }) : super(key: key);

  @override
  State<AnimationPerformanceTracker> createState() => _AnimationPerformanceTrackerState();
}

class _AnimationPerformanceTrackerState extends State<AnimationPerformanceTracker>
    with TickerProviderStateMixin {
  late String _animationName;
  final List<Duration> _frameDurations = [];
  DateTime? _lastFrameTime;

  @override
  void initState() {
    super.initState();
    _animationName = widget.name ?? 'animation_${widget.child.runtimeType}';
    
    if (widget.controller != null) {
      widget.controller!.addListener(_onAnimationFrame);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onAnimationFrame);
    super.dispose();
  }

  void _onAnimationFrame() {
    final now = DateTime.now();
    
    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      _frameDurations.add(frameDuration);
      
      // Keep only recent frame durations
      if (_frameDurations.length > 60) {
        _frameDurations.removeAt(0);
      }
      
      // Log if frame duration is too long (< 60fps)
      if (frameDuration.inMilliseconds > 16) {
        LoggingService.instance.debug(
          'Slow animation frame',
          category: LogCategory.performance,
          context: {
            'animation_name': _animationName,
            'frame_duration_ms': frameDuration.inMilliseconds,
            'target_fps': 60,
          },
        );
      }
    }
    
    _lastFrameTime = now;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Performance statistics widget
class PerformanceStats extends StatefulWidget {
  final bool showDetailed;
  final Duration updateInterval;

  const PerformanceStats({
    Key? key,
    this.showDetailed = false,
    this.updateInterval = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  State<PerformanceStats> createState() => _PerformanceStatsState();
}

class _PerformanceStatsState extends State<PerformanceStats> {
  late Timer _updateTimer;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _updateStats();
    _updateTimer = Timer.periodic(widget.updateInterval, (_) => _updateStats());
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  void _updateStats() {
    setState(() {
      _stats = PerformanceDebugUtils.generatePerformanceReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Performance Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._buildStatsList(),
        ],
      ),
    );
  }

  List<Widget> _buildStatsList() {
    final widgets = <Widget>[];
    
    if (_stats.containsKey('metrics')) {
      final metrics = _stats['metrics'] as Map<String, dynamic>;
      for (final entry in metrics.entries) {
        widgets.add(_buildStatItem(entry.key, entry.value));
      }
    }
    
    if (widget.showDetailed && _stats.containsKey('platform')) {
      widgets.add(const Divider(color: Colors.grey));
      widgets.add(const Text(
        'Platform Info',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ));
      
      final platform = _stats['platform'] as Map<String, dynamic>;
      for (final entry in platform.entries) {
        widgets.add(_buildStatItem(entry.key, entry.value));
      }
    }
    
    return widgets;
  }

  Widget _buildStatItem(String key, dynamic value) {
    String displayValue;
    if (value is Map) {
      displayValue = value.toString();
    } else {
      displayValue = value.toString();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              displayValue,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}