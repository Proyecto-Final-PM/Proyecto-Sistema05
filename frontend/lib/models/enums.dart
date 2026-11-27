enum RolUsuario {
  usuario,
  operador;

  static RolUsuario fromJson(String? value) {
    switch (value) {
      case 'operador':
        return RolUsuario.operador;
      case 'usuario':
      default:
        return RolUsuario.usuario;
    }
  }

  String toJson() => name;

  String get etiquetaVisible {
    switch (this) {
      case RolUsuario.operador:
        return 'Operador';
      case RolUsuario.usuario:
        return 'Usuario';
    }
  }
}

enum EstadoSolicitud {
  solicitada,
  aceptada,
  enRecoleccion,
  finalizada;

  static EstadoSolicitud fromJson(String? value) {
    switch (value) {
      case 'aceptada':
        return EstadoSolicitud.aceptada;
      case 'en_recoleccion':
        return EstadoSolicitud.enRecoleccion;
      case 'finalizada':
        return EstadoSolicitud.finalizada;
      case 'solicitada':
      default:
        return EstadoSolicitud.solicitada;
    }
  }

  String toJson() {
    switch (this) {
      case EstadoSolicitud.enRecoleccion:
        return 'en_recoleccion';
      case EstadoSolicitud.solicitada:
        return 'solicitada';
      case EstadoSolicitud.aceptada:
        return 'aceptada';
      case EstadoSolicitud.finalizada:
        return 'finalizada';
    }
  }

  String get etiquetaVisible {
    switch (this) {
      case EstadoSolicitud.solicitada:
        return 'Solicitada';
      case EstadoSolicitud.aceptada:
        return 'Aceptada';
      case EstadoSolicitud.enRecoleccion:
        return 'En recolección';
      case EstadoSolicitud.finalizada:
        return 'Finalizada';
    }
  }
}

enum AccionHistorial {
  creacion,
  modificacion,
  cambioEstado,
  cancelacion;

  static AccionHistorial fromJson(String? value) {
    switch (value) {
      case 'modificacion':
        return AccionHistorial.modificacion;
      case 'cambio_estado':
        return AccionHistorial.cambioEstado;
      case 'cancelacion':
        return AccionHistorial.cancelacion;
      case 'creacion':
      default:
        return AccionHistorial.creacion;
    }
  }

  String toJson() {
    switch (this) {
      case AccionHistorial.cambioEstado:
        return 'cambio_estado';
      case AccionHistorial.creacion:
        return 'creacion';
      case AccionHistorial.modificacion:
        return 'modificacion';
      case AccionHistorial.cancelacion:
        return 'cancelacion';
    }
  }
}