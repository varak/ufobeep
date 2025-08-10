import 'package:flutter/material.dart';
import '../../models/enriched_alert.dart';
import '../../models/quarantine_state.dart';
import '../../theme/app_theme.dart';

/// Quarantine moderation controls for moderators and reporters
class QuarantineControls extends StatefulWidget {
  const QuarantineControls({
    super.key,
    required this.alert,
    required this.isModerator,
    required this.isReporter,
    required this.currentUserId,
    this.onQuarantineAction,
    this.onApprove,
  });

  final EnrichedAlert alert;
  final bool isModerator;
  final bool isReporter;
  final String currentUserId;
  final Function(QuarantineAction action, List<QuarantineReason> reasons, String? customReason)? onQuarantineAction;
  final VoidCallback? onApprove;

  @override
  State<QuarantineControls> createState() => _QuarantineControlsState();
}

class _QuarantineControlsState extends State<QuarantineControls> {
  bool _showAdvancedControls = false;

  @override
  Widget build(BuildContext context) {
    // Only show controls if user has appropriate permissions
    if (!widget.isModerator && !widget.isReporter) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildCurrentStatus(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          if (_showAdvancedControls) ...[
            const SizedBox(height: 16),
            _buildAdvancedControls(),
          ],
          const SizedBox(height: 12),
          _buildToggleAdvanced(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.admin_panel_settings,
          size: 18,
          color: widget.isModerator ? AppColors.semanticWarning : AppColors.semanticInfo,
        ),
        const SizedBox(width: 8),
        Text(
          widget.isModerator ? 'Moderation Controls' : 'Reporter Controls',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (widget.alert.quarantine.isAutoQuarantined) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.semanticInfo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.semanticInfo.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.smart_toy,
                  size: 10,
                  color: AppColors.semanticInfo,
                ),
                const SizedBox(width: 3),
                Text(
                  'AUTO',
                  style: TextStyle(
                    color: AppColors.semanticInfo,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCurrentStatus() {
    final quarantine = widget.alert.quarantine;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(quarantine.action),
                size: 16,
                color: _getStatusColor(quarantine.action),
              ),
              const SizedBox(width: 6),
              Text(
                'Status: ${quarantine.actionDisplayName}',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (quarantine.reasons.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Reasons: ${quarantine.reasonsDisplayText}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
          if (quarantine.confidenceScore != null) ...[
            const SizedBox(height: 4),
            Text(
              'Confidence: ${(quarantine.confidenceScore! * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final quarantine = widget.alert.quarantine;
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Approve action (for moderators)
        if (widget.isModerator && quarantine.isQuarantined && !quarantine.isApproved)
          _buildActionButton(
            label: 'Approve',
            icon: Icons.check_circle,
            color: AppColors.semanticSuccess,
            onTap: () => _handleApprove(),
          ),
        
        // Quick quarantine actions (for moderators)
        if (widget.isModerator && !quarantine.isQuarantined)
          _buildActionButton(
            label: 'Hide Public',
            icon: Icons.visibility_off,
            color: AppColors.semanticWarning,
            onTap: () => _handleQuickQuarantine(QuarantineAction.hidePublic, [QuarantineReason.inappropriate]),
          ),
        
        // NSFW quarantine (for moderators)  
        if (widget.isModerator)
          _buildActionButton(
            label: quarantine.isNsfwQuarantined ? 'Remove NSFW' : 'Mark NSFW',
            icon: Icons.explicit,
            color: AppColors.semanticError,
            onTap: () => quarantine.isNsfwQuarantined 
                ? _handleApprove() 
                : _handleQuickQuarantine(QuarantineAction.hidePublic, [QuarantineReason.nsfw]),
          ),
        
        // Report actions (for reporters/general users)
        if (!widget.isModerator)
          _buildActionButton(
            label: 'Report NSFW',
            icon: Icons.report,
            color: AppColors.semanticError,
            onTap: () => _showReportDialog([QuarantineReason.nsfw]),
          ),
      ],
    );
  }

  Widget _buildAdvancedControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Actions',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (widget.isModerator) ...[
              _buildActionButton(
                label: 'Custom Quarantine',
                icon: Icons.build,
                color: AppColors.brandPrimary,
                onTap: () => _showCustomQuarantineDialog(),
              ),
              _buildActionButton(
                label: 'Remove Content',
                icon: Icons.delete,
                color: AppColors.semanticError,
                onTap: () => _handleQuickQuarantine(QuarantineAction.remove, [QuarantineReason.inappropriate]),
              ),
              _buildActionButton(
                label: 'Pending Review',
                icon: Icons.schedule,
                color: AppColors.semanticInfo,
                onTap: () => _handleQuickQuarantine(QuarantineAction.pendingReview, [QuarantineReason.reported]),
              ),
            ] else ...[
              _buildActionButton(
                label: 'Report Other',
                icon: Icons.flag,
                color: AppColors.semanticWarning,
                onTap: () => _showReportDialog([QuarantineReason.other]),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleAdvanced() {
    return InkWell(
      onTap: () {
        setState(() {
          _showAdvancedControls = !_showAdvancedControls;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _showAdvancedControls ? Icons.expand_less : Icons.expand_more,
            size: 16,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            _showAdvancedControls ? 'Less options' : 'More options',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  void _handleApprove() {
    if (widget.onApprove != null) {
      widget.onApprove!();
    } else {
      // Default approve action
      widget.onQuarantineAction?.call(
        QuarantineAction.approved,
        [],
        null,
      );
    }
  }

  void _handleQuickQuarantine(QuarantineAction action, List<QuarantineReason> reasons) {
    widget.onQuarantineAction?.call(action, reasons, null);
  }

  void _showCustomQuarantineDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomQuarantineDialog(
        alert: widget.alert,
        onAction: (action, reasons, customReason) {
          Navigator.of(context).pop();
          widget.onQuarantineAction?.call(action, reasons, customReason);
        },
      ),
    );
  }

  void _showReportDialog(List<QuarantineReason> suggestedReasons) {
    showDialog(
      context: context,
      builder: (context) => ReportContentDialog(
        alert: widget.alert,
        suggestedReasons: suggestedReasons,
        onReport: (reasons, customReason) {
          Navigator.of(context).pop();
          // For reporters, we set pending review action
          widget.onQuarantineAction?.call(
            QuarantineAction.pendingReview,
            reasons,
            customReason,
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(QuarantineAction action) {
    switch (action) {
      case QuarantineAction.none:
        return Icons.check_circle;
      case QuarantineAction.pendingReview:
        return Icons.schedule;
      case QuarantineAction.hidePublic:
        return Icons.visibility_off;
      case QuarantineAction.approved:
        return Icons.verified;
      case QuarantineAction.remove:
        return Icons.delete;
    }
  }

  Color _getStatusColor(QuarantineAction action) {
    switch (action) {
      case QuarantineAction.none:
        return AppColors.semanticSuccess;
      case QuarantineAction.pendingReview:
        return AppColors.semanticInfo;
      case QuarantineAction.hidePublic:
        return AppColors.semanticWarning;
      case QuarantineAction.approved:
        return AppColors.semanticSuccess;
      case QuarantineAction.remove:
        return AppColors.semanticError;
    }
  }
}

/// Dialog for custom quarantine actions
class CustomQuarantineDialog extends StatefulWidget {
  const CustomQuarantineDialog({
    super.key,
    required this.alert,
    required this.onAction,
  });

  final EnrichedAlert alert;
  final Function(QuarantineAction action, List<QuarantineReason> reasons, String? customReason) onAction;

  @override
  State<CustomQuarantineDialog> createState() => _CustomQuarantineDialogState();
}

class _CustomQuarantineDialogState extends State<CustomQuarantineDialog> {
  QuarantineAction _selectedAction = QuarantineAction.hidePublic;
  final Set<QuarantineReason> _selectedReasons = {};
  final TextEditingController _customReasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: Text(
        'Custom Quarantine Action',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionSelector(),
            const SizedBox(height: 16),
            _buildReasonSelector(),
            const SizedBox(height: 16),
            _buildCustomReasonField(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
        ),
        ElevatedButton(
          onPressed: _selectedReasons.isNotEmpty ? _handleSubmit : null,
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildActionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Action:',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        ...QuarantineAction.values.where((a) => a != QuarantineAction.none).map(
          (action) => RadioListTile<QuarantineAction>(
            value: action,
            groupValue: _selectedAction,
            onChanged: (value) => setState(() => _selectedAction = value!),
            title: Text(
              _getActionName(action),
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildReasonSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reasons:',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: QuarantineReason.values.map((reason) {
            final isSelected = _selectedReasons.contains(reason);
            return FilterChip(
              label: Text(
                reason.displayName,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? AppColors.darkBackground : AppColors.textSecondary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedReasons.add(reason);
                  } else {
                    _selectedReasons.remove(reason);
                  }
                });
              },
              backgroundColor: AppColors.darkBackground,
              selectedColor: AppColors.brandPrimary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Reason (optional):',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _customReasonController,
          maxLines: 3,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Provide additional context...',
            hintStyle: TextStyle(color: AppColors.textTertiary),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.darkBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.darkBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.brandPrimary),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    final customReason = _customReasonController.text.trim();
    widget.onAction(
      _selectedAction,
      _selectedReasons.toList(),
      customReason.isEmpty ? null : customReason,
    );
  }

  String _getActionName(QuarantineAction action) {
    switch (action) {
      case QuarantineAction.pendingReview:
        return 'Pending Review';
      case QuarantineAction.hidePublic:
        return 'Hide from Public';
      case QuarantineAction.approved:
        return 'Approve Content';
      case QuarantineAction.remove:
        return 'Remove Content';
      case QuarantineAction.none:
        return 'Clear Quarantine';
    }
  }
}

/// Dialog for reporting content
class ReportContentDialog extends StatefulWidget {
  const ReportContentDialog({
    super.key,
    required this.alert,
    required this.suggestedReasons,
    required this.onReport,
  });

  final EnrichedAlert alert;
  final List<QuarantineReason> suggestedReasons;
  final Function(List<QuarantineReason> reasons, String? customReason) onReport;

  @override
  State<ReportContentDialog> createState() => _ReportContentDialogState();
}

class _ReportContentDialogState extends State<ReportContentDialog> {
  final Set<QuarantineReason> _selectedReasons = {};
  final TextEditingController _customReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-select suggested reasons
    _selectedReasons.addAll(widget.suggestedReasons);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: Row(
        children: [
          Icon(Icons.flag, color: AppColors.semanticWarning, size: 20),
          const SizedBox(width: 8),
          Text(
            'Report Content',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Why are you reporting this content?',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            
            // Common report reasons
            ...QuarantineReason.values.where((r) => [
              QuarantineReason.nsfw,
              QuarantineReason.inappropriate,
              QuarantineReason.violence,
              QuarantineReason.harassment,
              QuarantineReason.spam,
              QuarantineReason.misinformation,
              QuarantineReason.other,
            ].contains(r)).map((reason) {
              return CheckboxListTile(
                value: _selectedReasons.contains(reason),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedReasons.add(reason);
                    } else {
                      _selectedReasons.remove(reason);
                    }
                  });
                },
                title: Text(
                  reason.displayName,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                ),
                subtitle: Text(
                  reason.description,
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }),
            
            const SizedBox(height: 12),
            TextField(
              controller: _customReasonController,
              maxLines: 2,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Additional details (optional)',
                labelStyle: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                hintText: 'Provide more context about the issue...',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.darkBorder),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
        ),
        ElevatedButton(
          onPressed: _selectedReasons.isNotEmpty ? _handleSubmit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.semanticWarning,
          ),
          child: const Text('Submit Report'),
        ),
      ],
    );
  }

  void _handleSubmit() {
    final customReason = _customReasonController.text.trim();
    widget.onReport(
      _selectedReasons.toList(),
      customReason.isEmpty ? null : customReason,
    );
  }
}