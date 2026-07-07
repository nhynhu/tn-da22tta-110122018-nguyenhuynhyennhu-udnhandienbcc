import 'package:flutter/foundation.dart';
import '../services/discovery_service.dart';

class ApiConfig {
  // Fallback IP nếu không tìm được server qua UDP discovery
  static const String _fallbackUrl = 'http://192.168.1.6:5000';

  // Base URL được cập nhật tự động qua UDP discovery
  static String _baseUrl = _fallbackUrl;

  /// Base URL hiện tại của server
  static String get baseUrl => _baseUrl;

  static const String predictEndpoint = '/api/predict';
  static const String speciesEndpoint = '/api/species';

  static String get predictUrl => '$_baseUrl$predictEndpoint';
  static String get speciesUrl => '$_baseUrl$speciesEndpoint';

  static String speciesDetailUrl(String className) =>
      '$_baseUrl$speciesEndpoint/$className';



  /// Tự động tìm server trên LAN qua UDP broadcast.
  /// Gọi hàm này 1 lần khi app khởi động.
  /// Trả về true nếu tìm được server, false nếu dùng fallback.
  static Future<bool> autoDiscover() async {
    final url = await DiscoveryService.discoverWithRetry(maxRetries: 2);
    if (url != null) {
      _baseUrl = url;
      debugPrint('[ApiConfig] Tự động tìm thấy server: $_baseUrl');
      return true;
    } else {
      _baseUrl = _fallbackUrl;
      debugPrint('[ApiConfig] Không tìm thấy server, dùng fallback: $_fallbackUrl');
      return false;
    }
  }

  /// Cập nhật lại IP (gọi khi đổi mạng WiFi)
  static Future<bool> refreshConnection() async {
    return await autoDiscover();
  }

  /// Set URL thủ công (nếu cần)
  static void setBaseUrl(String url) {
    _baseUrl = url;

  }
}
