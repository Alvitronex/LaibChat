import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/services.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatLaib'),
        backgroundColor: const Color.fromARGB(255, 123, 143, 177),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          const Text(
            "Salir",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            padding: EdgeInsets.symmetric(horizontal: 2),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
              Navigator.pushNamed(context, "login");
            },
          ),
        ],
      ),
      body: const Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Image(
                      image: AssetImage("assets/utils/splash_128.png"),
                      width: 100,
                      height: 100,
                      fit: BoxFit.fitHeight,
                      colorBlendMode: BlendMode.modulate),
                ],
              ),
              SizedBox(width: 20),
              Column(
                children: [
                  Text(
                    "Mario Alvarado",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
