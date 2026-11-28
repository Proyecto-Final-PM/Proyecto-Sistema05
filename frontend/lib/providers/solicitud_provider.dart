import 'dart:async';

import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../models/evidencia.dart';
import '../models/historial.dart';
import '../models/solicitud.dart';
import '../services/api_service.dart';
import '../services/solicitud_service.dart';

class SolicitudProvider extends ChangeNotifier {
  final SolicitudService _solicitudService = SolicitudService();

  // Listado
  List<Solicitud> _solicitudes = [];
  List<Solicitud> get solicitudes => _solicitudes;

  bool _cargandoSolicitudes = false;
  bool get cargandoSolicitudes => _cargandoSolicitudes;

  String? _errorSolicitudes;
  String? get errorSolicitudes => _errorSolicitudes;

  // Categorías
  List<Categoria> _categorias = [];
  List<Categoria> get categorias => _categorias;

  bool _cargandoCategorias = false;
  bool get cargandoCategorias => _cargandoCategorias;

  String? _errorCategorias;
  String? get errorCategorias => _errorCategorias;

  // Filtros
  String _busqueda = '';
  String get busqueda => _busqueda;

  String? _estadoFiltro;
  String? get estadoFiltro => _estadoFiltro;

  int? _categoriaFiltro;
  int? get categoriaFiltro => _categoriaFiltro;

  bool? _canceladaFiltro;
  bool? get canceladaFiltro => _canceladaFiltro;

  // Detalle
  Solicitud? _solicitudSeleccionada;
  Solicitud? get solicitudSeleccionada => _solicitudSeleccionada;

  bool _cargandoDetalle = false;
  bool get cargandoDetalle => _cargandoDetalle;

  String? _errorDetalle;
  String? get errorDetalle => _errorDetalle;

  // Evidencias
  List<Evidencia> _evidencias = [];
  List<Evidencia> get evidencias => _evidencias;

  // Historial
  List<Historial> _historial = [];
  List<Historial> get historial => _historial;

  bool _cargandoHistorial = false;
  bool get cargandoHistorial => _cargandoHistorial;

  String? _errorHistorial;
  String? get errorHistorial => _errorHistorial;

  bool _cargandoEvidencias = false;
  bool get cargandoEvidencias => _cargandoEvidencias;

  String? _errorEvidencias;
  String? get errorEvidencias => _errorEvidencias;

  // Cancelación
  bool _cancelando = false;
  bool get cancelando => _cancelando;

  String? _errorCancelacion;
  String? get errorCancelacion => _errorCancelacion;

