import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Service tự động tìm Backend server trên mạng LAN thông qua UDP broadcast.
///
/// Cách hoạt động:
///   1. Gửi UDP broadcast "BEETLE_DISCOVER" tới port 5001 trên toàn mạng LAN
///   2. Backend nhận được → trả về JSON chứa IP + port
///   3. Flutter parse JSON → cập nhật baseUrl tự động
///
/// Không cần gõ IP thủ công mỗi khi đổi mạng WiFi.
class DiscoveryService {
  static const int _discoveryPort = 5001;
  static const String _discoveryMessage = 'BEETLE_DISCOVER';
  static const Duration _timeout = Duration(seconds: 3);

  /// Tìm server trên LAN, trả về base URL (vd: "http://192.168.1.64:5000")
  /// Trả về null nếu không tìm thấy.
  static Future<String?> discoverServer() async {
    RawDatagramSocket? socket;
    try {
      // Bind tới bất kỳ port nào còn trống
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      // Gửi broadcast tới 255.255.255.255:5001
      final data = utf8.encode(_discoveryMessage);
      socket.send(data, InternetAddress('255.255.255.255'), _discoveryPort);

      // Chờ phản hồi từ server
      final completer = Completer<String?>();

      // Timeout sau 3 giây
      final timer = Timer(_timeout, () {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });

      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket?.receive();
          if (datagram != null) {
            try {
              final response = utf8.decode(datagram.data);
              final json = jsonDecode(response) as Map<String, dynamic>;

              if (json['service'] == 'beetle_api' && json['url'] != null) {
                timer.cancel();
                if (!completer.isCompleted) {
                  completer.complete(json['url'] as String);
                }
              }
            } catch (_) {
              // Bỏ qua response không hợp lệ
            }
          }
        }
      });

      return await completer.future;
    } catch (e) {
      return null;
    } finally {
      socket?.close();
    }
  }

  /// Tìm server với retry (thử lại nếu lần đầu không tìm thấy).
  static Future<String?> discoverWithRetry({int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      final url = await discoverServer();
      if (url != null) return url;
      // Chờ 1 giây trước khi thử lại
      await Future.delayed(const Duration(seconds: 1));
    }
    return null;
  }
}
