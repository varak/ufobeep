import 'package:flutter/material.dart';
import '../../models/enriched_alert.dart';
import '../../models/quarantine_state.dart';
import '../../theme/app_theme.dart';

/// Content warning overlay for NSFW or quarantined alerts
class ContentWarning extends StatefulWidget {
  const ContentWarning({
    super.key,
    required this.alert,
    required this.child,
    this.canReveal = true,
    this.showDetails = true,
    this.onReveal,
    this.onQuarantineAction,
  });

  final EnrichedAlert alert;
  final Widget child;
  final bool canReveal;
  final bool showDetails;
  final VoidCallback? onReveal;
  final Function(QuarantineAction action)? onQuarantineAction;

  @override
  State<ContentWarning> createState() => _ContentWarningState();
}

class _ContentWarningState extends State<ContentWarning> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    // Don't show warning if not quarantined or already revealed
    if (!widget.alert.isQuarantined || _isRevealed) {
      return widget.child;
    }

    return Container(
      child: Stack(
        children: [
          // Blurred content
          Container(
            child: widget.child,
            foregroundDecoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              backgroundBlendMode: BlendMode.srcOver,
            ),
          ),
          // Warning overlay
          Positioned.fill(
            child: _buildWarningOverlay(),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningOverlay() {
    final quarantine = widget.alert.quarantine;
    final primaryReason = quarantine.primaryReason;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getWarningColor(primaryReason).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Icon(
                _getWarningIcon(primaryReason),
                size: 48,
                color: _getWarningColor(primaryReason),
              ),
              const SizedBox(height: 16),
              
              // Warning title
              Text(
                _getWarningTitle(primaryReason),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Warning description
              Text(
                widget.alert.contentWarning ?? quarantine.reasonsDisplayText,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              if (widget.showDetails && quarantine.confidenceScore != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Confidence: ${(quarantine.confidenceScore! * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        if (widget.canReveal) _buildRevealButton(),
        _buildReportButton(),
        if (widget.showDetails) _buildDetailsButton(),
      ],
    );
  }

  Widget _buildRevealButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isRevealed = true;
        });
        widget.onReveal?.call();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: AppColors.darkBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.visibility, size: 16),
          const SizedBox(width: 6),
          const Text('View Content'),
        ],
      ),
    );
  }

  Widget _buildReportButton() {
    return TextButton(
      onPressed: () {
        // TODO: Implement report functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report functionality coming soon')),
        );
      },
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flag_outlined, size: 16),
          const SizedBox(width: 6),
          const Text('Report'),
        ],
      ),
    );
  }

  Widget _buildDetailsButton() {
    return TextButton(
      onPressed: () {
        _showQuarantineDetails();
      },
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textTertiary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, size: 16),
          const SizedBox(width: 6),
          const Text('Details'),
        ],
      ),
    );
  }

  void _showQuarantineDetails() {
    showDialog(
      context: context,
      builder: (context) => QuarantineDetailsDialog(
        alert: widget.alert,
        onAction: widget.onQuarantineAction,
      ),
    );
  }

  IconData _getWarningIcon(QuarantineReason reason) {
    switch (reason) {
      case QuarantineReason.nsfw:
        return Icons.explicit;
      case QuarantineReason.violence:
        return Icons.warning;
      case QuarantineReason.inappropriate:
        return Icons.block;
      case QuarantineReason.harassment:
        return Icons.report;
      case QuarantineReason.misinformation:
        return Icons.fact_check;
      case QuarantineReason.spam:
        return Icons.spam;
      case QuarantineReason.privacy:
        return Icons.privacy_tip;
      case QuarantineReason.lowQuality:
        return Icons.image_not_supported;
      case QuarantineReason.irrelevant:
        return Icons.off_screen;
      case QuarantineReason.hoax:
        return Icons.theaters;
      default:
        return Icons.warning_amber;
    }
  }

  Color _getWarningColor(QuarantineReason reason) {
    switch (reason.severity) {
      case 3:
        return AppColors.semanticError;
      case 2:
        return AppColors.semanticWarning;
      case 1:
        return AppColors.semanticInfo;
      default:
        return AppColors.textTertiary;
    }
  }

  String _getWarningTitle(QuarantineReason reason) {
    switch (reason) {
      case QuarantineReason.nsfw:
        return 'Sensitive Content Warning';
      case QuarantineReason.violence:
        return 'Violent Content Warning';
      case QuarantineReason.inappropriate:
        return 'Inappropriate Content';
      case QuarantineReason.harassment:
        return 'Potentially Harmful Content';
      case QuarantineReason.misinformation:
        return 'Unverified Information';
      case QuarantineReason.spam:
        return 'Low Quality Content';
      case QuarantineReason.privacy:
        return 'Privacy Concern';
      case QuarantineReason.lowQuality:
        return 'Poor Quality Media';
      case QuarantineReason.irrelevant:
        return 'Off-Topic Content';
      case QuarantineReason.hoax:
        return 'Potentially Staged Content';
      default:
        return 'Content Warning';
    }
  }
}

