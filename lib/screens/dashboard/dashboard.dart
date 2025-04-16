import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/services.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> chats = [
      {
        'name': 'Jenny Wilson',
        'message': 'Gracias por la información',
        'time': '10:15',
        // 'image': 'assets/utils/user1.jpg',
      },
      {
        'name': 'Rual López',
        'message': 'Perfecto, nos vemos luego',
        'time': '09:42',
      },
      {
        'name': 'Andrea Peña',
        'message': 'Hola, ¿cómo estás?',
        'time': 'Ayer',
      },
      {
        'name': 'Mario wilsons',
        'message': 'Te enviaré los archivos mañana',
        'time': '04 abr',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/utils/logo.jpeg',
              height: 40,
            ),
            const SizedBox(width: 10),
            const Text(
              'LaibChat',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            mouseCursor: SystemMouseCursors.click,
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
              Navigator.pushNamed(context, "login");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chat',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    leading: CircleAvatar(
                      radius: 26,
                      // backgroundImage: AssetImage(chat['image']!),
                    ),
                    title: Text(
                      chat['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(chat['message']!),
                    trailing: Text(
                      chat['time']!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      // Navegar al chat
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
