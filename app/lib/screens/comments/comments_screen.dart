import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/comment.dart';
import '../../services/comments_service.dart';
import '../../widgets/comments/comment_item.dart';
import '../../widgets/comments/comment_composer.dart';
import '../../theme/app_theme.dart';
import '../../services/ui_feedback.dart';
import '../../services/auth_repository.dart';
import '../../services/push_notification_service.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String sightingId;
  final String alertTitle;
  
  const CommentsScreen({
    super.key,
    required this.sightingId,
    required this.alertTitle,
  });
  
  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> with WidgetsBindingObserver {
  final CommentsService _commentsService = CommentsService();
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isFollowing = false; // TODO: Get actual follow status from API
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadComments();
    _autoFollowOnView(); // Auto-follow when viewing comments
    WidgetsBinding.instance.addObserver(this);
    // Listen for refresh notifications from push notifications
    CommentsRefreshNotifier.instance.addListener(widget.sightingId, _loadComments);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Remove refresh listener
    CommentsRefreshNotifier.instance.removeListener(widget.sightingId, _loadComments);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh comments when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _loadComments();
    }
  }
  
  Future<void> _loadComments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final comments = await _commentsService.getComments(widget.sightingId);
      
      // Auto-follow when viewing comments (so user gets notifications)
      bool followSuccess = false;
      try {
        await _commentsService.followSighting(widget.sightingId);
        followSuccess = true;
      } catch (e) {
        print('Auto-follow failed: $e');
      }
      
      setState(() {
        _comments = comments;
        _isLoading = false;
        _isFollowing = followSuccess;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _autoFollowOnView() async {
    try {
      // Check if user is authenticated first
      final authRepo = AuthRepository();
      final accessToken = await authRepo.getAccessToken();
      
      if (accessToken != null) {
        // Auto-follow when viewing comments (silent)
        await _commentsService.followSighting(widget.sightingId);
        setState(() {
          _isFollowing = true;
        });
        print('Auto-followed alert ${widget.sightingId} when viewing comments');
      }
    } catch (e) {
      // Fail silently - don't show error for auto-follow
      print('Auto-follow failed: $e');
    }
  }
  
  Future<void> _sendComment(String body) async {
    try {
      // Check if user is authenticated first
      final authRepo = AuthRepository();
      final accessToken = await authRepo.getAccessToken();
      
      if (accessToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please log in to post comments'),
              backgroundColor: AppColors.semanticWarning,
              action: SnackBarAction(
                label: 'Log In',
                textColor: Colors.white,
                onPressed: () {
                  context.go('/sign-in');
                },
              ),
            ),
          );
        }
        return;
      }
      
      final newComment = await _commentsService.postComment(widget.sightingId, body);
      
      setState(() {
        _comments.insert(0, newComment); // Add to top since API returns newest first
        _isFollowing = true; // Auto-follow when commenting
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post comment: ${e.toString()}'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    }
  }
  
  Future<void> _toggleFollow() async {
    await UiFeedback.click();
    
    try {
      // Check if user is authenticated first
      final authRepo = AuthRepository();
      final accessToken = await authRepo.getAccessToken();
      
      if (accessToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please log in to follow alerts'),
              backgroundColor: AppColors.semanticWarning,
              action: SnackBarAction(
                label: 'Log In',
                textColor: Colors.white,
                onPressed: () {
                  context.go('/sign-in');
                },
              ),
            ),
          );
        }
        return;
      }
      
      if (!_isFollowing) {
        await _commentsService.followSighting(widget.sightingId);
        setState(() {
          _isFollowing = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Following alert for notifications'),
              backgroundColor: AppColors.brandPrimary,
            ),
          );
        }
      } else {
        // TODO: Implement unfollow when API supports it
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unfollow not yet supported'),
            backgroundColor: AppColors.semanticWarning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle follow: ${e.toString()}'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Comments', style: TextStyle(fontSize: 16)),
            Text(
              widget.alertTitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          // Bell to mute/follow notifications
          IconButton(
            onPressed: _toggleFollow,
            icon: Icon(
              _isFollowing ? Icons.notifications_active : Icons.notifications_off,
              color: _isFollowing ? AppColors.brandPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Comments list
          Expanded(
            child: _buildCommentsBody(),
          ),
          
          // Comment composer
          CommentComposer(
            onSendComment: _sendComment,
            placeholder: 'Add a comment...',
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommentsBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandPrimary),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.semanticError,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load comments',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadComments,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_comments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No comments yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to comment on this sighting',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadComments,
      color: AppColors.brandPrimary,
      backgroundColor: AppColors.darkSurface,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _comments.length,
        separatorBuilder: (context, index) => const Divider(
          color: AppColors.darkBorder,
          height: 1,
          indent: 60,
        ),
        itemBuilder: (context, index) {
          return CommentItem(comment: _comments[index]);
        },
      ),
    );
  }
}