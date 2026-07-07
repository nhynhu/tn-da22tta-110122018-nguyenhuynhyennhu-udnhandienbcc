import '../config/api_config.dart';

class Prediction {
  final String className;
  final double confidence;
  final List<double> bbox;
  final String tenViet;
  final String tenKhoaHoc;
  final String gayHai;
  final String phongChong;

  final String hinhAnhUrl;
  final String hinhAnhGayHai;

  Prediction({
    required this.className,
    required this.confidence,
    required this.bbox,
    required this.tenViet,
    required this.tenKhoaHoc,
    required this.gayHai,
    required this.phongChong,

    required this.hinhAnhUrl,
    required this.hinhAnhGayHai,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['hinh_anh_url'] ?? '';
    final fullUrl = rawUrl.startsWith('http') ? rawUrl : '${ApiConfig.baseUrl}$rawUrl';

    final rawGayHaiUrl = json['hinh_anh_gay_hai'] ?? '';
    final fullGayHaiUrl = rawGayHaiUrl.isEmpty
        ? ''
        : rawGayHaiUrl.startsWith('http')
            ? rawGayHaiUrl
            : '${ApiConfig.baseUrl}$rawGayHaiUrl';

    return Prediction(
      className: json['class_name'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      bbox: (json['bbox'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      tenViet: json['ten_viet'] ?? '',
      tenKhoaHoc: json['ten_khoa_hoc'] ?? '',
      gayHai: json['gay_hai'] ?? '',
      phongChong: json['phong_chong'] ?? '',

      hinhAnhUrl: fullUrl,
      hinhAnhGayHai: fullGayHaiUrl,
    );
  }

  /// Confidence as percentage string
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';
}

