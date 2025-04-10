class Servidor {
  // Uri.parse('http://127.0.0.1:8000/api/sanctum/token'),
  //http://10.0.2.2:8000/api para movil
  // Para Flutter Web en desarrollo local
// final String baseUrl = 'http://localhost:8000/api';

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
        return 'http://10.0.2.2:8000/api'; // Para emulador Android/iOS
      }
    }
  }

  final headers = <String, String>{'Content-type': 'application/json'};
}
