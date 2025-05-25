// // Actualización de la clase Servidor para mejorar la gestión de conexiones HTTP
// // y optimizar la comunicación en tiempo real

// class Servidor {
//   // Configuración del entorno de ejecución
//   static const bool isProduction = false;

//   // Obtener la URL base según el entorno
//   String get baseUrl {
//     if (isProduction) {
//       return 'https://www.alvitronex.com/backend/public/api';
//     } else {
//       // Determinar la plataforma y usar la URL apropiada
//       const bool kIsWeb = identical(0, 0.0);

//       if (kIsWeb) {
//         return 'http://localhost:8000/api'; // Para web local
//       } else {
//         // Para emulador Android (10.0.2.2 es localhost del host)
//         // Para iOS usar 127.0.0.1
//         return 'http://10.0.2.2:8000/api';
//       }
//     }
//   }

//   // Método mejorado para obtener headers con opciones adicionales
//   Map<String, String> getHeaders({String? token, bool includeJson = true}) {
//     final headers = <String, String>{};

//     // Siempre incluir cabecera de identificación de solicitud
//     headers['X-Requested-With'] = 'XMLHttpRequest';

//     // Cabeceras para JSON si se requiere
//     if (includeJson) {
//       headers['Content-Type'] = 'application/json';
//       headers['Accept'] = 'application/json';
//     }

//     // Añadir token de autenticación si está disponible
//     if (token != null) {
//       headers['Authorization'] = 'Bearer $token';
//     }

//     // Añadir timestamp para evitar cacheo en respuestas
//     headers['X-Timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();

//     return headers;
//   }

//   // Timeout para peticiones HTTP (en milisegundos)
//   int get requestTimeout => 15000; // 15 segundos

//   // Número máximo de reintentos para peticiones fallidas
//   int get maxRetries => 3;

//   // Intervalo base para reintentar peticiones fallidas (en milisegundos)
//   int get retryInterval => 1000; // 1 segundo

//   // Compresión de datos habilitada
//   bool get useCompression => true;
// }
class Servidor {
  // Cambia esto según el entorno
  static const bool isProduction = false;
  // Añadir esta propiedad para dispositivos físicos
  static const bool isPhysicalDevice =
      true; // Establece a true para dispositivo físico

  // Para acceder desde dispositivos móviles, web y emuladores
  String get baseUrl {
    if (isProduction) {
      return 'https://www.alvitronex.com/backend/public/api';
    } else {
      // Determinar la plataforma y usar la URL apropiada
      const bool kIsWeb = identical(0, 0.0);

      if (kIsWeb) {
        return 'http://localhost:8000/api'; // Para web local
      } else if (isPhysicalDevice) {
        // IMPORTANTE: Reemplaza "192.168.1.X" con la IP real de tu computadora
        return 'http://192.168.1.36:8000/api'; // Para dispositivo físico
      } else {
        return 'http://10.0.2.2:8000/api'; // Para emulador Android
      }
    }
  }

  // Headers para las peticiones
  Map<String, String> getHeaders({String? token, bool includeJson = true}) {
    final headers = <String, String>{};

    if (includeJson) {
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';
    }

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
