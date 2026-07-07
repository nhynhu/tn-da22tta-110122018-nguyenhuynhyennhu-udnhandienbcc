import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../config/api_config.dart';
import '../models/prediction.dart';
import '../models/species.dart';

import '../models/video_result.dart';

class ApiService {
  /// Gửi ảnh lên server để nhận diện bọ cánh cứng
  static Future<List<Prediction>> predictImage(
    File imageFile,
    String deviceId,
  ) async {
    try {
      final uri = Uri.parse(ApiConfig.predictUrl);
      final request = http.MultipartRequest('POST', uri);

      // Detect MIME type
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
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



  /// Gửi cả video lên server, chờ xử lý, nhận về URL video đã vẽ khung.
  static Future<VideoDetectionResult> processVideo(
    File videoFile,
    String deviceId,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/predict_video');

    final request = http.MultipartRequest('POST', uri)
      ..fields['device_id'] = deviceId
      ..files.add(await http.MultipartFile.fromPath('video', videoFile.path));

    // Xử lý video lâu -> timeout dài
    final streamed = await request.send().timeout(const Duration(minutes: 10));
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 200) {
      throw Exception('Server trả về lỗi: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Xử lý video thất bại');
    }
    return VideoDetectionResult.fromJson(data);
  }
}
