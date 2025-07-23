import 'package:flutter/material.dart';
import '../loading/smart_loading_widget.dart';
import '../error/smart_error_widget.dart';

/// Smart state management widget that handles loading, error, empty, and content states
class SmartStateWidget<T> extends StatelessWidget {
  final AsyncSnapshot<T>? snapshot;
  final bool isLoading;
  final String? error;
  final T? data;
  final Widget Function(T data) contentBuilder;
  final Widget Function()? emptyBuilder;
  final Widget Function(String error)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final VoidCallback? onRetry;
  final VoidCallback? onRefresh;
  final String? loadingMessage;
  final LoadingType loadingType;
  final ErrorType errorType;
  final bool showEmptyState;
  final bool Function(T data)? isEmpty;

  const SmartStateWidget({
    Key? key,
    this.snapshot,
    this.isLoading = false,
    this.error,
    this.data,
    required this.contentBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.onRetry,
    this.onRefresh,
    this.loadingMessage,
    this.loadingType = LoadingType.generic,
    this.errorType = ErrorType.generic,
    this.showEmptyState = true,
    this.isEmpty,
  }) : super(key: key);

  /// Constructor for Future/Stream data
  SmartStateWidget.future({
    Key? key,
    required AsyncSnapshot<T> snapshot,
    required Widget Function(T data) contentBuilder,
    Widget Function()? emptyBuilder,
    Widget Function(String error)? errorBuilder,
    Widget Function()? loadingBuilder,
    VoidCallback? onRetry,
    VoidCallback? onRefresh,
    String? loadingMessage,
    LoadingType loadingType = LoadingType.generic,
    ErrorType errorType = ErrorType.generic,
    bool showEmptyState = true,
    bool Function(T data)? isEmpty,
  }) : this(
         key: key,
         snapshot: snapshot,
         contentBuilder: contentBuilder,
         emptyBuilder: emptyBuilder,
         errorBuilder: errorBuilder,
         loadingBuilder: loadingBuilder,
         onRetry: onRetry,
         onRefresh: onRefresh,
         loadingMessage: loadingMessage,
         loadingType: loadingType,
         errorType: errorType,
         showEmptyState: showEmptyState,
         isEmpty: isEmpty,
       );

  /// Constructor for manual state management
  SmartStateWidget.manual({
    Key? key,
    required bool isLoading,
    String? error,
    T? data,
    required Widget Function(T data) contentBuilder,
    Widget Function()? emptyBuilder,
    Widget Function(String error)? errorBuilder,
    Widget Function()? loadingBuilder,
    VoidCallback? onRetry,
    VoidCallback? onRefresh,
    String? loadingMessage,
    LoadingType loadingType = LoadingType.generic,
    ErrorType errorType = ErrorType.generic,
    bool showEmptyState = true,
    bool Function(T data)? isEmpty,
  }) : this(
         key: key,
         isLoading: isLoading,
         error: error,
         data: data,
         contentBuilder: contentBuilder,
         emptyBuilder: emptyBuilder,
         errorBuilder: errorBuilder,
         loadingBuilder: loadingBuilder,
         onRetry: onRetry,
         onRefresh: onRefresh,
         loadingMessage: loadingMessage,
         loadingType: loadingType,
         errorType: errorType,
         showEmptyState: showEmptyState,
         isEmpty: isEmpty,
       );

  @override
  Widget build(BuildContext context) {
    // Determine current state
    final currentState = _getCurrentState();

    switch (currentState) {
      case WidgetState.loading:
        return _buildLoadingState();

      case WidgetState.error:
        return _buildErrorState();

      case WidgetState.empty:
        return _buildEmptyState();

      case WidgetState.content:
        return _buildContentState();
    }
  }

  WidgetState _getCurrentState() {
    // Check snapshot first if available
    if (snapshot != null) {
      if (snapshot!.connectionState == ConnectionState.waiting) {
        return WidgetState.loading;
      }

      if (snapshot!.hasError) {
        return WidgetState.error;
      }

      if (snapshot!.hasData) {
        final data = snapshot!.data!;
        if (showEmptyState && _isDataEmpty(data)) {
          return WidgetState.empty;
        }
        return WidgetState.content;
      }

      return WidgetState.loading;
    }

    // Check manual state
    if (isLoading) {
      return WidgetState.loading;
    }

    if (error != null) {
      return WidgetState.error;
    }

    if (data != null) {
      if (showEmptyState && _isDataEmpty(data!)) {
        return WidgetState.empty;
      }
      return WidgetState.content;
    }

    return WidgetState.loading;
  }

