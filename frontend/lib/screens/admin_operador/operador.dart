import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../models/historial.dart';
import '../../models/solicitud.dart';
import '../../models/usuario.dart';
import '../../services/api_service.dart';
import '../../services/operador.dart';

class AdminOperadorScreen extends StatefulWidget {
  final Usuario? usuarioActual;

  const AdminOperadorScreen({super.key, this.usuarioActual});

  @override
  State<AdminOperadorScreen> createState() => _AdminOperadorScreenState();
}

class _AdminOperadorScreenState extends State<AdminOperadorScreen> {
  final OperadorService _operadorService = OperadorService();
  final TextEditingController _busquedaCtrl = TextEditingController();

  final Map<int, String> _categorias = const {
    1: 'PET y Plásticos',
    2: 'Cartón y Papel',
    3: 'Aluminio y Metales',
    4: 'Vidrio',
  };

  List<Solicitud> _solicitudes = [];
  List<Historial> _historialSeleccionado = [];
  Solicitud? _solicitudSeleccionada;

  EstadoSolicitud? _filtroEstado;
  int? _filtroCategoria;
  bool _cargando = false;
  bool _cargandoHistorial = false;
  bool _procesandoAccion = false;
  String? _errorMensaje;

  bool get _esOperador => widget.usuarioActual?.rol == RolUsuario.operador;

