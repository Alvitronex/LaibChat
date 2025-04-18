// Actualiza la clase Servidor en lib/services/server.dart

class Servidor {
  // Cambia esto según el entorno
  static const bool isProduction = false;

  // Para acceder desde dispositivos móviles, web y emuladores
  String get baseUrl {
    if (isProduction) {
      return 'https://www.alvitronex.com/backend/public/api';
    } else {
      // Determinar la plataforma y usar la URL apropiada
      const bool kIsWeb = identical(0, 0.0);

      if (kIsWeb) {
        return 'http://localhost:8000/api'; // Para web local
      } else {
        // La dirección 10.0.2.2 es para el emulador de Android
        // Si estás probando en un dispositivo físico, necesitarás
        // la dirección IP real de la máquina que ejecuta el servidor
        return 'http://10.0.2.2:8000/api';
      }
    }
  }

  // Encabezados HTTP para las peticiones
  Map<String, String> getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
