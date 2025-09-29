import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/user_preferences.dart';
import '../../providers/user_preferences_provider.dart';
import '../../services/api_client.dart';
import '../../services/user_service.dart';
import '../../services/beep_service.dart';
import '../../services/auth_repository.dart';
import '../../widgets/glass_card.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/alert_title_utils.dart';
import '../../providers/alerts_provider.dart';

class NotificationManagementScreen extends ConsumerStatefulWidget {
  const NotificationManagementScreen({super.key});

  @override
  ConsumerState<NotificationManagementScreen> createState() =>
      _NotificationManagementScreenState();
}

class _NotificationManagementScreenState
    extends ConsumerState<NotificationManagementScreen> {
  List<Map<String, dynamic>> _subscriptions = [];
  bool _loadingSubscriptions = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    try {
      debugPrint('🔄 Loading user subscriptions...');
      
      // Get user's followed alerts
      final userId = await userService.getCurrentUserId();
      debugPrint('📱 User ID: $userId');
      
      if (userId == null) {
        debugPrint('❌ No user ID found - user not authenticated');
        if (mounted) {
          setState(() {
            _loadingSubscriptions = false;
          });
        }
        return;
      }
      
      // Ensure authentication token is set
      final authRepo = AuthRepository();
      final accessToken = await authRepo.getAccessToken();
      if (accessToken != null) {
        ApiClient.setBearer(accessToken);
        debugPrint('🔑 Bearer token set for subscriptions request');
      } else {
        debugPrint('❌ No access token found - authentication required');
        if (mounted) {
          setState(() {
            _loadingSubscriptions = false;
          });
        }
        return;
      }
      
      debugPrint('📡 Calling /users/$userId/subscriptions...');
      final response = await ApiClient.dio.get('/users/$userId/subscriptions');
      debugPrint('✅ Subscriptions response: ${response.data}');

      if (mounted) {
        final rawSubscriptions = List<Map<String, dynamic>>.from(response.data['subscriptions'] ?? []);

        // Enhance subscription data with full alert details
        final enhancedSubscriptions = <Map<String, dynamic>>[];

        for (final sub in rawSubscriptions) {
          try {
            final sightingId = sub['sighting_id'];
            if (sightingId != null) {
              // Load full alert data for this subscription
              final alertResponse = await ApiClient.dio.get('/beep/$sightingId');
              final alertData = alertResponse.data['data'];

              // Combine subscription metadata with full alert data
              enhancedSubscriptions.add({
                ...sub, // Original subscription data (followed_at, etc.)
                'alert_title': alertData['title'] ?? 'UFO Sighting',
                'alert_description': alertData['description'],
                'alert_location': alertData['location']?['name'] ?? 'Unknown Location',
                'alert_created_at': alertData['created_at'],
                'alert_source': alertData['source'],
                'alert_username': alertData['reporter_username'],
              });
            }
          } catch (e) {
            // If alert loading fails, keep basic subscription data
            debugPrint('❌ Failed to load alert details for ${sub['sighting_id']}: $e');
            enhancedSubscriptions.add(sub);
          }
        }

        setState(() {
          _subscriptions = enhancedSubscriptions;
          _loadingSubscriptions = false;
        });
      }
      
      debugPrint('🎯 Loaded ${_subscriptions.length} subscriptions');
      
      // Fallback: if empty, also check device-based subscriptions for non-auth flows
      if ((_subscriptions.isEmpty) && mounted) {
        debugPrint('📱 No user subscriptions found, trying device-based fallback...');
        try {
          final deviceId = await BeepService().getOrCreateDeviceId();
          debugPrint('📱 Device ID: $deviceId');
          final resp2 = await ApiClient.dio.get('/beep/following', queryParameters: {
            'device_id': deviceId,
          });
          debugPrint('📡 Device fallback response: ${resp2.data}');
          if (resp2.data is Map && resp2.data['subscriptions'] is List) {
            setState(() {
              _subscriptions = List<Map<String, dynamic>>.from(resp2.data['subscriptions']);
            });
            debugPrint('🎯 Loaded ${_subscriptions.length} subscriptions from device fallback');
          }
        } catch (fallbackError) {
          debugPrint('⚠️ Device fallback failed: $fallbackError');
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading subscriptions: $e');
      if (e.toString().contains('401')) {
        debugPrint('🔐 Authentication error - user needs to log in again');
      } else if (e.toString().contains('403')) {
        debugPrint('🚫 Permission denied - user cannot access their own subscriptions');
      }
      
      if (mounted) {
        setState(() {
          _loadingSubscriptions = false;
        });
      }
    }
  }

  Future<void> _unfollow(String sightingId, String title) async {
    try {
      await ApiClient.dio.delete('/beep/$sightingId/follow');
      
      // Remove from local list
      setState(() {
        _subscriptions.removeWhere((sub) => sub['sighting_id'] == sightingId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unfollowed "$title"'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unfollow: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _toggleDndFor1Hour() async {
    final prefsProvider = ref.read(userPreferencesProvider.notifier);

    final currentPrefs = ref.read(userPreferencesProvider);
    if (currentPrefs == null) return;

    final dndUntil = DateTime.now().add(const Duration(hours: 1));
    final updatedPrefs = currentPrefs.copyWith(dndUntil: dndUntil);

    // Update provider and save to storage
    await prefsProvider.updatePreferences(updatedPrefs);

    // Sync DND to backend database
    await _syncDndToBackend(1); // 1 hour

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('DND enabled for 1 hour'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _setDndEnabled(bool enabled) async {
    final prefsProvider = ref.read(userPreferencesProvider.notifier);
    final currentPrefs = ref.read(userPreferencesProvider);
    if (currentPrefs == null) return;

    if (enabled) {
      final dndUntil = DateTime.now().add(const Duration(hours: 1));
      final updated = currentPrefs.copyWith(dndUntil: dndUntil);
      await prefsProvider.updatePreferences(updated);

      // Sync DND to backend database
      await _syncDndToBackend(1); // 1 hour

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('DND on until ${_formatTime(dndUntil)}'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      // Clear DND by setting dndUntil to null
      final updated = currentPrefs.copyWith(dndUntil: null);
      await prefsProvider.updatePreferences(updated);

      // Sync DND off to backend database
      await _syncDndToBackend(0); // 0 hours = disable DND

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('DND disabled - notifications restored'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _setDndDuration(Duration duration) async {
    final prefsProvider = ref.read(userPreferencesProvider.notifier);
    final currentPrefs = ref.read(userPreferencesProvider);
    if (currentPrefs == null) return;
    final until = DateTime.now().add(duration);
    await prefsProvider.updatePreferences(currentPrefs.copyWith(dndUntil: until));

    // Sync DND duration to backend database
    await _syncDndToBackend(duration.inHours);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('DND on until ${_formatTime(until)}'),
        backgroundColor: AppColors.success,
      ),
    );
    setState(() {});
  }

  Future<void> _toggleQuietHours(bool enabled) async {
    final prefsProvider = ref.read(userPreferencesProvider.notifier);
    final currentPrefs = ref.read(userPreferencesProvider);
    if (currentPrefs == null) return;
    
    final updatedPrefs = currentPrefs.copyWith(quietHoursEnabled: enabled);
    await prefsProvider.updatePreferences(updatedPrefs);
  }

  Future<void> _setQuietHoursTime(bool isStartTime, int hour) async {
    final prefsProvider = ref.read(userPreferencesProvider.notifier);
    final currentPrefs = ref.read(userPreferencesProvider);
    if (currentPrefs == null) return;
    
    final updatedPrefs = isStartTime
        ? currentPrefs.copyWith(quietHoursStart: hour)
        : currentPrefs.copyWith(quietHoursEnd: hour);
    
    await prefsProvider.updatePreferences(updatedPrefs);
  }

  Future<void> _showQuietHoursTimePicker(bool isStartTime) async {
    final currentPrefs = ref.read(userPreferencesProvider);
    if (currentPrefs == null) return;
    
    final currentHour = isStartTime ? currentPrefs.quietHoursStart : currentPrefs.quietHoursEnd;
    
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.brandPrimary,
              surface: Colors.transparent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      await _setQuietHoursTime(isStartTime, time.hour);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(userPreferencesProvider);
    
    return NightSkyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            AppLocalizations.of(context)!.notificationSettings,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: _buildBody(preferences),
      ),
    );
  }

  Widget _buildBody(UserPreferences? preferences) {
    if (preferences == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandPrimary),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickActionsSection(preferences),
          const SizedBox(height: 24),
          _buildQuietHoursSection(preferences),
          const SizedBox(height: 24),
          _buildSubscriptionsSection(),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(UserPreferences preferences) {
    final dndActive = preferences.dndUntil?.isAfter(DateTime.now()) ?? false;
    final dndText = dndActive 
        ? 'Until ${_formatTime(preferences.dndUntil!)}'
        : AppLocalizations.of(context)!.temporarilySilenceNotifications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.quickActions,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: [
              SwitchListTile(
                secondary: Icon(
                  dndActive ? Icons.do_not_disturb_on : Icons.do_not_disturb,
                  color: dndActive ? AppColors.warning : AppColors.brandPrimary,
                ),
                title: Text(
                  AppLocalizations.of(context)!.doNotDisturb,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  dndText,
                  style: const TextStyle(color: Colors.white70),
                ),
                value: dndActive,
                onChanged: (val) => _setDndEnabled(val),
                activeColor: AppColors.brandPrimary,
              ),
              const Divider(color: Colors.white24, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _DndChip(label: AppLocalizations.of(context)!.oneHour, selected: false, onTap: () => _setDndDuration(const Duration(hours: 1))),
                    const SizedBox(width: 8),
                    _DndChip(label: AppLocalizations.of(context)!.eightHours, selected: false, onTap: () => _setDndDuration(const Duration(hours: 8))),
                    const SizedBox(width: 8),
                    _DndChip(label: AppLocalizations.of(context)!.oneDay, selected: false, onTap: () => _setDndDuration(const Duration(days: 1))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuietHoursSection(UserPreferences preferences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quiet Hours',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.bedtime, color: AppColors.brandPrimary),
                title: const Text(
                  'Quiet Hours',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  preferences.quietHoursEnabled
                      ? 'Active ${_formatHour(preferences.quietHoursStart)} - ${_formatHour(preferences.quietHoursEnd)}'
                      : 'Silence notifications during sleep hours',
                  style: const TextStyle(color: Colors.white70),
                ),
                value: preferences.quietHoursEnabled,
                onChanged: _toggleQuietHours,
                activeColor: AppColors.brandPrimary,
              ),
              if (preferences.quietHoursEnabled) ...[
                const Divider(color: Colors.white30),
                ListTile(
                  leading: const Icon(Icons.nights_stay, color: Colors.white70),
                  title: Text(
                    AppLocalizations.of(context)!.startTime,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    _formatHour(preferences.quietHoursStart),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () => _showQuietHoursTimePicker(true),
                ),
                const Divider(color: Colors.white30),
                ListTile(
                  leading: const Icon(Icons.wb_sunny, color: Colors.white70),
                  title: Text(
                    AppLocalizations.of(context)!.endTime,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    _formatHour(preferences.quietHoursEnd),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () => _showQuietHoursTimePicker(false),
                ),
                const Divider(color: Colors.white30),
                SwitchListTile(
                  secondary: const Icon(Icons.warning, color: AppColors.warning),
                  title: Text(
                    AppLocalizations.of(context)!.emergencyOverride,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)!.allowCriticalAlertsDuringQuietHours,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  value: preferences.allowEmergencyOverride,
                  onChanged: (value) => _updatePreference(
                    preferences.copyWith(allowEmergencyOverride: value),
                  ),
                  activeColor: AppColors.brandPrimary,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.followingAlerts,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_subscriptions.isNotEmpty)
              Text(
                AppLocalizations.of(context)!.activeCount(_subscriptions.length),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: _loadingSubscriptions
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.brandPrimary),
                  ),
                )
              : _subscriptions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off,
                            color: Colors.white70,
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No Active Subscriptions',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Comment on alerts to follow them for notifications',
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: _subscriptions.map((sub) => _buildSubscriptionTile(sub)).toList(),
                    ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionTile(Map<String, dynamic> subscription) {
    // Create minimal Alert object for title translation (copying alert pattern)
    final sightingId = subscription['sighting_id'];
    final commentCount = subscription['comment_count'] ?? 0;
    final createdAt = subscription['alert_created_at'];
    final isLast = _subscriptions.indexOf(subscription) == _subscriptions.length - 1;

    // Create Alert object from subscription data to use AlertTitleUtils
    final alertForTitle = Alert(
      id: sightingId ?? '',
      title: subscription['alert_title'] ?? subscription['title'],
      description: subscription['alert_description'],
      latitude: 0.0, // Not needed for title
      longitude: 0.0, // Not needed for title
      createdAt: createdAt != null ? DateTime.parse(createdAt) : DateTime.now(),
      source: subscription['alert_source'],
      enrichment: null, // Would need full enrichment for MUFON cases
    );

    // Use same title logic as alerts tab
    final translatedTitle = AlertTitleUtils.getDynamicTitle(
      AppLocalizations.of(context)!,
      alertForTitle
    );

    final location = subscription['alert_location'] ?? subscription['location_name'] ?? 'Unknown Location';

    // Format date added to UFOBeep (copying alert date pattern)
    String dateAdded = '';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        final now = DateTime.now();
        final difference = now.difference(date);

        // Use T+ format like alerts tab (language-neutral)
        if (difference.inDays > 0) {
          final days = difference.inDays;
          final hours = difference.inHours.remainder(24);
          dateAdded = 'T+${days}d${hours}h';
        } else if (difference.inHours > 0) {
          final hours = difference.inHours;
          final minutes = difference.inMinutes.remainder(60);
          dateAdded = 'T+${hours}h${minutes}m';
        } else if (difference.inMinutes > 0) {
          final minutes = difference.inMinutes;
          dateAdded = 'T+${minutes}m';
        } else {
          dateAdded = 'T+0m';
        }
      } catch (e) {
        dateAdded = 'Added to UFOBeep';
      }
    }

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.notifications_active, color: AppColors.brandPrimary),
          title: Text(
            translatedTitle.length > 50 ? '${translatedTitle.substring(0, 50)}...' : translatedTitle,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: const TextStyle(color: Colors.white70),
              ),
              if (dateAdded.isNotEmpty)
                Text(
                  dateAdded,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              if (commentCount > 0)
                Text(
                  AppLocalizations.of(context)!.commentsCount(commentCount),
                  style: const TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          trailing: TextButton(
            onPressed: () => _showUnfollowDialog(sightingId, title),
            child: Text(
              AppLocalizations.of(context)!.unfollow,
              style: const TextStyle(color: AppColors.warning),
            ),
          ),
          onTap: () => context.go('/alert/$sightingId'),
        ),
        if (!isLast) const Divider(color: Colors.white30),
      ],
    );
  }


  Future<void> _showUnfollowDialog(String sightingId, String title) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          title: Text(
            AppLocalizations.of(context)!.unfollowAlert,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            'Stop receiving notifications for "$title"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _unfollow(sightingId, title);
              },
              child: const Text(
                'Unfollow',
                style: TextStyle(color: AppColors.warning),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearDnd() async {
    final prefsProvider = ref.read(userPreferencesProvider.notifier);
    final currentPrefs = ref.read(userPreferencesProvider);
    if (currentPrefs == null) return;

    final updatedPrefs = currentPrefs.copyWith(dndUntil: null);
    await prefsProvider.updatePreferences(updatedPrefs);

    // Sync DND off to backend database
    await _syncDndToBackend(0); // 0 hours = disable DND

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('DND disabled'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _updatePreference(UserPreferences updatedPrefs) async {
    final prefsProvider = ref.read(userPreferencesProvider.notifier);
    await prefsProvider.updatePreferences(updatedPrefs);
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }

  Future<void> _syncDndToBackend(int hours) async {
    try {
      // Get device ID for API call
      final deviceId = await beepService.getOrCreateDeviceId();

      // Call backend DND API to sync with database
      final response = await ApiClient.dio.post('/devices/$deviceId/dnd', data: {'hours': hours});

      if (response.data['success'] == true) {
        debugPrint('✅ DND synced to backend: ${hours}h');
      } else {
        debugPrint('❌ Backend DND sync failed: ${response.data}');
      }
    } catch (e) {
      debugPrint('❌ Failed to sync DND to backend: $e');
      // Don't fail the operation - local DND still works for app behavior
    }
  }
}

class _DndChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DndChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandPrimary : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.brandPrimary : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
