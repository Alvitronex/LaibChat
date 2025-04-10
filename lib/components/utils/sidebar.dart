import 'package:flutter/material.dart';
import 'package:frontend/screens/screens.dart';
import 'package:frontend/services/services.dart';
import 'package:provider/provider.dart';

import '../../screens/login/home.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<AuthService>(builder: (context, auth, child) {
        if (!auth.authenticated) {
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text("Iniciar Session"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text("Registrarse"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()));
                },
              ),
            ],
          );
        } else {
          return ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(auth.user.name),
                accountEmail: Text(auth.user.email),
                currentAccountPicture: const CircleAvatar(
                  child: ClipOval(
                    child: Image(
                      image: NetworkImage(
                          'https://media.revistagq.com/photos/5f45010acb266484bb785c78/1:1/w_720,h_720,c_limit/dragon-ball-z.jpg'),
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/utils/paisaje.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              ListTile(
                  leading: const Icon(Icons.home_filled),
                  title: const Text("Pantalla de inicio"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                    );
                  }),
              const Divider(
                height: 12,
              ),
              ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: const Text("Cerrar Session"),
                onTap: () {
                  Provider.of<AuthService>(context, listen: false).logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                  Navigator.pushNamed(context, "login");
                },
              ),
            ],
          );
        }
      }),
    );
  }
}
// }

// const UserAccountsDrawerHeader(
//             accountName: Text(
//               "MARIO ALVARADO",
//               style: TextStyle(color: Colors.black),
//             ),
//             accountEmail: Text("ss@gmaik.com"),
//             currentAccountPicture: CircleAvatar(
//               child: ClipOval(
//                 child: Image(
//                   image: NetworkImage(
//                       'https://media.revistagq.com/photos/5f45010acb266484bb785c78/1:1/w_720,h_720,c_limit/dragon-ball-z.jpg'),
//                   height: 90,
//                   width: 90,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/utils/paisaje.jpg"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           ListTile(
//               leading: const Icon(Icons.logout_outlined),
//               title: const Text("Cerrar Sesionss"),
//               onTap: () {
//                 print("presionando cerrar sesion");
//               }),
//           const Divider(
//             height: 12,
//           ),
//           ListTile(
//             leading: const Icon(Icons.login_rounded),
//             title: const Text("Iniciar Sesion"),
//             onTap: () {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (context) => LoginScreen()));
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.verified_user_rounded),
//             title: const Text("registrar Sesion"),
//             onTap: () {
//               print("Presionando Iniciar Sesion");
//             },
//           ),
