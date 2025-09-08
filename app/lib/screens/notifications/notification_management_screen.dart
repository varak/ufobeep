import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/user_preferences.dart';
import '../../providers/user_preferences_provider.dart';
import '../../services/api_client.dart';
import '../../services/user_service.dart';
import '../../services/beep_service.dart';
import '../../services/auth_repository.dart';
import '../../widgets/glass_card.dart';

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
      print('🔄 Loading user subscriptions...');
      
      // Get user's followed alerts
      final userId = await userService.getCurrentUserId();
      print('📱 User ID: $userId');
      
      if (userId == null) {
        print('❌ No user ID found - user not authenticated');
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
        print('🔑 Bearer token set for subscriptions request');
      } else {
        print('❌ No access token found - authentication required');
        if (mounted) {
          setState(() {
            _loadingSubscriptions = false;
          });
        }
        return;
      }
      
      print('📡 Calling /users/$userId/subscriptions...');
      final response = await ApiClient.dio.get('/users/$userId/subscriptions');
      print('✅ Subscriptions response: ${response.data}');
      
      if (mounted) {
        setState(() {
          _subscriptions = List<Map<String, dynamic>>.from(response.data['subscriptions'] ?? []);
          _loadingSubscriptions = false;
        });
      }
      
      print('🎯 Loaded ${_subscriptions.length} subscriptions');
      
      // Fallback: if empty, also check device-based subscriptions for non-auth flows
      if ((_subscriptions.isEmpty) && mounted) {
        print('📱 No user subscriptions found, trying device-based fallback...');
        try {
          final deviceId = await BeepService().getOrCreateDeviceId();
          print('📱 Device ID: $deviceId');
          final resp2 = await ApiClient.dio.get('/alerts/following', queryParameters: {
            'device_id': deviceId,
          });
          print('📡 Device fallback response: ${resp2.data}');
          if (resp2.data is Map && resp2.data['subscriptions'] is List) {
            setState(() {
              _subscriptions = List<Map<String, dynamic>>.from(resp2.data['subscriptions']);
            });
            print('🎯 Loaded ${_subscriptions.length} subscriptions from device fallback');
          }
        } catch (fallbackError) {
          print('⚠️ Device fallback failed: $fallbackError');
        }
      }
    } catch (e) {
      print('❌ Error loading subscriptions: $e');
      if (e.toString().contains('401')) {
        print('🔐 Authentication error - user needs to log in again');
      } else if (e.toString().contains('403')) {
        print('🚫 Permission denied - user cannot access their own subscriptions');
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
      await ApiClient.dio.delete('/alerts/$sightingId/follow');
      
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
      if (!mounted) return;
      // Force UI refresh by triggering setState
      setState(() {});
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
          title: const Text(
            'Notification Settings',
            style: TextStyle(
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
          const SizedBox(height: 24),
          _buildNotificationTypesSection(preferences),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(UserPreferences preferences) {
    final dndActive = preferences.dndUntil?.isAfter(DateTime.now()) ?? false;
    final dndText = dndActive 
        ? 'Until ${_formatTime(preferences.dndUntil!)}'
        : 'Temporarily silence all notifications';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
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
                secondary: Icon(
                  dndActive ? Icons.do_not_disturb_on : Icons.do_not_disturb,
                  color: dndActive ? AppColors.warning : AppColors.brandPrimary,
                ),
                title: const Text(
                  'Do Not Disturb',
                  style: TextStyle(color: Colors.white),
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
                    _DndChip(label: '1h', selected: false, onTap: () => _setDndDuration(const Duration(hours: 1))),
                    const SizedBox(width: 8),
                    _DndChip(label: '8h', selected: false, onTap: () => _setDndDuration(const Duration(hours: 8))),
                    const SizedBox(width: 8),
                    _DndChip(label: '1 day', selected: false, onTap: () => _setDndDuration(const Duration(days: 1))),
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
                  title: const Text(
                    'Start Time',
                    style: TextStyle(color: Colors.white),
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
                  title: const Text(
                    'End Time',
                    style: TextStyle(color: Colors.white),
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
                  title: const Text(
                    'Emergency Override',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Allow critical alerts during quiet hours',
                    style: TextStyle(color: Colors.white70),
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
            const Text(
              'Following Alerts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_subscriptions.isNotEmpty)
              Text(
                '${_subscriptions.length} active',
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
    final title = subscription['title'] ?? 'UFO Sighting';
    final location = subscription['location_name'] ?? 'Unknown Location';
    final sightingId = subscription['sighting_id'];
    final commentCount = subscription['comment_count'] ?? 0;
    final isLast = _subscriptions.indexOf(subscription) == _subscriptions.length - 1;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.notifications_active, color: AppColors.brandPrimary),
          title: Text(
            title.length > 50 ? '${title.substring(0, 50)}...' : title,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: const TextStyle(color: Colors.white70),
              ),
              if (commentCount > 0)
                Text(
                  '$commentCount comments',
                  style: const TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          trailing: TextButton(
            onPressed: () => _showUnfollowDialog(sightingId, title),
            child: const Text(
              'Unfollow',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
          onTap: () => Navigator.of(context).pushNamed('/alert/$sightingId'),
        ),
        if (!isLast) const Divider(color: Colors.white30),
      ],
    );
  }

  Widget _buildNotificationTypesSection(UserPreferences preferences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification Types',
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
                secondary: const Icon(Icons.location_on, color: AppColors.brandPrimary),
                title: const Text(
                  'Location Alerts',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'New sightings in your area',
                  style: TextStyle(color: Colors.white70),
                ),
                value: preferences.enableLocationAlerts,
                onChanged: (value) => _updatePreference(
                  preferences.copyWith(enableLocationAlerts: value),
                ),
                activeColor: AppColors.brandPrimary,
              ),
              const Divider(color: Colors.white30),
              SwitchListTile(
                secondary: const Icon(Icons.push_pin, color: AppColors.brandPrimary),
                title: const Text(
                  'Push Notifications',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'All notification types',
                  style: TextStyle(color: Colors.white70),
                ),
                value: preferences.enablePushNotifications,
                onChanged: (value) => _updatePreference(
                  preferences.copyWith(enablePushNotifications: value),
                ),
                activeColor: AppColors.brandPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showUnfollowDialog(String sightingId, String title) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          title: const Text(
            'Unfollow Alert',
            style: TextStyle(color: Colors.white),
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
