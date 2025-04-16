import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screens/chat/chat_detail_screen.dart';
import '../../services/services.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String?>> chats = [
      {
        'name': 'Jenny Wilson',
        'message': 'Gracias por la información',
        'time': '10:15',
        'image': null, // Ahora es explícitamente nulo
      },
      {
        'name': 'Raul López',
        'message': 'Perfecto, nos vemos luego',
        'time': '09:42',
        'image': null,
      },
      {
        'name': 'Raul López',
        'message': 'Perfecto, nos vemos luego',
        'time': '09:42',
        'image': null,
      },
      {
        'name': 'Raul López',
        'message': 'Perfecto, nos vemos luego',
        'time': '09:42',
        'image': null,
      },
      {
        'name': 'Raul López',
        'message': 'Perfecto, nos vemos luego',
        'time': '09:42',
        'image': null,
      },
      {
        'name': 'Raul López',
        'message': 'Perfecto, nos vemos luego',
        'time': '09:42',
        'image': null,
      },
      {
        'name': 'Raul López',
        'message': 'Perfecto, nos vemos luego',
        'time': '09:42',
        'image': null,
      },
      {
        'name': 'Raul López',
        'message': 'Perfecto, nos vemos luego',
        'time': '09:42',
        'image': null,
      },
      {
        'name': 'Raul López',
        'message': 'Perfecto, nos vemos luego',
        'time': '09:42',
        'image': null,
      },
      {
        'name': 'Raul López',
        'message': 'Perfecto, nos vemos luego',
        'time': '09:42',
        'image': null,
      },
      {
        'name': 'Andrea Peña',
        'message': 'Hola, ¿cómo estás?',
        'time': 'Ayer',
        'image': null,
      },
      {
        'name': 'Mario Wilson',
        'message': 'Te enviaré los archivos mañana',
        'time': '04 abr',
        'image': null,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Chat",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_outlined),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    mouseCursor: SystemMouseCursors.click,
                    onPressed: () {
                      Provider.of<AuthService>(context, listen: false).logout();
                      Navigator.pushNamed(context, "login");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    // Asegurarse de que el nombre no sea nulo
                    final name = chat['name'] ?? 'Usuario';
                    final message = chat['message'] ?? '';
                    final time = chat['time'] ?? '';
                    final image = chat['image'];

                    return InkWell(
                      onTap: () {
                        // Navegar a la pantalla de chat al hacer clic
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              name: name,
                              imageUrl: image,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.purple[100],
                              child: Text(
                                name.isNotEmpty ? name[0] : '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    message,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              time,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
