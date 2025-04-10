import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/models.dart';
import 'package:frontend/screens/screens.dart';
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
      final response =
          await http.post(Uri.parse('${servidor.baseUrl}/sanctum/token'),
              body: ({
                'email': email,
                'password': password,
                "device_name": deviceName,
              }));

      if (response.statusCode == 200) {
        String token = response.body.toString();
        tryToken(token);
        return "correcto";
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
    String password,
  ) async {
    try {
      final response =
          await http.post(Uri.parse('${servidor.baseUrl}/register'),
              body: ({
                'name': name,
                'email': email,
                'password': password,
              }));

      if (response.statusCode == 200) {
        String token = response.body.toString();
        tryToken(token);
        return "correcto";
      } else {
        return 'Datos incorrectos';
      }
    } catch (e) {
      return 'error';
    }
  }

  void tryToken(String? token) async {
    if (token == null) {
      return;
    } else {
      try {
        final response = await http.get(Uri.parse('${servidor.baseUrl}/user'),
            headers: {'Authorization': 'Bearer $token'});
        print(response.body);
        _isLoggedIn = true;
        _user = User.fromJson(jsonDecode(response.body));
        _token = token;
        storeToken(token);
        notifyListeners();
      } catch (e) {
        print(e);
      }
    }
  }

  void storeToken(String token) async {
    _storage.write(key: 'token', value: token);
    // print(token);
  }

  void logout() async {
    try {
      final response = await http.get(
          Uri.parse('${servidor.baseUrl}/user/revoke'),
          headers: {'Authorization': 'Bearer $_token'});
      cleanUp();
      notifyListeners();
      // print("Imprimiendo desde el servies");
    } catch (e) {
      print(e);
    }
  }

  void cleanUp() async {
    _user = null;
    _isLoggedIn = false;
    await _storage.delete(key: 'token');
  }
}
