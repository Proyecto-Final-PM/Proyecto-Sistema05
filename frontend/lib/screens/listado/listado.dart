
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../models/solicitud.dart';
import '../../models/enums.dart';
import '../../providers/solicitud_provider.dart';

class ListadoScreen extends StatefulWidget {
  const ListadoScreen({super.key});

  @override
  State<ListadoScreen> createState() => _ListadoScreenState();
}

class _ListadoScreenState extends State<ListadoScreen> {
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<SolicitudProvider>();
      provider.cargarSolicitudes();
      provider.cargarCategorias();
    });
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.formulario);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva solicitud'),
      ),
      body: Consumer<SolicitudProvider>(
        builder: (context, provider, child) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _construirBusqueda(provider),
                    const SizedBox(height: 12),
                    _construirFiltros(provider),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _construirContenido(provider),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _construirBusqueda(SolicitudProvider provider) {
    return TextField(
      controller: _busquedaController,
      onChanged: provider.cambiarBusqueda,
      decoration: InputDecoration(
        hintText: 'Buscar solicitudes...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _busquedaController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _busquedaController.clear();
                  provider.cambiarBusqueda('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _construirFiltros(SolicitudProvider provider) {
    return Column(
      children: [
        DropdownButtonFormField<String?>(
          initialValue: provider.estadoFiltro,
          decoration: InputDecoration(
            labelText: 'Estado',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: const [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('Todos los estados'),
            ),
            DropdownMenuItem<String?>(
              value: 'solicitada',
              child: Text('Solicitada'),
            ),
            DropdownMenuItem<String?>(
              value: 'aceptada',
              child: Text('Aceptada'),
            ),
            DropdownMenuItem<String?>(
              value: 'en_recoleccion',
              child: Text('En recolección'),
            ),
            DropdownMenuItem<String?>(
              value: 'finalizada',
              child: Text('Finalizada'),
            ),
          ],
          onChanged: provider.cambiarEstadoFiltro,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int?>(
          initialValue: provider.categoriaFiltro,
          decoration: InputDecoration(
            labelText: 'Categoría',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Todas las categorías'),
            ),
            ...provider.categorias.map(
              (categoria) => DropdownMenuItem<int?>(
                value: categoria.id,
                child: Text(categoria.nombre),
              ),
            ),
          ],
          onChanged: provider.cambiarCategoriaFiltro,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              _busquedaController.clear();
              provider.limpiarFiltros();
            },
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('Limpiar filtros'),
          ),
        ),
      ],
    );
  }

  Widget _construirContenido(SolicitudProvider provider) {
    if (provider.cargandoSolicitudes && provider.solicitudes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorSolicitudes != null &&
        provider.solicitudes.isEmpty) {
      return _construirError(provider);
    }

    if (provider.solicitudes.isEmpty) {
      return _construirVacio();
    }

    return RefreshIndicator(
      onRefresh: provider.cargarSolicitudes,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 90),
        itemCount: provider.solicitudes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final solicitud = provider.solicitudes[index];

          return _construirTarjeta(solicitud, provider);
        },
      ),
    );
  }

  Widget _construirError(SolicitudProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          const Text(
            'No se pudieron cargar las solicitudes.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorSolicitudes!,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: provider.cargarSolicitudes,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _construirVacio() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay solicitudes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No se encontraron solicitudes con los filtros actuales.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _construirTarjeta(
    Solicitud solicitud,
    SolicitudProvider provider,
  ) {
    final categoria = provider.categorias.where(
      (c) => c.id == solicitud.categoriaId,
    );

    final nombreCategoria =
        categoria.isNotEmpty ? categoria.first.nombre : 'Categoría';

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.detalle,
            arguments: solicitud.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Solicitud #${solicitud.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _construirEstado(solicitud),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                nombreCategoria,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                solicitud.descripcion,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      solicitud.direccion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (solicitud.fechaCreacion != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 6),
                    Text(_formatearFecha(solicitud.fechaCreacion!)),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.detalle,
                      arguments: solicitud.id,
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Ver detalle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirEstado(Solicitud solicitud) {
    final color = _colorEstado(solicitud);

    final texto = solicitud.cancelada
        ? 'Cancelada'
        : solicitud.estado.etiquetaVisible;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _colorEstado(Solicitud solicitud) {
    if (solicitud.cancelada) {
      return Colors.red;
    }

    switch (solicitud.estado) {
      case EstadoSolicitud.solicitada:
        return Colors.orange;
      case EstadoSolicitud.aceptada:
        return Colors.blue;
      case EstadoSolicitud.enRecoleccion:
        return Colors.purple;
      case EstadoSolicitud.finalizada:
        return Colors.green;
    }
  }

  String _formatearFecha(DateTime fecha) {
    final fechaLocal = fecha.toLocal();

    final dia = fechaLocal.day.toString().padLeft(2, '0');
    final mes = fechaLocal.month.toString().padLeft(2, '0');
    final anio = fechaLocal.year;

    final hora = fechaLocal.hour.toString().padLeft(2, '0');
    final minuto = fechaLocal.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio $hora:$minuto';
  }
}
