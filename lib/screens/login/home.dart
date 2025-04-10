import 'package:flutter/material.dart';
import 'package:frontend/screens/screens.dart';
import 'package:frontend/services/services.dart';
import 'package:provider/provider.dart';

// class Home extends StatelessWidget {
//   const Home({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const SideBar(),
//       appBar: AppBar(
//         title: const Center(
//           child: Text("Medicina"),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 70),
//         child: Center(
//           child: Column(children: [
//             Text(
//               "Bienvenido",
//               style: TextStyle(
//                 fontSize: 25,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey.shade400,
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
// }

//Funcion para guardar token en cache, sea si se cierra la app siempre se mantiene activa la session

// @override
// void initState() {
//   // TODO:  implementar instancia
//   readToken();
//   super.initState();
// }

// void readToken() async {
//   String? token = await storage.read(key: 'token');
//   Provider.of<AuthService>(context, listen: false).tryToken(token);
//   print(token);
// }

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      // appBar: AppBar(
      //   title: Text('S\'lud Healtech'),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.logout),
      //       onPressed: () {
      //         Provider.of<AuthService>(context, listen: false).logout();
      //         Navigator.pushReplacement(
      //           context,
      //           MaterialPageRoute(builder: (context) => const LoginScreen()),
      //         );
      //         Navigator.pushNamed(context, "login");
      //       },
      //     ),
      //   ],
      // ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/utils/descarga.jpeg',
                      width: 400,
                      height: 200,
                    ),
                  ),
                  const Text(
                    'Bienvenido a S\'lud Healtech',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // const Text(
                  //   '@ user_1',
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     color: Colors.blue,
                  //   ),
                  // ),
                  // const SizedBox(height: 30),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                    icon: const Icon(Icons.search),
                    label: const Text('Ver Medicinas'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VerMedicinaScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('Consultar Enfermedad'),
                    onPressed: () {
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
          Positioned(
            top: 20,
            right: 15,
            child: Row(
              children: [
                SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Provider.of<AuthService>(context, listen: false).logout();
                    Navigator.pushNamed(context, "login");
                  },
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VerMedicinaScreen extends StatefulWidget {
  @override
  _VerMedicinaScreenState createState() => _VerMedicinaScreenState();
}

class _VerMedicinaScreenState extends State<VerMedicinaScreen> {
  final List<Map<String, String>> medicamentos = [
    {
      "name": "Paracetamol",
      "image": "assets/utils/paracetamol.jpg",
      "description":
          "Beneficios:\n\nEficaz para aliviar dolores leves a moderados y reducir la fiebre. Usado para condiciones como dolores de cabeza, dolores dentales, dolores menstruales, artritis, dolores musculares y resfriados.\n\nEfectos secundarios:\n\nRaramente causa efectos secundarios cuando se toma en la dosis recomendada. Posibles efectos incluyen náuseas, erupciones cutáneas y reacciones alérgicas como hinchazón y dificultad para respirar. El uso excesivo puede causar daño hepático, especialmente cuando se combina con alcohol u otros medicamentos que contienen acetaminofén."
    },
    {
      "name": "Antiflu Des",
      "image": "assets/utils/Antiflu-Des.jpeg",
      "description":
          "Beneficios:\n\nAlivia síntomas del resfriado común y la gripe, como congestión, secreción nasal y dolores corporales.\n\nEfectos secundarios:\n\nPuede causar somnolencia, mareos, sequedad de boca y malestar estomacal. El uso excesivo o la combinación con alcohol puede aumentar el riesgo de daño hepático y otros efectos graves."
    },
    {
      "name": "Aspirina",
      "image": "assets/utils/Aspirina.jpeg",
      "description":
          "Beneficios:\n\nAlivia el dolor, reduce la fiebre y tiene propiedades antiinflamatorias. A menudo se usa para prevenir ataques cardíacos y accidentes cerebrovasculares en dosis bajas debido a sus efectos anticoagulantes.\n\nEfectos secundarios:\n\nProblemas gastrointestinales como dolor de estómago, acidez y úlceras. Mayor riesgo de sangrado y reacciones alérgicas."
    },
    {
      "name": "Bismutol",
      "image": "assets/utils/Bismutol.jpeg",
      "description":
          "Beneficios:\n\nTrata náuseas, acidez, indigestión y malestar estomacal. Usado para aliviar la diarrea y prevenir la diarrea del viajero.\n\nEfectos secundarios:\n\nHeces oscuras y lengua negra. Raramente, puede causar reacciones alérgicas graves."
    },
    {
      "name": "Clonazepam",
      "image": "assets/utils/Clonazepam.jpeg",
      "description":
          "Beneficios:\n\nUsado para tratar trastornos convulsivos y ataques de pánico. Tiene efectos calmantes y ayuda con la ansiedad.\n\nEfectos secundarios:\n\nSomnolencia, mareos y fatiga. Puede llevar a dependencia y síntomas de abstinencia."
    },
    {
      "name": "Diazepam",
      "image": "assets/utils/Diazepam.jpeg",
      "description":
          "Beneficios:\n\nTrata la ansiedad, los espasmos musculares y las convulsiones. Usado como sedante antes de procedimientos médicos.\n\nEfectos secundarios:\n\nSomnolencia, fatiga y debilidad muscular. Riesgo de dependencia y síntomas de abstinencia."
    },
    {
      "name": "Esomeprazol",
      "image": "assets/utils/Esomeprazol.jpeg",
      "description":
          "Beneficios:\n\nReduce el ácido estomacal y trata el reflujo gastroesofágico (GERD), úlceras y el síndrome de Zollinger-Ellison.\n\nEfectos secundarios:\n\nDolor de cabeza, diarrea y dolor de estómago. El uso a largo plazo puede aumentar el riesgo de fracturas óseas."
    },
    {
      "name": "Ibuprofeno",
      "image": "assets/utils/Ibuprofeno.jpeg",
      "description":
          "Beneficios:\n\nAlivia el dolor, reduce la fiebre y tiene efectos antiinflamatorios. Usado para condiciones como artritis, dolor menstrual y dolores musculares.\n\nEfectos secundarios:\n\nProblemas gastrointestinales como náuseas y úlceras. Mayor riesgo de eventos cardiovasculares y daño renal con el uso a largo plazo."
    },
    {
      "name": "Mebeverina",
      "image": "assets/utils/Mebeverina.jpeg",
      "description":
          "Beneficios:\n\nUsado para tratar los síntomas del síndrome del intestino irritable (SII) como los calambres estomacales y la distensión abdominal.\n\nEfectos secundarios:\n\nGeneralmente bien tolerado, pero puede causar mareos y reacciones cutáneas."
    },
    {
      "name": "Metoclopramida",
      "image": "assets/utils/Metoclopramida.jpeg",
      "description":
          "Beneficios:\n\nTrata náuseas, vómitos y gastroparesia. Usado para el reflujo gástrico y como ayuda en ciertos procedimientos médicos.\n\nEfectos secundarios:\n\nSomnolencia, fatiga y agitación. Puede causar efectos graves como discinesia tardía con el uso prolongado."
    },
    {
      "name": "Naproxeno",
      "image": "assets/utils/Naproxeno.jpeg",
      "description":
          "Beneficios:\n\nAlivia el dolor, reduce la fiebre y tiene propiedades antiinflamatorias. Usado para condiciones como artritis, gota y calambres menstruales.\n\nEfectos secundarios:\n\nProblemas gastrointestinales como úlceras y sangrado. Mayor riesgo de eventos cardiovasculares."
    },
    {
      "name": "Omeprazol",
      "image": "assets/utils/Omeprazol.png",
      "description":
          "Beneficios:\n\nReduce el ácido estomacal, trata el reflujo gastroesofágico (GERD) y cura úlceras. Usado para el manejo a largo plazo del síndrome de Zollinger-Ellison.\n\nEfectos secundarios:\n\nDolor de cabeza, dolor de estómago y diarrea. El uso a largo plazo puede llevar a una deficiencia de vitamina B12 y fracturas óseas."
    },
    {
      "name": "Ondansetrón",
      "image": "assets/utils/Ondansetrón.jpeg",
      "description":
          "Beneficios:\n\nPreviene náuseas y vómitos causados por quimioterapia, radiación y cirugía.\n\nEfectos secundarios:\n\nDolor de cabeza, estreñimiento y mareos. Raramente, puede causar problemas graves del ritmo cardíaco."
    },
    {
      "name": "Ranitidina",
      "image": "assets/utils/Ranitidina.jpeg",
      "description":
          "Beneficios:\n\nReduce el ácido estomacal y trata condiciones como el reflujo gastroesofágico (GERD) y úlceras.\n\nEfectos secundarios:\n\nDolor de cabeza, mareos y problemas gastrointestinales. El uso a largo plazo se ha asociado con un mayor riesgo de ciertas infecciones y deficiencia de vitamina B12."
    },
    {
      "name": "Tabcin",
      "image": "assets/utils/Tabcin.jpeg",
      "description":
          "Beneficios:\n\nAlivia síntomas del resfriado y la gripe, como congestión, fiebre y dolores corporales.\n\nEfectos secundarios:\n\nSomnolencia, mareos y sequedad de boca. El uso excesivo puede aumentar el riesgo de daño hepático."
    },
    {
      "name": "Trimebutina",
      "image": "assets/utils/Trimebutina.jpeg",
      "description":
          "Beneficios:\n\nUsado para tratar los síntomas del síndrome del intestino irritable (SII) como el dolor abdominal y los movimientos intestinales irregulares.\n\nEfectos secundarios:\n\nGeneralmente bien tolerado, pero puede causar náuseas y mareos."
    },
  ];

  List<Map<String, String>> displayedMedicamentos = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedMedicamentos = List.from(medicamentos);
    searchController.addListener(_searchMedicamentos);
  }

  @override
  void dispose() {
    searchController.removeListener(_searchMedicamentos);
    searchController.dispose();
    super.dispose();
  }

  void _searchMedicamentos() {
    final query = searchController.text.toLowerCase();
    setState(() {
      displayedMedicamentos = medicamentos.where((medicamento) {
        final nameLower = medicamento['name']?.toLowerCase() ?? '';
        return nameLower.contains(query);
      }).toList();
    });
  }

  void _clearSearch() {
    searchController.clear();
    setState(() {
      displayedMedicamentos = List.from(medicamentos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Medicina'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Acción para volver a la pantalla de bienvenida
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Busca un medicamento',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedMedicamentos.length,
              itemBuilder: (context, index) {
                final medicamento = displayedMedicamentos[index];
                return ListTile(
                  leading: Image.asset(medicamento['image']!),
                  title: Text(medicamento['name']!),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MedicamentoDetailScreen(medicamento: medicamento),
                      ),
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

class MedicamentoDetailScreen extends StatelessWidget {
  final Map<String, String> medicamento;

  MedicamentoDetailScreen({required this.medicamento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medicamento['name']!),
      ),
      body: SingleChildScrollView(
        // Añadido para evitar el desbordamiento
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(medicamento['image']!),
            const SizedBox(height: 16.0),
            Text(
              medicamento['description']!,
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
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
        title: const Text('Consultar Enfermedad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccione la enfermedad con la que se identifica:',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            DropdownButton<String>(
              value: _selectedDisease,
              onChanged: _handleDiseaseSelected,
              style: const TextStyle(color: Colors.black),
              underline: Container(
                height: 2,
                color: Colors.blue,
              ),
              icon: const Icon(Icons.arrow_drop_down),
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
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: _searchSuggestions,
              icon: const Icon(Icons.search),
              label: const Text('Buscar Sugerencia'),
            ),
            const SizedBox(height: 170),
            Container(
              padding: const EdgeInsets.all(10),
              color: const Color.fromARGB(255, 248, 240, 169),
              child: const Text(
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
          'image': 'assets/utils/paracetamol.jpg',
          'active_ingredients': ['Paracetamol'],
          'indications': 'Alivio del dolor y reducción de la fiebre.',
          'contraindications':
              'No usar en personas con hipersensibilidad al paracetamol.'
        },
        {
          'name': 'Aspirina',
          'mg': '500 mg',
          'image': 'assets/utils/Aspirina.jpeg',
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
          'image': 'assets/utils/Omeprazol.png',
          'active_ingredients': ['Omeprazol'],
          'indications': 'Tratamiento del reflujo gastroesofágico.',
          'contraindications':
              'No usar en personas con hipersensibilidad al omeprazol.'
        },
        {
          'name': 'Bismutol',
          'mg': '262 mg',
          'image': 'assets/utils/Bismutol.jpeg',
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
          'image': 'assets/utils/Antiflu-Des.jpeg',
          'active_ingredients': ['Paracetamol', 'Clorfenamina', 'Fenilefrina'],
          'indications':
              'Alivio de los síntomas de la gripe como congestión nasal, dolor y fiebre.',
          'contraindications':
              'No usar en personas con hipertensión severa o enfermedad coronaria grave.'
        },
        {
          'name': 'Tabcin',
          'mg': '325 mg',
          'image': 'assets/utils/Tabcin.jpeg',
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
          'image': 'assets/utils/Ibuprofeno.jpeg',
          'active_ingredients': ['Ibuprofeno'],
          'indications': 'Alivio del dolor y la inflamación.',
          'contraindications':
              'No usar en personas con úlceras gástricas activas o insuficiencia renal severa.'
        },
        {
          'name': 'Naproxeno',
          'mg': '500 mg',
          'image': 'assets/utils/Naproxeno.jpeg',
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
          'image': 'assets/utils/Diazepam.jpeg',
          'active_ingredients': ['Diazepam'],
          'indications':
              'Tratamiento de la ansiedad y los espasmos musculares.',
          'contraindications':
              'No usar en personas con insuficiencia respiratoria severa o apnea del sueño.'
        },
        {
          'name': 'Clonazepam',
          'mg': '2 mg',
          'image': 'assets/utils/Clonazepam.jpeg',
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
          'image': 'assets/utils/Metoclopramida.jpeg',
          'active_ingredients': ['Metoclopramida'],
          'indications': 'Tratamiento de las náuseas y vómitos.',
          'contraindications':
              'No usar en personas con hemorragia gastrointestinal, obstrucción mecánica o perforación.'
        },
        {
          'name': 'Ondansetrón',
          'mg': '8 mg',
          'image': 'assets/utils/Ondansetrón.jpeg',
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
          'image': 'assets/utils/Mebeverina.jpeg',
          'active_ingredients': ['Mebeverina'],
          'indications': 'Alivio del síndrome del intestino irritable.',
          'contraindications':
              'No usar en personas con hipersensibilidad a la mebeverina.'
        },
        {
          'name': 'Trimebutina',
          'mg': '200 mg',
          'image': 'assets/utils/Trimebutina.jpeg',
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
          'image': 'assets/utils/Ranitidina.jpeg',
          'active_ingredients': ['Ranitidina'],
          'indications':
              'Tratamiento de la úlcera gástrica y duodenal, y reflujo gastroesofágico.',
          'contraindications':
              'No usar en personas con hipersensibilidad a la ranitidina.'
        },
        {
          'name': 'Esomeprazol',
          'mg': '40 mg',
          'image': 'assets/utils/Esomeprazol.jpeg',
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
          ? const Center(
              child: Text('No hay medicamentos disponibles.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
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
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: Image.asset(
                        medication['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        medication['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 20),
            Text(
              'Ingredientes activos: ${medication['active_ingredients'].join(', ')}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Indicaciones: ${medication['indications']}'),
            const SizedBox(height: 10),
            Text('Contraindicaciones: ${medication['contraindications']}'),
          ],
        ),
      ),
    );
  }
}
