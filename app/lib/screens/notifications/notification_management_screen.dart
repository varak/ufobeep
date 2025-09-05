import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../theme/app_theme.dart';
import '../../models/user_preferences.dart';
import '../../providers/user_preferences_provider.dart';
import '../../services/api_client.dart';
import '../../services/user_service.dart';
import '../../services/ui_feedback.dart';
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
  bool _loadingPreferences = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    try {
      // Get user's followed alerts
      final userId = await userService.getCurrentUserId();
      final response = await ApiClient.dio.get('/users/$userId/subscriptions');
      
      if (mounted) {
        setState(() {
          _subscriptions = List<Map<String, dynamic>>.from(response.data['subscriptions'] ?? []);
          _loadingSubscriptions = false;
        });
      }
    } catch (e) {
      print('Error loading subscriptions: $e');
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
      
      UIFeedback.success('Unfollowed "$title"');
    } catch (e) {
      UIFeedback.error('Failed to unfollow: $e');
    }
  }

  Future<void> _toggleDndFor1Hour() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsProvider = ref.read(userPreferencesProvider.notifier);
    
    final currentPrefs = ref.read(userPreferencesProvider);
    if (currentPrefs == null) return;
    
    final dndUntil = DateTime.now().add(const Duration(hours: 1));
    final updatedPrefs = currentPrefs.copyWith(dndUntil: dndUntil);
    
    // Update provider and save to storage
    await prefsProvider.updatePreferences(updatedPrefs);
    
    UIFeedback.success('DND enabled for 1 hour');
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
              surface: AppColors.darkSurface,
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
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(preferences),
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
        ? 'DND until ${_formatTime(preferences.dndUntil!)}'
        : 'Enable DND for 1 hour';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  dndActive ? Icons.do_not_disturb_on : Icons.do_not_disturb,
                  color: dndActive ? AppColors.warningColor : AppColors.brandPrimary,
                ),
                title: Text(
                  dndText,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                subtitle: dndActive 
                    ? const Text(
                        'All notifications silenced',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    : const Text(
                        'Temporarily silence all notifications',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                trailing: dndActive
                    ? TextButton(
                        onPressed: () => _clearDnd(),
                        child: const Text('Clear', style: TextStyle(color: AppColors.brandPrimary)),
                      )
                    : null,
                onTap: dndActive ? null : _toggleDndFor1Hour,
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
            color: AppColors.textPrimary,
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
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                subtitle: Text(
                  preferences.quietHoursEnabled
                      ? 'Active ${_formatHour(preferences.quietHoursStart)} - ${_formatHour(preferences.quietHoursEnd)}'
                      : 'Silence notifications during sleep hours',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                value: preferences.quietHoursEnabled,
                onChanged: _toggleQuietHours,
                activeColor: AppColors.brandPrimary,
              ),
              if (preferences.quietHoursEnabled) ...[
                const Divider(color: AppColors.darkBorder),
                ListTile(
                  leading: const Icon(Icons.nights_stay, color: AppColors.textSecondary),
                  title: const Text(
                    'Start Time',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    _formatHour(preferences.quietHoursStart),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  onTap: () => _showQuietHoursTimePicker(true),
                ),
                const Divider(color: AppColors.darkBorder),
                ListTile(
                  leading: const Icon(Icons.wb_sunny, color: AppColors.textSecondary),
                  title: const Text(
                    'End Time',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    _formatHour(preferences.quietHoursEnd),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  onTap: () => _showQuietHoursTimePicker(false),
                ),
                const Divider(color: AppColors.darkBorder),
                SwitchListTile(
                  secondary: const Icon(Icons.warning, color: AppColors.warningColor),
                  title: const Text(
                    'Emergency Override',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: const Text(
                    'Allow critical alerts during quiet hours',
                    style: TextStyle(color: AppColors.textSecondary),
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
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_subscriptions.isNotEmpty)
              Text(
                '${_subscriptions.length} active',
                style: const TextStyle(
                  color: AppColors.textSecondary,
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
                            color: AppColors.textSecondary,
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No Active Subscriptions',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Comment on alerts to follow them for notifications',
                            style: TextStyle(color: AppColors.textSecondary),
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
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: const TextStyle(color: AppColors.textSecondary),
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
              style: TextStyle(color: AppColors.warningColor),
            ),
          ),
          onTap: () => Navigator.of(context).pushNamed('/alert/$sightingId'),
        ),
        if (!isLast) const Divider(color: AppColors.darkBorder),
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
            color: AppColors.textPrimary,
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
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  'New sightings in your area',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                value: preferences.enableLocationAlerts,
                onChanged: (value) => _updatePreference(
                  preferences.copyWith(enableLocationAlerts: value),
                ),
                activeColor: AppColors.brandPrimary,
              ),
              const Divider(color: AppColors.darkBorder),
              SwitchListTile(
                secondary: const Icon(Icons.push_pin, color: AppColors.brandPrimary),
                title: const Text(
                  'Push Notifications',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  'All notification types',
                  style: TextStyle(color: AppColors.textSecondary),
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
          backgroundColor: AppColors.darkSurface,
          title: const Text(
            'Unfollow Alert',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            'Stop receiving notifications for "$title"?',
            style: const TextStyle(color: AppColors.textSecondary),
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
                _unfollow(sightingId, title);
              },
              child: const Text(
                'Unfollow',
                style: TextStyle(color: AppColors.warningColor),
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
    
    UIFeedback.success('DND disabled');
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