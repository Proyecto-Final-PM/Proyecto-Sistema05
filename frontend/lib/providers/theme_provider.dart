import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Recuperar la preferencia guardada.
  Future<void> inicializarTema() async {
    final preferences = await SharedPreferences.getInstance();

    final modoOscuro = preferences.getBool('modo_oscuro') ?? false;

    _themeMode = modoOscuro ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }

  // Cambiar entre tema claro y oscuro.
  Future<void> cambiarTema(bool modoOscuro) async {
    _themeMode = modoOscuro ? ThemeMode.dark : ThemeMode.light;

    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool('modo_oscuro', modoOscuro);

    notifyListeners();
  }
}