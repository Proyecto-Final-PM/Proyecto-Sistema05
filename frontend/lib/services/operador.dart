import '../models/enums.dart';
import '../models/historial.dart';
import '../models/solicitud.dart';
import 'api_service.dart';

class OperadorService {
  final ApiService _apiService = ApiService();

  Future<List<Solicitud>> listarSolicitudesOperador({
    String? busqueda,
    EstadoSolicitud? estado,
    int? categoriaId,
  }) async {
    final Map<String, dynamic> params = {};
    if (busqueda != null && busqueda.trim().isNotEmpty) {
      params['q'] = busqueda.trim();
    }
    if (estado != null) {
      params['estado'] = estado.toJson();
    }
    if (categoriaId != null) {
      params['categoria_id'] = categoriaId;
    }

    final respuesta = await _apiService.get(
      '/solicitudes',
      queryParameters: params.isEmpty ? null : params,
    );

    if (respuesta is! List) {
      throw ApiException('La respuesta de solicitudes no es válida.');
    }

    return respuesta
        .map((e) => Solicitud.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> cambiarEstadoSolicitud({
    required int solicitudId,
    required EstadoSolicitud nuevoEstado,
    double? cantidadRecolectada,
  }) async {
    final Map<String, dynamic> body = {'estado': nuevoEstado.toJson()};
    if (cantidadRecolectada != null) {
      body['cantidad_recolectada'] = cantidadRecolectada;
    }

    await _apiService.patch('/solicitudes/$solicitudId/estado', data: body);
  }

  Future<List<Historial>> obtenerHistorialSolicitud(int solicitudId) async {
    final respuesta =
        await _apiService.get('/solicitudes/$solicitudId/historial');
    if (respuesta is! List) {
      throw ApiException('La respuesta del historial no es válida.');
    }

    return respuesta
        .map((e) => Historial.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}