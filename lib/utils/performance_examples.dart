import 'package:flutter/material.dart';
import '../widgets/common/lazy_loading_widgets.dart';
import '../widgets/common/performance_widgets.dart';
import '../services/image_cache_service.dart';
import 'performance_utils.dart';

/// Examples of how to use performance optimization features
class PerformanceExamples {
  
  /// Example 1: Lazy Loading List with Performance Monitoring
  static Widget lazyLoadingListExample() {
    return PerformanceMonitoringWidget(
      name: 'LazyListExample',
      child: LazyLoadingListView<String>(
        itemLoader: (page, pageSize) async {
          // Simulate API call
          await Future.delayed(const Duration(milliseconds: 500));
          return List.generate(
            pageSize, 
            (index) => 'Item ${page * pageSize + index}',
          );
        },
        itemBuilder: (context, item, index) {
          return BuildTimeTracker(
            name: 'ListItem_$index',
            child: ListTile(
              title: Text(item),
              subtitle: Text('Index: $index'),
              leading: const LazyImage(
                imageUrl: 'https://picsum.photos/50/50',
                width: 50,
                height: 50,
              ),
            ),
          );
        },
        config: const LazyLoadingConfig(
          preloadThreshold: 5,
          maxCacheSize: 200,
          enableLogging: true,
        ),
      ),
    );
  }

  /// Example 2: Lazy Loading Grid with Image Caching
  static Widget lazyLoadingGridExample() {
    return LazyLoadingGridView<Map<String, dynamic>>(
      itemLoader: (page, pageSize) async {
        await Future.delayed(const Duration(milliseconds: 300));
        return List.generate(pageSize, (index) => {
          'id': page * pageSize + index,
          'title': 'Photo ${page * pageSize + index}',
          'imageUrl': 'https://picsum.photos/200/200?random=${page * pageSize + index}',
        });
      },
      itemBuilder: (context, item, index) {
        return Card(
          child: Column(
            children: [
              Expanded(
                child: LazyImage(
                  imageUrl: item['imageUrl'],
                  fit: BoxFit.cover,
                  placeholder: (context) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
      crossAxisCount: 2,
      childAspectRatio: 0.8,
      config: const LazyLoadingConfig(
        preloadThreshold: 2,
        maxCacheSize: 50,
        enableLogging: true,
      ),
    );
  }

  /// Example 3: Performance Monitoring with Overlay
  static Widget performanceOverlayExample(Widget child) {
    return PerformanceOverlay(
      showFPS: true,
      showMemory: true,
      showBuildTimes: true,
      enableInProduction: false,
      child: child,
    );
  }

  /// Example 4: Scroll Performance Tracking
  static Widget scrollPerformanceExample() {
    return ScrollPerformanceTracker(
      name: 'MainScrollView',
      child: ListView.builder(
        itemCount: 1000,
        itemBuilder: (context, index) {
          return BuildTimeTracker(
            name: 'ScrollItem_$index',
            child: ListTile(
              title: Text('Scroll Item $index'),
              subtitle: Text('Performance tracked item'),
              leading: CircleAvatar(child: Text('$index')),
            ),
          );
        },
      ),
    );
  }

  /// Example 5: Animation Performance Tracking
  static Widget animationPerformanceExample() {
    return _AnimationExample();
  }

  /// Example 6: Code Splitting with Lazy Routes
  static Route<void> lazyRouteExample(String routeName) {
    return CodeSplittingUtils.lazyRoute(
      () async {
        // Simulate loading a heavy widget
        await Future.delayed(const Duration(milliseconds: 1000));
        return _HeavyWidget();
      },
      routeName: routeName,
    );
  }

  /// Example 7: Image Cache Service Usage
  static Future<void> imageCacheExample() async {
    final imageCache = ImageCacheService();
    await imageCache.initialize();

    // Preload images
    await imageCache.preloadImages([
      'https://picsum.photos/200/200?random=1',
      'https://picsum.photos/200/200?random=2',
      'https://picsum.photos/200/200?random=3',
    ]);

    // Get cache statistics
    final stats = imageCache.getCacheStats();
    print('Cache stats: $stats');

    // Clear cache if needed
    await imageCache.clearCache();
  }

  /// Example 8: Performance Utilities Usage
  static Future<void> performanceUtilsExample() async {
    // Start a performance timer
    PerformanceUtils.startTimer('data_processing');

    // Simulate some work
    await Future.delayed(const Duration(milliseconds: 500));

    // Stop timer and get result
    final duration = PerformanceUtils.stopTimer('data_processing');
    print('Data processing took: ${duration}ms');

    // Get performance statistics
    final stats = PerformanceUtils.getMetricStats('data_processing');
    print('Performance stats: $stats');

    // Memory monitoring
    final memoryTimer = MemoryUtils.startMemoryMonitoring(
      interval: const Duration(seconds: 10),
      onMemoryUpdate: (info) {
        print('Memory update: $info');
      },
    );

    // Stop monitoring after some time
    Future.delayed(const Duration(minutes: 1), () {
      memoryTimer.cancel();
    });
  }

  /// Example 9: Bundle Optimization Analysis
  static Future<void> bundleOptimizationExample() async {
    final analysis = await BundleOptimizationUtils.analyzeAssets();
    print('Bundle analysis: $analysis');
    
    // The analysis will provide recommendations for optimization
    final recommendations = analysis['recommendations'] as List<String>?;
    if (recommendations != null) {
      print('Optimization recommendations:');
      for (final recommendation in recommendations) {
        print('- $recommendation');
      }
    }
  }

  /// Example 10: Complete Performance Dashboard
  static Widget performanceDashboardExample() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
      ),
      body: const Column(
        children: [
          PerformanceStats(
            showDetailed: true,
            updateInterval: Duration(seconds: 3),
          ),
          Expanded(
            child: _PerformanceTestWidget(),
          ),
        ],
      ),
    );
  }
}

/// Heavy widget for testing lazy loading
class _HeavyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heavy Widget'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('This is a heavy widget that was lazy loaded'),
          ],
        ),
      ),
    );
  }
}