  String _mensajeError(Object error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 400:
          return error.message.isNotEmpty
              ? error.message
              : 'Datos inválidos (400). Revisa los campos.';
        case 403:
          return error.message.isNotEmpty
              ? error.message
              : 'No tienes permisos para realizar esta acción (403).';
        case 404:
          return error.message.isNotEmpty
              ? error.message
              : 'La solicitud no fue encontrada (404).';
        case 409:
          return error.message.isNotEmpty
              ? error.message
              : 'Esta solicitud ya no se puede modificar por su estado actual (409).';
        default:
          return error.message;
      }
    }
    return error.toString();
  }

  // Listar solicitudes aplicando los filtros actuales.
  Future<void> cargarSolicitudes() async {
    _cargandoSolicitudes = true;
    _errorSolicitudes = null;
    notifyListeners();

    try {
      _solicitudes = await _solicitudService.listarSolicitudes(
        busqueda: _busqueda,
        estado: _estadoFiltro,
        categoriaId: _categoriaFiltro,
        cancelada: _canceladaFiltro,
      );
    } catch (e) {
      _errorSolicitudes = _mensajeError(e);
    } finally {
      _cargandoSolicitudes = false;
      notifyListeners();
    }
  }

  // Crear solicitud y refrescar el listado.
  Future<bool> crearSolicitud({
    required int categoriaId,
    required String descripcion,
    required String direccion,
    required double latitud,
    required double longitud,
  }) async {
    _errorSolicitudes = null;
    notifyListeners();

    try {
      await _solicitudService.crearSolicitud(
        categoriaId: categoriaId,
        descripcion: descripcion,
        direccion: direccion,
        latitud: latitud,
        longitud: longitud,
      );
      await cargarSolicitudes();
      return true;
    } catch (e) {
      _errorSolicitudes = _mensajeError(e);
      notifyListeners();
      return false;
    }
  }

  // Actualizar solicitud existente (PUT) y refrescar listado/detalle.
  Future<bool> actualizarSolicitud({
    required int id,
    required int categoriaId,
    required String descripcion,
    required String direccion,
    required double latitud,
    required double longitud,
  }) async {
    _errorSolicitudes = null;
    notifyListeners();

    try {
      await _solicitudService.actualizarSolicitud(
        id: id,
        categoriaId: categoriaId,
        descripcion: descripcion,
        direccion: direccion,
        latitud: latitud,
        longitud: longitud,
      );
      await cargarSolicitudes();
      if (_solicitudSeleccionada?.id == id) {
        await cargarDetalle(id);
      }
      return true;
    } catch (e) {
      _errorSolicitudes = _mensajeError(e);
      notifyListeners();
      return false;
    }
  }

  // Cambiar búsqueda.
  Future<void> cambiarBusqueda(String valor) async {
    _busqueda = valor;
    await cargarSolicitudes();
  }

  // Cambiar filtro de estado.
  Future<void> cambiarEstadoFiltro(String? estado) async {
    _estadoFiltro = estado;
    await cargarSolicitudes();
  }

  // Cambiar filtro de categoría.
  Future<void> cambiarCategoriaFiltro(int? categoriaId) async {
    _categoriaFiltro = categoriaId;
    await cargarSolicitudes();
  }

  // Cambiar filtro de cancelación.
  Future<void> cambiarCanceladaFiltro(bool? cancelada) async {
    _canceladaFiltro = cancelada;
    await cargarSolicitudes();
  }

  // Limpiar todos los filtros.
  Future<void> limpiarFiltros() async {
    _busqueda = '';
    _estadoFiltro = null;
    _categoriaFiltro = null;
    _canceladaFiltro = null;

    await cargarSolicitudes();
  }

  // Cargar categorías.
  Future<void> cargarCategorias() async {
    _cargandoCategorias = true;
    _errorCategorias = null;
    notifyListeners();

    try {
      _categorias = await _solicitudService.listarCategorias();
    } catch (e) {
      _errorCategorias = _mensajeError(e);
    } finally {
      _cargandoCategorias = false;
      notifyListeners();
    }
  }

  // Cargar detalle de una solicitud.
  Future<void> cargarDetalle(int id) async {
    _cargandoDetalle = true;
    _errorDetalle = null;
    _solicitudSeleccionada = null;
    notifyListeners();

    try {
      _solicitudSeleccionada =
          await _solicitudService.obtenerSolicitud(id);
    } catch (e) {
      _errorDetalle = _mensajeError(e);
    } finally {
      _cargandoDetalle = false;
      notifyListeners();
    }
  }

  // Cargar evidencias.
  Future<void> cargarEvidencias(int solicitudId) async {
    _cargandoEvidencias = true;
    _errorEvidencias = null;
    _evidencias = [];
    notifyListeners();

    try {
      _evidencias =
          await _solicitudService.listarEvidencias(solicitudId);
    } catch (e) {
      _errorEvidencias = _mensajeError(e);
    } finally {
      _cargandoEvidencias = false;
      notifyListeners();
    }
  }

  // Cargar historial de una solicitud.
  Future<void> cargarHistorial(int solicitudId) async {
    _cargandoHistorial = true;
    _errorHistorial = null;
    _historial = [];
    notifyListeners();

    try {
      _historial =
          await _solicitudService.listarHistorial(solicitudId);
    } catch (e) {
      _errorHistorial = _mensajeError(e);
    } finally {
      _cargandoHistorial = false;
      notifyListeners();
    }
  }

  // Cancelar solicitud.
  Future<bool> cancelarSolicitud(int id) async {
    _cancelando = true;
    _errorCancelacion = null;
    notifyListeners();

    try {
      await _solicitudService.cancelarSolicitud(id);

      // Actualizar el listado después de cancelar.
      await cargarSolicitudes();

      // Actualizar detalle e historial si corresponde.
      if (_solicitudSeleccionada?.id == id) {
        await cargarDetalle(id);
        await cargarHistorial(id);
      }

      return true;
    } catch (e) {
      _errorCancelacion = _mensajeError(e);
      return false;
    } finally {
      _cancelando = false;
      notifyListeners();
    }
  }

  // Obtener URL de una evidencia.
  String obtenerUrlEvidencia(Evidencia evidencia) {
    return _solicitudService.obtenerUrlEvidencia(evidencia);
  }

  // Obtener headers de autenticación para imágenes.
  Future<Map<String, String>> obtenerHeadersEvidencia() {
    return _solicitudService.obtenerHeadersEvidencia();
  }

  // Limpiar detalle al salir de la pantalla.
  void limpiarDetalle() {
    _solicitudSeleccionada = null;
    _evidencias = [];
    _errorDetalle = null;
    _errorEvidencias = null;
    _historial = [];
    _errorHistorial = null;
    _cargandoHistorial = false;
    notifyListeners();
  }
}