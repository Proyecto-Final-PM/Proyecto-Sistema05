import 'package:flutter/material.dart';
import '../../core/app_routes.dart';
import '../../models/solicitud.dart';

class FormularioScreen extends StatefulWidget {
  final Solicitud? solicitudInicial;

  const FormularioScreen({super.key, this.solicitudInicial});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _latitudCtrl;
  late final TextEditingController _longitudCtrl;

  final List<Map<String, dynamic>> _categoriasEjemplo = [
    {'id': 1, 'nombre': 'PET y Plásticos'},
    {'id': 2, 'nombre': 'Cartón y Papel'},
    {'id': 3, 'nombre': 'Aluminio y Metales'},
    {'id': 4, 'nombre': 'Vidrio'},
  ];

  final List<String> _sugerenciasDescripcion = [
    'Botellas PET limpias y aplastadas en bolsa',
    'Cajas de cartón dobladas y secos de papel',
    'Latas de aluminio y envases metálicos limpios',
  ];

  int? _categoriaSeleccionadaId;
  bool _enviando = false;
  bool _hayErrorValidacion = false;

  bool get _esEdicion => widget.solicitudInicial != null;

  @override
  void initState() {
    super.initState();
    final inicial = widget.solicitudInicial;
    _descripcionCtrl = TextEditingController(text: inicial?.descripcion ?? '');
    _direccionCtrl = TextEditingController(text: inicial?.direccion ?? '');
    _latitudCtrl = TextEditingController(
      text: inicial != null ? inicial.latitud.toString() : '',
    );
    _longitudCtrl = TextEditingController(
      text: inicial != null ? inicial.longitud.toString() : '',
    );
    _categoriaSeleccionadaId =
        inicial?.categoriaId ?? (_categoriasEjemplo.first['id'] as int);

    _descripcionCtrl.addListener(_refrescarContador);
  }

