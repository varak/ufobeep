# ufobeep_camera_caps

A tiny Flutter plugin that exposes **camera zoom capabilities** (min/max zoom factor and lens anchors like `0.5× · 1× · 3×`) so your in‑app camera UI can scale with the user’s hardware.

Designed to pair perfectly with **Camerawesome**.

## What you get
- `CameraCaps { minX, maxX, anchorsX }`
- Helpers to convert Camerawesome’s **normalized zoom (0..1)** ⟷ **real “×” factor**
- Works on Android (Camera2) & iOS (AVFoundation)

## Install (path dependency while developing)
```yaml
dependencies:
  ufobeep_camera_caps:
    path: ../ufobeep_camera_caps
```

## Use with Camerawesome
```dart
final caps = await UfobeepCameraCaps.getCaps();
final factor = UfobeepCameraCaps.normToFactor(normZoom, caps); // e.g., 2.3×
final norm = UfobeepCameraCaps.factorToNorm(3.0, caps); // jump to 3× if supported
```

Render chips when present:
```dart
Row(
  children: [
    for (final ax in caps.anchorsX)
      ChoiceChip(
        label: Text('${ax.toStringAsFixed(ax >= 10 ? 0 : 1)}×'),
        selected: (currentFactor - ax).abs() < 0.15,
        onSelected: (_) => sensor.setZoom(UfobeepCameraCaps.factorToNorm(ax, caps)),
      ),
  ],
);
```

See `example/lib/main.dart` for a tiny example.
