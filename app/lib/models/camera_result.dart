class CameraCaptureResult {
  final String path;
  final bool isVideo;
  final Map<String, dynamic>? sensorData;
  final Map<String, dynamic>? photoMetadata;
  final String? description;
  final String? attachToSightingId;
  
  const CameraCaptureResult({
    required this.path,
    this.isVideo = false,
    this.sensorData,
    this.photoMetadata,
    this.description,
    this.attachToSightingId,
  });
}