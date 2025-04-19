import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            ]),
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  bool _registrationSuccess = false;

  @override
  Widget build(BuildContext context) {
    final registerForm = Provider.of<registerfromprovider>(context);

    if (_registrationSuccess) {
      // Si el registro fue exitoso, mostrar mensaje y botón para ir a login
      return Column(
        children: [
          const SizedBox(height: 20),
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            '¡Registro completado con éxito!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tu cuenta se ha creado correctamente.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Text(
              'Iniciar Sesión',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "El nombre no puede estar vacío";
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            autocorrect: false,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) => registerForm.phone = value,
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
              if (!RegExp(r'^\d+$').hasMatch(value)) {
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "El correo no puede estar vacío";
              }
              final emailRegExp = RegExp(
                r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
              );
              if (!emailRegExp.hasMatch(value)) {
                return "Correo electrónico no válido";
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            autocorrect: false,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            onChanged: (value) => registerForm.password = value,
            decoration: InputDecoration(
              labelText: "Contraseña",
              prefixIcon: const Icon(Icons.password_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "La contraseña no puede estar vacía";
              } else if (value.length < 8) {
                return 'La contraseña debe tener al menos 8 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            autocorrect: false,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: registerForm.isLoading
                ? null
                : () async {
                    FocusScope.of(context).unfocus();
                    if (!registerForm.isValidForm()) {
                      // Mostrar mensaje de validación
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Por favor complete todos los campos correctamente'),
                          backgroundColor: Colors.red[100],
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    registerForm.isLoading = true;

                    final authService =
                        Provider.of<AuthService>(context, listen: false);

                    String respuesta = await authService.register(
                      registerForm.name,
                      registerForm.email,
                      registerForm.phone,
                      registerForm.password,
                    );

                    registerForm.isLoading = false;

                    // ignore: use_build_context_synchronously
                    if (respuesta == "correcto" ||
                        respuesta.contains("creado exitosamente")) {
                      // Cambiar el estado para mostrar el mensaje de éxito
                      setState(() {
                        _registrationSuccess = true;
                      });
                    } else if (respuesta == "error") {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Error de conexión con el servidor'),
                          backgroundColor: Colors.red[100],
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(respuesta),
                          backgroundColor: Colors.red[100],
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                registerForm.isLoading ? 'Espere...' : 'Registrarse',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Text(
              '¿Ya tienes cuenta? Inicia sesión',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          )
        ],
      ),
    );
  }
}
