import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CameraDiagScreen extends StatefulWidget {
  const CameraDiagScreen({super.key});

  static const routeName = '/diag/camera';

  @override
  State<CameraDiagScreen> createState() => _CameraDiagScreenState();
}

class _CameraDiagScreenState extends State<CameraDiagScreen> with WidgetsBindingObserver {
  String status = 'Booting…';
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  bool _initialized = false;
  bool _disposed = false;
  File? _logFile;

  Future<void> logLine(String msg) async {
    final ts = DateTime.now().toIso8601String();
    dev.log('[CAM-DIAG] $ts $msg');
    try {
      if (_logFile == null) {
        final dir = await getApplicationDocumentsDirectory();
        _logFile = File('${dir.path}/camera_diag.log');
      }
      await _logFile!.writeAsString('$ts $msg\n', mode: FileMode.append, flush: true);
    } catch (_) {}
    if (mounted) setState(() => status = msg);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Prove initState is reached and run diag after the first frame.
    Future.microtask(_runDiag);
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logLine('Lifecycle: $state');
    if (!_initialized || _controller == null) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _reinitAfterResume();
    }
  }

  Future<void> _reinitAfterResume() async {
    try {
      await logLine('Reinit after resume…');
      if (_cameras.isEmpty) {
        _cameras = await availableCameras().timeout(const Duration(seconds: 8));
      }
      _controller = CameraController(_cameras.first, ResolutionPreset.max, enableAudio: false);
      await _controller!.initialize().timeout(const Duration(seconds: 8));
      if (mounted) setState(() => _initialized = true);
      await logLine('Reinit OK');
    } catch (e, st) {
      await logLine('Reinit failed: $e\n$st');
    }
  }

  Future<void> _runDiag() async {
    try {
      await logLine('initState() reached; starting _runDiag…');

      // 1) Permission phase with timeout
      await logLine('Requesting camera permission…');
      final camStatus = await Permission.camera.request().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Permission request timed out'),
      );
      await logLine('Permission result: $camStatus');

      if (!await Permission.camera.isGranted) {
        await logLine('Camera permission NOT granted → aborting.');
        return;
      }

      // 2) availableCameras() with timeout
      await logLine('Calling availableCameras()…');
      _cameras = await availableCameras().timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw TimeoutException('availableCameras() timed out'),
      );
      await logLine('availableCameras() returned ${_cameras.length} camera(s).');
      if (_cameras.isEmpty) {
        await logLine('No cameras found on device → aborting.');
        return;
      }

      // 3) Controller initialize with timeout
      await logLine('Creating CameraController…');
      _controller = CameraController(_cameras.first, ResolutionPreset.max, enableAudio: false);
      await logLine('Initializing controller…');
      await _controller!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('controller.initialize() timed out'),
      );

      _initialized = true;
      if (mounted) setState(() {});
      await logLine('Camera initialized successfully ✅');
    } catch (e, st) {
      await logLine('DIAG ERROR: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = (!_initialized || _controller == null)
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(status, textAlign: TextAlign.center),
              ],
            ),
          )
        : CameraPreview(_controller!);

    return Scaffold(
      appBar: AppBar(title: const Text('Camera Diagnostic')),
      body: body,
      bottomNavigationBar: _logHelpBar(),
    );
  }

  Widget _logHelpBar() => Material(
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Tip: run `adb logcat | grep -iE "flutter|camera|CAM-DIAG"`\n'
            'Pull file log with: adb shell run-as <your.package.id> cat files/camera_diag.log',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
}