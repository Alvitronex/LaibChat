import 'package:frontend/providers/providers.dart';
import 'package:frontend/screens/screens.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final TextEditingController _emailController = TextEditingController();
    // final TextEditingController _password = TextEditingController();
    // final _formkey = GlobalKey<FormState>();

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
                  child: _LoginForm(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                      fullscreenDialog: true, // Agrega esta línea
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

class _LoginForm extends StatelessWidget {
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
                    borderRadius: BorderRadius.circular(10.0))),
          ),
          const SizedBox(height: 15),
          TextFormField(
            autocorrect: false,
            obscureText: true,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => loginForm.password = value,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 25),
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            disabledColor: Colors.grey,
            elevation: 5,
            color: Colors.amber[700],
            onPressed: loginForm.isLoading
                ? null
                : () async {
                    FocusScope.of(context).unfocus();
                    if (!loginForm.isValidForm()) return;
                    loginForm.isLoading = true;

                    final authService =
                        Provider.of<AuthService>(context, listen: false);

                    String respuesta = await authService.login(
                        loginForm.email, loginForm.password, 'movile');

                    // Set isLoading to false regardless of response
                    loginForm.isLoading = false;

                    // ignore: use_build_context_synchronously
                    if (respuesta == "correcto") {
                      Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Dashboard(),
                          fullscreenDialog: true,
                        ),
                      );
                    } else if (respuesta == "error") {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Error de conexión'),
                          backgroundColor: Colors.red[100],
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else {
                      // Show error message and allow retry
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Credenciales incorrectas'),
                          backgroundColor: Colors.red[100],
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 100.0, vertical: 15),
              child: Text(
                loginForm.isLoading ? 'Espere' : 'Iniciar Sesión',
                style: const TextStyle(
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
