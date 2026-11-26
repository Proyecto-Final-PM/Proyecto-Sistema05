import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor para agregar automáticamente el token JWT.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final preferences = await SharedPreferences.getInstance();
          final token = preferences.getString('token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );
  }

  // GET
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // POST
  Future<dynamic> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);

      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // Guardar token
  Future<void> guardarToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('token', token);
  }

  // Recuperar token
  Future<String?> obtenerToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('token');
  }

  // Eliminar token
  Future<void> eliminarToken() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('token');
  }
}

// Manejo centralizado de errores
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('La conexión tardó demasiado. Intenta nuevamente.');

      case DioExceptionType.connectionError:
        return ApiException(
          'No se pudo conectar con el servidor. '
          'Verifica que el backend esté funcionando.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;

        final responseData = error.response?.data;

        if (responseData is Map && responseData['error'] != null) {
          return ApiException(responseData['error'].toString());
        }

        return ApiException('Error del servidor (código $statusCode).');

      case DioExceptionType.cancel:
        return ApiException('La solicitud fue cancelada.');

      default:
        return ApiException(
          'Ocurrió un error inesperado al comunicarse con el servidor.',
        );
    }
  }

  @override
  String toString() => message;
}
