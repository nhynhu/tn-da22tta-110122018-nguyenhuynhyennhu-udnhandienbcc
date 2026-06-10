class ApiConfig {
  // Đổi IP này thành IP máy tính chạy Flask server
  // - Android Emulator: 10.0.2.2
  // - Điện thoại thật cùng WiFi: IP LAN của máy (vd: 192.168.1.100)
  static const String baseUrl = 'http://192.168.1.70:5000';

  static const String predictEndpoint = '/api/predict';
  static const String speciesEndpoint = '/api/species';

  static const String feedbackEndpoint = '/api/feedback';

  static String get predictUrl => '$baseUrl$predictEndpoint';
  static String get speciesUrl => '$baseUrl$speciesEndpoint';

  static String get feedbackUrl => '$baseUrl$feedbackEndpoint';

  static String speciesDetailUrl(String className) =>
      '$baseUrl$speciesEndpoint/$className';
}
