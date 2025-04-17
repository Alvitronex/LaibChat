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

  bool get  authenticated => _isLoggedIn;
  User get user => _user!;
  // Añadir getter para token
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

      final response =
          await http.post(Uri.parse('${servidor.baseUrl}/sanctum/token'),
              body: ({
                'email': email,
                'password': password,
                "device_name": deviceName,
              }));

      if (response.statusCode == 200) {
        String token = response.body.toString();
        final bool tokenValid = await tryToken(token);
        if (tokenValid) {
          return "correcto";
        } else {
          return 'Token inválido';
        }
      } else {
        return 'Datos incorrectos';
      }
    } catch (e) {
      return 'error';
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

      int phoneInt;
      try {
        phoneInt = int.parse(phone);
      } catch (e) {
        return 'El número de teléfono debe ser numérico';
      }

      final response =
          await http.post(Uri.parse('${servidor.baseUrl}/register'),
              body: ({
                'name': name,
                'email': email,
                'phone': phoneInt.toString(),
                'password': password,
              }));

      if (response.statusCode == 200) {
        String token = response.body.toString();
        final bool tokenValid = await tryToken(token);
        if (tokenValid) {
          return "correcto";
        } else {
          return 'Token inválido';
        }
      } else {
        return 'Datos incorrectos';
      }
    } catch (e) {
      return 'error';
    }
  }

  Future<bool> tryToken(String? token) async {
    if (token == null) {
      return false;
    } else {
      try {
        final response = await http.get(Uri.parse('${servidor.baseUrl}/user'),
            headers: {'Authorization': 'Bearer $token'});

        if (response.statusCode == 200) {
          _isLoggedIn = true;
          _user = User.fromJson(jsonDecode(response.body));
          _token = token;
          storeToken(token);
          notifyListeners();
          return true;
        } else {
          // Token inválido o no autorizado
          cleanUp();
          notifyListeners();
          return false;
        }
      } catch (e) {
        cleanUp();
        notifyListeners();
        return false;
      }
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
