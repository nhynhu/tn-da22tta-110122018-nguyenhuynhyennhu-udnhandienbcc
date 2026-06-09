class DetectionHistoryItem {
  final int id;
  final String deviceId;
  final String className;
  final double confidence;
  final String bbox;
  final String detectedAt;

  DetectionHistoryItem({
    required this.id,
    required this.deviceId,
    required this.className,
    required this.confidence,
    required this.bbox,
    required this.detectedAt,
  });

  factory DetectionHistoryItem.fromJson(Map<String, dynamic> json) {
    return DetectionHistoryItem(
      id: json['id'] ?? 0,
      deviceId: json['device_id'] ?? '',
      className: json['class_name'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      bbox: json['bbox'] ?? '',
      detectedAt: json['detected_at'] ?? '',
    );
  }

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';
}
