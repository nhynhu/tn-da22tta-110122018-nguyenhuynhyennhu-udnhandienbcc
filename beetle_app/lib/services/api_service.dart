import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../config/api_config.dart';
import '../models/prediction.dart';
import '../models/species.dart';
import '../models/history.dart';

class ApiService {
  /// Gửi ảnh lên server để nhận diện bọ cánh cứng
  static Future<List<Prediction>> predictImage(
      File imageFile, String deviceId) async {
    try {
      final uri = Uri.parse(ApiConfig.predictUrl);
      final request = http.MultipartRequest('POST', uri);

      // Detect MIME type
      final mimeType =
          lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final mimeTypeSplit = mimeType.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType(mimeTypeSplit[0], mimeTypeSplit[1]),
        ),
      );
      request.fields['device_id'] = deviceId;

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final predictions = (data['predictions'] as List)
              .map((p) => Prediction.fromJson(p))
              .toList();
          return predictions;
        } else {
          throw Exception(data['message'] ?? 'Nhận diện thất bại');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến server. Kiểm tra kết nối mạng.');
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy danh sách tất cả loài
  static Future<List<Species>> getAllSpecies() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.speciesUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((s) => Species.fromJson(s)).toList();
      } else {
        throw Exception('Lỗi khi tải danh sách loài');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến server');
    }
  }

  /// Lấy chi tiết 1 loài
  static Future<Species> getSpeciesDetail(String className) async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.speciesDetailUrl(className)))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return Species.fromJson(json.decode(response.body));
      } else {
        throw Exception('Không tìm thấy loài');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến server');
    }
  }

  /// Lấy lịch sử nhận diện
  static Future<List<DetectionHistoryItem>> getHistory({
    String? deviceId,
    int limit = 20,
  }) async {
    try {
      final params = <String, String>{'limit': limit.toString()};
      if (deviceId != null) params['device_id'] = deviceId;

      final uri =
          Uri.parse(ApiConfig.historyUrl).replace(queryParameters: params);
      final response =
          await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((h) => DetectionHistoryItem.fromJson(h)).toList();
      } else {
        throw Exception('Lỗi khi tải lịch sử');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến server');
    }
  }

  /// Gửi phản hồi khi nhận diện sai
  static Future<bool> sendFeedback({
    required String deviceId,
    required String predictedClass,
    required String correctClass,
    String ghiChu = '',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.feedbackUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'device_id': deviceId,
              'predicted_class': predictedClass,
              'correct_class': correctClass,
              'ghi_chu': ghiChu,
            }),
          )
          .timeout(const Duration(seconds: 15));

      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Xóa 1 mục lịch sử nhận diện
  static Future<void> deleteHistoryItem(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('${ApiConfig.historyUrl}/$id'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Xóa mục lịch sử thất bại');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến server. Kiểm tra kết nối mạng.');
    } catch (e) {
      rethrow;
    }
  }

  /// Xóa toàn bộ lịch sử của thiết bị
  static Future<void> clearHistory(String deviceId) async {
    try {
      final uri = Uri.parse(ApiConfig.historyUrl).replace(
        queryParameters: {'device_id': deviceId},
      );
      final response = await http.delete(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Xóa toàn bộ lịch sử thất bại');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến server. Kiểm tra kết nối mạng.');
    } catch (e) {
      rethrow;
    }
  }
}
