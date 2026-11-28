import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/evidencia.dart';
import '../../models/enums.dart';
import '../../providers/solicitud_provider.dart';

class DetalleScreen extends StatefulWidget {
  const DetalleScreen({super.key});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  int? _solicitudId;
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_iniciado) return;
    _iniciado = true;

    final argumento = ModalRoute.of(context)?.settings.arguments;

    if (argumento is int) {
      _solicitudId = argumento;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final provider = context.read<SolicitudProvider>();

        provider.cargarDetalle(argumento);
        provider.cargarEvidencias(argumento);
        provider.cargarHistorial(argumento);

        if (provider.categorias.isEmpty) {
          provider.cargarCategorias();
        }
      });
    }
  }

  String _nombreCategoria(
    SolicitudProvider provider,
    int categoriaId,
  ) {
    for (final categoria in provider.categorias) {
      if (categoria.id == categoriaId) {
        return categoria.nombre;
      }
    }

    return 'Categoría #$categoriaId';
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'No disponible';

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year;

    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio $hora:$minuto';
  }

  Color _colorEstado(EstadoSolicitud estado) {
    switch (estado) {
      case EstadoSolicitud.solicitada:
        return Colors.orange;
      case EstadoSolicitud.aceptada:
        return Colors.blue;
      case EstadoSolicitud.enRecoleccion:
        return Colors.deepPurple;
      case EstadoSolicitud.finalizada:
        return Colors.green;
    }
  }

  String _etiquetaAccion(AccionHistorial accion) {
    switch (accion) {
      case AccionHistorial.creacion:
        return 'Solicitud creada';
      case AccionHistorial.modificacion:
        return 'Solicitud modificada';
      case AccionHistorial.cambioEstado:
        return 'Cambio de estado';
      case AccionHistorial.cancelacion:
        return 'Solicitud cancelada';
    }
  }

  Future<void> _confirmarCancelacion(
    BuildContext context,
    SolicitudProvider provider,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar solicitud'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta solicitud?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancelar solicitud'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final resultado = await provider.cancelarSolicitud(_solicitudId!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resultado
              ? 'Solicitud cancelada correctamente.'
              : provider.errorCancelacion ?? 'No se pudo cancelar la solicitud.',
        ),
      ),
    );
  }

  Widget _dato(String titulo, String valor, {IconData? icono}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 21, color: Colors.grey.shade700),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor.isEmpty ? 'No disponible' : valor,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirEvidencias(
    SolicitudProvider provider,
  ) {
    if (provider.cargandoEvidencias) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.errorEvidencias != null) {
      return Text(
        'No se pudieron cargar las evidencias: ${provider.errorEvidencias}',
        style: const TextStyle(color: Colors.red),
      );
    }

    if (provider.evidencias.isEmpty) {
      return const Text('Esta solicitud no tiene evidencias adjuntas.');
    }

    return FutureBuilder<Map<String, String>>(
      future: provider.obtenerHeadersEvidencia(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Text(
            'No se pudieron obtener las credenciales para mostrar las imágenes.',
            style: TextStyle(color: Colors.red),
          );
        }

        final headers = snapshot.data!;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: provider.evidencias.map((Evidencia evidencia) {
            final url = provider.obtenerUrlEvidencia(evidencia);

            return SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      headers: headers,
                      width: 220,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 220,
                          height: 160,
                          color: Colors.grey.shade200,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: 36),
                              SizedBox(height: 8),
                              Text('No se pudo cargar la imagen'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Evidencia #${evidencia.id}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _formatearFecha(evidencia.fechaSubida),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _construirHistorial(SolicitudProvider provider) {
    if (provider.cargandoHistorial) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.errorHistorial != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No se pudo cargar el historial: ${provider.errorHistorial}',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => provider.cargarHistorial(_solicitudId!),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      );
    }

    if (provider.historial.isEmpty) {
      return const Text(
        'Esta solicitud todavía no tiene movimientos registrados.',
      );
    }

    return Column(
      children: provider.historial.map((movimiento) {
        final estadoAnterior = movimiento.estadoAnterior;
        final estadoNuevo = movimiento.estadoNuevo;

        final hayCambioEstado = estadoAnterior != null &&
            estadoNuevo != null &&
            estadoAnterior != estadoNuevo;

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: Icon(
                  Icons.history,
                  color: Colors.blue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _etiquetaAccion(movimiento.accion),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (hayCambioEstado) ...[
                      const SizedBox(height: 5),
                      Text(
                        '${estadoAnterior.etiquetaVisible} → '
                        '${estadoNuevo.etiquetaVisible}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      _formatearFecha(movimiento.fechaCambio),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_solicitudId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de solicitud')),
        body: const Center(
          child: Text('No se recibió un ID de solicitud válido.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitud #$_solicitudId'),
      ),
      body: Consumer<SolicitudProvider>(
        builder: (context, provider, child) {
          if (provider.cargandoDetalle &&
              provider.solicitudSeleccionada == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorDetalle != null &&
              provider.solicitudSeleccionada == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No se pudo cargar la solicitud:\n${provider.errorDetalle}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        provider.cargarDetalle(_solicitudId!);
                        provider.cargarEvidencias(_solicitudId!);
                        provider.cargarHistorial(_solicitudId!);
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final solicitud = provider.solicitudSeleccionada;

          if (solicitud == null || solicitud.id != _solicitudId) {
            return const Center(
              child: Text('No se encontró la solicitud.'),
            );
          }

          final puedeCancelar =
              solicitud.estado == EstadoSolicitud.solicitada &&
              !solicitud.cancelada;

          final colorEstado = _colorEstado(solicitud.estado);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Información general',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(
                                  solicitud.cancelada
                                      ? 'Cancelada'
                                      : solicitud.estado.etiquetaVisible,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: solicitud.cancelada
                                    ? Colors.red
                                    : colorEstado,
                              ),
                            ],
                          ),
                          const Divider(height: 28),
                          _dato(
                            'Número de solicitud',
                            '#${solicitud.id}',
                            icono: Icons.confirmation_number_outlined,
                          ),
                          _dato(
                            'Categoría',
                            _nombreCategoria(
                              provider,
                              solicitud.categoriaId,
                            ),
                            icono: Icons.category_outlined,
                          ),
                          _dato(
                            'Descripción',
                            solicitud.descripcion,
                            icono: Icons.description_outlined,
                          ),
                          _dato(
                            'Dirección',
                            solicitud.direccion,
                            icono: Icons.location_on_outlined,
                          ),
                          _dato(
                            'Fecha de creación',
                            _formatearFecha(solicitud.fechaCreacion),
                            icono: Icons.calendar_today_outlined,
                          ),
                          _dato(
                            'Cantidad recolectada',
                            solicitud.cantidadRecolectada == null
                                ? 'Sin registrar'
                                : '${solicitud.cantidadRecolectada}',
                            icono: Icons.scale_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Evidencias',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 28),
                          _construirEvidencias(provider),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Historial de movimientos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 28),
                          _construirHistorial(provider),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (puedeCancelar)
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: provider.cancelando
                            ? null
                            : () => _confirmarCancelacion(
                                  context,
                                  provider,
                                ),
                        icon: provider.cancelando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.cancel_outlined),
                        label: Text(
                          provider.cancelando
                              ? 'Cancelando...'
                              : 'Cancelar solicitud',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver al listado'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
