import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../services/logging_service.dart';
import '../../services/observability_service.dart';

/// Configuration for lazy loading behavior
class LazyLoadingConfig {
  final int preloadThreshold;
  final int maxCacheSize;
  final Duration debounceDelay;
  final bool enableLogging;

  const LazyLoadingConfig({
    this.preloadThreshold = 3,
    this.maxCacheSize = 100,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.enableLogging = false,
  });
}

/// Lazy loading list view with optimized performance
class LazyLoadingListView<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) itemLoader;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final int pageSize;
  final LazyLoadingConfig config;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const LazyLoadingListView({
    Key? key,
    required this.itemLoader,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.pageSize = 20,
    this.config = const LazyLoadingConfig(),
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  State<LazyLoadingListView<T>> createState() => _LazyLoadingListViewState<T>();
}

class _LazyLoadingListViewState<T> extends State<LazyLoadingListView<T>> {
  final List<T> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    if (widget.config.enableLogging) {
      LoggingService.instance.info(
        'Loading initial data for lazy list',
        category: LogCategory.performance,
        context: {'pageSize': widget.pageSize},
      );
    }

    await _loadMoreData();
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stopwatch = Stopwatch()..start();
      final newItems = await widget.itemLoader(_currentPage, widget.pageSize);
      stopwatch.stop();

      if (widget.config.enableLogging) {
        LoggingService.instance.info(
          'Loaded page data',
          category: LogCategory.performance,
          context: {
            'page': _currentPage,
            'itemCount': newItems.length,
            'loadTime': stopwatch.elapsedMilliseconds,
          },
        );
      }

      // Record performance metrics
      ObservabilityService.instance.recordPerformanceEvent(
        'lazy_list_page_load',
        stopwatch.elapsedMilliseconds,
        metadata: {
          'page': _currentPage.toString(),
          'item_count': newItems.length.toString(),
        },
      );

      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _hasMore = newItems.length == widget.pageSize;
        _isLoading = false;
      });

      // Manage cache size
      if (_items.length > widget.config.maxCacheSize) {
        final removeCount = _items.length - widget.config.maxCacheSize;
        _items.removeRange(0, removeCount);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      LoggingService.instance.error(
        'Failed to load lazy list data',
        error: e,
        category: LogCategory.performance,
        context: {'page': _currentPage},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _items.isEmpty) {
      return widget.errorBuilder?.call(context, _error!) ??
          Center(child: Text('Error: $_error'));
    }

    if (_items.isEmpty && _isLoading) {
      return widget.loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return widget.emptyBuilder?.call(context) ??
          const Center(child: Text('No items found'));
    }

    return ListView.builder(
      controller: widget.controller ?? _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return widget.itemBuilder(context, _items[index], index);
      },
    );
  }
}

/// Lazy loading grid view with optimized performance
class LazyLoadingGridView<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) itemLoader;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final int pageSize;
  final LazyLoadingConfig config;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const LazyLoadingGridView({
    Key? key,
    required this.itemLoader,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 4.0,
    this.crossAxisSpacing = 4.0,
    this.childAspectRatio = 1.0,
    this.pageSize = 20,
    this.config = const LazyLoadingConfig(),
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  State<LazyLoadingGridView<T>> createState() => _LazyLoadingGridViewState<T>();
}

class _LazyLoadingGridViewState<T> extends State<LazyLoadingGridView<T>> {
  final List<T> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    await _loadMoreData();
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stopwatch = Stopwatch()..start();
      final newItems = await widget.itemLoader(_currentPage, widget.pageSize);
      stopwatch.stop();

      ObservabilityService.instance.recordPerformanceEvent(
        'lazy_grid_page_load',
        stopwatch.elapsedMilliseconds,
        metadata: {
          'page': _currentPage.toString(),
          'item_count': newItems.length.toString(),
        },
      );

      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _hasMore = newItems.length == widget.pageSize;
        _isLoading = false;
      });

      // Manage cache size
      if (_items.length > widget.config.maxCacheSize) {
        final removeCount = _items.length - widget.config.maxCacheSize;
        _items.removeRange(0, removeCount);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      LoggingService.instance.error(
        'Failed to load lazy grid data',
        error: e,
        category: LogCategory.performance,
        context: {'page': _currentPage},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _items.isEmpty) {
      return widget.errorBuilder?.call(context, _error!) ??
          Center(child: Text('Error: $_error'));
    }

    if (_items.isEmpty && _isLoading) {
      return widget.loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return widget.emptyBuilder?.call(context) ??
          const Center(child: Text('No items found'));
    }

    return GridView.builder(
      controller: widget.controller ?? _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: _items.length + (_hasMore ? widget.crossAxisCount : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(child: CircularProgressIndicator());
        }

        return widget.itemBuilder(context, _items[index], index);
      },
    );
  }
}

/// Optimized image widget with lazy loading and caching
class LazyImage extends StatefulWidget {
  final String imageUrl;
  final Widget Function(BuildContext context)? placeholder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool enableMemoryCache;
  final bool enableDiskCache;

  const LazyImage({
    Key? key,
    required this.imageUrl,
    this.placeholder,
    this.errorBuilder,
    this.width,
    this.height,
    this.fit,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
  }) : super(key: key);

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.imageUrl),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible) {
          setState(() {
            _isVisible = true;
          });
        }
      },
      child: _isVisible
          ? Image.network(
              widget.imageUrl,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return widget.placeholder?.call(context) ??
                    const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return widget.errorBuilder?.call(context, error.toString()) ??
                    const Icon(Icons.error);
              },
            )
          : widget.placeholder?.call(context) ??
              Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey[300],
              ),
    );
  }
}

/// Visibility detector for lazy loading
class VisibilityDetector extends StatefulWidget {
  final Key key;
  final Widget child;
  final Function(VisibilityInfo) onVisibilityChanged;

  const VisibilityDetector({
    required this.key,
    required this.child,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _checkVisibility();
        return false;
      },
      child: widget.child,
    );
  }

  void _checkVisibility() {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      final viewport = RenderAbstractViewport.of(renderObject);
      if (viewport != null) {
        final vpHeight = viewport.paintBounds.height;
        final vpWidth = viewport.paintBounds.width;
        final bounds = renderObject.localToGlobal(Offset.zero) & renderObject.size;
        
        final visibleArea = bounds.intersect(Rect.fromLTWH(0, 0, vpWidth, vpHeight));
        final totalArea = bounds.width * bounds.height;
        final visibleFraction = totalArea > 0 ? (visibleArea.width * visibleArea.height) / totalArea : 0.0;
        
        widget.onVisibilityChanged(VisibilityInfo(visibleFraction: visibleFraction));
      }
    }
  }
}

/// Visibility information
class VisibilityInfo {
  final double visibleFraction;

  const VisibilityInfo({required this.visibleFraction});
}