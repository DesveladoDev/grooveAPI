import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/logging_service.dart';
import '../services/observability_service.dart';

/// Performance monitoring utilities
class PerformanceUtils {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<int>> _metrics = {};

  /// Start a performance timer
  static void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
    
    if (kDebugMode) {
      LoggingService.instance.debug(
        'Started performance timer: $name',
        category: LogCategory.performance,
      );
    }
  }

  /// Stop a performance timer and record the result
  static int stopTimer(String name) {
    final timer = _timers[name];
    if (timer == null) {
      LoggingService.instance.warning(
        'Timer not found: $name',
        category: LogCategory.performance,
      );
      return 0;
    }

    timer.stop();
    final elapsed = timer.elapsedMilliseconds;
    _timers.remove(name);

    // Record metric
    _metrics.putIfAbsent(name, () => []).add(elapsed);
    
    // Log performance
    LoggingService.instance.info(
      'Performance timer completed: $name',
      category: LogCategory.performance,
      context: {
        'duration_ms': elapsed,
        'timer_name': name,
      },
    );

    // Record in observability service
    ObservabilityService.instance.recordPerformanceEvent(
      name,
      elapsed,
      metadata: {'timer_type': 'custom'},
    );

    return elapsed;
  }

  /// Get performance statistics for a metric
  static Map<String, dynamic> getMetricStats(String name) {
    final values = _metrics[name];
    if (values == null || values.isEmpty) {
      return {};
    }

    values.sort();
    final count = values.length;
    final sum = values.reduce((a, b) => a + b);
    final avg = sum / count;
    final median = count % 2 == 0
        ? (values[count ~/ 2 - 1] + values[count ~/ 2]) / 2
        : values[count ~/ 2].toDouble();
    final min = values.first;
    final max = values.last;

    return {
      'count': count,
      'sum': sum,
      'average': avg,
      'median': median,
      'min': min,
      'max': max,
      'p95': values[(count * 0.95).floor()],
      'p99': values[(count * 0.99).floor()],
    };
  }

  /// Clear all metrics
  static void clearMetrics() {
    _metrics.clear();
    _timers.clear();
  }

  /// Get all metrics summary
  static Map<String, Map<String, dynamic>> getAllMetrics() {
    final result = <String, Map<String, dynamic>>{};
    for (final name in _metrics.keys) {
      result[name] = getMetricStats(name);
    }
    return result;
  }
}

/// Memory monitoring utilities
class MemoryUtils {
  /// Get current memory usage information
  static Future<Map<String, dynamic>> getMemoryInfo() async {
    final info = <String, dynamic>{};
    
    try {
      // Get VM memory info
      final vmInfo = developer.Service.getInfo();
      info['vm_info'] = vmInfo.toString();
      
      // Platform-specific memory info
      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile memory info would require platform channels
        info['platform'] = Platform.operatingSystem;
      }
      
      // Record timestamp
      info['timestamp'] = DateTime.now().toIso8601String();
      
    } catch (e) {
      LoggingService.instance.error(
        'Failed to get memory info',
        error: e,
        category: LogCategory.performance,
      );
    }
    
    return info;
  }

  /// Monitor memory usage over time
  static Timer startMemoryMonitoring({
    Duration interval = const Duration(seconds: 30),
    Function(Map<String, dynamic>)? onMemoryUpdate,
  }) {
    return Timer.periodic(interval, (timer) async {
      final memoryInfo = await getMemoryInfo();
      
      LoggingService.instance.info(
        'Memory monitoring update',
        category: LogCategory.performance,
        context: memoryInfo,
      );
      
      onMemoryUpdate?.call(memoryInfo);
    });
  }
}

/// Bundle size optimization utilities
class BundleOptimizationUtils {
  /// Analyze asset usage and suggest optimizations
  static Future<Map<String, dynamic>> analyzeAssets() async {
    final analysis = <String, dynamic>{};
    
    try {
      // Get asset manifest
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifest = Map<String, dynamic>.from(
        const JsonDecoder().convert(manifestContent) as Map,
      );
      
      analysis['total_assets'] = manifest.length;
      analysis['asset_types'] = _categorizeAssets(manifest);
      analysis['recommendations'] = _generateOptimizationRecommendations(manifest);
      
    } catch (e) {
      LoggingService.instance.error(
        'Failed to analyze assets',
        error: e,
        category: LogCategory.performance,
      );
    }
    
    return analysis;
  }

  static Map<String, int> _categorizeAssets(Map<String, dynamic> manifest) {
    final categories = <String, int>{};
    
    for (final asset in manifest.keys) {
      final extension = asset.split('.').last.toLowerCase();
      categories[extension] = (categories[extension] ?? 0) + 1;
    }
    
    return categories;
  }

  static List<String> _generateOptimizationRecommendations(Map<String, dynamic> manifest) {
    final recommendations = <String>[];
    final categories = _categorizeAssets(manifest);
    
    // Check for large image counts
    final imageExtensions = ['png', 'jpg', 'jpeg', 'gif', 'webp'];
    final imageCount = imageExtensions.fold<int>(
      0, 
      (sum, ext) => sum + (categories[ext] ?? 0),
    );
    
    if (imageCount > 50) {
      recommendations.add('Consider using WebP format for images to reduce bundle size');
      recommendations.add('Implement lazy loading for images');
    }
    
    // Check for font usage
    final fontCount = categories['ttf'] ?? 0 + categories['otf'] ?? 0;
    if (fontCount > 5) {
      recommendations.add('Consider reducing the number of font files');
    }
    
    // Check for JSON files
    final jsonCount = categories['json'] ?? 0;
    if (jsonCount > 10) {
      recommendations.add('Consider loading JSON data dynamically instead of bundling');
    }
    
    return recommendations;
  }
}

