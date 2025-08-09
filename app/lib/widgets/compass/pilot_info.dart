import 'package:flutter/material.dart';
import '../../models/compass_data.dart';
import '../../models/pilot_data.dart';
import '../../theme/app_theme.dart';

class PilotInfo extends StatelessWidget {
  const PilotInfo({
    super.key,
    required this.pilotData,
    this.target,
  });

  final PilotNavigationData pilotData;
  final CompassTarget? target;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Flight instruments row
          _buildFlightInstruments(),
          
          const SizedBox(height: 16),
          
          // Navigation solution
          if (target != null && pilotData.solution != null) 
            _buildNavigationSolution(),
          
          const SizedBox(height: 16),
          
          // Wind and performance data
          Row(
            children: [
              if (pilotData.wind != null) 
                Expanded(child: _buildWindCard()),
              
              if (pilotData.wind != null && _hasPerformanceData())
                const SizedBox(width: 16),
              
              if (_hasPerformanceData())
                Expanded(child: _buildPerformanceCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlightInstruments() {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flight,
                  color: AppColors.brandPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Flight Instruments',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Primary flight data
            Row(
              children: [
                Expanded(
                  child: _buildInstrumentItem(
                    'Heading',
                    '${pilotData.compass.trueHeading.toStringAsFixed(0)}°T',
                    '${pilotData.compass.magneticHeading.toStringAsFixed(0)}°M',
                  ),
                ),
                if (pilotData.groundSpeed != null)
                  Expanded(
                    child: _buildInstrumentItem(
                      'Ground Speed',
                      pilotData.groundSpeedFormatted,
                      pilotData.trueAirspeed != null 
                          ? 'TAS ${pilotData.trueAirspeedFormatted}'
                          : null,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Attitude and altitude
            Row(
              children: [
                if (pilotData.bankAngle != null)
                  Expanded(
                    child: _buildInstrumentItem(
                      'Bank',
                      '${pilotData.bankAngle!.toStringAsFixed(0)}°',
                      pilotData.bankDescription,
                    ),
                  ),
                
                if (pilotData.altitude != null)
                  Expanded(
                    child: _buildInstrumentItem(
                      'Altitude',
                      pilotData.altitudeFormatted,
                      pilotData.verticalSpeed != null
                          ? pilotData.verticalSpeedFormatted
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationSolution() {
    final solution = pilotData.solution!;
    
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.navigation,
                  color: AppColors.brandPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Navigation to ${target!.name}',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
                  ),
                  child: Text(
                    'DIRECT',
                    style: TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Distance and bearing
            Row(
              children: [
                Expanded(
                  child: _buildInstrumentItem(
                    'Distance',
                    solution.distanceFormatted,
                    solution.estimatedTimeEnrouteFormatted != null
                        ? 'ETE ${solution.estimatedTimeEnrouteFormatted}'
                        : null,
                  ),
                ),
                Expanded(
                  child: _buildInstrumentItem(
                    'Bearing',
                    solution.bearingFormatted,
                    'M${solution.magneticBearingFormatted}',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Navigation guidance
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getGuidanceIcon(solution.relativeBearing),
                    color: AppColors.brandPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          solution.navigationGuidance,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Relative: ${solution.relativeBearingFormatted}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Wind correction (if required heading differs from bearing)
            if (solution.requiredHeading != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.semanticInfo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.semanticInfo.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.air,
                      color: AppColors.semanticInfo,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Wind correction: Fly ${solution.requiredHeading!.toStringAsFixed(0)}° to track ${solution.bearingFormatted}',
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
            
            // Cross-track error
            if (solution.trackError != null) ...[
              const SizedBox(height: 8),
              Text(
                'Cross-track: ${solution.trackErrorFormatted}',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWindCard() {
    final wind = pilotData.wind!;
    final currentHeading = pilotData.compass.trueHeading;
    
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.air,
                  color: AppColors.semanticInfo,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Wind',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInstrumentItem(
              'Wind',
              wind.formattedWind,
              wind.accuracy.shortName,
            ),
            
            const SizedBox(height: 12),
            
            _buildInstrumentItem(
              'Component',
              wind.getWindComponent(currentHeading),
              'H=Headwind T=Tailwind X=Crosswind',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: AppColors.semanticSuccess,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Performance',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (pilotData.turnRate.abs() > 0.5)
              _buildInstrumentItem(
                'Turn Rate',
                '${pilotData.turnRate.toStringAsFixed(1)}°/s',
                pilotData.turnRate > 0 ? 'Right turn' : 'Left turn',
              ),
            
            if (pilotData.altitude != null && pilotData.verticalSpeed != null) ...[
              const SizedBox(height: 12),
              _buildInstrumentItem(
                'Climb Rate',
                pilotData.verticalSpeedFormatted,
                pilotData.verticalSpeed! > 0 ? 'Climbing' : 
                 pilotData.verticalSpeed! < 0 ? 'Descending' : 'Level',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstrumentItem(String label, String value, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
      ],
    );
  }

  IconData _getGuidanceIcon(double relativeBearing) {
    final abs = relativeBearing.abs();
    if (abs < 15) return Icons.keyboard_arrow_up;
    if (abs < 90) {
      return relativeBearing > 0 ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_left;
    }
    return Icons.keyboard_arrow_down;
  }

  bool _hasPerformanceData() {
    return pilotData.bankAngle != null || 
           pilotData.altitude != null ||
           pilotData.verticalSpeed != null ||
           pilotData.turnRate.abs() > 0.5;
  }
}

class ETACalculator extends StatelessWidget {
  const ETACalculator({
    super.key,
    required this.solution,
    required this.groundSpeed,
  });

  final NavigationSolution solution;
  final double groundSpeed;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.brandPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Time to Target',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ETE',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        solution.estimatedTimeEnrouteFormatted ?? '--',
                        style: TextStyle(
                          color: AppColors.brandPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ETA',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _calculateETA(),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateETA() {
    if (solution.estimatedTimeEnroute == null) return '--:--';
    
    final eta = DateTime.now().add(solution.estimatedTimeEnroute!);
    final hour = eta.hour;
    final minute = eta.minute;
    
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

class VectoringDisplay extends StatelessWidget {
  const VectoringDisplay({
    super.key,
    required this.solution,
    this.intercept,
  });

  final NavigationSolution solution;
  final InterceptSolution? intercept;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppColors.semanticWarning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Vectoring',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (intercept != null) ...[
              // Intercept solution
              Text(
                'Intercept Solution',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Heading',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          intercept!.headingFormatted,
                          style: TextStyle(
                            color: AppColors.semanticWarning,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          intercept!.timeFormatted,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Direct navigation
              Text(
                'Direct Navigation',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Fly direct to target at ${solution.bearingFormatted}',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}