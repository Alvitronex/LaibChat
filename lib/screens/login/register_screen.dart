import 'package:flutter/material.dart';
import 'package:frontend/providers/providers.dart';
import 'package:frontend/screens/screens.dart';
import 'package:frontend/services/services.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: const SideBar(),
      appBar: null,

      // ignore: deprecated_member_use
      body: WillPopScope(
        onWillPop: () async => false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Column(children: [
              const SizedBox(
                height: 40,
              ),
              const Image(
                image: AssetImage("assets/utils/logo.jpeg"),
                width: 250,
                height: 250,
              ),
              const Text("Crea tu cuenta en \n LaibChat",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w900)),
              Center(
                child: ChangeNotifierProvider(
                  create: (_) => registerfromprovider(),
                  child: _RegisterForm(),
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
                      builder: (context) => const LoginScreen(),
                      fullscreenDialog: true, // Agrega esta línea
                    ),
                  );
                },
                child: const Text(
                  textAlign: TextAlign.center,
                  '¿Ya tienes cuenta? Inicia sesión',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final registerForm = Provider.of<registerfromprovider>(context);
    return Form(
      key: registerForm.formkey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextFormField(
            autocorrect: false,
            keyboardType: TextInputType.name,
            onChanged: (value) => registerForm.name = value,
            decoration: InputDecoration(
              labelText: "Nombre Completo",
              prefixIcon: const Icon(Icons.person_outline),
              prefixStyle: const TextStyle(
                  color: Color.fromARGB(255, 128, 93, 93),
                  fontWeight: FontWeight.bold),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextFormField(
            autocorrect: false,
            keyboardType: TextInputType.phone,
            // onChanged: (value) => registerForm.phone = value,
            decoration: InputDecoration(
              labelText: 'Numero Telefonico',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "El número telefónico no puede estar vacío";
              }
              if (int.tryParse(value) == null) {
                return "Ingrese solo números";
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => registerForm.email = value,
            decoration: InputDecoration(
              labelText: "Correo Electronico",
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextFormField(
            autocorrect: false,
            obscureText: true,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => registerForm.password = value,
            decoration: InputDecoration(
              labelText: "Contraseña",
              prefixIcon: const Icon(Icons.password_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (value) {
              if (value != null &&
                  value.length >= 8 &&
                  value == registerForm.password) {
                return null;
              } else if (value == null || value.isEmpty) {
                return "La contraseña no puede estar vacía";
              }
              return 'La contraseña es demasiado corta';
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            autocorrect: false,
            obscureText: true,
            // onChanged: (value) => registerForm.password = value,
            decoration: InputDecoration(
              labelText: 'Confirmar contraseña',
              prefixIcon: const Icon(Icons.password_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (value) {
              if (value != registerForm.password) {
                return 'Las contraseñas no coinciden';
              } else if (value == null || value.isEmpty) {
                return "La contraseña no puede estar vacía";
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            disabledColor: Colors.grey,
            elevation: 5,
            color: Colors.amber[700],
            onPressed: registerForm.isLoading
                ? null
                : () async {
                    FocusScope.of(context).unfocus();
                    if (!registerForm.isValidForm()) return;
                    registerForm.isLoading = true;

                    final authService =
                        Provider.of<AuthService>(context, listen: false);

                    String respuesta = await authService.register(
                        registerForm.name,
                        registerForm.email,
                        // int.parse(
                        //     registerForm.phone), // Conversión de String a int
                        registerForm.password);
                    registerForm.isLoading = false;

                    // ignore: use_build_context_synchronously
                    if (respuesta == "correcto") {
                      Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
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
                  const EdgeInsets.symmetric(horizontal: 116.0, vertical: 15),
              child: Text(
                registerForm.isLoading ? 'Espere' : 'Registrarse',
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
