// lib/ufo_camera_with_zoom.dart
import 'dart:async';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ufobeep_camera_caps/ufobeep_camera_caps.dart';

class UfoCameraWithZoom extends StatefulWidget {
  const UfoCameraWithZoom({super.key});

  @override
  State<UfoCameraWithZoom> createState() => _UfoCameraWithZoomState();
}

class _UfoCameraWithZoomState extends State<UfoCameraWithZoom> {
  static const double _step = 0.07;
  static const double _holdStep = 0.03;
  static const Duration _holdEvery = Duration(milliseconds: 40);
  Timer? _holdTimer;
  CameraCaps? _caps;

  @override
  void initState() {
    super.initState();
    _initCaps();
  }

  Future<void> _initCaps() async {
    final caps = await UfobeepCameraCaps.getCaps();
    if (mounted) setState(() => _caps = caps);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraAwesomeBuilder.awesome(
      saveConfig: SaveConfig.photoAndVideo(),
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
            // Other events (capturing, failure, etc.)
            break;
        }
      },
      // Use built-in UI but add our custom zoom controls
      bottomActionsBuilder: (state) {
        if (_caps == null) return const SizedBox.shrink();

        return Positioned(
          right: 12,
          bottom: 20,
          child: StreamBuilder<SensorConfig>(
            stream: state.sensorConfig$,
            builder: (context, sensorSnap) {
              if (!sensorSnap.hasData) return const SizedBox.shrink();
              final sensor = sensorSnap.requireData;
              return StreamBuilder<double>(
                stream: sensor.zoom$,
                initialData: sensor.zoom,
                builder: (context, zoomSnap) {
                  final z = (zoomSnap.data ?? 0.0).clamp(0.0, 1.0);
                  final caps = _caps!;
                  final factor = UfobeepCameraCaps.normToFactor(z, caps);

                  Future<void> setZoom(double v) async {
                    final next = v.clamp(0.0, 1.0);
                    await sensor.setZoom(next);
                  }

                  void startHold(double delta) {
                    _holdTimer?.cancel();
                    _holdTimer = Timer.periodic(_holdEvery, (_) {
                      setZoom((zoomSnap.data ?? 0.0) + delta);
                    });
                  }

                  void stopHold() {
                    _holdTimer?.cancel();
                    _holdTimer = null;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Zoom indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${factor.toStringAsFixed(1)}×',
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
                          _roundBtn(
                            icon: Icons.remove,
                            onTap: () => setZoom(z - _step),
                            onHoldStart: () => startHold(-_holdStep),
                            onHoldEnd: stopHold,
                          ),
                          const SizedBox(width: 8),
                          _roundBtn(
                            icon: Icons.add,
                            onTap: () => setZoom(z + _step),
                            onHoldStart: () => startHold(_holdStep),
                            onHoldEnd: stopHold,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
      // Add lens anchors on the left
      middleContentBuilder: (state) {
        if (_caps == null || _caps!.anchorsX.length <= 1) {
          return const SizedBox.shrink();
        }

        return Positioned(
              right: 12,
              bottom: 120,
              child: StreamBuilder<SensorConfig>(
                stream: state.sensorConfig$,
                builder: (context, sensorSnap) {
                  if (!sensorSnap.hasData) return const SizedBox.shrink();
                  final sensor = sensorSnap.requireData;
                  return StreamBuilder<double>(
                    stream: sensor.zoom$,
                    initialData: sensor.zoom,
                    builder: (context, zoomSnap) {
                      final z = (zoomSnap.data ?? 0.0).clamp(0.0, 1.0);
                      final caps = _caps ?? const CameraCaps(minX: 1.0, maxX: 8.0, anchorsX: [1.0]);
                      final factor = UfobeepCameraCaps.normToFactor(z, caps);

                      Future<void> setZoom(double v) async {
                        final next = v.clamp(0.0, 1.0);
                        if (next != z) {
                          HapticFeedback.selectionClick();
                          await sensor.setZoom(next);
                        }
                      }

                      void startHold(double delta) {
                        _holdTimer?.cancel();
                        _holdTimer = Timer.periodic(_holdEvery, (_) {
                          setZoom((sensor.zoom) + delta);
                        });
                      }

                      void stopHold() { _holdTimer?.cancel(); _holdTimer = null; }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onDoubleTap: () => setZoom(0.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${factor.toStringAsFixed(1)}×',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _roundBtn(
                                icon: Icons.remove,
                                onTap: () => setZoom(z - _step),
                                onHoldStart: () => startHold(-_holdStep),
                                onHoldEnd: stopHold,
                              ),
                              const SizedBox(width: 10),
                              _roundBtn(
                                icon: Icons.add,
                                onTap: () => setZoom(z + _step),
                                onHoldStart: () => startHold(_holdStep),
                                onHoldEnd: stopHold,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LensAnchors extends StatelessWidget {
  final CameraCaps caps;
  final CameraState state;
  const _LensAnchors({required this.caps, required this.state});

  @override
  Widget build(BuildContext context) {
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
            final currentFactor = UfobeepCameraCaps.normToFactor(z, caps);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final ax in caps.anchorsX)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _chip(
                      label: '${ax.toStringAsFixed(ax >= 10 ? 0 : 1)}×',
                      selected: (currentFactor - ax).abs() < 0.15,
                      onTap: () {
                        final n = UfobeepCameraCaps.factorToNorm(ax, caps);
                        sensor.setZoom(n);
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _roundBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onHoldStart;
  final VoidCallback? onHoldEnd;

  const _roundBtn({required this.icon, required this.onTap, this.onHoldStart, this.onHoldEnd});

  @override
  State<_roundBtn> createState() => _roundBtnState();
}

class _roundBtnState extends State<_roundBtn> {
  bool _holding = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) { _holding = true; widget.onHoldStart?.call(); },
      onTapUp: (_) { if (_holding) { _holding = false; widget.onHoldEnd?.call(); } },
      onTapCancel: () { if (_holding) { _holding = false; widget.onHoldEnd?.call(); } },
      child: ClipOval(
        child: Material(
          color: Colors.black.withOpacity(0.5),
          child: SizedBox(
            width: 44, height: 44, child: Icon(widget.icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

Widget _chip({required String label, required bool selected, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: selected ? Border.all(color: Colors.black12) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.black : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    ),
  );
}
