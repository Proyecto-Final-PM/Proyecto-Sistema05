import 'enums.dart';

class Solicitud {
  final int id;
  final int usuarioId;
  final int categoriaId;
  final String descripcion;
  final String direccion;
  final double latitud;
  final double longitud;
  final EstadoSolicitud estado;
  final bool cancelada;
  final double? cantidadRecolectada;
  final DateTime? fechaCreacion;

  const Solicitud({
    required this.id,
    required this.usuarioId,
    required this.categoriaId,
    required this.descripcion,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.estado,
    required this.cancelada,
    this.cantidadRecolectada,
    this.fechaCreacion,
  });

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    return Solicitud(
      id: (json['id'] as num?)?.toInt() ?? 0,
      usuarioId: (json['usuario_id'] as num?)?.toInt() ?? 0,
      categoriaId: (json['categoria_id'] as num?)?.toInt() ?? 0,
      descripcion: json['descripcion'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      estado: EstadoSolicitud.fromJson(json['estado'] as String?),
      cancelada: json['cancelada'] as bool? ?? false,
      cantidadRecolectada: (json['cantidad_recolectada'] as num?)?.toDouble(),
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'categoria_id': categoriaId,
      'descripcion': descripcion,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'estado': estado.toJson(),
      'cancelada': cancelada,
      'cantidad_recolectada': cantidadRecolectada,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion!.toIso8601String(),
    };
  }
}