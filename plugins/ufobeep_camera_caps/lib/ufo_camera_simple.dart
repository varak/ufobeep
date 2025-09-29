import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class UfoCameraSimple extends StatelessWidget {
  const UfoCameraSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.photoAndVideo(),
      availableFilters: [], // Remove filters - not needed for UFO evidence
      enablePhysicalButton: true,
      topActionsBuilder: (state) {
        // Remove GPS toggle - return empty container
        return const SizedBox.shrink();
      },
      middleContentBuilder: (state) {
        // Simple photo/video toggle
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: AwesomeCameraModeSelector(state: state),
        );
      },
      sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.back),
          aspectRatio: CameraAspectRatios.ratio_4_3,
          flashMode: FlashMode.auto,
          zoom: 0.0,
        ),
        onMediaCaptureEvent: (event) {
          switch ((event.status, event.isPicture, event.isVideo)) {
            case (MediaCaptureStatus.success, true, false):
              // Photo captured - return to UFOBeep
              Navigator.of(context).pop();
              break;
            case (MediaCaptureStatus.success, false, true):
              // Video captured - return to UFOBeep
              Navigator.of(context).pop();
              break;
            default:
              break;
          }
        },
        // Simple zoom controls on the right side
        bottomActionsBuilder: (state) {
          return StreamBuilder<SensorConfig>(
            stream: state.sensorConfig$,
            builder: (context, sensorSnap) {
              if (!sensorSnap.hasData) return const SizedBox.shrink();
              final sensor = sensorSnap.requireData;

              return StreamBuilder<double>(
                stream: sensor.zoom$,
                initialData: sensor.zoom,
                builder: (context, zoomSnap) {
                  final z = (zoomSnap.data ?? 0.0).clamp(0.0, 1.0);
                  final zoomPercent = (z * 100).round();

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Zoom indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${zoomPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Zoom buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _zoomButton(
                            icon: Icons.remove,
                            onPressed: () {
                              final newZoom = (z - 0.05).clamp(0.0, 1.0); // Smaller steps
                              sensor.setZoom(newZoom);
                            },
                          ),
                          const SizedBox(width: 8),
                          _zoomButton(
                            icon: Icons.add,
                            onPressed: () {
                              final newZoom = (z + 0.05).clamp(0.0, 1.0); // Smaller steps
                              sensor.setZoom(newZoom);
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _zoomButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}