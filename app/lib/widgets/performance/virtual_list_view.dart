import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// High-performance virtual list view that only renders visible items
class VirtualListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final double? itemExtent;
  final double Function(T item)? itemExtentBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final Axis scrollDirection;
  final bool reverse;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int? semanticChildCount;
  final double cacheExtent;
  final int preloadCount;
  final Function()? onEndReached;
  final double endReachedThreshold;

  const VirtualListView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.itemExtent,
    this.itemExtentBuilder,
    this.padding,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.shrinkWrap = false,
    this.physics,
    this.semanticChildCount,
    this.cacheExtent = RenderAbstractViewport.defaultCacheExtent,
    this.preloadCount = 3,
    this.onEndReached,
    this.endReachedThreshold = 200.0,
  }) : super(key: key);

  @override
  State<VirtualListView<T>> createState() => _VirtualListViewState<T>();
}

class _VirtualListViewState<T> extends State<VirtualListView<T>> {
  late ScrollController _scrollController;
  final Map<int, double> _itemExtents = {};
  double _averageItemExtent = 100.0;
  int _firstVisibleIndex = 0;
  int _lastVisibleIndex = 0;
  bool _hasCalledEndReached = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Calculate initial average item extent
    if (widget.itemExtent != null) {
      _averageItemExtent = widget.itemExtent!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    _updateVisibleRange();
    _checkEndReached();
  }

  void _updateVisibleRange() {
    if (widget.items.isEmpty) return;

    final viewportDimension = _scrollController.position.viewportDimension;
    final scrollOffset = _scrollController.position.pixels;
    
    // Calculate visible range based on scroll position
    int firstIndex = 0;
    int lastIndex = widget.items.length - 1;
    
    if (widget.itemExtent != null) {
      // Fixed item extent - simple calculation
      final itemExtent = widget.itemExtent!;
      firstIndex = math.max(0, (scrollOffset / itemExtent).floor() - widget.preloadCount);
      lastIndex = math.min(
        widget.items.length - 1,
        ((scrollOffset + viewportDimension) / itemExtent).ceil() + widget.preloadCount,
      );
    } else {
      // Variable item extents - more complex calculation
      double currentOffset = 0;
      bool foundFirst = false;
      
      for (int i = 0; i < widget.items.length; i++) {
        final itemExtent = _getItemExtent(i);
        
        if (!foundFirst && currentOffset + itemExtent >= scrollOffset - (_averageItemExtent * widget.preloadCount)) {
          firstIndex = math.max(0, i);
          foundFirst = true;
        }
        
        if (currentOffset > scrollOffset + viewportDimension + (_averageItemExtent * widget.preloadCount)) {
          lastIndex = math.min(widget.items.length - 1, i);
          break;
        }
        
        currentOffset += itemExtent;
      }
    }

    if (firstIndex != _firstVisibleIndex || lastIndex != _lastVisibleIndex) {
      setState(() {
        _firstVisibleIndex = firstIndex;
        _lastVisibleIndex = lastIndex;
      });
    }
  }

  void _checkEndReached() {
    if (widget.onEndReached == null || _hasCalledEndReached) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    if (maxScroll - currentScroll <= widget.endReachedThreshold) {
      _hasCalledEndReached = true;
      widget.onEndReached!();
      
      // Reset flag after a delay to allow for new items
      Future.delayed(const Duration(seconds: 1), () {
        _hasCalledEndReached = false;
      });
    }
  }

  double _getItemExtent(int index) {
    if (widget.itemExtent != null) {
      return widget.itemExtent!;
    }
    
    if (widget.itemExtentBuilder != null) {
      return widget.itemExtentBuilder!(widget.items[index]);
    }
    
    // Use cached extent or average
    return _itemExtents[index] ?? _averageItemExtent;
  }

  void _updateItemExtent(int index, double extent) {
    if (widget.itemExtent != null) return; // Fixed extent, no need to cache
    
    _itemExtents[index] = extent;
    
    // Update average extent for better estimates
    if (_itemExtents.isNotEmpty) {
      final totalExtent = _itemExtents.values.reduce((a, b) => a + b);
      _averageItemExtent = totalExtent / _itemExtents.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateVisibleRange();
        });

