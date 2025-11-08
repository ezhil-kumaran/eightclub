import 'package:dio/dio.dart';
import '../models/experience.dart';

class ApiService {
  static const String baseUrl = 'https://staging.chamberofsecrets.8club.co/v1';

  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  Future<ExperienceResponse> getExperiences() async {
    try {
      final response = await _dio.get(
        '/experiences',
        queryParameters: {'active': true},
      );

      if (response.statusCode == 200) {
        return ExperienceResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load experiences');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
