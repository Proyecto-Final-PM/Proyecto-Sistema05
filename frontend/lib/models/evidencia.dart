class Evidencia {
  final int id;
  final int solicitudId;
  final int usuarioId;
  final String url;
  final DateTime? fechaSubida;

  const Evidencia({
    required this.id,
    required this.solicitudId,
    required this.usuarioId,
    required this.url,
    this.fechaSubida,
  });

  factory Evidencia.fromJson(Map<String, dynamic> json) {
    return Evidencia(
      id: (json['id'] as num?)?.toInt() ?? 0,
      solicitudId: (json['solicitud_id'] as num?)?.toInt() ?? 0,
      usuarioId: (json['usuario_id'] as num?)?.toInt() ?? 0,
      url: json['url'] as String? ?? '',
      fechaSubida: json['fecha_subida'] != null
          ? DateTime.tryParse(json['fecha_subida'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'solicitud_id': solicitudId,
      'usuario_id': usuarioId,
      'url': url,
      if (fechaSubida != null) 'fecha_subida': fechaSubida!.toIso8601String(),
    };
  }
}