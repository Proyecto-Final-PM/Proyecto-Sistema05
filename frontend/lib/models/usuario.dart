import 'enums.dart';

class Usuario {
  final int id;
  final String nombre;
  final String correo;
  final RolUsuario rol;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      rol: RolUsuario.fromJson(json['rol'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'rol': rol.toJson(),
    };
  }
}