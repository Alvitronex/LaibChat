import 'package:frontend/providers/providers.dart';
import 'package:frontend/screens/screens.dart';
import 'package:frontend/services/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: const SideBar(),
      appBar: null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              const Image(
                image: AssetImage("assets/utils/logo.jpeg"),
                width: 300,
                height: 300,
              ),
              const Text(
                textAlign: TextAlign.center,
                'Bienvenido a \n LaibChat',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Center(
                child: ChangeNotifierProvider(
                  create: (_) => loginformprovider(),
                  child: _LoginForm(
                    onLoading: (isLoading) {
                      setState(() {
                        _isLoading = isLoading;
                      });
                    },
                    onError: (message) {
                      setState(() {
                        _errorMessage = message;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Colors.red[100],
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    onSuccess: () {
                      // Navegar al dashboard tras el login exitoso
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Dashboard(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                child: const Text(
                  textAlign: TextAlign.center,
                  '¿No tienes una cuenta? Regístrate',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  final Function(bool isLoading) onLoading;
  final Function(String message) onError;
  final Function() onSuccess;

  const _LoginForm({
    required this.onLoading,
    required this.onError,
    required this.onSuccess,
  });

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<loginformprovider>(context);

    return Form(
      key: loginForm.formkey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => loginForm.email = value,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su correo electrónico';
              }
              final emailRegExp = RegExp(
                r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
              );
              if (!emailRegExp.hasMatch(value)) {
                return 'Ingrese un correo electrónico válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            autocorrect: false,
            obscureText: _obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            onChanged: (value) => loginForm.password = value,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su contraseña';
              } else if (value.length < 8) {
                return 'La contraseña debe tener al menos 8 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 25),
          _isSubmitting
              ? const CircularProgressIndicator(
                  color: Colors.amber,
                )
              : MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledColor: Colors.grey,
                  elevation: 5,
                  color: Colors.amber[700],
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (!loginForm.isValidForm()) {
                      widget.onError(
                          'Por favor complete todos los campos correctamente');
                      return;
                    }

                    setState(() {
                      _isSubmitting = true;
                    });
                    widget.onLoading(true);

                    try {
                      final authService =
                          Provider.of<AuthService>(context, listen: false);

                      String respuesta = await authService.login(
                        loginForm.email,
                        loginForm.password,
                        'mobile', // Corregido de 'movile' a 'mobile'
                      );

                      if (respuesta == "correcto") {
                        widget.onSuccess();
                      } else {
                        widget.onError(respuesta);
                      }
                    } catch (e) {
                      widget.onError('Error inesperado: $e');
                    } finally {
                      setState(() {
                        _isSubmitting = false;
                      });
                      widget.onLoading(false);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100.0, vertical: 15),
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
