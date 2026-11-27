class AuthRepository {
  // Usuarios simulados almacenados en memoria
  final Map<String, Map<String, dynamic>> _usuarios = {
    'usuario@example.com': {
      'id': 1,
      'nombre': 'Usuario de prueba',
      'correo': 'usuario@example.com',
      'password': 'Usuario123!',
      'rol': 'usuario',
    },
    'operador@example.com': {
      'id': 2,
      'nombre': 'Operador de prueba',
      'correo': 'operador@example.com',
      'password': 'Operador123!',
      'rol': 'operador',
    },
  };

  int _siguienteId = 3;

  // Login simulado
  Future<Map<String, dynamic>> login({
    required String correo,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final correoNormalizado = correo.trim().toLowerCase();
    final usuario = _usuarios[correoNormalizado];

    if (usuario == null || usuario['password'] != password) {
      throw Exception('Credenciales incorrectas');
    }

    return {
      'mensaje': 'Inicio de sesión exitoso',
      'token': 'token_simulado_${usuario['id']}',
      'tipo_token': 'Bearer',
      'usuario': {
        'id': usuario['id'],
        'nombre': usuario['nombre'],
        'correo': usuario['correo'],
        'rol': usuario['rol'],
      },
    };
  }

  // Registro simulado
  Future<Map<String, dynamic>> registro({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final correoNormalizado = correo.trim().toLowerCase();

    if (_usuarios.containsKey(correoNormalizado)) {
      throw Exception('El correo ya está registrado');
    }

    final usuario = {
      'id': _siguienteId++,
      'nombre': nombre.trim(),
      'correo': correoNormalizado,
      'password': password,
      'rol': 'usuario',
    };

    _usuarios[correoNormalizado] = usuario;

    return {
      'mensaje': 'Usuario registrado correctamente',
      'usuario': {
        'id': usuario['id'],
        'nombre': usuario['nombre'],
        'correo': usuario['correo'],
        'rol': usuario['rol'],
      },
    };
  }
}
