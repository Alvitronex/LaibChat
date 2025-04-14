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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MedicineScreen()),
                  );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DiseaseConsultPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
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


class DiseaseConsultPage extends StatefulWidget {
  @override
  _DiseaseConsultPageState createState() => _DiseaseConsultPageState();
}

class _DiseaseConsultPageState extends State<DiseaseConsultPage> {
  String? _selectedDisease;

  void _handleDiseaseSelected(String? newValue) {
    setState(() {
      _selectedDisease = newValue;
    });
  }

  void _searchSuggestions() {
    if (_selectedDisease != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MedicinesSuggestionPage(disease: _selectedDisease!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Por favor, seleccione una enfermedad.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultar Enfermedad'),
      ),
      body: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccione la enfermedad con la que se identifica:',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            DropdownButton<String>(
              value: _selectedDisease,
              onChanged: _handleDiseaseSelected,
              style: TextStyle(color: Colors.black),
              underline: Container(
                height: 2,
                color: Colors.blue,
              ),
              icon: Icon(Icons.arrow_drop_down),
              elevation: 8,
              dropdownColor: Colors.grey[200],
              iconEnabledColor: Colors.black,
              items: <String>[
                'Dolor de cabeza',
                'Dolor de estómago',
                'Gripe',
                'Dolor de huesos',
                'Ataque de nervios',
                'Náuseas',
                'Colon',
                'Gastritis'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: _searchSuggestions,
              icon: Icon(Icons.search),
              label: Text('Buscar Sugerencia'),
            ),
            SizedBox(height: 170),
            Container(
              padding: EdgeInsets.all(10),
              color: Color.fromARGB(255, 248, 240, 169),
              child: Text(
                'Advertencia:\n\nTodo medicamento sugerido puede dañar su salud si se hace uso excesivo del mismo. Se recomienda consultar a su médico antes de ingerir cualquier tipo de medicamento.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicinesSuggestionPage extends StatelessWidget {
  final String disease;

  const MedicinesSuggestionPage({required this.disease});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> diseaseMedications = {
      'Dolor de cabeza': [
        {
          'name': 'Paracetamol',
          'mg': '500 mg',
          'image': 'assets/images/paracetamol.jpg',
          'active_ingredients': ['Paracetamol'],
          'indications': 'Alivio del dolor y reducción de la fiebre.',
          'contraindications':
              'No usar en personas con hipersensibilidad al paracetamol.'
        },
        {
          'name': 'Aspirina',
          'mg': '500 mg',
          'image': 'assets/images/Aspirina.jpeg',
          'active_ingredients': ['Ácido acetilsalicílico'],
          'indications':
              'Alivio del dolor leve a moderado, reducción de fiebre.',
          'contraindications':
              'No usar en personas con úlceras gástricas activas o hemofilia.'
        },
      ],
      'Dolor de estómago': [
        {
          'name': 'Omeprazol',
          'mg': '20 mg',
          'image': 'assets/images/Omeprazol.png',
          'active_ingredients': ['Omeprazol'],
          'indications': 'Tratamiento del reflujo gastroesofágico.',
          'contraindications':
              'No usar en personas con hipersensibilidad al omeprazol.'
        },
        {
          'name': 'Bismutol',
          'mg': '262 mg',
          'image': 'assets/images/Bismutol.jpeg',
          'active_ingredients': ['Subsalicilato de bismuto'],
          'indications': 'Alivio de la indigestión y malestar estomacal.',
          'contraindications':
              'No usar en personas alérgicas a los salicilatos.'
        },
      ],
      'Gripe': [
        {
          'name': 'Antiflu-Des',
          'mg': '500 mg',
          'image': 'assets/images/Antiflu-Des.jpeg',
          'active_ingredients': ['Paracetamol', 'Clorfenamina', 'Fenilefrina'],
          'indications':
              'Alivio de los síntomas de la gripe como congestión nasal, dolor y fiebre.',
          'contraindications':
              'No usar en personas con hipertensión severa o enfermedad coronaria grave.'
        },
        {
          'name': 'Tabcin',
          'mg': '325 mg',
          'image': 'assets/images/Tabcin.jpeg',
          'active_ingredients': ['Paracetamol', 'Clorfenamina', 'Fenilefrina'],
          'indications':
              'Alivio de los síntomas del resfriado común y la gripe.',
          'contraindications':
              'No usar en personas con hipertensión severa o enfermedad coronaria grave.'
        },
      ],
      'Dolor de huesos': [
        {
          'name': 'Ibuprofeno',
          'mg': '600 mg',
          'image': 'assets/images/Ibuprofeno.jpeg',
          'active_ingredients': ['Ibuprofeno'],
          'indications': 'Alivio del dolor y la inflamación.',
          'contraindications':
              'No usar en personas con úlceras gástricas activas o insuficiencia renal severa.'
        },
        {
          'name': 'Naproxeno',
          'mg': '500 mg',
          'image': 'assets/images/Naproxeno.jpeg',
          'active_ingredients': ['Naproxeno'],
          'indications': 'Alivio del dolor y la inflamación.',
          'contraindications':
              'No usar en personas con úlceras gástricas activas o insuficiencia renal severa.'
        },
      ],
      'Ataque de nervios': [
        {
          'name': 'Diazepam',
          'mg': '10 mg',
          'image': 'assets/images/Diazepam.jpeg',
          'active_ingredients': ['Diazepam'],
          'indications':
              'Tratamiento de la ansiedad y los espasmos musculares.',
          'contraindications':
              'No usar en personas con insuficiencia respiratoria severa o apnea del sueño.'
        },
        {
          'name': 'Clonazepam',
          'mg': '2 mg',
          'image': 'assets/images/Clonazepam.jpeg',
          'active_ingredients': ['Clonazepam'],
          'indications':
              'Tratamiento de trastornos de ansiedad y convulsiones.',
          'contraindications':
              'No usar en personas con insuficiencia respiratoria severa o apnea del sueño.'
        },
      ],
      'Náuseas': [
        {
          'name': 'Metoclopramida',
          'mg': '10 mg',
          'image': 'assets/images/Metoclopramida.jpeg',
          'active_ingredients': ['Metoclopramida'],
          'indications': 'Tratamiento de las náuseas y vómitos.',
          'contraindications':
              'No usar en personas con hemorragia gastrointestinal, obstrucción mecánica o perforación.'
        },
        {
          'name': 'Ondansetrón',
          'mg': '8 mg',
          'image': 'assets/images/Ondansetrón.jpeg',
          'active_ingredients': ['Ondansetrón'],
          'indications':
              'Prevención de náuseas y vómitos inducidos por quimioterapia.',
          'contraindications':
              'No usar en personas con hipersensibilidad al ondansetrón.'
        },
      ],
      'Colon': [
        {
          'name': 'Mebeverina',
          'mg': '135 mg',
          'image': 'assets/images/Mebeverina.jpeg',
          'active_ingredients': ['Mebeverina'],
          'indications': 'Alivio del síndrome del intestino irritable.',
          'contraindications':
              'No usar en personas con hipersensibilidad a la mebeverina.'
        },
        {
          'name': 'Trimebutina',
          'mg': '200 mg',
          'image': 'assets/images/Trimebutina.jpeg',
          'active_ingredients': ['Trimebutina'],
          'indications': 'Tratamiento del síndrome del intestino irritable.',
          'contraindications':
              'No usar en personas con hipersensibilidad a la trimebutina.'
        },
      ],
      'Gastritis': [
        {
          'name': 'Ranitidina',
          'mg': '150 mg',
          'image': 'assets/images/Ranitidina.jpeg',
          'active_ingredients': ['Ranitidina'],
          'indications':
              'Tratamiento de la úlcera gástrica y duodenal, y reflujo gastroesofágico.',
          'contraindications':
              'No usar en personas con hipersensibilidad a la ranitidina.'
        },
        {
          'name': 'Esomeprazol',
          'mg': '40 mg',
          'image': 'assets/images/Esomeprazol.jpeg',
          'active_ingredients': ['Esomeprazol'],
          'indications': 'Tratamiento del reflujo gastroesofágico.',
          'contraindications':
              'No usar en personas con hipersensibilidad al esomeprazol.'
        },
      ],
    };

    final List<Map<String, dynamic>>? medications = diseaseMedications[disease];

    return Scaffold(
      appBar: AppBar(
        title: Text('Medicamentos para $disease'),
      ),
      body: medications == null
          ? Center(child: Text('No hay medicamentos disponibles.'))
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: medications.length,
              itemBuilder: (context, index) {
                final medication = medications[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicationDetailPage(
                          medication: medication,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: Image.asset(
                        medication['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        medication['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${medication['mg']}'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class MedicationDetailPage extends StatelessWidget {
  final Map<String, dynamic> medication;

  const MedicationDetailPage({required this.medication});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${medication['name']} (${medication['mg']})'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                medication['image'],
                width: 150, // Cambia el tamaño según lo necesites
                height: 150, // Cambia el tamaño según lo necesites
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Ingredientes activos: ${medication['active_ingredients'].join(', ')}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Indicaciones: ${medication['indications']}'),
            SizedBox(height: 10),
            Text('Contraindicaciones: ${medication['contraindications']}'),
          ],
        ),
      ),
    );
  }
}
