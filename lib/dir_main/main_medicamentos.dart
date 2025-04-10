import 'package:flutter/material.dart';

void main() {
  runApp(MedicineApp());
}

class MedicineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MedicineScreen(),
    );
  }
}

class MedicineScreen extends StatefulWidget {
  @override
  _MedicineScreenState createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  final List<Map<String, String>> medicines = [
    {
      "name": "Paracetamol",
      "mg": "500 mg",
      "image": "assets/images/paracetamol.jpg"
    },
    {
      "name": "Aspirina",
      "mg": "100 mg",
      "image": "assets/images/Aspirina.jpeg"
    },
    {
      "name": "Omeprazol",
      "mg": "20 mg",
      "image": "assets/images/Omeprazol.png"
    },
    {"name": "Bismutol", "mg": "10 mg", "image": "assets/images/Bismutol.jpeg"},
    {
      "name": "Antiflu-Des",
      "mg": "5 mg",
      "image": "assets/images/Antiflu-Des.jpeg"
    },
    {"name": "Tabcin", "mg": "5 mg", "image": "assets/images/Tabcin.jpeg"},
    {
      "name": "Ibuprofeno",
      "mg": "200 mg",
      "image": "assets/images/Ibuprofeno.jpeg"
    },
    {
      "name": "Naproxeno",
      "mg": "250 mg",
      "image": "assets/images/Naproxeno.jpeg"
    },
    {"name": "Diazepam", "mg": "5 mg", "image": "assets/images/Diazepam.jpeg"},
    {
      "name": "Clonazepam",
      "mg": "2 mg",
      "image": "assets/images/Clonazepam.jpeg"
    },
    {
      "name": "Metoclopramida",
      "mg": "10 mg",
      "image": "assets/images/Metoclopramida.jpeg"
    },
    {
      "name": "Ondansetrón",
      "mg": "8 mg",
      "image": "assets/images/Ondansetrón.jpeg"
    },
    {
      "name": "Mebeverina",
      "mg": "135 mg",
      "image": "assets/images/Mebeverina.jpeg"
    },
    {
      "name": "Trimebutina",
      "mg": "200 mg",
      "image": "assets/images/Trimebutina.jpeg"
    },
    {
      "name": "Ranitidina",
      "mg": "150 mg",
      "image": "assets/images/Ranitidina.jpeg"
    },
    {
      "name": "Esomeprazol",
      "mg": "40 mg",
      "image": "assets/images/Esomeprazol.jpeg"
    },
  ];

  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMedicines = medicines.where((medicine) {
      final name = medicine['name']!.toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Medicinas"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Buscar',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = "";
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredMedicines.length,
              itemBuilder: (context, index) {
                final medicine = filteredMedicines[index];
                return ListTile(
                  leading:
                      Image.asset(medicine['image']!, width: 50, height: 50),
                  title: Text(medicine['name']!),
                  subtitle: Text(medicine['mg']!),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(medicine['name']!),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(medicine['image']!,
                                  width: 100, height: 100),
                              SizedBox(height: 10),
                              Text(medicine['mg']!),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text("Cerrar"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