  bool _isDataEmpty(T data) {
    if (isEmpty != null) {
      return isEmpty!(data);
    }

    if (data is List) {
      return (data as List).isEmpty;
    }

    if (data is Map) {
      return (data as Map).isEmpty;
    }

    if (data is String) {
      return (data as String).isEmpty;
    }

    return false;
  }

  Widget _buildLoadingState() {
    if (loadingBuilder != null) {
      return loadingBuilder!();
    }

    return Center(
      child: SmartLoadingWidget(type: loadingType, message: loadingMessage),
    );
  }

  Widget _buildErrorState() {
    final errorMessage =
        error ?? snapshot?.error?.toString() ?? 'Unknown error';

    if (errorBuilder != null) {
      return errorBuilder!(errorMessage);
    }

    return Center(
      child: SmartErrorWidget(
        error: errorMessage,
        type: errorType,
        onRetry: onRetry,
      ),
    );
  }

  Widget _buildEmptyState() {
    if (emptyBuilder != null) {
      return emptyBuilder!();
    }

    return _buildDefaultEmptyState();
  }

  Widget _buildContentState() {
    final contentData = data ?? snapshot!.data!;

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async {
          onRefresh!();
        },
        child: contentBuilder(contentData),
      );
    }

    return contentBuilder(contentData);
  }

  Widget _buildDefaultEmptyState() {
    return const Center(child: EmptyStateWidget());
  }
}

/// Widget state enumeration
enum WidgetState { loading, error, empty, content }

/// Default empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    Key? key,
    this.title,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon ?? Icons.inbox_outlined,
            size: 60,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          title ?? 'Henüz içerik yok',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          subtitle ?? 'İçerik eklendiğinde burada görünecek',
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
          textAlign: TextAlign.center,
        ),

        if (onAction != null) ...[
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onAction,
            child: Text(actionLabel ?? 'Yenile'),
          ),
        ],
      ],
    );
  }
}

/// Paginated state widget for lists with pagination
class PaginatedStateWidget<T> extends StatelessWidget {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final Widget Function(T item, int index) itemBuilder;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRefresh;
  final VoidCallback? onRetry;
  final Widget? separator;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;

  const PaginatedStateWidget({
    Key? key,
    required this.items,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    required this.itemBuilder,
    this.onLoadMore,
    this.onRefresh,
    this.onRetry,
    this.separator,
    this.padding,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && isLoading) {
      return const Center(
        child: SmartLoadingWidget(
          type: LoadingType.generic,
          message: 'Yükleniyor...',
        ),
      );
    }

    if (items.isEmpty && error != null) {
      return Center(
        child: SmartErrorWidget(
          error: error!,
          type: ErrorType.generic,
          onRetry: onRetry,
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(child: EmptyStateWidget());
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: ListView.separated(
        padding: padding,
        physics: physics,
        itemCount: items.length + (hasMore ? 1 : 0),
        separatorBuilder: (context, index) {
          if (index == items.length - 1 && hasMore) {
            return const SizedBox.shrink();
          }
          return separator ?? const SizedBox(height: 8);
        },
        itemBuilder: (context, index) {
          if (index == items.length) {
            // Loading more indicator
            return _buildLoadMoreIndicator(context);
          }

          // Trigger load more when near end
          if (index == items.length - 3 && hasMore && !isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onLoadMore?.call();
            });
          }

          return itemBuilder(items[index], index);
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator(BuildContext context) {
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Yükleme hatası: $error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SmartLoadingWidget(type: LoadingType.generic, size: 40),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Smart list widget that combines SmartStateWidget with pagination
class SmartListWidget<T> extends StatelessWidget {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final Widget Function(T item, int index) itemBuilder;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRefresh;
  final VoidCallback? onRetry;
  final Widget? separator;
  final Widget? emptyWidget;
  final EdgeInsets? padding;

  const SmartListWidget({
    Key? key,
    required this.items,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    required this.itemBuilder,
    this.onLoadMore,
    this.onRefresh,
    this.onRetry,
    this.separator,
    this.emptyWidget,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmartStateWidget<List<T>>.manual(
      isLoading: isLoading && items.isEmpty,
      error: error != null && items.isEmpty ? error : null,
      data: items,
      isEmpty: (data) => data.isEmpty,
      contentBuilder: (data) => PaginatedStateWidget<T>(
        items: data,
        isLoading: isLoading,
        hasMore: hasMore,
        error: items.isNotEmpty ? error : null,
        itemBuilder: itemBuilder,
        onLoadMore: onLoadMore,
        onRefresh: onRefresh,
        onRetry: onRetry,
        separator: separator,
        padding: padding,
      ),
      emptyBuilder: () => emptyWidget ?? const EmptyStateWidget(),
      onRetry: onRetry,
      onRefresh: onRefresh,
    );
  }
}
