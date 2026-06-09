import '../config/api_config.dart';

class Prediction {
  final String className;
  final double confidence;
  final List<double> bbox;
  final String tenViet;
  final String tenKhoaHoc;
  final String gayHai;
  final String phongChong;
  final String mucDoNguyHiem;
  final String hinhAnhUrl;

  Prediction({
    required this.className,
    required this.confidence,
    required this.bbox,
    required this.tenViet,
    required this.tenKhoaHoc,
    required this.gayHai,
    required this.phongChong,
    required this.mucDoNguyHiem,
    required this.hinhAnhUrl,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['hinh_anh_url'] ?? '';
    final fullUrl = rawUrl.startsWith('http') ? rawUrl : '${ApiConfig.baseUrl}$rawUrl';

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
      mucDoNguyHiem: json['muc_do_nguy_hiem'] ?? '',
      hinhAnhUrl: fullUrl,
    );
  }

  /// Confidence as percentage string
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';
}

