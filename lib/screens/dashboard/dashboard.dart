import 'package:flutter/material.dart';
import 'package:frontend/models/models.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screens/chat/chat_detail_screen.dart';
import 'package:frontend/services/services.dart';
import 'dart:async';
import 'dart:math' as Math;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLoading = true;
  String _errorMessage = '';
  bool _showWelcome = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _startConversationUpdateTimer();

    // Configuramos que el mensaje de bienvenida desaparezca después de 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showWelcome = false;
        });
      }
    });
  }

  Timer? _updateTimer;

  void _startConversationUpdateTimer() {
    // Actualizar conversaciones cada 15 segundos
    _updateTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        _loadConversations();
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);

    if (!authService.authenticated) {
      // Si no hay autenticación, redirigir al login
      Future.microtask(() => Navigator.pushReplacementNamed(context, 'login'));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Obtener las conversaciones
    // Obtener las conversaciones
    try {
      final token = authService.token;
      if (token != null) {
        print('Cargando conversaciones');
        await chatService.fetchConversations(token);
        print('Conversaciones cargadas: ${chatService.conversations.length}');

        // Después de cargar las conversaciones, también precargamos los mensajes
        // de las primeras conversaciones para mostrar el último mensaje
        if (chatService.conversations.isNotEmpty) {
          for (int i = 0;
              i < Math.min(3, chatService.conversations.length);
              i++) {
            final conversation = chatService.conversations[i];
            try {
              await chatService.fetchMessages(
                  token, conversation.id, authService.user.id);
            } catch (e) {
              print(
                  'Error al precargar mensajes para conversación ${conversation.id}: $e');
            }
          }
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar conversaciones: $e';
      });
      print('Error detallado al cargar conversaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final chatService = Provider.of<ChatService>(context);

    // Verificar autenticación
    if (!authService.authenticated) {
      // Si no está autenticado, mostrar mensaje y botón de login
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No has iniciado sesión'),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, 'login'),
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      );
    }

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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 40,
                  width: 40,
                  color: Colors.grey[300],
                  child: const Icon(Icons.message, color: Colors.grey),
                );
              },
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
              try {
                authService.logout();
                Navigator.pushReplacementNamed(context, "login");
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al cerrar sesión: $e')),
                );
                Navigator.pushReplacementNamed(context, "login");
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Contenido principal
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage))
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Chat',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                    _errorMessage = '';
                                  });
                                  _loadConversations();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Barra de búsqueda
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Buscar',
                                      border: InputBorder.none,
                                      hintStyle:
                                          TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: chatService.conversations.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('No hay conversaciones'),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Aquí iría la lógica para iniciar una nueva conversación
                                            _showNewChatDialog(context);
                                          },
                                          child: const Text('Iniciar chat'),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: chatService.conversations.length,
                                    itemBuilder: (context, index) {
                                      final conversation =
                                          chatService.conversations[index];

                                      // Obtener el nombre de la conversación
                                      String conversationName = '';
                                      String message = '';
                                      String time = '';

                                      if (conversation.isGroup) {
                                        // Si es grupo, usar el nombre del grupo
                                        conversationName = conversation.name;
                                      } else if (conversation
                                          .users.isNotEmpty) {
                                        // Si no es grupo, usar el nombre del otro usuario (no el actual)
                                        final otherUsers = conversation.users
                                            .where((user) =>
                                                user.id != authService.user.id)
                                            .toList();

                                        if (otherUsers.isNotEmpty) {
                                          conversationName =
                                              otherUsers.first.name;
                                        }
                                      }

                                      // Información del último mensaje
                                      if (conversation.lastMessage != null) {
                                        message =
                                            conversation.lastMessage!.text;
                                        time = conversation.lastMessage!.time;
                                      } else {
                                        message = 'No hay mensajes';
                                        final now = DateTime.now();
                                        time =
                                            '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
                                      }

                                      return InkWell(
                                        onTap: () {
                                          // Navegar a la pantalla de chat
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatDetailScreen(
                                                conversationId: conversation.id,
                                                name: conversationName,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
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
                                                backgroundColor:
                                                    Colors.purple[100],
                                                child: Text(
                                                  conversationName.isNotEmpty
                                                      ? conversationName[0]
                                                      : '',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      conversationName,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
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

          // Botón flotante para nuevo chat
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.orange,
              child: const Icon(Icons.message),
              onPressed: () {
                // Mostrar diálogo para seleccionar destinatario
                _showNewChatDialog(context);
              },
            ),
          ),

          // Mensaje de bienvenida
          if (_showWelcome)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                color: Colors.green[100],
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '¡Bienvenido, ${authService.user.name}!!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _showWelcome = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Agregar este método a la clase _DashboardState
void _showNewChatDialog(BuildContext context) async {
  final authService = Provider.of<AuthService>(context, listen: false);
  final chatService = Provider.of<ChatService>(context, listen: false);

  // Obtener usuarios disponibles si aún no se han cargado
  if (chatService.availableUsers.isEmpty) {
    try {
      final token = authService.token;
      if (token != null) {
        await chatService.fetchAvailableUsers(token);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: $e')),
      );
      return;
    }
  }

  // Si no hay usuarios disponibles
  if (chatService.availableUsers.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay usuarios disponibles')),
    );
    return;
  }

  // Usuario seleccionado inicialmente
  User? selectedUser;

  // Mostrar diálogo para seleccionar usuario
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Nueva conversación'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Selecciona un usuario para chatear:'),
          const SizedBox(height: 10),
          Container(
            height: 200,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: chatService.availableUsers.length,
              itemBuilder: (context, index) {
                final user = chatService.availableUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple[100],
                    child: Text(
                      user.name.isNotEmpty ? user.name[0] : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  onTap: () {
                    selectedUser = user;
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    ),
  );

  // Si se seleccionó un usuario, crear conversación
  if (selectedUser != null) {
    try {
      final token = authService.token;
      if (token != null) {
        final conversation = await chatService.createConversation(
          token,
          [selectedUser!.id],
        );

        if (conversation != null) {
          // Navegar a la pantalla de chat
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                conversationId: conversation.id,
                name: selectedUser!.name,
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear conversación: $e')),
      );
    }
  }
}
