import 'package:flutter/material.dart';
import 'package:frontend/services/services.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Verificar si hay un token guardado
    final isAuthenticated = await authService.checkToken();

    // Redireccionar según el estado de autenticación
    Future.delayed(const Duration(seconds: 2), () {
      if (isAuthenticated) {
        Navigator.pushReplacementNamed(context, 'dashboard');
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: Image(
                image: AssetImage("assets/utils/logo.jpeg"),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
