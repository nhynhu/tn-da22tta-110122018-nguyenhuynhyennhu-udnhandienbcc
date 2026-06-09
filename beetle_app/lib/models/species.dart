import '../config/api_config.dart';

class Species {
  final int id;
  final String className;
  final String tenViet;
  final String tenKhoaHoc;
  final String ho;
  final String kichThuoc;
  final String mauSac;
  final String moiTruong;
  final String gayHai;
  final String phongChong;
  final String mucDoNguyHiem;
  final String hinhAnhUrl;

  Species({
    required this.id,
    required this.className,
    required this.tenViet,
    required this.tenKhoaHoc,
    required this.ho,
    required this.kichThuoc,
    required this.mauSac,
    required this.moiTruong,
    required this.gayHai,
    required this.phongChong,
    required this.mucDoNguyHiem,
    required this.hinhAnhUrl,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['hinh_anh_url'] ?? '';
    // Nếu là relative path (bắt đầu bằng /), thêm baseUrl phía trước
    final fullUrl = rawUrl.startsWith('http') ? rawUrl : '${ApiConfig.baseUrl}$rawUrl';

    return Species(
      id: json['id'] ?? 0,
      className: json['class_name'] ?? '',
      tenViet: json['ten_viet'] ?? '',
      tenKhoaHoc: json['ten_khoa_hoc'] ?? '',
      ho: json['ho'] ?? '',
      kichThuoc: json['kich_thuoc'] ?? '',
      mauSac: json['mau_sac'] ?? '',
      moiTruong: json['moi_truong'] ?? '',
      gayHai: json['gay_hai'] ?? '',
      phongChong: json['phong_chong'] ?? '',
      mucDoNguyHiem: json['muc_do_nguy_hiem'] ?? '',
      hinhAnhUrl: fullUrl,
    );
  }
}

