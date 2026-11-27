import 'enums.dart';

class Historial {
  final int id;
  final int solicitudId;
  final int usuarioId;
  final AccionHistorial accion;
  final EstadoSolicitud? estadoAnterior;
  final EstadoSolicitud? estadoNuevo;
  final DateTime? fechaCambio;

  const Historial({
    required this.id,
    required this.solicitudId,
    required this.usuarioId,
    required this.accion,
    this.estadoAnterior,
    this.estadoNuevo,
    this.fechaCambio,
  });

  factory Historial.fromJson(Map<String, dynamic> json) {
    return Historial(
      id: (json['id'] as num?)?.toInt() ?? 0,
      solicitudId: (json['solicitud_id'] as num?)?.toInt() ?? 0,
      usuarioId: (json['usuario_id'] as num?)?.toInt() ?? 0,
      accion: AccionHistorial.fromJson(json['accion'] as String?),
      estadoAnterior: json['estado_anterior'] != null
          ? EstadoSolicitud.fromJson(json['estado_anterior'] as String?)
          : null,
      estadoNuevo: json['estado_nuevo'] != null
          ? EstadoSolicitud.fromJson(json['estado_nuevo'] as String?)
          : null,
      fechaCambio: json['fecha_cambio'] != null
          ? DateTime.tryParse(json['fecha_cambio'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'solicitud_id': solicitudId,
      'usuario_id': usuarioId,
      'accion': accion.toJson(),
      'estado_anterior': estadoAnterior?.toJson(),
      'estado_nuevo': estadoNuevo?.toJson(),
      if (fechaCambio != null) 'fecha_cambio': fechaCambio!.toIso8601String(),
    };
  }
}