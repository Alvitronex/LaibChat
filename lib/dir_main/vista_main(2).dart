import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vista de Medicamentos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MedicamentoPage(),
    );
  }
}

class MedicamentoPage extends StatefulWidget {
  @override
  _MedicamentoPageState createState() => _MedicamentoPageState();
}

class _MedicamentoPageState extends State<MedicamentoPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _medicamentos = [
    {
      'name': 'Enantyum',
      'mg': '500 mg',
      'image': 'assets/images/paracetamol.jpg'
    },
    {'name': 'Eutirox', 'mg': '5 mg', 'image': 'assets/images/prednisona.jpg'},
    {
      'name': 'Paracetamol',
      'mg': '25 mg',
      'image': 'assets/images/enantyum.jpg'
    },
    {
      'name': 'Prednisona',
      'mg': '100 mg',
      'image': 'assets/images/eutirox.jpg'
    },
    {'name': 'Ventolin', 'mg': 'mg', 'image': 'assets/images/ventolin.jpeg'},
  ];
  List<Map<String, String>> _filteredMedicamentos = [];

  @override
  void initState() {
    super.initState();
    _filteredMedicamentos = _medicamentos;
  }

  void _filterMedicamentos(String query) {
    setState(() {
      _filteredMedicamentos = _medicamentos.where((medicamento) {
        return medicamento['name']!
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            medicamento['mg']!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterMedicamentos('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicamentos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _filterMedicamentos,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: _clearSearch,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredMedicamentos.length,
                itemBuilder: (context, index) {
                  final medicamento = _filteredMedicamentos[index];
                  return Card(
                    child: ListTile(
                      leading: _buildImage(medicamento['image']!),
                      title: Text(medicamento['name']!),
                      subtitle: Text(medicamento['mg']!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    return Image.asset(
      imagePath,
      width: 50,
      height: 50,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.broken_image, size: 50);
      },
    );
  }
}
