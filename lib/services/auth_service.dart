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
  Servidor servidor = Servidor();

  final _storage = const FlutterSecureStorage();

  Future<String> login(
    String email,
    String password,
    String deviceName,
  ) async {
    try {
      // Clean previous auth state to prevent unauthorized access
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
//limpiando la cache
      cleanUp();

      // ignore: avoid_print
      print('Intentando registrar: $name, $email, $phone');

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
                'phone': phoneInt
                    .toString(), // Enviamos como string pero contiene solo un número
                'password': password,
              }));
      // ignore: avoid_print
      print(
          'Respuesta del servidor: ${response.statusCode} - ${response.body}');

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
          // ignore: avoid_print
          print(response.body);
          _isLoggedIn = true;
          _user = User.fromJson(jsonDecode(response.body));
          _token = token;
          storeToken(token);
          notifyListeners();
          return true;
        } else {
          // Invalid token or unauthorized
          cleanUp();
          notifyListeners();
          return false;
        }
      } catch (e) {
        // ignore: avoid_print
        print(e);
        cleanUp();
        notifyListeners();
        return false;
      }
    }
  }

  void storeToken(String token) async {
    _storage.write(key: 'token', value: token);
    // print(token);
  }

  void logout() async {
    try {
      // ignore: unused_local_variable
      final response = await http.get(
          Uri.parse('${servidor.baseUrl}/user/revoke'),
          headers: {'Authorization': 'Bearer $_token'});
      cleanUp();
      notifyListeners();
      // print("Imprimiendo desde el servies");
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void cleanUp() async {
    _user = null;
    _isLoggedIn = false;
    await _storage.delete(key: 'token');
  }
}
