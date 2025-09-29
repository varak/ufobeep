import 'package:flutter/material.dart';
import 'package:ufobeep_camera_caps/ufobeep_camera_caps.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CameraCaps? caps;
  @override
  void initState() {
    super.initState();
    UfobeepCameraCaps.getCaps().then((c) => setState(() => caps = c));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('ufobeep_camera_caps demo')),
        body: Center(
          child: Text(caps?.toString() ?? 'Loading caps...'),
        ),
      ),
    );
  }
}
