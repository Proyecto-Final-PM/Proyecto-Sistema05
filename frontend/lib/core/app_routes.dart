import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../screens/admin_operador/operador.dart';
import '../screens/administracion/administracion.dart';
import '../screens/detalle/detalle.dart';
import '../screens/formulario/formulario.dart';
import '../screens/listado/listado.dart';
import '../screens/login/login.dart';
import '../screens/perfil/perfil.dart';
import '../screens/principal/principal.dart';
import '../screens/registro/registro.dart';

class AppRoutes {
  static const String login = '/login';
  static const String registro = '/registro';
  static const String principal = '/principal';
  static const String listado = '/listado';
  static const String detalle = '/detalle';
  static const String formulario = '/formulario';
  static const String administracion = '/administracion';
  static const String adminOperador = '/admin-operador';
  static const String perfil = '/perfil';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      registro: (context) => const RegistroScreen(),
      principal: (context) => const PrincipalScreen(),
      listado: (context) => const ListadoScreen(),
      detalle: (context) => const DetalleScreen(),
      formulario: (context) => const FormularioScreen(),
      administracion: (context) => const AdministracionScreen(),
      adminOperador: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final usuarioActual = args is Usuario ? args : null;
        return AdminOperadorScreen(usuarioActual: usuarioActual);
      },
      perfil: (context) => const PerfilScreen(),
    };
  }
}