        return ListView.builder(
          controller: _scrollController,
          padding: widget.padding,
          scrollDirection: widget.scrollDirection,
          reverse: widget.reverse,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          cacheExtent: widget.cacheExtent,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            // Only build visible items plus cache extent
            if (index < _firstVisibleIndex || index > _lastVisibleIndex) {
              // Return a placeholder with estimated height for non-visible items
              return SizedBox(
                height: widget.scrollDirection == Axis.vertical ? _getItemExtent(index) : null,
                width: widget.scrollDirection == Axis.horizontal ? _getItemExtent(index) : null,
              );
            }

            // Build the actual item and measure its size
            return _MeasurableWidget(
              onSizeChanged: (size) {
                final extent = widget.scrollDirection == Axis.vertical ? size.height : size.width;
                _updateItemExtent(index, extent);
              },
              child: widget.itemBuilder(context, index, widget.items[index]),
            );
          },
        );
      },
    );
  }
}

/// Widget that measures its size and reports changes
class _MeasurableWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChanged;

  const _MeasurableWidget({
    required this.child,
    required this.onSizeChanged,
  });

  @override
  State<_MeasurableWidget> createState() => _MeasurableWidgetState();
}

class _MeasurableWidgetState extends State<_MeasurableWidget> {
  Size? _previousSize;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox?.hasSize == true) {
            final size = renderBox!.size;
            if (_previousSize != size) {
              _previousSize = size;
              widget.onSizeChanged(size);
            }
          }
        });
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: widget.child,
      ),
    );
  }
}

/// Optimized alert list view with virtual scrolling
class OptimizedAlertListView<T> extends StatefulWidget {
  final List<T> alerts;
  final Widget Function(BuildContext context, int index, T alert) alertBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final RefreshCallback? onRefresh;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final double itemSpacing;

  const OptimizedAlertListView({
    Key? key,
    required this.alerts,
    required this.alertBuilder,
    this.controller,
    this.padding,
    this.onRefresh,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
    this.loadingWidget,
    this.emptyWidget,
    this.itemSpacing = 12.0,
  }) : super(key: key);

  @override
  State<OptimizedAlertListView<T>> createState() => _OptimizedAlertListViewState<T>();
}

class _OptimizedAlertListViewState<T> extends State<OptimizedAlertListView<T>>
    with AutomaticKeepAliveStateMixin {
  
  @override
  bool get wantKeepAlive => true;

  Widget _buildLoadingIndicator() {
    return widget.loadingWidget ?? 
      const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
  }

  Widget _buildEmptyState() {
    return widget.emptyWidget ?? 
      const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No alerts found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.alerts.isEmpty && !widget.isLoading) {
      return widget.onRefresh != null 
        ? RefreshIndicator(
            onRefresh: widget.onRefresh!,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: _buildEmptyState(),
              ),
            ),
          )
        : _buildEmptyState();
    }

    Widget listView = VirtualListView<T>(
      items: widget.alerts,
      controller: widget.controller,
      padding: widget.padding,
      itemExtentBuilder: (alert) => _estimateItemHeight(alert),
      preloadCount: 5, // Preload 5 items in each direction
      cacheExtent: 500, // Cache 500 pixels worth of items
      onEndReached: widget.onLoadMore,
      endReachedThreshold: 300,
      itemBuilder: (context, index, alert) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < widget.alerts.length - 1 ? widget.itemSpacing : 0,
          ),
          child: widget.alertBuilder(context, index, alert),
        );
      },
    );

    // Add loading indicator at the bottom if loading more
    if (widget.hasMore || widget.isLoading) {
      listView = Column(
        children: [
          Expanded(child: listView),
          if (widget.isLoading) _buildLoadingIndicator(),
        ],
      );
    }

    // Wrap with RefreshIndicator if onRefresh is provided
    if (widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listView,
      );
    }

    return listView;
  }

  double _estimateItemHeight(T alert) {
    // Estimate item height based on content
    // This could be made more sophisticated based on alert content
    return 120.0; // Base height for alert cards
  }
}

/// Performance-optimized sliver list
class OptimizedSliverList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final double? itemExtent;
  final int preloadCount;

  const OptimizedSliverList({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.itemExtent,
    this.preloadCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (itemExtent != null) {
      return SliverFixedExtentList(
        itemExtent: itemExtent!,
        delegate: SliverChildBuilderDelegate(
          (context, index) => itemBuilder(context, index, items[index]),
          childCount: items.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return RepaintBoundary(
            child: itemBuilder(context, index, items[index]),
          );
        },
        childCount: items.length,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false, // We handle this manually
      ),
    );
  }
}