  void _refrescarContador() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _descripcionCtrl.removeListener(_refrescarContador);
    _descripcionCtrl.dispose();
    _direccionCtrl.dispose();
    _latitudCtrl.dispose();
    _longitudCtrl.dispose();
    super.dispose();
  }

  IconData _iconoPorCategoria(int? id) {
    switch (id) {
      case 1:
        return Icons.water_drop_outlined;
      case 2:
        return Icons.inventory_2_outlined;
      case 3:
        return Icons.construction_outlined;
      case 4:
        return Icons.wine_bar_outlined;
      default:
        return Icons.recycling;
    }
  }

  String? _validarRequerido(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Revisa este campo: falta $campo';
    }
    return null;
  }

  String? _validarLatitud(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Revisa este campo: falta la latitud';
    }
    final numero = double.tryParse(valor.trim().replaceAll(',', '.'));
    if (numero == null) {
      return 'Valor inválido: escribe solo números (ej. 21.8818)';
    }
    if (numero < -90 || numero > 90) {
      return 'Número fuera de rango: debe ir de -90 a 90';
    }
    return null;
  }

  String? _validarLongitud(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Revisa este campo: falta la longitud';
    }
    final numero = double.tryParse(valor.trim().replaceAll(',', '.'));
    if (numero == null) {
      return 'Valor inválido: escribe solo números (ej. -102.2916)';
    }
    if (numero < -180 || numero > 180) {
      return 'Número fuera de rango: debe ir de -180 a 180';
    }
    return null;
  }

  void _llenarCoordenadasEjemplo() {
    setState(() {
      _latitudCtrl.text = '21.8818';
      _longitudCtrl.text = '-102.2916';
      _hayErrorValidacion = false;
    });
  }

  void _limpiarFormulario() {
    setState(() {
      _descripcionCtrl.clear();
      _direccionCtrl.clear();
      _latitudCtrl.clear();
      _longitudCtrl.clear();
      _categoriaSeleccionadaId = _categoriasEjemplo.first['id'] as int;
      _hayErrorValidacion = false;
    });
    _formKey.currentState?.reset();
  }

  Future<void> _guardarSolicitud() async {
    final esValido = _formKey.currentState!.validate();
    setState(() => _hayErrorValidacion = !esValido);

    if (!esValido) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isDark
              ? const Color(0xFF4A1919)
              : const Color(0xFFB3261E),
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB4AB)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Revisa los campos marcados en rojo antes de continuar.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _esEdicion
                      ? 'Solicitud actualizada (modo de prueba).'
                      : 'Solicitud registrada (modo de prueba).',
                ),
              ),
            ],
          ),
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.listado);
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  InputDecoration _estiloCampo({
    required BuildContext context,
    required String label,
    required IconData icono,
    String? hint,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final alertaColor = isDark ? const Color(0xFFFF7A7A) : scheme.error;
    final rellenoColor = isDark
        ? const Color(0xFF232C25)
        : scheme.surfaceContainerLowest;
    final bordeNormal = isDark
        ? const Color(0xFF3C4B40)
        : scheme.outlineVariant;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: rellenoColor,
      prefixIcon: Icon(icono, color: scheme.primary),
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(
        color: isDark ? const Color(0xFFC7D4CA) : scheme.onSurfaceVariant,
      ),
      hintStyle: TextStyle(
        color: isDark ? const Color(0xFF8A9B8F) : scheme.onSurfaceVariant,
      ),
      errorStyle: TextStyle(
        color: alertaColor,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: bordeNormal),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: alertaColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: alertaColor, width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _tituloSeccion({
    required BuildContext context,
    required IconData icono,
    required String titulo,
    Widget? accionDerecha,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icono, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        if (accionDerecha != null) accionDerecha,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final fondoPantalla = isDark
        ? const Color(0xFF0E1310)
        : scheme.surfaceContainerLowest;
    final tarjetaColor = isDark ? const Color(0xFF171E19) : scheme.surface;
    final bordeTarjeta = isDark
        ? const Color(0xFF2D3830)
        : scheme.outlineVariant;
    final divisorColor = isDark
        ? const Color(0xFF28332B)
        : scheme.outlineVariant.withValues(alpha: 0.6);
    final alertaColor = isDark ? const Color(0xFFFF7A7A) : scheme.error;
    final alertaFondo = isDark
        ? const Color(0xFF3A1818)
        : scheme.errorContainer;
    final badgeCirculo = isDark
        ? const Color(0xFF233829)
        : const Color(0xFFD9F2DF);

    final caracteresDesc = _descripcionCtrl.text.trim().length;

    return Scaffold(
      backgroundColor: fondoPantalla,
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Solicitud' : 'Formulario de Recolección'),
        actions: [
          IconButton(
            tooltip: 'Limpiar campos',
            onPressed: _limpiarFormulario,
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
            child: Column(
              children: [
                // Encabezado tipo badge similar a la estética de Mi perfil
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: badgeCirculo,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _esEdicion
                        ? Icons.edit_note_rounded
                        : Icons.recycling_rounded,
                    size: 38,
                    color: isDark
                        ? const Color(0xFF7CE096)
                        : const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _esEdicion
                      ? 'Editar Solicitud de Reciclaje'
                      : 'Formulario de Recolección',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                // Tarjeta principal dividida en secciones limpias
                Card(
                  color: tarjetaColor,
                  elevation: isDark ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: bordeTarjeta),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_hayErrorValidacion) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: alertaFondo,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: alertaColor.withValues(alpha: 0.7),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: alertaColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Revisa bien los campos: hay datos faltantes o valores inválidos.',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: alertaColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],

                          // Sección 1: Material y descripción
                          _tituloSeccion(
                            context: context,
                            icono: Icons.inventory_2_outlined,
                            titulo: 'Material y detalle',
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            value: _categoriaSeleccionadaId,
                            dropdownColor: isDark
                                ? const Color(0xFF202923)
                                : scheme.surface,
                            decoration: _estiloCampo(
                              context: context,
                              label: 'Categoría',
                              icono: _iconoPorCategoria(
                                _categoriaSeleccionadaId,
                              ),
                            ),
                            items: _categoriasEjemplo
                                .map(
                                  (cat) => DropdownMenuItem<int>(
                                    value: cat['id'] as int,
                                    child: Text(cat['nombre'] as String),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _categoriaSeleccionadaId = value);
                            },
                            validator: (value) => value == null
                                ? 'Revisa este campo: selecciona una categoría'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _descripcionCtrl,
                            maxLines: 3,
                            decoration: _estiloCampo(
                              context: context,
                              label: 'Descripción',
                              hint: 'Ej. Botellas de PET limpias en bolsas',
                              icono: Icons.description_outlined,
                              suffixIcon: _descripcionCtrl.text.isNotEmpty
                                  ? IconButton(
                                      tooltip: 'Borrar descripción',
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () {
                                        _descripcionCtrl.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                            validator: (v) =>
                                _validarRequerido(v, 'la descripción'),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tip rápido:',
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '$caracteresDesc caracteres',
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _sugerenciasDescripcion
                                .map(
                                  (texto) => ActionChip(
                                    avatar: Icon(
                                      Icons.auto_awesome,
                                      size: 15,
                                      color: scheme.primary,
                                    ),
                                    label: Text(
                                      texto,
                                      style: textTheme.labelSmall,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _descripcionCtrl.text = texto;
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Divider(color: divisorColor, height: 1),
                          ),

                          // Sección 2: Ubicación
                          _tituloSeccion(
                            context: context,
                            icono: Icons.pin_drop_outlined,
                            titulo: 'Ubicación de recolección',
                            accionDerecha: TextButton.icon(
                              onPressed: _llenarCoordenadasEjemplo,
                              icon: const Icon(Icons.gps_fixed, size: 16),
                              label: const Text('Ejemplo AGS'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _direccionCtrl,
                            decoration: _estiloCampo(
                              context: context,
                              label: 'Dirección',
                              hint: 'Calle, número, colonia',
                              icono: Icons.location_on_outlined,
                            ),
                            validator: (v) =>
                                _validarRequerido(v, 'la dirección'),
                          ),
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final esAncho = constraints.maxWidth >= 480;
                              final latField = TextFormField(
                                controller: _latitudCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                decoration: _estiloCampo(
                                  context: context,
                                  label: 'Latitud (-90 a 90)',
                                  hint: 'Ej. 21.8818',
                                  icono: Icons.my_location_outlined,
                                ),
                                validator: _validarLatitud,
                              );
                              final lngField = TextFormField(
                                controller: _longitudCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                decoration: _estiloCampo(
                                  context: context,
                                  label: 'Longitud (-180 a 180)',
                                  hint: 'Ej. -102.2916',
                                  icono: Icons.explore_outlined,
                                ),
                                validator: _validarLongitud,
                              );

                              if (esAncho) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: latField),
                                    const SizedBox(width: 12),
                                    Expanded(child: lngField),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  latField,
                                  const SizedBox(height: 14),
                                  lngField,
                                ],
                              );
                            },
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Divider(color: divisorColor, height: 1),
                          ),

                          // Sección 3: Evidencia fotográfica
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E2721)
                                  : scheme.surfaceContainerHighest.withValues(
                                      alpha: 0.45,
                                    ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: bordeTarjeta),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: scheme.primary.withValues(
                                      alpha: isDark ? 0.2 : 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    color: scheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Evidencia fotográfica',
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Disponible en la siguiente fase',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: null,
                                  icon: const Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Agregar foto'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Botones principales
                          SizedBox(
                            height: 48,
                            child: FilledButton.icon(
                              onPressed: _enviando ? null : _guardarSolicitud,
                              icon: Icon(
                                _enviando
                                    ? Icons.hourglass_top
                                    : (_esEdicion
                                          ? Icons.save_outlined
                                          : Icons.add_circle_outline),
                              ),
                              label: Text(
                                _enviando
                                    ? 'Guardando...'
                                    : (_esEdicion
                                          ? 'Guardar cambios'
                                          : 'Crear solicitud'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.listado,
                              ),
                              icon: const Icon(Icons.list_alt),
                              label: const Text('Ver Listado'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}