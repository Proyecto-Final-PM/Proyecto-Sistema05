import '../core/api_config.dart';
import '../models/categoria.dart';
import '../models/evidencia.dart';
import '../models/solicitud.dart';
import 'api_service.dart';
import '../models/historial.dart';

class SolicitudService {
  final ApiService _apiService = ApiService();

  // Listar solicitudes con búsqueda y filtros.
  Future<List<Solicitud>> listarSolicitudes({
    String? busqueda,
    String? estado,
    int? categoriaId,
    bool? cancelada,
  }) async {
    final Map<String, dynamic> parametros = {};

    if (busqueda != null && busqueda.trim().isNotEmpty) {
      parametros['q'] = busqueda.trim();
    }

    if (estado != null && estado.isNotEmpty) {
      parametros['estado'] = estado;
    }

    if (categoriaId != null) {
      parametros['categoria_id'] = categoriaId;
    }

    if (cancelada != null) {
      parametros['cancelada'] = cancelada;
    }

    final respuesta = await _apiService.get(
      '/solicitudes',
      queryParameters: parametros.isEmpty ? null : parametros,
    );

    if (respuesta is! List) {
      throw ApiException('La respuesta de solicitudes no es válida.');
    }

    return respuesta
        .map((json) => Solicitud.fromJson(
              Map<String, dynamic>.from(json),
            ))
        .toList();
  }

  // Obtener el detalle de una solicitud.
  Future<Solicitud> obtenerSolicitud(int id) async {
    final respuesta = await _apiService.get('/solicitudes/$id');

    if (respuesta is! Map) {
      throw ApiException('La respuesta de la solicitud no es válida.');
    }

    return Solicitud.fromJson(
      Map<String, dynamic>.from(respuesta),
    );
  }

  // Obtener el historial de una solicitud.
  Future<List<Historial>> listarHistorial(int solicitudId) async {
    final respuesta = await _apiService.get(
      '/solicitudes/$solicitudId/historial',
    );

    if (respuesta is! List) {
      throw ApiException('La respuesta del historial no es válida.');
    }

    return respuesta
        .map((json) => Historial.fromJson(
              Map<String, dynamic>.from(json),
            ))
        .toList();
  }

  // Cancelar una solicitud.
  Future<void> cancelarSolicitud(int id) async {
    await _apiService.patch('/solicitudes/$id/cancelar');
  }

  // Obtener categorías disponibles.
  Future<List<Categoria>> listarCategorias() async {
    final respuesta = await _apiService.get('/categorias');

    if (respuesta is! List) {
      throw ApiException('La respuesta de categorías no es válida.');
    }

    return respuesta
        .map((json) => Categoria.fromJson(
              Map<String, dynamic>.from(json),
            ))
        .toList();
  }

  // Obtener evidencias de una solicitud.
  Future<List<Evidencia>> listarEvidencias(int solicitudId) async {
    final respuesta = await _apiService.get(
      '/solicitudes/$solicitudId/evidencias',
    );

    if (respuesta is! List) {
      throw ApiException('La respuesta de evidencias no es válida.');
    }

    return respuesta
        .map((json) => Evidencia.fromJson(
              Map<String, dynamic>.from(json),
            ))
        .toList();
  }

  // Construir la URL completa de una evidencia.
  String obtenerUrlEvidencia(Evidencia evidencia) {
    final baseUri = Uri.parse(ApiConfig.baseUrl);

    return baseUri.resolve(evidencia.url).toString();
  }

  // Obtener headers para cargar imágenes protegidas.
  Future<Map<String, String>> obtenerHeadersEvidencia() async {
    final token = await _apiService.obtenerToken();

    if (token == null || token.isEmpty) {
      throw ApiException('No hay una sesión autenticada.');
    }

    return {
      'Authorization': 'Bearer $token',
    };
  }
}