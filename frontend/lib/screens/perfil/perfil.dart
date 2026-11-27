import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;
    final themeProvider = context.watch<ThemeProvider>();

    if (usuario == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 20),

              CircleAvatar(
                radius: 45,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                usuario.nombre,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 8),

              Center(
                child: Chip(
                  avatar: Icon(
                    usuario.rol == RolUsuario.operador
                        ? Icons.admin_panel_settings
                        : Icons.person_outline,
                  ),
                  label: Text(usuario.rol.etiquetaVisible),
                ),
              ),

              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text('Nombre'),
                        subtitle: Text(usuario.nombre),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Correo electrónico'),
                        subtitle: Text(usuario.correo),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Tipo de usuario'),
                        subtitle: Text(usuario.rol.etiquetaVisible),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  title: const Text('Tema oscuro'),
                  subtitle: Text(
                    themeProvider.isDarkMode
                        ? 'Modo oscuro activado'
                        : 'Modo claro activado',
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.cambiarTema(value);
                  },
                ),
              ),

              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.principal,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home_outlined),
                label: const Text('Volver a principal'),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();

                  if (!context.mounted) return;

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}