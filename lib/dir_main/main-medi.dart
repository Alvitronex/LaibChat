import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ver Medicina',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VerMedicinaScreen(),
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
      "image": "assets/images/paracetamol.jpg",
      "description":
          "Beneficios:\n\nEficaz para aliviar dolores leves a moderados y reducir la fiebre. Usado para condiciones como dolores de cabeza, dolores dentales, dolores menstruales, artritis, dolores musculares y resfriados.\n\nEfectos secundarios:\n\nRaramente causa efectos secundarios cuando se toma en la dosis recomendada. Posibles efectos incluyen náuseas, erupciones cutáneas y reacciones alérgicas como hinchazón y dificultad para respirar. El uso excesivo puede causar daño hepático, especialmente cuando se combina con alcohol u otros medicamentos que contienen acetaminofén."
    },
    {
      "name": "Antiflu Des",
      "image": "assets/images/Antiflu-Des.jpeg",
      "description":
          "Beneficios:\n\nAlivia síntomas del resfriado común y la gripe, como congestión, secreción nasal y dolores corporales.\n\nEfectos secundarios:\n\nPuede causar somnolencia, mareos, sequedad de boca y malestar estomacal. El uso excesivo o la combinación con alcohol puede aumentar el riesgo de daño hepático y otros efectos graves."
    },
    {
      "name": "Aspirina",
      "image": "assets/images/Aspirina.jpeg",
      "description":
          "Beneficios:\n\nAlivia el dolor, reduce la fiebre y tiene propiedades antiinflamatorias. A menudo se usa para prevenir ataques cardíacos y accidentes cerebrovasculares en dosis bajas debido a sus efectos anticoagulantes.\n\nEfectos secundarios:\n\nProblemas gastrointestinales como dolor de estómago, acidez y úlceras. Mayor riesgo de sangrado y reacciones alérgicas."
    },
    {
      "name": "Bismutol",
      "image": "assets/images/Bismutol.jpeg",
      "description":
          "Beneficios:\n\nTrata náuseas, acidez, indigestión y malestar estomacal. Usado para aliviar la diarrea y prevenir la diarrea del viajero.\n\nEfectos secundarios:\n\nHeces oscuras y lengua negra. Raramente, puede causar reacciones alérgicas graves."
    },
    {
      "name": "Clonazepam",
      "image": "assets/images/Clonazepam.jpeg",
      "description":
          "Beneficios:\n\nUsado para tratar trastornos convulsivos y ataques de pánico. Tiene efectos calmantes y ayuda con la ansiedad.\n\nEfectos secundarios:\n\nSomnolencia, mareos y fatiga. Puede llevar a dependencia y síntomas de abstinencia."
    },
    {
      "name": "Diazepam",
      "image": "assets/images/Diazepam.jpeg",
      "description":
          "Beneficios:\n\nTrata la ansiedad, los espasmos musculares y las convulsiones. Usado como sedante antes de procedimientos médicos.\n\nEfectos secundarios:\n\nSomnolencia, fatiga y debilidad muscular. Riesgo de dependencia y síntomas de abstinencia."
    },
    {
      "name": "Esomeprazol",
      "image": "assets/images/Esomeprazol.jpeg",
      "description":
          "Beneficios:\n\nReduce el ácido estomacal y trata el reflujo gastroesofágico (GERD), úlceras y el síndrome de Zollinger-Ellison.\n\nEfectos secundarios:\n\nDolor de cabeza, diarrea y dolor de estómago. El uso a largo plazo puede aumentar el riesgo de fracturas óseas."
    },
    {
      "name": "Ibuprofeno",
      "image": "assets/images/Ibuprofeno.jpeg",
      "description":
          "Beneficios:\n\nAlivia el dolor, reduce la fiebre y tiene efectos antiinflamatorios. Usado para condiciones como artritis, dolor menstrual y dolores musculares.\n\nEfectos secundarios:\n\nProblemas gastrointestinales como náuseas y úlceras. Mayor riesgo de eventos cardiovasculares y daño renal con el uso a largo plazo."
    },
    {
      "name": "Mebeverina",
      "image": "assets/images/Mebeverina.jpeg",
      "description":
          "Beneficios:\n\nUsado para tratar los síntomas del síndrome del intestino irritable (SII) como los calambres estomacales y la distensión abdominal.\n\nEfectos secundarios:\n\nGeneralmente bien tolerado, pero puede causar mareos y reacciones cutáneas."
    },
    {
      "name": "Metoclopramida",
      "image": "assets/images/Metoclopramida.jpeg",
      "description":
          "Beneficios:\n\nTrata náuseas, vómitos y gastroparesia. Usado para el reflujo gástrico y como ayuda en ciertos procedimientos médicos.\n\nEfectos secundarios:\n\nSomnolencia, fatiga y agitación. Puede causar efectos graves como discinesia tardía con el uso prolongado."
    },
    {
      "name": "Naproxeno",
      "image": "assets/images/Naproxeno.jpeg",
      "description":
          "Beneficios:\n\nAlivia el dolor, reduce la fiebre y tiene propiedades antiinflamatorias. Usado para condiciones como artritis, gota y calambres menstruales.\n\nEfectos secundarios:\n\nProblemas gastrointestinales como úlceras y sangrado. Mayor riesgo de eventos cardiovasculares."
    },
    {
      "name": "Omeprazol",
      "image": "assets/images/Omeprazol.png",
      "description":
          "Beneficios:\n\nReduce el ácido estomacal, trata el reflujo gastroesofágico (GERD) y cura úlceras. Usado para el manejo a largo plazo del síndrome de Zollinger-Ellison.\n\nEfectos secundarios:\n\nDolor de cabeza, dolor de estómago y diarrea. El uso a largo plazo puede llevar a una deficiencia de vitamina B12 y fracturas óseas."
    },
    {
      "name": "Ondansetrón",
      "image": "assets/images/Ondansetrón.jpeg",
      "description":
          "Beneficios:\n\nPreviene náuseas y vómitos causados por quimioterapia, radiación y cirugía.\n\nEfectos secundarios:\n\nDolor de cabeza, estreñimiento y mareos. Raramente, puede causar problemas graves del ritmo cardíaco."
    },
    {
      "name": "Ranitidina",
      "image": "assets/images/Ranitidina.jpeg",
      "description":
          "Beneficios:\n\nReduce el ácido estomacal y trata condiciones como el reflujo gastroesofágico (GERD) y úlceras.\n\nEfectos secundarios:\n\nDolor de cabeza, mareos y problemas gastrointestinales. El uso a largo plazo se ha asociado con un mayor riesgo de ciertas infecciones y deficiencia de vitamina B12."
    },
    {
      "name": "Tabcin",
      "image": "assets/images/Tabcin.jpeg",
      "description":
          "Beneficios:\n\nAlivia síntomas del resfriado y la gripe, como congestión, fiebre y dolores corporales.\n\nEfectos secundarios:\n\nSomnolencia, mareos y sequedad de boca. El uso excesivo puede aumentar el riesgo de daño hepático."
    },
    {
      "name": "Trimebutina",
      "image": "assets/images/Trimebutina.jpeg",
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
        title: Text('Ver Medicina'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Acción para volver a la pantalla de bienvenida
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
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
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
            SizedBox(height: 16.0),
            Text(
              medicamento['description']!,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
