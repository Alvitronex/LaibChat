# Indicaciones 

ChatLaib es un aplicativo generado para android y plataformas web, demostrando lo versatil y generativo es crear una app enfocada a chat persistente y de forma instantánea, formando la creación por Flutter como diseño  Frontend tomado de la mano con su lenguaje de programación Dart creado por google, y tambien Laravel como enfoque al backend siendo PHP el motor de lenguaje de programacion usando sus herramientas muy ágiles y escalables formando la base de datos por medio de migraciones y muchos mas paquetes de desarrollo.

## Instalación

- Usaremos los siguientes comandos:
```bash
flutter clean
```
Limpia toda cache y configuración porque es en nuestro equipo que estaremos ambientando el proyecto.

```bash
flutter pub get
```
Agregar todos los paquetes e integrarlos a nuestro equipo de desarrollo.

```bash
flutter upgrade
```
Actualizar la version de flutter a la mas reciente o integrarse a la que tenemos instalada por tema de compatibilidad de emuladores físicos y virtuales.


### ENV Development
Tener en cuenta la api que se estará llamando por medio de laravel, conectar de manera correcta para tener los endpoints de forma fluida y sin problemas.

```python
Path /lib/services/server.dart

class Servidor {
  
  // Cambia esto según el entorno
  static const bool isProduction = false;

  // Para acceder desde dispositivos móviles, web y emuladores
  String get baseUrl {
    if (isProduction) { //script para levantamiento en servidor externo
      return 'https://www.alvitronex.com/backend/public/api';
    } else {
      // Determinar la plataforma y usar la URL apropiada
      const bool kIsWeb = identical(0, 0.0);

      if (kIsWeb) {
        return 'http://localhost:8000/api'; // Para web local (backend - laravel)
      } else {
        return 'http://10.0.2.2:8000/api'; // Para emulador Android
      }
    }
  }
//encabezado ante endpoints o consultas
  final headers = <String, String>{'Content-type': 'application/json'};
}

```
