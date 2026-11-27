
import 'api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  // Inicio de sesión mediante el backend.
  Future<Map<String, dynamic>> login({
    required String correo,
    required String password,
  }) async {
    final respuesta = await _apiService.post(
      '/auth/login',
      data: {
        'correo': correo.trim().toLowerCase(),
        'password': password,
      },
    );

    return Map<String, dynamic>.from(respuesta);
  }

  // Registro de usuario mediante el backend.
  Future<Map<String, dynamic>> registro({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    final respuesta = await _apiService.post(
      '/auth/registro',
      data: {
        'nombre': nombre.trim(),
        'correo': correo.trim().toLowerCase(),
        'password': password,
      },
    );

    return Map<String, dynamic>.from(respuesta);
  }
}
