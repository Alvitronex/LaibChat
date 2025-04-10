import 'package:flutter/material.dart';
import 'package:frontend/components/components.dart';
import 'package:frontend/main.dart';
// import 'package:frontend/components/components.dart';
import 'package:frontend/providers/providers.dart';
import 'package:frontend/screens/login/home.dart';
import 'package:frontend/screens/screens.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/widgets.dart';
import 'package:provider/provider.dart';

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
              const SizedBox(
                height: 75,
              ),
              Text(
                "S'lud Healtech",
                style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Image(
                image: AssetImage("assets/utils/splash_128.png"),
              ),
              const SizedBox(height: 30),
              const Text(
                'Inicio de Sesión',
                style: TextStyle(
                  color: Color.fromARGB(255, 63, 163, 245),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Center(
                child: ChangeNotifierProvider(
                  create: (_) => loginformprovider(),
                  child: _LoginForm(),
                ),
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
                child: const Text('¿No tienes una cuenta? Regístrate aquí'),
              ),
            ],
          ),
        ),
        // const SizedBox(
        //   height: 300,
        // ),
        // CardContainer(
        //   child: Column(
        //     children: [
        //       const SizedBox(height: 10),
        //       const Text(
        //         "Iniciar Sesion",
        //         // style: Theme.of(context).textTheme.headlineMedium,
        //       ),
        //       const SizedBox(height: 30),
        //       ChangeNotifierProvider(
        //         create: (_) => loginformprovider(),
        //         child: _LoginForm(),
        //       ),
        //     ],
        //   ),
        // ),
        // const SizedBox(height: 30),
        // Center(
        //   child: Column(
        //     children: [
        //       ListTile(
        //         leading: const Icon(Icons.app_registration),
        //         title: Text(
        //           "Registrate",
        //           textAlign: TextAlign.center,
        //           style: TextStyle(
        //             fontSize: 25,
        //             fontWeight: FontWeight.bold,
        //             color: Colors.grey.shade400,
        //           ),
        //         ),
        //         onTap: () {
        //           Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) => const RegisterScreen()));
        //         },
        //       ),
        //     ],
        //   ),
        // ),
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
          SizedBox(
            height: 20,
          ),
          TextFormField(
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => loginForm.email = value,
            decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0))),
          ),
          const SizedBox(height: 20),
          TextFormField(
            autocorrect: false,
            obscureText: true,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => loginForm.password = value,
            validator: (value) {
              if (value != null && value.length >= 8) return null;
              return 'La contrasena es demasiado corta';
            },
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 30),
          MaterialButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            disabledColor: Colors.grey,
            elevation: 0,
            color: Colors.blue,
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
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Home(),
                          fullscreenDialog: true,
                        ),
                      );
                    } else {
                      // Show error message and allow retry
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $respuesta'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
            // onPressed: () {
            //   print('presionando');
            //   print(loginForm.email);
            //   print(loginForm.password);
            // }

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              child: Text(
                loginForm.isLoading ? 'Espere' : 'Ingresar',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogoAlerta extends StatelessWidget {
  final String mensaje;
  const _DialogoAlerta({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Error"),
      content: Text(mensaje),
    );
  }
}
