import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiProvider {
  final Dio _dio = Dio();
  static final String? url = dotenv.env['BASE_URL'];

  ApiProvider() {
    if (url == null) {
      throw Exception('No BASE_URL defined');
    }
    _dio.options.baseUrl = url!;
    _dio.options.validateStatus = (_) => true;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 5);
  }

  Future<Response> getRequest({
    required String endpoint,
    dynamic headers,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: Options(headers: headers),
      );
      return response;
    } on DioException {
      throw Exception('An error occurred. Please try again later.');
    }
  }

  Future<Response> postRequest({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioException {
      throw Exception('An error occurred. Please try again later.');
    }
  }
}
