import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';

class PrincipalScreen extends StatelessWidget {
  const PrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;

    final botones = <(String, String)>[
      ('Ir a Listado', AppRoutes.listado),
      ('Nueva Solicitud (Formulario)', AppRoutes.formulario),
      ('Perfil', AppRoutes.perfil),
    ];

    if (usuario?.rol == RolUsuario.operador) {
      botones.add(('Admin y seguimiento', AppRoutes.adminOperador));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla Principal'),
      ),
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
                    onPressed: () => Navigator.pushNamed(
                      context,
                      item.$2,
                      arguments: usuario,
                    ),
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
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}