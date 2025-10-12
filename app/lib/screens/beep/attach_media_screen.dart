import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/alerts_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_client.dart';
import '../../services/comments_service.dart';
import '../../services/permission_service.dart';
import '../../services/ui_feedback.dart';
import '../../services/sound_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/dev_menu_button.dart';

class AttachMediaScreen extends ConsumerStatefulWidget {
  final String sightingId;
  final List<File>? initialMediaFiles;

  const AttachMediaScreen({
    super.key,
    required this.sightingId,
    this.initialMediaFiles,
  });

  @override
  ConsumerState<AttachMediaScreen> createState() => _AttachMediaScreenState();
}

class _AttachMediaScreenState extends ConsumerState<AttachMediaScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  List<File> _selectedMedia = [];
  bool _isAttaching = false;
  bool _isCapturing = false;
  String? _errorMessage;
  int _currentUploadIndex = -1;
  Set<int> _completedUploads = {};

  @override
  void initState() {
    super.initState();
    debugPrint('📎 ATTACH: Screen created for sighting ${widget.sightingId}');

    // Load initial media if provided
    if (widget.initialMediaFiles != null) {
      _selectedMedia = List.from(widget.initialMediaFiles!);
      debugPrint('📎 ATTACH: Loaded ${_selectedMedia.length} initial media files');
    }

    UiFeedback.init();
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;

    // Show camera mode popup instead of navigation
    _showCameraModePopup();
  }

  void _showCameraModePopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 100, // Move up to avoid nav bar
        ),
        child: Container(
        decoration: BoxDecoration(
          color: AppColors.nightSkyBottom,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Photo option
            GlassCard(
              onTap: () async {
                Navigator.pop(context);
                await _launchNativeCamera(isVideo: false);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white, size: 24),
                    const SizedBox(width: 16),
                    Text(
                      'Photo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Video option
            GlassCard(
              onTap: () async {
                Navigator.pop(context);
                await _launchNativeCamera(isVideo: true);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.videocam, color: Colors.white, size: 24),
                    const SizedBox(width: 16),
                    Text(
                      'Video',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _launchNativeCamera({required bool isVideo}) async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? capturedFile;

      if (isVideo) {
        capturedFile = await picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(seconds: 30),
        );
      } else {
        capturedFile = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 90,
        );
      }

      if (capturedFile != null) {
        final mediaFile = File(capturedFile.path);
        setState(() {
          _selectedMedia.add(mediaFile);
          _errorMessage = null;
        });
        debugPrint('📎 ATTACH: Added ${isVideo ? 'video' : 'photo'} - ${mediaFile.path}');
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      String friendlyMessage;

      // Parse error and provide user-friendly message
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('camera_access_denied') || errorStr.contains('permission')) {
        friendlyMessage = l10n.cameraPermissionDenied;
      } else if (errorStr.contains('camera not available') || errorStr.contains('no camera')) {
        friendlyMessage = l10n.cameraNotAvailable;
      } else {
        friendlyMessage = '${l10n.cameraError}: ${l10n.pleaseTryAgain}';
      }

      setState(() {
        _errorMessage = friendlyMessage;
      });

      debugPrint('📎 ATTACH: Camera error - $e');
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isCapturing) return;

    final hasPermission = await permissionService.requestPhotosForGallery();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo library permission is required to select media'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final newFiles = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();

        setState(() {
          _selectedMedia.addAll(newFiles);
        });

        debugPrint('📎 ATTACH: Added ${newFiles.length} files from gallery');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to access gallery: $e';
      });
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _attachMedia() async {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedMedia.isEmpty) {
      setState(() {
        _errorMessage = l10n.selectMediaToAttach;
      });
      return;
    }

    setState(() {
      _isAttaching = true;
      _errorMessage = null;
      _currentUploadIndex = 0;
      _completedUploads.clear();
    });

    await SoundService.I.play(AlertSound.tap, haptic: true);

    try {
      debugPrint('📎 ATTACH: Starting upload of ${_selectedMedia.length} files to sighting ${widget.sightingId}');

      int uploadedCount = 0;

      // Upload all files sequentially
      for (int i = 0; i < _selectedMedia.length; i++) {
        final mediaFile = _selectedMedia[i];

        if (mounted) {
          setState(() {
            _currentUploadIndex = i;
          });
        }

        try {
          await ApiClient.instance.uploadMediaToSighting(
            widget.sightingId,
            mediaFile,
          );

          uploadedCount++;

          if (mounted) {
            setState(() {
              _completedUploads.add(i);
            });
          }

          debugPrint('📎 ATTACH: Uploaded file ${i + 1}/${_selectedMedia.length}');
        } catch (e) {
          debugPrint('📎 ATTACH: Failed to upload file ${mediaFile.path}: $e');
        }
      }

      if (uploadedCount == 0) {
        throw Exception('No files could be uploaded');
      }

      // Add comment to notify followers
      final description = _descriptionController.text.trim();
      final commentText = description.isNotEmpty
          ? description
          : uploadedCount == 1
              ? '📸 ${l10n.newMediaUploaded}'
              : '📸 $uploadedCount ${l10n.mediaFilesUploaded}';

      try {
        await CommentsService().postComment(
          widget.sightingId,
          commentText,
        );
        debugPrint('📎 ATTACH: Comment posted to notify followers');
      } catch (e) {
        debugPrint('📎 ATTACH: Failed to post comment: $e');
        // Continue anyway - media upload succeeded
      }

      // Success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $uploadedCount ${l10n.filesAttachedSuccessfully}'),
            backgroundColor: AppColors.semanticSuccess,
          ),
        );

        // Invalidate the specific alert cache so it shows new media
        ref.invalidate(alertByIdProvider(widget.sightingId));

        // Return to alert detail screen
        context.pop();
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to attach media: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAttaching = false;
          _currentUploadIndex = -1;
          _completedUploads.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NightSkyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.attachMedia,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: const [DevMenuButton()],
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Description input
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.addCommentOptional,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.describeNewMedia,
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.brandPrimary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Media thumbnails
                if (_selectedMedia.isNotEmpty) ...[
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedMedia.length} ${l10n.filesSelected}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedMedia.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(right: 8),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Stack(
                                    children: [
                                      _isAttaching
                                          ? Container(
                                              color: _completedUploads.contains(index)
                                                  ? Colors.green.withOpacity(0.3)
                                                  : (index == _currentUploadIndex
                                                      ? Colors.blue.withOpacity(0.3)
                                                      : Colors.black.withOpacity(0.8)),
                                              child: index == _currentUploadIndex
                                                  ? Icon(Icons.upload, color: Colors.white70, size: 20)
                                                  : (_completedUploads.contains(index)
                                                      ? Icon(Icons.check, color: Colors.white70, size: 20)
                                                      : null),
                                            )
                                          : _buildMediaThumbnail(_selectedMedia[index]),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: _isAttaching ? null : () {
                                            setState(() {
                                              _selectedMedia.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Error message
                if (_errorMessage != null) ...[
                  GlassCard(
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: AppColors.error, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Camera and Gallery buttons
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        onTap: _isCapturing || _isAttaching ? null : () async {
                          await UiFeedback.click();
                          _capturePhoto();
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
                              l10n.camera,
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
                        onTap: _isCapturing || _isAttaching ? null : () async {
                          await UiFeedback.click();
                          _pickFromGallery();
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
                              l10n.gallery,
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

                const SizedBox(height: 24),

                // Attach Media button
                GestureDetector(
                  onTap: _isAttaching || _selectedMedia.isEmpty ? null : () async {
                    await UiFeedback.click();
                    _attachMedia();
                  },
                  child: GlassCard(
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _selectedMedia.isEmpty
                              ? AppColors.textTertiary
                              : AppColors.brandPrimary,
                          width: 2,
                        ),
                      ),
                      child: _isAttaching
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.brandPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              l10n.attachMedia,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _selectedMedia.isEmpty
                                    ? AppColors.textTertiary
                                    : AppColors.brandPrimary,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaThumbnail(File mediaFile) {
    final String fileName = mediaFile.path.toLowerCase();
    final bool isVideo = fileName.endsWith('.mp4') ||
                         fileName.endsWith('.mov') ||
                         fileName.endsWith('.avi') ||
                         fileName.endsWith('.webm') ||
                         fileName.endsWith('.3gp') ||
                         fileName.endsWith('.mkv');

    if (isVideo) {
      return Container(
        width: 80,
        height: 80,
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam,
                color: AppColors.brandPrimary,
                size: 24,
              ),
              SizedBox(height: 4),
              Icon(
                Icons.play_circle_filled,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
            ],
          ),
        ),
      );
    } else {
      return Image.file(
        mediaFile,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.white.withOpacity(0.1),
            child: Icon(
              Icons.broken_image,
              color: Colors.white.withOpacity(0.5),
              size: 20,
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}

class NightSkyBackground extends StatelessWidget {
  final Widget child;

  const NightSkyBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.nightSkyTop,
            AppColors.nightSkyMiddle,
            AppColors.nightSkyBottom,
          ],
        ),
      ),
      child: child,
    );
  }
}