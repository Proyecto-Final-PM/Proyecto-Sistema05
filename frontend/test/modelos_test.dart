import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/categoria.dart';
import 'package:frontend/models/enums.dart';
import 'package:frontend/models/evidencia.dart';
import 'package:frontend/models/historial.dart';
import 'package:frontend/models/solicitud.dart';
import 'package:frontend/models/usuario.dart';

void main() {
  test('Parseo y serializacion de modelos segun contrato', () {
    final usuario = Usuario.fromJson({
      'id': 1,
      'nombre': 'Ana López',
      'correo': 'ana@example.com',
      'rol': 'usuario',
    });
    expect(usuario.rol, RolUsuario.usuario);
    expect(usuario.toJson()['correo'], 'ana@example.com');

    final categoria = Categoria.fromJson({'id': 1, 'nombre': 'Plástico'});
    expect(categoria.nombre, 'Plástico');

    final solicitud = Solicitud.fromJson({
      'id': 1,
      'usuario_id': 3,
      'categoria_id': 2,
      'descripcion': 'Cajas de cartón y hojas usadas',
      'direccion': 'Av. Universidad 100',
      'latitud': 21.9123456,
      'longitud': -102.3123456,
      'estado': 'solicitada',
      'cancelada': false,
      'cantidad_recolectada': null,
      'fecha_creacion': '2026-11-20T15:30:00Z',
    });
    expect(solicitud.estado, EstadoSolicitud.solicitada);
    expect(solicitud.toJson()['estado'], 'solicitada');

    final evidencia = Evidencia.fromJson({
      'id': 1,
      'solicitud_id': 5,
      'usuario_id': 3,
      'url': '/api/evidencias/1/archivo',
      'fecha_subida': '2026-11-20T15:35:00Z',
    });
    expect(evidencia.url, '/api/evidencias/1/archivo');

    final historial = Historial.fromJson({
      'id': 1,
      'solicitud_id': 5,
      'usuario_id': 2,
      'accion': 'cambio_estado',
      'estado_anterior': 'solicitada',
      'estado_nuevo': 'aceptada',
      'fecha_cambio': '2026-11-20T16:30:00Z',
    });
    expect(historial.accion, AccionHistorial.cambioEstado);
    expect(historial.estadoNuevo, EstadoSolicitud.aceptada);
  });
}