/// Animation example with performance tracking
class _AnimationExample extends StatefulWidget {
  @override
  State<_AnimationExample> createState() => _AnimationExampleState();
}

class _AnimationExampleState extends State<_AnimationExample>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimationPerformanceTracker(
      controller: _controller,
      name: 'RotationAnimation',
      child: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value * 2 * 3.14159,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Performance test widget
class _PerformanceTestWidget extends StatefulWidget {
  const _PerformanceTestWidget();

  @override
  State<_PerformanceTestWidget> createState() => _PerformanceTestWidgetState();
}

class _PerformanceTestWidgetState extends State<_PerformanceTestWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return BuildTimeTracker(
      name: 'PerformanceTestWidget',
      onBuildTimeRecorded: (duration) {
        if (duration.inMilliseconds > 5) {
          print('Slow build detected: ${duration.inMilliseconds}ms');
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Build counter: $_counter',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _counter++;
              });
            },
            child: const Text('Trigger Rebuild'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              PerformanceUtils.startTimer('heavy_computation');
              
              // Simulate heavy computation
              await Future.delayed(const Duration(milliseconds: 100));
              
              final duration = PerformanceUtils.stopTimer('heavy_computation');
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Computation took: ${duration}ms'),
                  ),
                );
              }
            },
            child: const Text('Run Heavy Computation'),
          ),
        ],
      ),
    );
  }
}

/// Usage examples in a complete app structure
class PerformanceOptimizedApp extends StatelessWidget {
  const PerformanceOptimizedApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Performance Optimized App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PerformanceExamples.performanceOverlayExample(
        const _MainScreen(),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/lazy-list':
            return CodeSplittingUtils.lazyRoute(
              () async => Scaffold(
                appBar: AppBar(title: const Text('Lazy List')),
                body: PerformanceExamples.lazyLoadingListExample(),
              ),
              routeName: 'lazy-list',
              settings: settings,
            );
          case '/lazy-grid':
            return CodeSplittingUtils.lazyRoute(
              () async => Scaffold(
                appBar: AppBar(title: const Text('Lazy Grid')),
                body: PerformanceExamples.lazyLoadingGridExample(),
              ),
              routeName: 'lazy-grid',
              settings: settings,
            );
          case '/performance-dashboard':
            return CodeSplittingUtils.lazyRoute(
              () async => PerformanceExamples.performanceDashboardExample(),
              routeName: 'performance-dashboard',
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            );
        }
      },
    );
  }
}

class _MainScreen extends StatelessWidget {
  const _MainScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/lazy-list'),
            child: const Text('Lazy Loading List'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/lazy-grid'),
            child: const Text('Lazy Loading Grid'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/performance-dashboard'),
            child: const Text('Performance Dashboard'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Performance Features:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• Lazy loading lists and grids'),
          const Text('• Image caching and optimization'),
          const Text('• Performance monitoring overlay'),
          const Text('• Build time tracking'),
          const Text('• Scroll performance monitoring'),
          const Text('• Animation performance tracking'),
          const Text('• Code splitting and lazy routes'),
          const Text('• Bundle size optimization'),
          const Text('• Memory usage monitoring'),
        ],
      ),
    );
  }
}