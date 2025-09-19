import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../providers/alerts_provider.dart';
import '../../providers/app_state.dart';
import '../../providers/user_preferences_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/alert_title_utils.dart';
import '../../widgets/alert_sections/alert_hero_section.dart';
import '../../widgets/alert_sections/alert_details_section.dart';
import '../../widgets/alert_sections/alert_direction_section.dart';
import '../../widgets/alert_sections/alert_actions_section.dart';
import '../../widgets/better_player_widget.dart';
import '../../widgets/enrichment/enrichment_section.dart';
import '../../services/beep_service.dart';
import '../../services/user_service.dart';
import '../../services/api_client.dart';
import '../../services/ui_feedback.dart';
import '../../widgets/glass_card.dart';
import '../../l10n/app_localizations.dart';
import '../../services/comments_service.dart';
import '../../services/push_notification_service.dart';
import '../../models/comment.dart';
import '../../utils/short_url_utils.dart';

class AlertDetailScreen extends ConsumerStatefulWidget {
  const AlertDetailScreen({super.key, required this.alertId, this.initialCommentId, this.shouldFocusComment});

  final String alertId;
  final String? initialCommentId;
  final bool? shouldFocusComment;

  @override
  ConsumerState<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends ConsumerState<AlertDetailScreen> {
  String? _currentUserDeviceId;
  String? _currentUsername;
  bool _isWitnessConfirmed = false;
  bool _isFollowing = false;
  bool _followingLoading = false;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final GlobalKey _commentInputKey = GlobalKey();
  bool _isPostingComment = false;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _commentKeys = {};
  bool _hasScrolledToComment = false;
  bool _hasFocusedComment = false;
  List<Comment>? _comments;
  bool _loadingComments = true;
  String? _commentsError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadComments();
    // Listen for refresh notifications from push notifications
    debugPrint('💬 AlertDetailScreen: registering listener for alertId=${widget.alertId}');
    CommentsRefreshNotifier.instance.addListener(widget.alertId, _refreshComments);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    // Remove refresh listener
    debugPrint('💬 AlertDetailScreen: removing listener for alertId=${widget.alertId}');
    CommentsRefreshNotifier.instance.removeListener(widget.alertId, _refreshComments);
    super.dispose();
  }