/// Detailed quarantine information dialog
class QuarantineDetailsDialog extends StatelessWidget {
  const QuarantineDetailsDialog({
    super.key,
    required this.alert,
    this.onAction,
  });

  final EnrichedAlert alert;
  final Function(QuarantineAction action)? onAction;

  @override
  Widget build(BuildContext context) {
    final quarantine = alert.quarantine;
    
    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: Row(
        children: [
          Icon(
            Icons.security,
            color: AppColors.semanticWarning,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Quarantine Details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Status', quarantine.actionDisplayName),
            _buildDetailRow('Reason', quarantine.reasonsDisplayText),
            
            if (quarantine.confidenceScore != null)
              _buildDetailRow(
                'Confidence',
                '${(quarantine.confidenceScore! * 100).toStringAsFixed(0)}%',
              ),
            
            if (quarantine.quarantinedAt != null)
              _buildDetailRow(
                'Quarantined',
                _formatDateTime(quarantine.quarantinedAt!),
              ),
            
            if (quarantine.moderatorName != null)
              _buildDetailRow('Moderator', quarantine.moderatorName!),
            
            if (quarantine.reviewedAt != null)
              _buildDetailRow(
                'Reviewed',
                _formatDateTime(quarantine.reviewedAt!),
              ),
            
            const SizedBox(height: 16),
            
            _buildReasonsSection(),
            
            if (quarantine.isAutoQuarantined) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.semanticInfo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.semanticInfo.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.smart_toy,
                      size: 16,
                      color: AppColors.semanticInfo,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Auto-quarantined by content analysis',
                        style: TextStyle(
                          color: AppColors.semanticInfo,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonsSection() {
    final quarantine = alert.quarantine;
    if (quarantine.reasons.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reasons:',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        ...quarantine.reasons.map((reason) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reason.displayName,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Compact quarantine badge for alert cards
class QuarantineBadge extends StatelessWidget {
  const QuarantineBadge({
    super.key,
    required this.quarantine,
    this.compact = false,
  });

  final QuarantineState quarantine;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!quarantine.isQuarantined) return const SizedBox.shrink();
    
    final reason = quarantine.primaryReason;
    final color = _getReasonColor(reason);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getReasonIcon(reason),
            size: compact ? 10 : 12,
            color: color,
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              _getCompactText(reason),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getReasonColor(QuarantineReason reason) {
    switch (reason.severity) {
      case 3:
        return AppColors.semanticError;
      case 2:
        return AppColors.semanticWarning;
      case 1:
        return AppColors.semanticInfo;
      default:
        return AppColors.textTertiary;
    }
  }

  IconData _getReasonIcon(QuarantineReason reason) {
    switch (reason) {
      case QuarantineReason.nsfw:
        return Icons.explicit;
      case QuarantineReason.inappropriate:
        return Icons.block;
      case QuarantineReason.violence:
        return Icons.warning;
      default:
        return Icons.warning_amber;
    }
  }

  String _getCompactText(QuarantineReason reason) {
    switch (reason) {
      case QuarantineReason.nsfw:
        return 'NSFW';
      case QuarantineReason.inappropriate:
        return 'BLOCKED';
      case QuarantineReason.violence:
        return 'WARNING';
      default:
        return 'QUARANTINE';
    }
  }
}