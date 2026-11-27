import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../providers/auth_provider.dart';

class PrincipalScreen extends StatelessWidget {
  const PrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final botones = [
      ('Ir a Listado', AppRoutes.listado),
      ('Nueva Solicitud (Formulario)', AppRoutes.formulario),
      ('Administración', AppRoutes.administracion),
      ('Perfil', AppRoutes.perfil),
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
              children: [
                ...botones.map(
                  (item) => ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, item.$2),
                    child: Text(item.$1),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();

                    if (!context.mounted) return;

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                  child: const Text('Cerrar sesión (Login)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
