import 'package:flutter/material.dart';
import '../../core/app_routes.dart';

class PrincipalScreen extends StatelessWidget {
  const PrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final botones = [
      ('Ir a Listado', AppRoutes.listado),
      ('Nueva Solicitud (Formulario)', AppRoutes.formulario),
      ('Administración', AppRoutes.administracion),
      ('Perfil', AppRoutes.perfil),
      ('Cerrar sesión (Login)', AppRoutes.login),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Pantalla Principal')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: botones
                  .map(
                    (item) => ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, item.$2),
                      child: Text(item.$1),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}