/// Code splitting utilities
class CodeSplittingUtils {
  /// Lazy load a widget with performance tracking
  static Widget lazyLoadWidget({
    required Future<Widget> Function() builder,
    Widget? placeholder,
    String? traceName,
  }) {
    return FutureBuilder<Widget>(
      future: _loadWithTracking(builder, traceName),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        } else if (snapshot.hasError) {
          LoggingService.instance.error(
            'Failed to lazy load widget',
            error: snapshot.error,
            category: LogCategory.performance,
            context: {'trace_name': traceName},
          );
          return const Icon(Icons.error);
        } else {
          return placeholder ?? const CircularProgressIndicator();
        }
      },
    );
  }

  static Future<Widget> _loadWithTracking(
    Future<Widget> Function() builder,
    String? traceName,
  ) async {
    final name = traceName ?? 'lazy_widget_load';
    PerformanceUtils.startTimer(name);
    
    try {
      final widget = await builder();
      PerformanceUtils.stopTimer(name);
      return widget;
    } catch (e) {
      PerformanceUtils.stopTimer(name);
      rethrow;
    }
  }

  /// Create a lazy route with performance tracking
  static Route<T> lazyRoute<T extends Object?>(
    Future<Widget> Function() builder, {
    String? routeName,
    RouteSettings? settings,
  }) {
    return MaterialPageRoute<T>(
      settings: settings,
      builder: (context) => lazyLoadWidget(
        builder: builder,
        traceName: 'lazy_route_${routeName ?? 'unknown'}',
        placeholder: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

/// Widget performance monitoring
class PerformanceMonitoringWidget extends StatefulWidget {
  final Widget child;
  final String? name;
  final bool enableFrameMetrics;
  final bool enableBuildMetrics;

  const PerformanceMonitoringWidget({
    Key? key,
    required this.child,
    this.name,
    this.enableFrameMetrics = true,
    this.enableBuildMetrics = true,
  }) : super(key: key);

  @override
  State<PerformanceMonitoringWidget> createState() => 
      _PerformanceMonitoringWidgetState();
}

class _PerformanceMonitoringWidgetState 
    extends State<PerformanceMonitoringWidget> 
    with WidgetsBindingObserver {
  
  late String _widgetName;
  int _buildCount = 0;
  final Stopwatch _buildTimer = Stopwatch();

  @override
  void initState() {
    super.initState();
    _widgetName = widget.name ?? widget.child.runtimeType.toString();
    WidgetsBinding.instance.addObserver(this);
    
    if (widget.enableFrameMetrics) {
      WidgetsBinding.instance.addTimingsCallback(_onFrameMetrics);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.enableFrameMetrics) {
      WidgetsBinding.instance.removeTimingsCallback(_onFrameMetrics);
    }
    super.dispose();
  }

  void _onFrameMetrics(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildDuration = timing.buildDuration.inMilliseconds;
      final rasterDuration = timing.rasterDuration.inMilliseconds;
      
      if (buildDuration > 16 || rasterDuration > 16) { // > 60fps threshold
        LoggingService.instance.warning(
          'Frame performance issue detected',
          category: LogCategory.performance,
          context: {
            'widget': _widgetName,
            'build_duration_ms': buildDuration,
            'raster_duration_ms': rasterDuration,
            'total_duration_ms': timing.totalSpan.inMilliseconds,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enableBuildMetrics) {
      _buildTimer.reset();
      _buildTimer.start();
    }

    final child = widget.child;

    if (widget.enableBuildMetrics) {
      _buildTimer.stop();
      _buildCount++;
      
      final buildTime = _buildTimer.elapsedMicroseconds;
      
      if (buildTime > 1000) { // > 1ms build time
        LoggingService.instance.info(
          'Widget build performance',
          category: LogCategory.performance,
          context: {
            'widget': _widgetName,
            'build_time_us': buildTime,
            'build_count': _buildCount,
          },
        );
      }
    }

    return child;
  }
}

/// Performance debugging utilities
class PerformanceDebugUtils {
  /// Enable performance overlay in debug mode
  static void enablePerformanceOverlay() {
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // This would show performance overlay
        // Implementation depends on specific requirements
      });
    }
  }

  /// Log widget rebuild information
  static void logRebuild(String widgetName, [Map<String, dynamic>? context]) {
    if (kDebugMode) {
      LoggingService.instance.debug(
        'Widget rebuild: $widgetName',
        category: LogCategory.performance,
        context: context ?? {},
      );
    }
  }

  /// Create a performance report
  static Map<String, dynamic> generatePerformanceReport() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'metrics': PerformanceUtils.getAllMetrics(),
      'platform': {
        'is_debug': kDebugMode,
        'is_profile': kProfileMode,
        'is_release': kReleaseMode,
        'platform': defaultTargetPlatform.toString(),
      },
    };
  }
}