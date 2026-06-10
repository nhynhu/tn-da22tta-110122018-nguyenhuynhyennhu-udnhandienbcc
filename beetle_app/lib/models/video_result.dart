class VideoDetectionResult {
  final String videoUrl;
  final double fps;
  final int frames;
  final List<DetectedSpecies> detections;

  VideoDetectionResult({
    required this.videoUrl,
    required this.fps,
    required this.frames,
    required this.detections,
  });

  factory VideoDetectionResult.fromJson(Map<String, dynamic> json) {
    return VideoDetectionResult(
      videoUrl: json['video_url'] as String,
      fps: (json['fps'] as num?)?.toDouble() ?? 0,
      frames: (json['frames'] as num?)?.toInt() ?? 0,
      detections: (json['detections'] as List? ?? [])
          .map((e) => DetectedSpecies.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DetectedSpecies {
  final String className;
  final String tenViet;
  final int count;
  final double confidence; // %

  DetectedSpecies({
    required this.className,
    required this.tenViet,
    required this.count,
    required this.confidence,
  });

  factory DetectedSpecies.fromJson(Map<String, dynamic> json) {
    return DetectedSpecies(
      className: json['class_name'] as String? ?? '',
      tenViet: json['ten_viet'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }
}
