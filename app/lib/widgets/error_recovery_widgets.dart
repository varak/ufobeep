import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/network_connectivity_service.dart';
import '../services/offline_cache.dart';

/// Error recovery banner widget
class ErrorRecoveryBanner extends ConsumerWidget {
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showOfflineMode;

  const ErrorRecoveryBanner({
    Key? key,
    this.error,
    this.onRetry,
    this.onDismiss,
    this.showOfflineMode = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final networkService = NetworkConnectivityService();
    
    return StreamBuilder<NetworkStatus>(
      stream: networkService.networkStatusStream,
      builder: (context, snapshot) {
        final networkStatus = snapshot.data ?? NetworkStatus.unknown;
        final hasConnection = networkStatus == NetworkStatus.connected;
        
        if (hasConnection && error == null) {
          return const SizedBox.shrink();
        }
        
        Color backgroundColor;
        IconData icon;
        String message;
        
        if (!hasConnection) {
          backgroundColor = theme.colorScheme.surfaceVariant;
          icon = Icons.wifi_off;
          message = showOfflineMode 
              ? 'Offline mode - Showing cached content'
              : 'No internet connection';
        } else if (error != null) {
          backgroundColor = theme.colorScheme.errorContainer;
          icon = Icons.error_outline;
          message = 'Error: $error';
        } else {
          return const SizedBox.shrink();
        }
        
        return Container(
          width: double.infinity,
          color: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onRetry,
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              if (onDismiss != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onDismiss,
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Comprehensive error state widget
class ErrorStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final String? subMessage;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String retryLabel;
  final List<Widget>? additionalActions;
  final bool showNetworkStatus;

  const ErrorStateWidget({
    Key? key,
    this.title,
    this.message,
    this.subMessage,
    this.icon,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.additionalActions,
    this.showNetworkStatus = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final networkService = NetworkConnectivityService();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                color: theme.colorScheme.onErrorContainer,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title ?? 'Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
            if (subMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                subMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (showNetworkStatus) ...[
              const SizedBox(height: 16),
              StreamBuilder<NetworkStatus>(
                stream: networkService.networkStatusStream,
                builder: (context, snapshot) {
                  final status = snapshot.data ?? NetworkStatus.unknown;
                  final description = networkService.connectionDescription;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getNetworkIcon(status),
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (onRetry != null)
                  FilledButton(
                    onPressed: onRetry,
                    child: Text(retryLabel),
                  ),
                ...?additionalActions,
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNetworkIcon(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return Icons.wifi;
      case NetworkStatus.limited:
        return Icons.wifi_off;
      case NetworkStatus.disconnected:
        return Icons.wifi_off;
      case NetworkStatus.unknown:
        return Icons.help_outline;
    }
  }
}

/// Loading state with error handling
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool showProgress;
  final VoidCallback? onCancel;

  const LoadingStateWidget({
    Key? key,
    this.message,
    this.showProgress = true,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showProgress)
            const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
          if (onCancel != null) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Retry button with countdown
class RetryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final Duration? cooldownDuration;
  final bool enabled;

  const RetryButton({
    Key? key,
    this.onPressed,
    this.label = 'Retry',
    this.cooldownDuration,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<RetryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _cooldownTimer;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    if (widget.cooldownDuration == null) return;
    
    setState(() {
      _countdown = widget.cooldownDuration!.inSeconds;
    });
    
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });
      
      if (_countdown <= 0) {
        timer.cancel();
        _cooldownTimer = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isInCooldown = _countdown > 0;
    final isEnabled = widget.enabled && !isInCooldown;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FilledButton(
          onPressed: isEnabled ? () {
            _controller.forward().then((_) {
              _controller.reverse();
            });
            _startCooldown();
            widget.onPressed?.call();
          } : null,
          child: Text(
            isInCooldown 
                ? '${widget.label} ($_countdown)'
                : widget.label,
          ),
        );
      },
    );
  }
}

/// Offline indicator widget
class OfflineIndicator extends ConsumerWidget {
  final bool showWhenOnline;
  final EdgeInsetsGeometry? padding;

  const OfflineIndicator({
    Key? key,
    this.showWhenOnline = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final networkService = NetworkConnectivityService();
    
    return StreamBuilder<NetworkStatus>(
      stream: networkService.networkStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? NetworkStatus.unknown;
        final isOffline = status != NetworkStatus.connected;
        
        if (!isOffline && !showWhenOnline) {
          return const SizedBox.shrink();
        }
        
        return Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(8),
          color: isOffline 
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.primaryContainer,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isOffline ? Icons.cloud_off : Icons.cloud_done,
                size: 16,
                color: isOffline 
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                isOffline ? 'Offline' : 'Online',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isOffline 
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Cache status widget
class CacheStatusWidget extends StatefulWidget {
  final bool showDetails;
  
  const CacheStatusWidget({
    Key? key,
    this.showDetails = false,
  }) : super(key: key);

  @override
  State<CacheStatusWidget> createState() => _CacheStatusWidgetState();
}

class _CacheStatusWidgetState extends State<CacheStatusWidget> {
  CacheStatistics? _cacheStats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCacheStats();
  }

  Future<void> _loadCacheStats() async {
    try {
      final cacheService = OfflineCacheService();
      await cacheService.initialize();
      final stats = await cacheService.getCacheStatistics();
      
      if (mounted) {
        setState(() {
          _cacheStats = stats;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    
    if (_cacheStats == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: widget.showDetails 
          ? _buildDetailedStats(theme)
          : _buildSimpleStats(theme),
    );
  }

  Widget _buildSimpleStats(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.storage,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          '${_cacheStats!.totalEntries} cached',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStats(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Cache Status',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Total: ${_cacheStats!.totalEntries}',
          style: theme.textTheme.bodySmall,
        ),
        Text(
          'Alerts: ${_cacheStats!.alertsCount}',
          style: theme.textTheme.bodySmall,
        ),
        Text(
          'API Responses: ${_cacheStats!.apiResponsesCount}',
          style: theme.textTheme.bodySmall,
        ),
        if (_cacheStats!.pendingSubmissionsCount > 0)
          Text(
            'Pending Sync: ${_cacheStats!.pendingSubmissionsCount}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (_cacheStats!.expiredEntriesCount > 0)
          Text(
            'Expired: ${_cacheStats!.expiredEntriesCount}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
      ],
    );
  }
}

/// Error boundary widget for catching and displaying errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
    this.onError,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    
    // Catch Flutter errors
    FlutterError.onError = (details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
      }
      widget.onError?.call(details.exception, details.stack);
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }
      
      return ErrorStateWidget(
        title: 'Application Error',
        message: _error.toString(),
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
          });
        },
      );
    }
    
    return widget.child;
  }
}