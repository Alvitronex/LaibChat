import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/services.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> chats = [
      {
        'name': 'Jenny Wilson ',
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
        'name': 'Jenny Wilson ',
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
        'name': 'Jenny Wilson ',
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
        'name': 'Jenny Wilson ',
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
        'name': 'Jenny Wilson ',
        'message': 'Gracias por la información',
        'time': '10:15',
        // 'image': 'assets/utils/user1.jpg',
      },
      {
        'name': 'Rual López',
        'message': 'Perfecto, nos vemos luego',
        'time': '09:42',
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
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: const CircleAvatar(
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
      ),
    );
  }
}
