import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/models.dart';
import 'package:frontend/services/services.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  User? _user;
  String? _token;

  bool get authenticated => _isLoggedIn;
  User get user => _user!;
  String? get token => _token;

  Servidor servidor = Servidor();

  final _storage = const FlutterSecureStorage();

  // Verificar token guardado al inicio
  Future<bool> checkToken() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      return await tryToken(token);
    }
    return false;
  }

  Future<String> login(
    String email,
    String password,
    String deviceName,
  ) async {
    try {
      // Limpiar estado anterior
      cleanUp();

      // Realizar la solicitud en el formato esperado por el backend
      final response = await http.post(
        Uri.parse('${servidor.baseUrl}/sanctum/token'),
        body: {
          'email': email,
          'password': password,
          'device_name': deviceName,
        },
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      // Intentar decodificar como JSON para verificar si es una respuesta de error
      try {
        final jsonResponse = jsonDecode(response.body);

        // Si contiene un mensaje, probablemente sea un error
        if (jsonResponse is Map && jsonResponse.containsKey('message')) {
          return jsonResponse['message'] ?? 'Error no especificado';
        }

        // Si contiene errors, es definitivamente un error
        if (jsonResponse is Map && jsonResponse.containsKey('errors')) {
          final errors = jsonResponse['errors'];
          if (errors is Map && errors.containsKey('email')) {
            return errors['email'][0] ?? 'Error de validación';
          }
          return 'Error de validación';
        }
      } catch (e) {
        // Si no es JSON, podría ser el token directamente como texto plano
        print('Respuesta no es JSON: probablemente un token');
      }

      // Si la respuesta no es JSON, asumimos que es el token
      final token = response.body.trim();

      // Comprobar si el token es válido
      if (token.length > 20) {
        // Un token suele ser bastante largo
        final tokenValid = await tryToken(token);
        if (tokenValid) {
          return "correcto";
        }
      }

      // Si llegamos aquí, no pudimos autenticar
      return 'Credenciales incorrectas o error de conexión';
    } catch (e) {
      print('Excepción en login: $e');
      return 'Error de conexión';
    }
  }

  Future<bool> tryToken(String? token) async {
    if (token == null || token.isEmpty) {
      return false;
    } else {
      try {
        final response = await http.get(
          Uri.parse('${servidor.baseUrl}/user'),
          headers: {'Authorization': 'Bearer $token'},
        );

        print('Try token response status: ${response.statusCode}');
        print('Try token body length: ${response.body.length}');
        if (response.body.length < 100) {
          print('Try token response body: ${response.body}');
        } else {
          print(
              'Try token response body: (respuesta larga, probablemente contiene datos de usuario)');
        }

        if (response.statusCode == 200) {
          try {
            final userData = jsonDecode(response.body);
            _user = User.fromJson(userData);
            _isLoggedIn = true;
            _token = token;
            storeToken(token);
            notifyListeners();
            return true;
          } catch (e) {
            print('Error al decodificar datos de usuario: $e');
            return false;
          }
        } else {
          // Token inválido o no autorizado
          cleanUp();
          return false;
        }
      } catch (e) {
        print('Error al validar token: $e');
        cleanUp();
        return false;
      }
    }
  }

  Future<String> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      // Limpiar cache
      cleanUp();

      // Validar que el teléfono tenga sólo dígitos
      if (!RegExp(r'^\d+$').hasMatch(phone)) {
        return 'El número de teléfono debe ser numérico';
      }

      // Realizar la solicitud según la API esperada
      final response = await http.post(
        Uri.parse('${servidor.baseUrl}/register'),
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      // Intentar decodificar como JSON para verificar si es respuesta de error
      try {
        final jsonResponse = jsonDecode(response.body);

        // Verificar si es un mensaje de error
        if (jsonResponse is Map && jsonResponse.containsKey('message')) {
          return jsonResponse['message'];
        }

        // Verificar si son errores de validación
        if (jsonResponse is Map && jsonResponse.containsKey('errors')) {
          final errors = jsonResponse['errors'];
          if (errors is Map) {
            for (var key in errors.keys) {
              if (errors[key] is List && errors[key].isNotEmpty) {
                return errors[key][0];
              }
            }
          }
          return 'Error de validación';
        }

        // Si es un mensaje de texto, como "usuario creado exitosamente"
        if (jsonResponse is String && jsonResponse.contains('exitosamente')) {
          return 'correcto';
        }
      } catch (e) {
        // Si no es JSON, podría ser el token directamente como texto plano
        print('Respuesta no es JSON: podría ser el token o mensaje simple');
      }

      // Si el código de estado es exitoso
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Podría ser un token como texto plano
        if (response.body.length > 20 && !response.body.contains('{')) {
          return 'correcto';
        }

        // O podría ser un mensaje simple
        if (response.body.contains('exitosamente')) {
          return 'correcto';
        }

        return 'correcto';
      }

      return 'Error en el registro. Intenta más tarde';
    } catch (e) {
      print('Excepción en registro: $e');
      return 'error';
    }
  }

  void storeToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.get(Uri.parse('${servidor.baseUrl}/user/revoke'),
            headers: {'Authorization': 'Bearer $_token'});
      }
    } catch (e) {
      print('Error al cerrar sesión: $e');
      // Manejar errores silenciosamente
    } finally {
      cleanUp();
      notifyListeners();
    }
  }

  void cleanUp() async {
    _user = null;
    _isLoggedIn = false;
    _token = null;
    await _storage.delete(key: 'token');
  }
}
