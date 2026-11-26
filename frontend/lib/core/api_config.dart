import 'package:flutter/foundation.dart';

class ApiConfig {
  // Permite configurar la URL al ejecutar la aplicación.
  static const String _customBaseUrl = String.fromEnvironment('API_BASE_URL');

  // URL base del backend
  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Emulador de Android
        return 'http://10.0.2.2:3000/api';

      case TargetPlatform.iOS:
        // Simulador de iOS
        return 'http://localhost:3000/api';

      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        // Aplicación de escritorio
        return 'http://localhost:3000/api';

      default:
        return 'http://localhost:3000/api';
    }
  }
}
