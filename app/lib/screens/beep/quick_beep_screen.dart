import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../theme/app_theme.dart';
import '../../services/anonymous_beep_service.dart';
import '../../services/alert_sound_service.dart';
import '../../providers/app_state.dart';
import '../../widgets/beep_button.dart';

class QuickBeepScreen extends ConsumerStatefulWidget {
  const QuickBeepScreen({super.key});

  @override
  ConsumerState<QuickBeepScreen> createState() => _QuickBeepScreenState();
}

class _QuickBeepScreenState extends ConsumerState<QuickBeepScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  
  bool _isBeeping = false;
  String? _lastBeepId;
  Position? _currentPosition;
  String _statusMessage = 'TAP TO BEEP';
  
  @override
  void initState() {
    super.initState();
    
    // Pulse animation for the button
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Ripple animation for after beep
    _rippleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
    
    // Try to get location immediately
    _attemptLocationFetch();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }
  
  Future<void> _attemptLocationFetch() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Don't block, just note it
        setState(() {
          _statusMessage = 'TAP TO BEEP\n(location will be requested)';
        });
      } else if (permission == LocationPermission.deniedForever) {
        setState(() {
          _statusMessage = 'TAP TO BEEP\n(manual location mode)';
        });
      } else {
        // Try to get location in background
        Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        ).then((position) {
          if (mounted) {
            setState(() {
              _currentPosition = position;
              _statusMessage = 'READY TO BEEP';
            });
          }
        }).catchError((e) {
          // Silent fail, we'll try again on beep
        });
      }
    } catch (e) {
      // Silent fail
    }
  }
  
  Future<void> _handleBeep() async {
    if (_isBeeping) return;
    
    setState(() {
      _isBeeping = true;
      _statusMessage = 'SENDING ALERT...';
    });
    
    // Start ripple animation
    _rippleController.forward();
    
    // Play immediate feedback sound
    await alertSoundService.playAlertSound(AlertLevel.normal);
    
    try {
      // Try to get location if we don't have it
      Position? position = _currentPosition;
      if (position == null) {
        try {
          // Request permission if needed
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          
          if (permission != LocationPermission.deniedForever) {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium,
              timeLimit: const Duration(seconds: 3),
            );
          }
        } catch (e) {
          // Location failed, but don't block the beep
          debugPrint('Location failed: $e');
        }
      }
      
      // Send anonymous beep (with or without location)
      final beepResult = await anonymousBeepService.sendBeep(
        latitude: position?.latitude,
        longitude: position?.longitude,
        heading: position?.heading,
        description: 'Quick beep - something in the sky!',
      );
      
      setState(() {
        _lastBeepId = beepResult['sighting_id'];
        _statusMessage = 'ALERT SENT!';
      });
      
      // Set the device ID as current user so navigation button is hidden
      final deviceId = await anonymousBeepService.getOrCreateDeviceId();
      ref.read(appStateProvider.notifier).setCurrentUser(deviceId);
      
      // Wait a moment then show options
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        _showPostBeepOptions();
      }
      
    } catch (e) {
      setState(() {
        _statusMessage = 'FAILED - TAP TO RETRY';
      });
      debugPrint('Beep failed: $e');
    } finally {
      setState(() {
        _isBeeping = false;
      });
      
      // Reset after delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _statusMessage = 'TAP TO BEEP AGAIN';
          });
          _rippleController.reset();
        }
      });
    }
  }
  
  void _showPostBeepOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🛸 Alert Sent Successfully!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Add more details button
            _OptionButton(
              icon: Icons.add_a_photo,
              label: 'Add Photos/Videos',
              onTap: () {
                Navigator.pop(context);
                context.go('/beep/compose', extra: {
                  'beepId': _lastBeepId,
                  'isUpdate': true,
                });
              },
            ),
            
            // Share button
            _OptionButton(
              icon: Icons.share,
              label: 'Share This Sighting',
              onTap: () {
                Navigator.pop(context);
                _shareBeep();
              },
            ),
            
            // View alert button
            _OptionButton(
              icon: Icons.visibility,
              label: 'View Alert Details',
              onTap: () {
                Navigator.pop(context);
                if (_lastBeepId != null) {
                  context.go('/alert/$_lastBeepId');
                }
              },
            ),
            
            // Sign up button
            _OptionButton(
              icon: Icons.person_add,
              label: 'Create Account (Claim This Beep)',
              onTap: () {
                Navigator.pop(context);
                context.go('/profile/register', extra: {
                  'claimBeepId': _lastBeepId,
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Close button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Done',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _shareBeep() {
    // TODO: Implement share functionality
    final shareUrl = 'https://ufobeep.com/s/$_lastBeepId';
    final shareText = '🛸 UFO sighting reported! Look up NOW!\n\n'
        'Multiple witnesses needed to confirm.\n\n'
        'Download UFOBeep to see location: $shareUrl';
    
    // This would use share_plus package
    debugPrint('Share: $shareText');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  AppColors.brandPrimary.withOpacity(0.1),
                  AppColors.darkBackground,
                ],
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Minimal header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'UFOBeep',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up, color: AppColors.textSecondary),
                            onPressed: () async {
                              // Test sound
                              await alertSoundService.playAlertSound(AlertLevel.normal);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.history, color: AppColors.textSecondary),
                            onPressed: () => context.go('/'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Spacer
                const Expanded(child: SizedBox()),
                
                // Big beep button
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ripple effect
                      AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 300 + (200 * _rippleAnimation.value),
                            height: 300 + (200 * _rippleAnimation.value),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.brandPrimary.withOpacity(
                                  1.0 - _rippleAnimation.value,
                                ),
                                width: 3,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Pulse animation
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: child,
                          );
                        },
                        child: GestureDetector(
                          onTap: _handleBeep,
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _isBeeping 
                                      ? AppColors.semanticSuccess 
                                      : AppColors.brandPrimary,
                                  _isBeeping 
                                      ? AppColors.semanticSuccess.withOpacity(0.6)
                                      : AppColors.brandPrimary.withOpacity(0.3),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brandPrimary.withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isBeeping ? Icons.satellite_alt : Icons.touch_app,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'BEEP',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status message
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: _isBeeping 
                          ? AppColors.brandPrimary 
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Spacer
                const Expanded(child: SizedBox()),
                
                // Bottom info
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No account needed • 100% Anonymous',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.darkBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.brandPrimary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}