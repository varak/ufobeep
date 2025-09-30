import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../models/alerts_filter.dart';
import '../../providers/alerts_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_client.dart';

class AlertsSettingsScreen extends ConsumerStatefulWidget {
  const AlertsSettingsScreen({super.key});

  @override
  ConsumerState<AlertsSettingsScreen> createState() => _AlertsSettingsScreenState();
}

class _AlertsSettingsScreenState extends ConsumerState<AlertsSettingsScreen> {
  bool _showUfoBeep = true;
  bool _showMufon = true;
  bool _sortByNewest = true;
  double _alertRangeKm = 100.0;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Load current filter state
      final currentFilter = ref.read(alertsFilterStateProvider);

      // Load alert range from backend
      final response = await ApiClient.dio.get('/users/me');
      final alertRangeKm = response.data['user']['alert_range_km'] as num;

      if (mounted) {
        setState(() {
          // Map current filter to checkboxes
          if (currentFilter.showUfoBeepOnly == true) {
            _showUfoBeep = true;
            _showMufon = false;
          } else if (currentFilter.showUfoBeepOnly == false) {
            _showUfoBeep = false;
            _showMufon = true;
          } else {
            _showUfoBeep = true;
            _showMufon = true;
          }

          _sortByNewest = currentFilter.sortBy != AlertSortBy.distance;
          _alertRangeKm = alertRangeKm.toDouble();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load settings: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load settings: $e'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      // Map checkboxes to source filter
      bool? showUfoBeepOnly;
      if (_showUfoBeep && !_showMufon) {
        showUfoBeepOnly = true;  // UFOBeep only
      } else if (!_showUfoBeep && _showMufon) {
        showUfoBeepOnly = false;  // MUFON only
      } else {
        showUfoBeepOnly = null;  // Both or neither
      }

      // Create new filter
      final newFilter = AlertsFilter(
        showUfoBeepOnly: showUfoBeepOnly,
        sortBy: _sortByNewest ? AlertSortBy.newest : AlertSortBy.distance,
      );

      // Save filter to state
      ref.read(alertsFilterStateProvider.notifier).updateFilter(newFilter);

      // Save alert range to backend
      await ApiClient.dio.put('/users/me/alert-range', data: _alertRangeKm);

      // Refresh alerts list with new filter
      ref.invalidate(alertsListProvider);

      debugPrint('✅ Settings saved successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved'),
            backgroundColor: AppColors.semanticSuccess,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ Failed to save settings: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.filterAlerts),
          backgroundColor: AppColors.darkSurface,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.filterAlerts),
        backgroundColor: AppColors.darkSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Alert Range Section
          Card(
            color: AppColors.darkSurface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.alertRadius,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current range: ${_alertRangeKm.toInt()} km',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _alertRangeKm,
                    min: 1,
                    max: 10000,
                    divisions: 100,
                    activeColor: AppColors.brandPrimary,
                    label: '${_alertRangeKm.toInt()} km',
                    onChanged: (value) {
                      setState(() => _alertRangeKm = value);
                    },
                  ),
                  Text(
                    'You\'ll receive notifications for sightings within this distance',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Alert Sources Section
          Card(
            color: AppColors.darkSurface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alert Sources',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text(
                      'UFOBeep Reports',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      'Community sightings from mobile app users',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    value: _showUfoBeep,
                    activeColor: AppColors.brandPrimary,
                    onChanged: (value) {
                      setState(() => _showUfoBeep = value ?? true);
                    },
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'MUFON Reports',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: const Text(
                      'Historical sightings from MUFON database',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    value: _showMufon,
                    activeColor: AppColors.brandPrimary,
                    onChanged: (value) {
                      setState(() => _showMufon = value ?? true);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sort By Section
          Card(
            color: AppColors.darkSurface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.sortBy,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<bool>(
                    title: Text(
                      l10n.sortByNewest,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    value: true,
                    groupValue: _sortByNewest,
                    activeColor: AppColors.brandPrimary,
                    onChanged: (value) {
                      setState(() => _sortByNewest = value ?? true);
                    },
                  ),
                  RadioListTile<bool>(
                    title: Text(
                      l10n.sortByNearest,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    value: false,
                    groupValue: _sortByNewest,
                    activeColor: AppColors.brandPrimary,
                    onChanged: (value) {
                      setState(() => _sortByNewest = value ?? true);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.textSecondary),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.black),
                          ),
                        )
                      : Text(
                          l10n.save,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