  @override
  void initState() {
    super.initState();
    if (_esOperador) {
      _cargarSolicitudes();
    }
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarSolicitudes() async {
    setState(() {
      _cargando = true;
      _errorMensaje = null;
    });

    try {
      final lista = await _operadorService.listarSolicitudesOperador(
        busqueda: _busquedaCtrl.text,
        estado: _filtroEstado,
        categoriaId: _filtroCategoria,
      );
      if (!mounted) return;

      Solicitud? seleccionadaActualizada;
      if (_solicitudSeleccionada != null) {
        for (final item in lista) {
          if (item.id == _solicitudSeleccionada!.id) {
            seleccionadaActualizada = item;
            break;
          }
        }
      }

      setState(() {
        _solicitudes = lista;
        _solicitudSeleccionada = seleccionadaActualizada;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMensaje = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMensaje = e.toString());
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _seleccionarSolicitud(Solicitud solicitud) async {
    setState(() {
      _solicitudSeleccionada = solicitud;
      _cargandoHistorial = true;
      _historialSeleccionado = [];
    });

    try {
      final items =
          await _operadorService.obtenerHistorialSolicitud(solicitud.id);
      if (!mounted) return;
      setState(() => _historialSeleccionado = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _historialSeleccionado = []);
    } finally {
      if (mounted) {
        setState(() => _cargandoHistorial = false);
      }
    }
  }

  EstadoSolicitud? _siguienteEstado(Solicitud s) {
    if (s.cancelada) return null;
    switch (s.estado) {
      case EstadoSolicitud.solicitada:
        return EstadoSolicitud.aceptada;
      case EstadoSolicitud.aceptada:
        return EstadoSolicitud.enRecoleccion;
      case EstadoSolicitud.enRecoleccion:
        return EstadoSolicitud.finalizada;
      case EstadoSolicitud.finalizada:
        return null;
    }
  }

  String _textoAccion(EstadoSolicitud siguiente) {
    switch (siguiente) {
      case EstadoSolicitud.aceptada:
        return 'Aceptar';
      case EstadoSolicitud.enRecoleccion:
        return 'Iniciar recolección';
      case EstadoSolicitud.finalizada:
        return 'Finalizar';
      case EstadoSolicitud.solicitada:
        return 'Solicitada';
    }
  }

  String _etiquetaEstado(EstadoSolicitud estado) {
    switch (estado) {
      case EstadoSolicitud.solicitada:
        return 'Solicitada';
      case EstadoSolicitud.aceptada:
        return 'Aceptada';
      case EstadoSolicitud.enRecoleccion:
        return 'En recolección';
      case EstadoSolicitud.finalizada:
        return 'Finalizada';
    }
  }

  String _etiquetaAccionHistorial(AccionHistorial accion) {
    switch (accion) {
      case AccionHistorial.creacion:
        return 'Creación';
      case AccionHistorial.modificacion:
        return 'Modificación';
      case AccionHistorial.cancelacion:
        return 'Cancelación';
      case AccionHistorial.cambioEstado:
        return 'Cambio de estado';
    }
  }

  String? _validarCantidad(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Ingresa la cantidad recolectada en kg.';
    }
    final limpio = raw.trim().replaceAll(',', '.');
    final regexDosDecimales = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!regexDosDecimales.hasMatch(limpio)) {
      return 'Usa un número válido con máximo 2 decimales.';
    }
    final valor = double.tryParse(limpio);
    if (valor == null || valor <= 0) {
      return 'La cantidad debe ser mayor a 0.';
    }
    if (valor > 99999999.99) {
      return 'La cantidad no puede superar 99,999,999.99 kg.';
    }
    return null;
  }

  Future<double?> _mostrarDialogoFinalizar(Solicitud solicitud) async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<double>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Finalizar solicitud #${solicitud.id}'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cantidad recolectada (kg)',
                hintText: 'Ej. 12.50',
              ),
              validator: _validarCantidad,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final limpio = ctrl.text.trim().replaceAll(',', '.');
                  Navigator.pop(ctx, double.parse(limpio));
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _avanzarEstado(Solicitud solicitud) async {
    final siguiente = _siguienteEstado(solicitud);
    if (siguiente == null || _procesandoAccion) return;

    double? cantidadKg;
    if (siguiente == EstadoSolicitud.finalizada) {
      cantidadKg = await _mostrarDialogoFinalizar(solicitud);
      if (cantidadKg == null || !mounted) return;
    }

    setState(() => _procesandoAccion = true);
    try {
      await _operadorService.cambiarEstadoSolicitud(
        solicitudId: solicitud.id,
        nuevoEstado: siguiente,
        cantidadRecolectada: cantidadKg,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Solicitud #${solicitud.id} actualizada a ${_etiquetaEstado(siguiente)}.',
          ),
        ),
      );

      await _cargarSolicitudes();
      if (_solicitudSeleccionada?.id == solicitud.id) {
        await _seleccionarSolicitud(solicitud);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      final prefix = e.statusCode != null ? 'Error ${e.statusCode}: ' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$prefix${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _procesandoAccion = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_esOperador) {
      return Scaffold(
        appBar: AppBar(title: const Text('Administración de Operador')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Esta sección está disponible únicamente para cuentas con rol de operador.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración y Seguimiento'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargando ? null : _cargarSolicitudes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _busquedaCtrl,
              decoration: InputDecoration(
                labelText: 'Buscar por descripción o dirección',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busquedaCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _busquedaCtrl.clear();
                          _cargarSolicitudes();
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _cargarSolicitudes(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<EstadoSolicitud?>(
                    value: _filtroEstado,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: [
                      const DropdownMenuItem<EstadoSolicitud?>(
                        value: null,
                        child: Text('Todos'),
                      ),
                      ...EstadoSolicitud.values.map(
                        (est) => DropdownMenuItem<EstadoSolicitud?>(
                          value: est,
                          child: Text(_etiquetaEstado(est)),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => _filtroEstado = val);
                      _cargarSolicitudes();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    value: _filtroCategoria,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ..._categorias.entries.map(
                        (entry) => DropdownMenuItem<int?>(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => _filtroCategoria = val);
                      _cargarSolicitudes();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_errorMensaje != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMensaje!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _solicitudes.isEmpty
                      ? const Center(
                          child: Text('No hay solicitudes para mostrar.'),
                        )
                      : ListView.separated(
                          itemCount: _solicitudes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final s = _solicitudes[index];
                            final siguiente = _siguienteEstado(s);
                            final categoriaNombre =
                                _categorias[s.categoriaId] ??
                                    'Categoría #${s.categoriaId}';

                            return Card(
                              child: ListTile(
                                title: Text(
                                  '#${s.id} · $categoriaNombre (${_etiquetaEstado(s.estado)})',
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.descripcion),
                                    Text(s.direccion),
                                    if (s.cantidadRecolectada != null)
                                      Text(
                                        'Recolectado: ${s.cantidadRecolectada} kg',
                                      ),
                                  ],
                                ),
                                isThreeLine: true,
                                onTap: () => _seleccionarSolicitud(s),
                                trailing: siguiente != null
                                    ? FilledButton(
                                        onPressed: _procesandoAccion
                                            ? null
                                            : () => _avanzarEstado(s),
                                        child: Text(_textoAccion(siguiente)),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
            ),
            if (_solicitudSeleccionada != null) ...[
              const Divider(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Historial de solicitud #${_solicitudSeleccionada!.id}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: _cargandoHistorial
                    ? const Center(child: CircularProgressIndicator())
                    : _historialSeleccionado.isEmpty
                        ? const Center(
                            child: Text('Sin registros en el historial.'),
                          )
                        : ListView.builder(
                            itemCount: _historialSeleccionado.length,
                            itemBuilder: (context, idx) {
                              final h = _historialSeleccionado[idx];
                              return ListTile(
                                dense: true,
                                title: Text(_etiquetaAccionHistorial(h.accion)),
                                subtitle: Text(
                                  '${h.estadoAnterior != null ? _etiquetaEstado(h.estadoAnterior!) : '—'} → ${h.estadoNuevo != null ? _etiquetaEstado(h.estadoNuevo!) : '—'}',
                                ),
                              );
                            },
                          ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}