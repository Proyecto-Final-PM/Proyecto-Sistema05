import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final ApiService _apiService = ApiService();

  Usuario? _usuario;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;

  Usuario? get usuario => _usuario;
  bool get isAuthenticated => _usuario != null;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;

  // Recuperar la sesión al iniciar la aplicación.
  Future<void> inicializarSesion() async {
    try {
      final token = await _apiService.obtenerToken();

      if (token == null || token.isEmpty) {
        _usuario = null;
        return;
      }

      final respuesta = await _apiService.get('/auth/me');

      final datosUsuario = Map<String, dynamic>.from(respuesta);
      final usuario = Usuario.fromJson(datosUsuario);

      final preferences = await SharedPreferences.getInstance();

      await preferences.setString(
        'usuario',
        jsonEncode(usuario.toJson()),
      );

      _usuario = usuario;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _limpiarSesion();
      }
    } catch (e) {
      // Se conserva el token si ocurre un error inesperado.
      debugPrint('Error al validar la sesión: $e');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _limpiarSesion() async {
    await _apiService.eliminarToken();

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('usuario');

    _usuario = null;
  }

  // Iniciar sesión.
  Future<bool> login({required String correo, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final respuesta = await _authRepository.login(
        correo: correo,
        password: password,
      );

      final token = respuesta['token'] as String;

      final usuarioJson = respuesta['usuario'] as Map<String, dynamic>;

      final usuario = Usuario.fromJson(usuarioJson);

      await _apiService.guardarToken(token);

      final preferences = await SharedPreferences.getInstance();

      await preferences.setString('usuario', jsonEncode(usuario.toJson()));

      _usuario = usuario;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  // Registrar usuario.
  Future<bool> registro({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.registro(
        nombre: nombre,
        correo: correo,
        password: password,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  // Cerrar sesión.
  Future<void> logout() async {
    await _apiService.eliminarToken();

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('usuario');

    _usuario = null;
    _errorMessage = null;

    notifyListeners();
  }

  // Limpiar mensajes de error.
  void limpiarError() {
    _errorMessage = null;
    notifyListeners();
  }
}
