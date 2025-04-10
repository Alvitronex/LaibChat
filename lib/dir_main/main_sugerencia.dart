
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S\'lud Healtech',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('S\'lud Healtech'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Acción para cerrar sesión
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/descarga.jpeg', // Asegúrate de tener esta imagen en tu carpeta assets
                  width: 400,
                  height: 200,
                ),
              ),
              Text(
                'Bienvenido a S\'lud Healtech',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '@ user_1',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                icon: Icon(Icons.search),
                label: Text('Ver Medicinas'),
                onPressed: () {
                  // Acción para ver medicinas
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => MedicinesPage()),
                  // );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                icon: Icon(Icons.edit),
                label: Text('Consultar Enfermedad'),
                onPressed: () {
                  // Acción para consultar enfermedad
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => DiseaseConsultPage()),
                  // );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