  Future<void> _loadComments({bool fromNotification = false}) async {
    try {
      setState(() {
        _loadingComments = true;
        _commentsError = null;
      });

      final comments = await CommentsService().getComments(widget.alertId);

      if (mounted) {
        setState(() {
          _comments = comments;
          _loadingComments = false;
        });

        // Scroll to target comment or bottom after comments are loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (fromNotification && _comments?.isNotEmpty == true) {
            // Auto-scroll to bottom for notification-triggered refreshes
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            _scrollToCommentIfNeeded();
          }
          _focusCommentIfNeeded();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _commentsError = e.toString();
          _loadingComments = false;
        });
      }
    }
  }

  void _refreshComments() {
    debugPrint('💬 AlertDetailScreen: refreshing comments for ${widget.alertId}');
    _loadComments(fromNotification: true);
  }

  void _scrollToBottom() {
    debugPrint('🔄 AlertDetailScreen: _scrollToBottom called: hasClients=${_scrollController.hasClients}');
    if (_scrollController.hasClients) {
      final maxExtent = _scrollController.position.maxScrollExtent;
      debugPrint('🔄 AlertDetailScreen: Scrolling to maxExtent: $maxExtent');
      _scrollController.animateTo(
        maxExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      debugPrint('❌ AlertDetailScreen: Cannot scroll: no scroll controller clients');
    }
  }

  Future<void> _loadUserData() async {
    // Get current user's ID (username-based system MP13-1)
    try {
      // Try to get user ID first, fallback to device ID for transition period
      String? userId;
      try {
        userId = await userService.getCurrentUserId();
        final username = await userService.getCurrentUsername();
        debugPrint('DEBUG: Loaded user ID: "$userId", username: "$username"');

        if (mounted) {
          setState(() {
            _currentUserDeviceId = userId; // Using same variable name during transition
            _currentUsername = username;
          });
          debugPrint('DEBUG: Set _currentUserDeviceId: "$_currentUserDeviceId", _currentUsername: "$_currentUsername"');
        }

        // Check if this user is a confirmed witness
        if (userId != null) {
          await _checkWitnessStatus(userId);
        }

        // Check follow status for comments
        await _checkFollowStatus();
      } catch (e) {
        debugPrint('DEBUG: Could not get user info: $e');
        // Don't fallback to device ID - use null for proper filtering
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _checkWitnessStatus(String deviceId) async {
    try {
      final result = await ApiClient.instance.getWitnessStatus(
        sightingId: widget.alertId,
        deviceId: deviceId,
      );
      
      if (mounted) {
        setState(() {
          _isWitnessConfirmed = result['data']?['has_confirmed'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('❌ ERROR checking witness status: $e');
      if (mounted) {
        setState(() {
          _isWitnessConfirmed = false;
        });
      }
    }
  }
  
  Future<void> _postInlineComment(String sightingId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isPostingComment) return;
    setState(() { _isPostingComment = true; });
    try {
      final service = CommentsService();
      await service.postComment(sightingId, text);
      if (mounted) {
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.commentPosted), backgroundColor: AppColors.brandPrimary),
        );
        // Refresh details to update comment count
        ref.invalidate(alertByIdProvider(widget.alertId));
        // Refresh comments to show the new comment
        _loadComments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric), backgroundColor: AppColors.semanticError),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isPostingComment = false; });
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      final service = CommentsService();
      await service.deleteComment(widget.alertId, commentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment deleted'),
            backgroundColor: AppColors.brandPrimary,
          ),
        );
        // Refresh details to update comment list
        ref.invalidate(alertByIdProvider(widget.alertId));
        // Refresh comments to remove the deleted comment
        _loadComments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete comment: $e'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    }
  }

  Future<void> _checkFollowStatus() async {
    try {
      final response = await ApiClient.dio.get(
        '/beep/${widget.alertId}/follow',
        queryParameters: _currentUserDeviceId != null ? {'device_id': _currentUserDeviceId} : null,
      );
      if (mounted) {
        setState(() {
          _isFollowing = response.data['following'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('❌ ERROR checking follow status: $e');
      if (mounted) {
        setState(() {
          _isFollowing = false;
        });
      }
    }
  }
  
  Future<void> _toggleFollow() async {
    if (_followingLoading) return;
    
    setState(() {
      _followingLoading = true;
    });
    
    try {
      if (_isFollowing) {
        await ApiClient.dio.delete(
          '/beep/${widget.alertId}/follow',
          data: _currentUserDeviceId != null ? {'device_id': _currentUserDeviceId} : null,
        );
        setState(() {
          _isFollowing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unfollowed alert - no more comment notifications'),
              backgroundColor: AppColors.textSecondary,
            ),
          );
        }
      } else {
        await ApiClient.dio.post(
          '/beep/${widget.alertId}/follow',
          data: _currentUserDeviceId != null ? {'device_id': _currentUserDeviceId} : null,
        );
        setState(() {
          _isFollowing = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Following alert - you\'ll get comment notifications'),
              backgroundColor: AppColors.brandPrimary,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error toggling follow: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _followingLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertAsync = ref.watch(alertByIdProvider(widget.alertId));
    final appState = ref.watch(appStateProvider);
    final alertsAsync = ref.watch(alertsListProvider);

    return alertAsync.when(
      data: (alert) {
        if (alert == null) {
          return FutureBuilder(
            future: Future.delayed(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Alert')),
                  body: const Center(
                    child: CircularProgressIndicator(color: AppColors.brandPrimary),
                  ),
                );
              }
              return Scaffold(
                appBar: AppBar(title: const Text('Alert')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Alert not found'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(alertByIdProvider(widget.alertId)),
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        debugPrint('DEBUG: Building alert detail for alert.reporterId: "${alert.reporterId}"');
        debugPrint('DEBUG: Current _currentUserDeviceId: "$_currentUserDeviceId"');
        
        return NightSkyBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Builder(
                builder: (ctx) {
                  final l10n = AppLocalizations.of(ctx)!;

                  final caseNumber = alert.enrichment?['mufon_case_number'];
                  final title = caseNumber != null
                    ? l10n.mufonCaseTitle(caseNumber)
                    : 'UFOBeep ${l10n.ufo} ${l10n.alert}';

                  return Text(title);
                },
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _showShareOptions(alert),
                ),
            ],
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero section with media
                AlertHeroSection(
                  alert: alert,
                  onMediaTap: (index) => _showFullscreenImage(alert, index),
                ),
                const SizedBox(height: 24),
                
                // Alert details
                AlertDetailsSection(
                  alert: alert,
                  units: (ref.read(userPreferencesProvider)?.units ?? 'metric'),
                  onShareTap: () => _showShareOptions(alert),
                ),
                const SizedBox(height: 16),
                
                
                // Direction and compass - hidden for MUFON alerts
                if (alert.source != 'mufon') ...[
                  AlertDirectionSection(
                    alert: alert,
                    onNavigate: (bearing, distance) => _navigateToSighting(alert, bearing, distance),
                    onShowMap: (userLocation, alert) => _showMapView(userLocation, alert),
                  ),
                  const SizedBox(height: 24),
                ],

                // Environmental context (if available) - hidden for MUFON alerts
                if (alert.enrichment != null && alert.enrichment!.isNotEmpty && alert.source != 'mufon') ...[
                  EnrichmentSection(
                    enrichmentData: alert.enrichment,
                    alertCreatorDeviceId: alert.reporterId,
                    currentUserDeviceId: _currentUserDeviceId,
                    isWitnessConfirmed: _isWitnessConfirmed,
                    alertSource: alert.source,
                    reporterUsername: alert.username,
                  ),
                  const SizedBox(height: 24),
                ],

                // Photo analysis (if available) 
                if (alert.photoAnalysis != null && alert.photoAnalysis!.isNotEmpty) ...[
                  _buildPhotoAnalysisSection(alert),
                  const SizedBox(height: 24),
                ],


                // Action buttons (including witness confirmation) - hidden for MUFON alerts
                if (alert.source != 'mufon') ...[
                  AlertActionsSection(
                    alert: alert,
                    currentUserDeviceId: _currentUserDeviceId,
                    currentUsername: _currentUsername,
                    onAddPhotos: () => _showAddPhotosDialog(widget.alertId),
                    onReportToMufon: () => _showMufonReportDialog(),
                    onWitnessConfirmed: (witnessCount) {
                      // Refresh witness status after confirmation
                      if (_currentUserDeviceId != null) {
                        _checkWitnessStatus(_currentUserDeviceId!);
                      }
                      // Also refresh the alert data to update witness count display
                    ref.invalidate(alertByIdProvider(widget.alertId));
                  },
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Follow toggle for comment notifications
                _buildFollowSection(),
                const SizedBox(height: 16),
                
                // Comments section
                _buildCommentsSection(alert),
              ],
            ),
          ),
        ), // Scaffold
        ); // NightSkyBackground
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Alert')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.brandPrimary),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Alert')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.semanticError,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load alert',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.invalidate(alertByIdProvider(widget.alertId)),
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullscreenImage(Alert alert, [int startIndex = 0]) {
    if (alert.mediaFiles.isEmpty) return;
    
    final media = alert.mediaFiles[startIndex];
    final mediaUrl = media['url'] as String? ?? '';
    final mediaType = media['type'] as String? ?? 'image';
    
    if (mediaUrl.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: _buildFullscreenMediaContent(mediaUrl, mediaType),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 32,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullscreenMediaContent(String mediaUrl, String mediaType) {
    if (mediaType == 'video') {
      // For videos, use BetterPlayerWidget with proper aspect ratio preservation
      return Center(
        child: BetterPlayerWidget(
          videoUrl: mediaUrl,
          autoPlay: true,
          showControls: true,
        ),
      );
    } else {
      // For images, use InteractiveViewer for zoom functionality
      return InteractiveViewer(
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          mediaUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: AppColors.semanticError),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  void _navigateToSighting(Alert alert, double bearing, double distance) {
    final targetName = AlertTitleUtils.getShortTitleFromAlert(alert);
    final compassParams = {
      'targetLat': alert.latitude.toString(),
      'targetLon': alert.longitude.toString(),
      'targetName': Uri.encodeComponent(targetName),
      'targetBearing': bearing.toStringAsFixed(1),
      'distance': distance.toStringAsFixed(1),
      'alertId': alert.id,
    };
    
    final uri = Uri(path: '/compass', queryParameters: compassParams);
    context.go(uri.toString());
  }

  void _showMapView(Position userLocation, Alert alert) {
    final targetName = AlertTitleUtils.getShortTitleFromAlert(alert);
    final mapParams = {
      'userLat': userLocation.latitude.toString(),
      'userLon': userLocation.longitude.toString(),
      'alertLat': alert.latitude.toString(),
      'alertLon': alert.longitude.toString(),
      'alertId': alert.id,
      'alertName': Uri.encodeComponent(targetName),
    };
    
    final uri = Uri(path: '/map', queryParameters: mapParams);
    context.go(uri.toString());
  }

  Future<void> _pickFromGalleryForAlert(String alertId) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true, // Enable multiple file selection
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // User cancelled
      }

      // Close the modal
      Navigator.of(context).pop();

      // Navigate to multi-file upload screen
      context.push('/beep/multi-upload', extra: {
        'files': result.files,
        'alertId': alertId,
      });

    } catch (e) {
      debugPrint('Error picking files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick files: $e')),
      );
    }
  }

  void _refreshAlert() {
    // Refresh the alert data after media upload
    ref.refresh(alertByIdProvider(widget.alertId));
  }

  void _showAddPhotosDialog(String alertId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.edit,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.beepExplain,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    onTap: () async {
                      await UiFeedback.click();
                      Navigator.pop(context);
                      context.push('/beep/camera', extra: {
                        'attachToSightingId': alertId,
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.capturePhoto,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassCard(
                    onTap: () async {
                      await UiFeedback.click();
                      Navigator.pop(context);
                      await _pickFromGalleryForAlert(alertId);
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.pickFromGallery,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMufonReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: Row(
            children: [
              const Icon(Icons.report_outlined, color: AppColors.brandPrimary),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.reportToMufon),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About UFOBeep & MUFON',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'UFOBeep is designed for quick, real-time alerts to help witnesses connect and verify sightings instantly.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 12),
                Text(
                  'MUFON (Mutual UFO Network) is the world\'s oldest and largest UFO investigation organization. They collect detailed scientific reports and conduct thorough investigations.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.whyReportToMufon,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Permanent scientific record\n'
                  '• Professional investigation\n'
                  '• Detailed witness testimony\n'
                  '• Contributing to UFO research\n'
                  '• Access to MUFON\'s global database',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 16),
                Text(
                  'The MUFON report form will ask for detailed information about your sighting including time, duration, weather conditions, and a full description.',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                final Uri mufonUrl = Uri.parse('https://mufon.com/cms-ifo-info/');
                try {
                  await launchUrl(
                    mufonUrl, 
                    mode: LaunchMode.externalApplication,
                    webViewConfiguration: const WebViewConfiguration(
                      enableJavaScript: true,
                      enableDomStorage: true,
                    ),
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not open MUFON website: $e'),
                        backgroundColor: AppColors.semanticError,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.open_in_browser),
              label: Text(AppLocalizations.of(context)!.openMufonReport),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  // Keep only essential legacy sections for environmental and photo analysis
  // These will be modularized later if needed

  Widget _buildPhotoAnalysisSection(Alert alert) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo, color: AppColors.brandPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.photoAnalysisTitle,
                style: const TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.mediaItemsProcessed(alert.photoAnalysis!.length),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFollowSection() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            _isFollowing ? Icons.notifications : Icons.notifications_outlined,
            color: _isFollowing ? AppColors.brandPrimary : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isFollowing 
                    ? AppLocalizations.of(context)!.autoFollowEnabled 
                    : AppLocalizations.of(context)!.notifications,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isFollowing 
                    ? AppLocalizations.of(context)!.newCommentNotification
                    : AppLocalizations.of(context)!.enablePushNotifications,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (_followingLoading) 
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.brandPrimary,
              ),
            )
          else
            Switch(
              value: _isFollowing,
              onChanged: (_) => _toggleFollow(),
              activeColor: AppColors.brandPrimary,
            ),
        ],
      ),
    );
  }
  
  Widget _buildCommentsSection(Alert alert) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline, color: AppColors.brandPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.commentsTitle,
                style: const TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (alert.commentCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${alert.commentCount}',
                    style: const TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          
          // Show existing comments - uses state variables for real-time updates
          _buildCommentsDisplay(),
          
          // Inline comment input
          Container(
            key: _commentInputKey,
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              maxLines: 3,
              minLines: 1,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.addComment,
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.darkBorder.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.darkBorder.withOpacity(0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: AppColors.brandPrimary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isPostingComment ? null : () => _postInlineComment(alert.id),
              icon: _isPostingComment
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandPrimary),
                    )
                  : const Icon(Icons.send, size: 16),
              label: Text(AppLocalizations.of(context)!.send),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkSurface,
                foregroundColor: AppColors.brandPrimary,
                side: const BorderSide(color: AppColors.brandPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsDisplay() {
    if (_loadingComments) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(color: AppColors.brandPrimary, strokeWidth: 2),
        ),
      );
    }

    if (_commentsError != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Error loading comments',
          style: const TextStyle(color: AppColors.semanticError, fontSize: 14),
        ),
      );
    }

    final comments = _comments ?? [];
    if (comments.isNotEmpty) {
      // Scroll to target comment after comments are rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCommentIfNeeded();
      });

      return Column(
        children: [
          ...comments.map((comment) => _buildCommentItem(comment)).toList(),
          const SizedBox(height: 16),
          const Divider(color: AppColors.darkBorder, thickness: 1),
          const SizedBox(height: 16),
        ],
      );
    }

    // If no comments, still show a small spacing before the input field
    return const SizedBox(height: 8);
  }

  Widget _buildCommentItem(Comment comment) {
    final timeAgo = _formatCommentTime(context, comment.createdAt);
    final canDelete = _currentUserDeviceId != null && comment.userId == _currentUserDeviceId;

    // Create or get a GlobalKey for this comment
    final commentId = comment.id.toString();
    _commentKeys[commentId] ??= GlobalKey();
    final commentKey = _commentKeys[commentId]!;

    // Check if this is the target comment from notification
    final isTargetComment = widget.initialCommentId == commentId;

    return Container(
      key: commentKey,
      padding: const EdgeInsets.only(bottom: 12),
      decoration: isTargetComment ? BoxDecoration(
        color: AppColors.brandPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
      ) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.brandPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (canDelete) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showDeleteCommentDialog(comment),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: AppColors.semanticError,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              comment.body,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteCommentDialog(Comment comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: const Text(
            'Delete Comment',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Are you sure you want to delete this comment? This action cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteComment(comment.id.toString());
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.semanticError),
              ),
            ),
          ],
        );
      },
    );
  }
  
  String _formatCommentTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return l10n!.timeDaysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n!.timeHoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l10n!.timeMinutesAgo(difference.inMinutes);
    } else {
      return l10n!.timeJustNow;
    }
  }

  void _scrollToCommentIfNeeded() {
    // Only scroll once and only if we have an initialCommentId
    if (widget.initialCommentId != null && !_hasScrolledToComment) {
      final commentKey = _commentKeys[widget.initialCommentId!];
      if (commentKey?.currentContext != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            Scrollable.ensureVisible(
              commentKey!.currentContext!,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              alignment: 0.1, // Scroll to 10% from top of screen
            );
            _hasScrolledToComment = true;
          } catch (e) {
            debugPrint('Error scrolling to comment: $e');
          }
        });
      }
    }
  }

  void _focusCommentIfNeeded() {
    // Only focus once and only if shouldFocusComment is true
    if (widget.shouldFocusComment == true && !_hasFocusedComment) {
      final commentInputContext = _commentInputKey.currentContext;
      if (commentInputContext != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            // First scroll to the comment input area
            Scrollable.ensureVisible(
              commentInputContext,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              alignment: 0.8, // Scroll to 80% from top to keep input visible
            ).then((_) {
              // Then focus the text field after scrolling is complete
              if (mounted) {
                _commentFocusNode.requestFocus();
                debugPrint('💬 Focused comment input for quick reply');
              }
            });
            _hasFocusedComment = true;
          } catch (e) {
            debugPrint('Error focusing comment input: $e');
          }
        });
      }
    }
  }

  void _showShareOptions(Alert alert) {
    final l10n = AppLocalizations.of(context)!;
    final shareUrl = 'https://ufobeep.com/${alert.shortUrl}';
    final shareText = '${l10n.ufoSightingAlert}: ${alert.description ?? l10n.anomalyReported} - ${alert.locationName ?? l10n.unknownLocation}';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.shareAlert,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Copy link option
            ListTile(
              leading: const Icon(Icons.content_copy, color: AppColors.brandPrimary),
              title: Text(l10n.copyShortLink, style: const TextStyle(color: AppColors.textPrimary)),
              subtitle: Text(shareUrl, style: const TextStyle(color: AppColors.textSecondary)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: shareUrl));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.copyShortLink)),
                );
              },
            ),

            // Native share option
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.brandPrimary),
              title: Text(l10n.shareAlert, style: const TextStyle(color: AppColors.textPrimary)),
              subtitle: Text(l10n.shareAlert, style: const TextStyle(color: AppColors.textSecondary)),
              onTap: () async {
                Navigator.pop(context);
                await _shareNatively(shareText, shareUrl);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareNatively(String text, String url) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Use share_plus for proper native sharing
      final shareContent = '$text\n\n$url';
      await Share.share(
        shareContent,
        subject: l10n.ufoSightingAlert,
      );
    } catch (e) {
      debugPrint('Native sharing failed: $e');
      // Fallback to clipboard
      await Clipboard.setData(ClipboardData(text: '$text\n\n$url'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.copyShortLink)),
        );
      }
    }
  }


}
